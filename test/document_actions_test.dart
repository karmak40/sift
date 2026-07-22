import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/data/io_file_storage_service.dart';
import 'package:sift/data/models/ai_summary.dart';
import 'package:sift/data/models/document.dart';
import 'package:sift/data/repository/document_repository.dart';
import 'package:sift/data/storage_location_service.dart';
import 'package:sift/providers/document_actions.dart';
import 'package:sift/services/reminders/reminder_service.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.tempDir);
  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}

/// Records what got deleted, standing in for DriftDocumentRepository so
/// this test doesn't need a real database.
class _FakeDocumentRepository implements DocumentRepository {
  List<int>? deletedIds;

  @override
  Future<void> delete(List<int> ids) async => deletedIds = ids;

  @override
  Future<void> create({
    required String name,
    required DocType type,
    required String categoryId,
    required int sizeBytes,
    required String storageKey,
    AiSummary? ai,
    DateTime? addedAt,
  }) => throw UnimplementedError();

  @override
  Future<void> moveToCategory(List<int> ids, String categoryId) =>
      throw UnimplementedError();

  @override
  Future<void> updateAiSummary(int id, AiSummary? ai) =>
      throw UnimplementedError();

  @override
  Future<void> setExpiration(int id, {DateTime? expiresAt, int? reminderDaysBefore}) =>
      throw UnimplementedError();

  @override
  Stream<List<Document>> watchAll() => throw UnimplementedError();
}

/// `ReminderService` already no-ops safely off Android/iOS (see
/// `supportsRealNotifications`), which this test host is — so `super.call()`
/// is safe here too, this just also records what was asked for.
class _RecordingReminderService extends ReminderService {
  final List<int> cancelledIds = [];

  @override
  Future<void> cancelReminder(int documentId) async {
    cancelledIds.add(documentId);
    await super.cancelReminder(documentId);
  }
}

void main() {
  late Directory tempDir;
  late IoFileStorageService fileStorage;
  late _FakeDocumentRepository repo;
  late _RecordingReminderService reminders;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sift_delete_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    SharedPreferences.setMockInitialValues({});
    fileStorage = IoFileStorageService(StorageLocationService());
    repo = _FakeDocumentRepository();
    reminders = _RecordingReminderService();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Document docWith({
    required int id,
    required String storageKey,
    DateTime? expiresAt,
  }) => Document(
    id: id,
    name: 'doc-$id.pdf',
    type: DocType.pdf,
    categoryId: 'finance',
    sizeBytes: 10,
    addedAt: DateTime(2026, 1, 1),
    storageKey: storageKey,
    expiresAt: expiresAt,
  );

  test('deletes the stored file and the repository row', () async {
    final key = await fileStorage.store('bill.pdf', Uint8List.fromList([1, 2, 3]));
    final doc = docWith(id: 1, storageKey: key);

    await deleteDocuments(
      documents: [doc],
      documentRepository: repo,
      fileStorageService: fileStorage,
      reminderService: reminders,
    );

    expect(repo.deletedIds, [1]);
    expect(await fileStorage.read(key), isNull);
    expect(
      File(p.join(await fileStorage.currentFilesDirPath(), key)).existsSync(),
      isFalse,
    );
  });

  test('deletes every document in a bulk selection, not just the first', () async {
    final key1 = await fileStorage.store('a.pdf', Uint8List.fromList([1]));
    final key2 = await fileStorage.store('b.pdf', Uint8List.fromList([2]));
    final docs = [docWith(id: 1, storageKey: key1), docWith(id: 2, storageKey: key2)];

    await deleteDocuments(
      documents: docs,
      documentRepository: repo,
      fileStorageService: fileStorage,
      reminderService: reminders,
    );

    expect(repo.deletedIds, [1, 2]);
    expect(await fileStorage.read(key1), isNull);
    expect(await fileStorage.read(key2), isNull);
  });

  test('a document with no attached file (empty storageKey) is still removed', () async {
    final doc = docWith(id: 7, storageKey: '');

    await deleteDocuments(
      documents: [doc],
      documentRepository: repo,
      fileStorageService: fileStorage,
      reminderService: reminders,
    );

    expect(repo.deletedIds, [7]);
  });

  test('cancels the reminder for a document that had an expiration set', () async {
    final doc = docWith(id: 3, storageKey: '', expiresAt: DateTime(2027, 1, 1));

    await deleteDocuments(
      documents: [doc],
      documentRepository: repo,
      fileStorageService: fileStorage,
      reminderService: reminders,
    );

    expect(reminders.cancelledIds, [3]);
  });

  test('does not bother cancelling a reminder for a document with no expiration', () async {
    final doc = docWith(id: 4, storageKey: '');

    await deleteDocuments(
      documents: [doc],
      documentRepository: repo,
      fileStorageService: fileStorage,
      reminderService: reminders,
    );

    expect(reminders.cancelledIds, isEmpty);
  });
}
