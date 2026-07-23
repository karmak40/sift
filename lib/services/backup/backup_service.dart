import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/io_file_storage_service.dart';
import '../../data/local/database.dart';
import '../current_localizations.dart';

/// Thrown when a file handed to [BackupService.restoreFromArchive] isn't a
/// Sift backup, or is one made by a newer, incompatible version of the app.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
}

const _manifestEntry = 'manifest.json';
const _dbEntry = 'sift_db.sqlite';
const _filesPrefix = 'files/';

/// Everything a restore needs to rebuild the on-disk database file — see
/// `lib/data/local/database.dart`'s `_openConnection()`, which is the only
/// other place this filename convention is defined.
Future<File> _dbFile() async {
  final docsDir = await getApplicationDocumentsDirectory();
  return File(p.join(docsDir.path, 'sift_db.sqlite'));
}

/// Backs up/restores everything Sift stores locally — the SQLite database
/// (categories, documents, expiration dates, AI summaries) plus the actual
/// uploaded files — into a single zip file the user controls entirely. No
/// network involved: exporting just hands the user bytes, and importing
/// just reads bytes back in.
///
/// Android/iOS/Windows only (backed by [IoFileStorageService], which needs a
/// real filesystem) — Web stores everything as BLOB rows in the same
/// database Drift already backs up as part of the export, so there's
/// nothing extra to add there, but a from-scratch Web backup/restore would
/// need different plumbing and isn't built yet; see `settings_screen.dart`
/// for where this is gated to `!kIsWeb`.
class BackupService {
  BackupService(this._db, this._fileStorage);

  final AppDatabase _db;
  final IoFileStorageService _fileStorage;

  static const formatVersion = 1;

  Future<Uint8List> createBackupArchive() async {
    final tempDir = await Directory.systemTemp.createTemp('sift_backup_export_');
    try {
      final tempDbPath = p.join(tempDir.path, 'export.sqlite');
      // VACUUM INTO produces a single-file, fully consistent snapshot of the
      // database as of right now — safe to run against the live connection,
      // unlike copying the raw .sqlite file (which could race a pending
      // write or miss data still sitting in a WAL file). The target path is
      // part of the SQL grammar here (not a bindable parameter), so a
      // single-quote escape is done by hand — this is our own temp path,
      // never user input, but a stray apostrophe in an OS username
      // shouldn't be able to break the statement.
      final escapedPath = tempDbPath.replaceAll("'", "''");
      await _db.customStatement("VACUUM INTO '$escapedPath'");
      final dbBytes = await File(tempDbPath).readAsBytes();

      final archive = Archive();
      archive.addFile(ArchiveFile(
        _manifestEntry,
        0,
        utf8.encode(jsonEncode({
          'formatVersion': formatVersion,
          'createdAt': DateTime.now().toIso8601String(),
        })),
      ));
      archive.addFile(ArchiveFile(_dbEntry, dbBytes.length, dbBytes));

      final filesDir = Directory(await _fileStorage.currentFilesDirPath());
      if (await filesDir.exists()) {
        await for (final entity in filesDir.list()) {
          if (entity is! File) continue;
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile('$_filesPrefix${p.basename(entity.path)}', bytes.length, bytes));
        }
      }

      return Uint8List.fromList(ZipEncoder().encode(archive));
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  /// Replaces every document, category, and stored file with the contents
  /// of [zipBytes]. Closes the live database connection as part of this —
  /// callers must tell the user to fully close and reopen the app
  /// afterward (see `settings_screen.dart`) rather than trying to hot-swap
  /// Riverpod's provider tree onto a freshly-overwritten database file.
  Future<void> restoreFromArchive(Uint8List zipBytes) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);

    final manifestEntry = archive.findFile(_manifestEntry);
    final dbEntry = archive.findFile(_dbEntry);
    if (manifestEntry == null || dbEntry == null) {
      throw BackupFormatException(currentLocalizations().invalidBackupFile);
    }

    final Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(utf8.decode(manifestEntry.content as List<int>)) as Map<String, dynamic>;
    } on FormatException {
      throw BackupFormatException(currentLocalizations().invalidBackupFile);
    }
    final version = manifest['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw BackupFormatException(currentLocalizations().backupTooNew);
    }

    await _db.close();

    final dbFile = await _dbFile();
    await dbFile.writeAsBytes(dbEntry.content as List<int>, flush: true);
    // A stale -wal/-shm from the connection we just closed would otherwise
    // shadow the restored data the next time the database is opened.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${dbFile.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }

    final filesDir = Directory(await _fileStorage.currentFilesDirPath());
    if (await filesDir.exists()) {
      await filesDir.delete(recursive: true);
    }
    await filesDir.create(recursive: true);
    for (final entry in archive.files) {
      if (!entry.isFile || !entry.name.startsWith(_filesPrefix)) continue;
      final name = entry.name.substring(_filesPrefix.length);
      if (name.isEmpty) continue;
      await File(p.join(filesDir.path, name)).writeAsBytes(entry.content as List<int>, flush: true);
    }
  }
}
