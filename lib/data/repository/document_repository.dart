import '../models/ai_summary.dart';
import '../models/document.dart';

/// Contract for reading/writing documents. Implemented today by
/// [DriftDocumentRepository]; a future `RemoteDocumentRepository` can
/// implement this same interface without any UI changes.
abstract class DocumentRepository {
  Stream<List<Document>> watchAll();

  /// Creates a document row; [storageKey] must already point at bytes that
  /// have been persisted by a `FileStorageService` implementation.
  Future<void> create({
    required String name,
    required DocType type,
    required String categoryId,
    required int sizeBytes,
    required String storageKey,
    AiSummary? ai,
    DateTime? addedAt,
  });

  Future<void> updateAiSummary(int id, AiSummary? ai);

  Future<void> moveToCategory(List<int> ids, String categoryId);
}
