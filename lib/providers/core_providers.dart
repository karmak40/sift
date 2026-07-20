import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/file_storage_service.dart';
import '../data/io_file_storage_service.dart';
import '../data/local/database.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/document_repository.dart';
import '../data/repository/drift_category_repository.dart';
import '../data/repository/drift_document_repository.dart';
import '../data/web_file_storage_service.dart';
import '../services/ai/ai_summary_service.dart';
import '../services/ai/disabled_ai_summary_service.dart';

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

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  if (kIsWeb) {
    return WebFileStorageService(ref.watch(appDatabaseProvider));
  }
  return IoFileStorageService();
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
