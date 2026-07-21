import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// The folder documents are currently stored in, and the ability to change
/// it. Windows-only feature (see `ui/settings/settings_screen.dart`) — the
/// actual move happens in [IoFileStorageService.changeBaseDirectory], this
/// just exposes it as watchable state with a loading spinner while a move
/// is in progress.
class StorageLocationController extends AsyncNotifier<String> {
  @override
  Future<String> build() {
    return ref.watch(ioFileStorageServiceProvider).currentFilesDirPath();
  }

  Future<void> changePath(String? newCustomBasePath) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(ioFileStorageServiceProvider);
      await service.changeBaseDirectory(newCustomBasePath);
      return service.currentFilesDirPath();
    });
  }

  Future<String> defaultPath() {
    return ref.read(ioFileStorageServiceProvider).defaultFilesDirPath();
  }
}

final storageLocationControllerProvider =
    AsyncNotifierProvider<StorageLocationController, String>(
  StorageLocationController.new,
);
