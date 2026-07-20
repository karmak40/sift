import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'file_storage_service.dart';

/// Copies uploaded files into `<app documents dir>/sift_files/`. Used on
/// Android/iOS, where the app has a real sandboxed filesystem.
class IoFileStorageService implements FileStorageService {
  static const _uuid = Uuid();

  Future<Directory> _filesDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docsDir.path, 'sift_files'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

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
}
