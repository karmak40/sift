import 'dart:typed_data';

/// Persists uploaded file bytes and hands back an opaque storage key that a
/// [DocumentRepository] row can later use to look the bytes up again.
///
/// Two implementations exist, selected in `lib/providers/*` via `kIsWeb`:
/// [IoFileStorageService] (Android/iOS — real filesystem) and
/// [WebFileStorageService] (Web — bytes stored as a DB blob).
abstract class FileStorageService {
  Future<String> store(String suggestedName, Uint8List bytes);

  Future<Uint8List?> read(String storageKey);

  Future<void> delete(String storageKey);
}
