import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/data/io_file_storage_service.dart';
import 'package:sift/data/storage_location_service.dart';

/// Stands in for the real path_provider plugin (which needs a live app to
/// answer platform-channel calls). Points "app documents directory" at a
/// throwaway temp folder so the test exercises real dart:io file writes and
/// reads on whatever OS is running the test — Windows included.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.tempDir);
  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}

void main() {
  late Directory tempDir;
  late IoFileStorageService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sift_storage_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    SharedPreferences.setMockInitialValues({});
    service = IoFileStorageService(StorageLocationService());
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('store() writes real bytes to a real file, read() reads them back', () async {
    final bytes = Uint8List.fromList('hello from a real upload'.codeUnits);

    final key = await service.store('note.txt', bytes);

    // The file genuinely exists on disk — not mocked away.
    final onDisk = File('${tempDir.path}/sift_files/$key');
    expect(onDisk.existsSync(), isTrue);
    expect(onDisk.readAsBytesSync(), bytes);

    // And the service's own read() returns the same bytes back.
    final readBack = await service.read(key);
    expect(readBack, bytes);
  });

  test('read() of an unknown key returns null instead of throwing', () async {
    final result = await service.read('does-not-exist.pdf');
    expect(result, isNull);
  });

  test('delete() removes the file so a later read() returns null', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final key = await service.store('data.bin', bytes);

    expect(await service.read(key), isNotNull);

    await service.delete(key);

    expect(await service.read(key), isNull);
  });

  test('store() keeps the original file extension in the storage key', () async {
    final key = await service.store('Utility Bill June.pdf', Uint8List(0));
    expect(key, endsWith('.pdf'));
  });

  test('changeBaseDirectory() moves existing files so they stay readable', () async {
    final bytes = Uint8List.fromList('moved along with the folder'.codeUnits);
    final key = await service.store('carry-over.txt', bytes);

    final newLocation = Directory.systemTemp.createTempSync('sift_storage_test_new_');
    addTearDown(() => newLocation.deleteSync(recursive: true));

    await service.changeBaseDirectory(newLocation.path);

    // The old copy is gone...
    final oldFile = File(p.join(tempDir.path, 'sift_files', key));
    expect(oldFile.existsSync(), isFalse);

    // ...and the same storageKey now resolves under the new folder.
    final newFile = File(p.join(newLocation.path, 'sift_files', key));
    expect(newFile.existsSync(), isTrue);
    expect(await service.read(key), bytes);
    expect(await service.currentFilesDirPath(), p.join(newLocation.path, 'sift_files'));
  });

  test('openExternally() on an empty storageKey returns a clear message without touching disk', () async {
    final message = await service.openExternally('');
    expect(message, contains('no file attached'));
  });

  test('openExternally() on a missing file returns a clear message instead of throwing', () async {
    final message = await service.openExternally('does-not-exist-on-disk.pdf');
    expect(message, contains('missing from disk'));
  });

  // Actually launching the OS "open with" handler needs a real platform
  // plugin channel, which isn't available in a unit test — that path is
  // covered by integration_test/file_storage_roundtrip_test.dart on a real
  // device/desktop instead.

  test('changeBaseDirectory(null) moves files back to the default folder', () async {
    final custom = Directory.systemTemp.createTempSync('sift_storage_test_custom_');
    addTearDown(() => custom.deleteSync(recursive: true));
    await service.changeBaseDirectory(custom.path);

    final bytes = Uint8List.fromList([9, 9, 9]);
    final key = await service.store('back-to-default.bin', bytes);

    await service.changeBaseDirectory(null);

    expect(await service.currentFilesDirPath(), await service.defaultFilesDirPath());
    expect(await service.read(key), bytes);
  });
}
