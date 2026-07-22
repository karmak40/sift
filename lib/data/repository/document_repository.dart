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

  /// Sets or clears when this document expires and how many days ahead of
  /// that to remind the user. Pass `expiresAt: null` to stop tracking an
  /// expiration entirely (clears `reminderDaysBefore` too).
  Future<void> setExpiration(int id, {DateTime? expiresAt, int? reminderDaysBefore});

  /// Deletes document rows only. Callers should go through
  /// `document_actions.dart`'s `deleteDocuments`/`deleteDocumentsWithRef`
  /// instead of calling this directly — it also cleans up the underlying
  /// stored file bytes, which this method alone does not do.
  Future<void> delete(List<int> ids);
}
