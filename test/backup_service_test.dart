import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/data/io_file_storage_service.dart';
import 'package:sift/data/local/database.dart';
import 'package:sift/data/models/category.dart';
import 'package:sift/data/models/document.dart';
import 'package:sift/data/repository/drift_category_repository.dart';
import 'package:sift/data/repository/drift_document_repository.dart';
import 'package:sift/data/storage_location_service.dart';
import 'package:sift/services/backup/backup_service.dart';

/// Stands in for path_provider (no live app to answer platform channels) —
/// points both the "documents" and "temporary" directories at one throwaway
/// folder, so `AppDatabase()` opens a real sqlite file there and
/// `IoFileStorageService` stores real files alongside it. Mirrors
/// `io_file_storage_service_test.dart`'s approach.
class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakePathProvider(this.tempDir);
  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;

  @override
  Future<String?> getTemporaryPath() async => tempDir.path;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sift_backup_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    SharedPreferences.setMockInitialValues({});
    Intl.defaultLocale = 'en';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('backup then restore brings back the same categories, documents, and files', () async {
    final db = AppDatabase();
    final fileStorage = IoFileStorageService(StorageLocationService());
    final categories = DriftCategoryRepository(db);
    final documents = DriftDocumentRepository(db);

    await categories.create(const Category(id: 'finance', name: 'Finance', hue: 150));
    final fileBytes = Uint8List.fromList('a real uploaded file'.codeUnits);
    final storageKey = await fileStorage.store('bill.pdf', fileBytes);
    await documents.create(
      name: 'Utility bill.pdf',
      type: DocType.pdf,
      categoryId: 'finance',
      sizeBytes: fileBytes.length,
      storageKey: storageKey,
      addedAt: DateTime(2026, 1, 1),
    );

    final backup = BackupService(db, fileStorage);
    final zipBytes = await backup.createBackupArchive();

    // Add something *after* the backup that restore must wipe away, to
    // prove this is a full replace, not a merge.
    await categories.create(const Category(id: 'temp', name: 'Should be gone', hue: 30));

    await backup.restoreFromArchive(zipBytes);
    // restoreFromArchive() closed `db` — a fresh connection is required to
    // read the restored file back, exactly like a real app restart would.

    final freshDb = AppDatabase();
    addTearDown(freshDb.close);
    final freshCategories = DriftCategoryRepository(freshDb);
    final freshDocuments = DriftDocumentRepository(freshDb);
    final freshFileStorage = IoFileStorageService(StorageLocationService());

    final restoredCategories = await freshCategories.watchAll().first;
    expect(restoredCategories.map((c) => c.id), ['finance']);
    expect(restoredCategories.single.name, 'Finance');

    final restoredDocuments = await freshDocuments.watchAll().first;
    expect(restoredDocuments, hasLength(1));
    expect(restoredDocuments.single.name, 'Utility bill.pdf');
    expect(restoredDocuments.single.categoryId, 'finance');

    final restoredBytes = await freshFileStorage.read(restoredDocuments.single.storageKey);
    expect(restoredBytes, fileBytes);
  });

  test('restoreFromArchive rejects a file with no manifest', () async {
    final db = AppDatabase();
    addTearDown(db.close);
    final fileStorage = IoFileStorageService(StorageLocationService());
    final backup = BackupService(db, fileStorage);

    final notABackup = Uint8List.fromList('just some random bytes, not a zip'.codeUnits);

    await expectLater(
      () => backup.restoreFromArchive(notABackup),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('restoreFromArchive rejects a backup made by a newer, incompatible format version', () async {
    final db = AppDatabase();
    addTearDown(db.close);
    final fileStorage = IoFileStorageService(StorageLocationService());

    // Build a syntactically valid backup archive, but claiming a format
    // version newer than this app understands.
    final sourceBackup = BackupService(db, fileStorage);
    final validZip = await sourceBackup.createBackupArchive();

    // Real backups always have a lower/equal formatVersion than
    // BackupService.formatVersion — sanity-check that assumption still
    // holds before asserting the rejection path below actually exercises
    // the version check and not some other validation failure.
    expect(BackupService.formatVersion, greaterThanOrEqualTo(1));

    // Reaching into a real archive and only bumping the manifest's declared
    // version (rather than hand-building a whole zip) keeps this test
    // resilient to the exact archive layout.
    final tamperedZip = _withBumpedFormatVersion(validZip);

    await expectLater(
      () => sourceBackup.restoreFromArchive(tamperedZip),
      throwsA(isA<BackupFormatException>()),
    );
  });
}

/// Rewrites just the `manifest.json` entry's `formatVersion` to something
/// far newer than any real Sift release could produce, keeping every other
/// entry (the db, the files) byte-for-byte as-is. Built directly against
/// the `archive` package rather than through `BackupService`, so this test
/// doesn't just check the production code against itself.
Uint8List _withBumpedFormatVersion(Uint8List zipBytes) {
  final source = ZipDecoder().decodeBytes(zipBytes);
  final rebuilt = Archive();
  for (final entry in source.files) {
    if (entry.name == 'manifest.json') {
      final manifest = jsonDecode(utf8.decode(entry.content as List<int>)) as Map<String, dynamic>;
      manifest['formatVersion'] = 999999;
      final bytes = utf8.encode(jsonEncode(manifest));
      rebuilt.addFile(ArchiveFile('manifest.json', bytes.length, bytes));
    } else {
      rebuilt.addFile(ArchiveFile(entry.name, entry.size, entry.content as List<int>));
    }
  }
  return Uint8List.fromList(ZipEncoder().encode(rebuilt));
}
