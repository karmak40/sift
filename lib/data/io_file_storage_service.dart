import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../services/current_localizations.dart';
import 'file_storage_service.dart';
import 'storage_location_service.dart';

/// Copies uploaded files into `<base dir>/sift_files/`. Used on
/// Android/iOS/desktop, where the app has a real filesystem. `<base dir>` is
/// normally the app's documents directory, but the user can point it
/// somewhere else (Windows Settings > Storage) — see [StorageLocationService]
/// and [changeBaseDirectory].
class IoFileStorageService implements FileStorageService {
  IoFileStorageService(this._locationService);

  static const _uuid = Uuid();
  final StorageLocationService _locationService;

  Future<Directory> _defaultBaseDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return Directory(docsDir.path);
  }

  Future<Directory> _baseDir() async {
    final custom = await _locationService.getCustomBasePath();
    if (custom != null && custom.trim().isNotEmpty) {
      return Directory(custom);
    }
    return _defaultBaseDir();
  }

  Future<Directory> _filesDir() async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'sift_files'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// The folder documents currently live in — for display in Settings.
  Future<String> currentFilesDirPath() async => (await _filesDir()).path;

  /// The default folder, for a "reset to default" option in Settings.
  Future<String> defaultFilesDirPath() async =>
      p.join((await _defaultBaseDir()).path, 'sift_files');

  @override
  Future<String> store(String suggestedName, Uint8List bytes) async {
    final dir = await _filesDir();
    final ext = p.extension(suggestedName);
    final key = '${_uuid.v4()}$ext';
    final file = File(p.join(dir.path, key));
    await file.writeAsBytes(bytes, flush: true);
    return key;
  }

  @override
  Future<Uint8List?> read(String storageKey) async {
    final dir = await _filesDir();
    final file = File(p.join(dir.path, storageKey));
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  @override
  Future<void> delete(String storageKey) async {
    final dir = await _filesDir();
    final file = File(p.join(dir.path, storageKey));
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String?> openExternally(String storageKey) async {
    if (storageKey.trim().isEmpty) {
      return currentLocalizations().noFileAttached;
    }
    final dir = await _filesDir();
    final file = File(p.join(dir.path, storageKey));
    if (!await file.exists()) {
      return currentLocalizations().fileMissingFromDiskDetailed;
    }
    final result = await OpenFilex.open(file.path);
    return result.type == ResultType.done ? null : result.message;
  }

  /// Moves every already-stored file from the current folder into
  /// `newCustomBasePath` (or back to the default app-data folder, if null),
  /// then remembers the new location for future store()/read()/delete()
  /// calls. Existing documents stay readable no matter when they were
  /// uploaded — nothing needs to change on the `Document` rows, since
  /// `storageKey` is just a filename, not a full path.
  Future<void> changeBaseDirectory(String? newCustomBasePath) async {
    final oldDir = await _filesDir();
    final newBase = (newCustomBasePath != null && newCustomBasePath.trim().isNotEmpty)
        ? Directory(newCustomBasePath)
        : await _defaultBaseDir();
    final newDir = Directory(p.join(newBase.path, 'sift_files'));

    if (p.equals(oldDir.path, newDir.path)) {
      await _locationService.setCustomBasePath(newCustomBasePath);
      return;
    }

    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    if (await oldDir.exists()) {
      await for (final entity in oldDir.list()) {
        if (entity is! File) continue;
        final destPath = p.join(newDir.path, p.basename(entity.path));
        try {
          await entity.rename(destPath);
        } on FileSystemException {
          // Different drive/volume — rename() can't cross those, fall back
          // to copy + delete.
          await entity.copy(destPath);
          await entity.delete();
        }
      }
    }

    await _locationService.setCustomBasePath(newCustomBasePath);
  }
}
