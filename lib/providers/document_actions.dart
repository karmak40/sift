import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/file_storage_service.dart';
import '../data/models/document.dart';
import '../data/repository/document_repository.dart';
import '../services/reminders/reminder_service.dart';
import 'core_providers.dart';

/// Deletes documents and cleans up their stored files (and any pending
/// expiration reminder) in one step. Screens should call this instead of
/// `DocumentRepository.delete` directly — deleting only the DB row would
/// leave the underlying file (or web blob row) orphaned forever, since
/// nothing else ever references a `storageKey` once its `Document` row is
/// gone, and would leave a stale notification scheduled for a document that
/// no longer exists.
///
/// Takes the repository/service as parameters (rather than reading them
/// itself) so the composition can be unit-tested with fakes — see
/// [deleteDocumentsWithRef] for the version UI code actually calls.
Future<void> deleteDocuments({
  required List<Document> documents,
  required DocumentRepository documentRepository,
  required FileStorageService fileStorageService,
  required ReminderService reminderService,
}) async {
  for (final doc in documents) {
    if (doc.storageKey.isNotEmpty) {
      await fileStorageService.delete(doc.storageKey);
    }
    if (doc.hasExpiration) {
      await reminderService.cancelReminder(doc.id);
    }
  }
  await documentRepository.delete(documents.map((d) => d.id).toList());
}

Future<void> deleteDocumentsWithRef(WidgetRef ref, List<Document> documents) {
  return deleteDocuments(
    documents: documents,
    documentRepository: ref.read(documentRepositoryProvider),
    fileStorageService: ref.read(fileStorageServiceProvider),
    reminderService: ref.read(reminderServiceProvider),
  );
}
