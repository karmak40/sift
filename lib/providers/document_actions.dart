import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/file_storage_service.dart';
import '../data/models/document.dart';
import '../data/repository/document_repository.dart';
import '../services/reminders/reminder_service.dart';
import 'core_providers.dart';

/// A file ready to become a document — the common shape produced by the file
/// picker (single or multi) and the scanner, so `addDocument` doesn't care
/// where it came from.
class PreparedFile {
  const PreparedFile({
    required this.name,
    required this.type,
    required this.bytes,
    required this.sizeBytes,
  });

  final String name;
  final DocType type;

  /// Null only in the degenerate "picked file had no readable bytes" case;
  /// the resulting document then just has no stored file (empty storageKey),
  /// same as the seed/demo documents.
  final Uint8List? bytes;
  final int sizeBytes;
}

/// Persists one [PreparedFile]: stores its bytes (if any) via the file
/// storage service, then creates the document row. Screens call
/// [addDocumentsWithRef]; kept parameterized for testing, mirroring
/// [deleteDocuments].
Future<void> addDocument({
  required PreparedFile file,
  required String categoryId,
  required DocumentRepository documentRepository,
  required FileStorageService fileStorageService,
}) async {
  var storageKey = '';
  final bytes = file.bytes;
  if (bytes != null) {
    storageKey = await fileStorageService.store(file.name, bytes);
  }
  await documentRepository.create(
    name: file.name,
    type: file.type,
    categoryId: categoryId,
    sizeBytes: file.sizeBytes,
    storageKey: storageKey,
  );
}

Future<void> addDocumentsWithRef(
  WidgetRef ref,
  List<PreparedFile> files,
  String categoryId,
) async {
  final documentRepository = ref.read(documentRepositoryProvider);
  final fileStorageService = ref.read(fileStorageServiceProvider);
  for (final file in files) {
    await addDocument(
      file: file,
      categoryId: categoryId,
      documentRepository: documentRepository,
      fileStorageService: fileStorageService,
    );
  }
}

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

/// Sets (or clears, when [expiresAt] is null) a document's expiration and
/// keeps the scheduled reminder in sync in one call — the two always have to
/// move together, so both the detail sheet and the Coming Up "Renew" action
/// go through this rather than repeating the repo+reminder pair. Returns the
/// updated [Document] so callers can refresh local state without re-reading.
Future<Document> setDocumentExpirationWithRef(
  WidgetRef ref,
  Document document, {
  required DateTime? expiresAt,
  int? reminderDaysBefore,
}) async {
  final days = reminderDaysBefore ?? document.reminderDaysBefore ?? 30;
  await ref.read(documentRepositoryProvider).setExpiration(
        document.id,
        expiresAt: expiresAt,
        reminderDaysBefore: days,
      );
  final updated = expiresAt == null
      ? document.copyWith(clearExpiresAt: true)
      : document.copyWith(expiresAt: expiresAt, reminderDaysBefore: days);
  final reminderService = ref.read(reminderServiceProvider);
  if (expiresAt == null) {
    await reminderService.cancelReminder(document.id);
  } else {
    await reminderService.scheduleReminder(updated);
  }
  return updated;
}
