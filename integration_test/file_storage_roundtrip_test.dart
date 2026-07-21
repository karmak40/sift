import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sift/data/io_file_storage_service.dart';
import 'package:sift/data/storage_location_service.dart';

/// Runs on a real device/emulator, so path_provider answers with a genuine
/// platform-specific documents directory — no faking needed here, unlike
/// the host-machine test in test/io_file_storage_service_test.dart. This is
/// the on-device proof that upload -> store -> read works for real on
/// whatever device this is run against (`flutter test integration_test/... -d <device>`).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('IoFileStorageService round-trips real bytes on-device', (tester) async {
    final service = IoFileStorageService(StorageLocationService());
    final bytes = Uint8List.fromList('real upload, real device'.codeUnits);

    final key = await service.store('device_test.txt', bytes);
    final readBack = await service.read(key);
    expect(readBack, bytes);

    await service.delete(key);
    expect(await service.read(key), isNull);
  });
}
