import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../data/file_storage_service.dart';
import '../data/io_file_storage_service.dart';
import '../data/local/database.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/document_repository.dart';
import '../data/repository/drift_category_repository.dart';
import '../data/repository/drift_document_repository.dart';
import '../data/storage_location_service.dart';
import '../data/web_file_storage_service.dart';
import '../services/ai/ai_summary_service.dart';
import '../services/ai/disabled_ai_summary_service.dart';
import '../services/backup/backup_service.dart';
import '../services/reminders/reminder_service.dart';
import '../services/scan/document_scanner_service.dart';
import '../services/scan/pdf_builder.dart';

/// Storage backend selection. Only `local` is wired up today; `remote` is
/// reserved for a future `RemoteDocumentRepository`/`RemoteCategoryRepository`
/// pair that implements the same interfaces.
enum StorageBackend { local, remote }

final storageBackendProvider = Provider<StorageBackend>(
  (ref) => StorageBackend.local,
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final storageLocationServiceProvider = Provider<StorageLocationService>(
  (ref) => StorageLocationService(),
);

/// The desktop/mobile filesystem-backed storage service, typed concretely
/// (not as the [FileStorageService] interface) so the Settings screen's
/// "change storage folder" control — a Windows-only feature, see
/// `settings_screen.dart` — can call [IoFileStorageService.changeBaseDirectory]
/// directly. Only ever read on non-web platforms.
final ioFileStorageServiceProvider = Provider<IoFileStorageService>((ref) {
  return IoFileStorageService(ref.watch(storageLocationServiceProvider));
});

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  if (kIsWeb) {
    return WebFileStorageService(ref.watch(appDatabaseProvider));
  }
  return ref.watch(ioFileStorageServiceProvider);
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  switch (ref.watch(storageBackendProvider)) {
    case StorageBackend.local:
      return DriftDocumentRepository(ref.watch(appDatabaseProvider));
    case StorageBackend.remote:
      throw UnimplementedError('Remote storage backend is not built yet.');
  }
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  switch (ref.watch(storageBackendProvider)) {
    case StorageBackend.local:
      return DriftCategoryRepository(ref.watch(appDatabaseProvider));
    case StorageBackend.remote:
      throw UnimplementedError('Remote storage backend is not built yet.');
  }
});

/// AI summary service. Always [DisabledAiSummaryService] while
/// [AppConfig.aiEnabled] is false — see that flag to enable a real backend.
final aiSummaryServiceProvider = Provider<AiSummaryService>((ref) {
  if (!AppConfig.aiEnabled) {
    return const DisabledAiSummaryService();
  }
  // Swap in StubHttpAiSummaryService(baseUrl: ..., apiKey: ...) here once a
  // real summarization backend exists.
  return const DisabledAiSummaryService();
});

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());

/// Non-web only — see `BackupService`'s doc comment and
/// `settings_screen.dart`'s `_canUseBackup` gate.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider), ref.watch(ioFileStorageServiceProvider));
});

final pdfBuilderProvider = Provider<PdfBuilder>((ref) => const PdfBuilder());

/// App name/version/build number, for the Settings > About section.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

final documentScannerServiceProvider = Provider<DocumentScannerService>(
  (ref) => DocumentScannerService(ref.watch(pdfBuilderProvider)),
);
