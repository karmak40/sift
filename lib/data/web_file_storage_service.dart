import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../services/current_localizations.dart';
import 'file_storage_service.dart';
import 'local/database.dart';

/// Stores uploaded file bytes as a BLOB row in the Drift database. Used on
/// Web, which has no real filesystem to copy files into.
class WebFileStorageService implements FileStorageService {
  WebFileStorageService(this._db);

  static const _uuid = Uuid();
  final AppDatabase _db;

  @override
  Future<String> store(String suggestedName, Uint8List bytes) async {
    final key = _uuid.v4();
    await _db
        .into(_db.webFiles)
        .insert(WebFilesCompanion.insert(id: key, bytes: bytes));
    return key;
  }

  @override
  Future<Uint8List?> read(String storageKey) async {
    final row =
        await (_db.select(_db.webFiles)
              ..where((f) => f.id.equals(storageKey)))
            .getSingleOrNull();
    return row == null ? null : Uint8List.fromList(row.bytes);
  }

  @override
  Future<void> delete(String storageKey) async {
    await (_db.delete(_db.webFiles)..where((f) => f.id.equals(storageKey)))
        .go();
  }

  @override
  Future<String?> openExternally(String storageKey) async {
    // There's no real filesystem in a browser sandbox to hand off to an
    // "open with" dialog — only Android/iOS/desktop (IoFileStorageService)
    // support this today.
    return currentLocalizations().openNotSupportedWeb;
  }
}
