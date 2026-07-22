import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/data/io_file_storage_service.dart';
import 'package:sift/data/models/ai_summary.dart';
import 'package:sift/data/models/document.dart';
import 'package:sift/data/repository/document_repository.dart';
import 'package:sift/data/storage_location_service.dart';
import 'package:sift/providers/document_actions.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.tempDir);
  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}

/// Records each created row so the test can assert what got persisted,
/// standing in for DriftDocumentRepository (no real DB needed).
class _RecordingDocumentRepository implements DocumentRepository {
  final List<({String name, DocType type, String categoryId, int sizeBytes, String storageKey})> created = [];

  @override
  Future<void> create({
    required String name,
    required DocType type,
    required String categoryId,
    required int sizeBytes,
    required String storageKey,
    AiSummary? ai,
    DateTime? addedAt,
  }) async {
    created.add((name: name, type: type, categoryId: categoryId, sizeBytes: sizeBytes, storageKey: storageKey));
  }

  @override
  Future<void> delete(List<int> ids) => throw UnimplementedError();
  @override
  Future<void> moveToCategory(List<int> ids, String categoryId) => throw UnimplementedError();
  @override
  Future<void> updateAiSummary(int id, AiSummary? ai) => throw UnimplementedError();
  @override
  Future<void> rename(int id, String name) => throw UnimplementedError();
  @override
  Future<void> setExpiration(int id, {DateTime? expiresAt, int? reminderDaysBefore}) => throw UnimplementedError();
  @override
  Stream<List<Document>> watchAll() => throw UnimplementedError();
}

void main() {
  late Directory tempDir;
  late IoFileStorageService fileStorage;
  late _RecordingDocumentRepository repo;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sift_add_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    SharedPreferences.setMockInitialValues({});
    fileStorage = IoFileStorageService(StorageLocationService());
    repo = _RecordingDocumentRepository();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  PreparedFile prepared(String name, DocType type, List<int> bytes) => PreparedFile(
    name: name,
    type: type,
    bytes: Uint8List.fromList(bytes),
    sizeBytes: bytes.length,
  );

  test('stores the bytes and creates a row for a single file', () async {
    await addDocument(
      file: prepared('Lease.pdf', DocType.pdf, [1, 2, 3, 4]),
      categoryId: 'housing',
      documentRepository: repo,
      fileStorageService: fileStorage,
    );

    expect(repo.created, hasLength(1));
    final row = repo.created.single;
    expect(row.name, 'Lease.pdf');
    expect(row.categoryId, 'housing');
    expect(row.sizeBytes, 4);
    expect(row.storageKey, isNotEmpty);
    // The bytes really landed on disk under the storage key.
    expect(await fileStorage.read(row.storageKey), Uint8List.fromList([1, 2, 3, 4]));
  });

  test('a multi-file batch creates every row into the chosen category', () async {
    // Mirrors addDocumentsWithRef's loop without needing a WidgetRef.
    final files = [
      prepared('a.pdf', DocType.pdf, [1]),
      prepared('b.jpg', DocType.img, [2, 2]),
      prepared('c.docx', DocType.doc, [3, 3, 3]),
    ];
    for (final f in files) {
      await addDocument(
        file: f,
        categoryId: 'finance',
        documentRepository: repo,
        fileStorageService: fileStorage,
      );
    }

    expect(repo.created.map((r) => r.name), ['a.pdf', 'b.jpg', 'c.docx']);
    expect(repo.created.every((r) => r.categoryId == 'finance'), isTrue);
    // Each got its own distinct storage key.
    final keys = repo.created.map((r) => r.storageKey).toSet();
    expect(keys, hasLength(3));
  });

  test('a file with null bytes still creates a row, with no stored file', () async {
    await addDocument(
      file: const PreparedFile(name: 'placeholder.txt', type: DocType.txt, bytes: null, sizeBytes: 0),
      categoryId: 'personal',
      documentRepository: repo,
      fileStorageService: fileStorage,
    );

    expect(repo.created.single.storageKey, isEmpty);
  });
}
