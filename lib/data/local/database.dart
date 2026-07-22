import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get hue => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DocumentRow')
class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get categoryId => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get addedAt => dateTime()();
  TextColumn get storageKey => text()();
  TextColumn get aiSummaryJson => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  IntColumn get reminderDaysBefore => integer().nullable()();
}

/// BLOB-backed file storage used only on Web, where there is no real
/// filesystem to copy uploaded files into. Native platforms use
/// [IoFileStorageService] instead and never touch this table.
class WebFiles extends Table {
  TextColumn get id => text()();
  BlobColumn get bytes => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Documents, WebFiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 -> v2: added expiration-reminder tracking (expiresAt/
      // reminderDaysBefore) to Documents. Existing rows just get NULL for
      // both — "not tracked" is the correct default for documents that
      // predate this feature.
      if (from < 2) {
        await m.addColumn(documents, documents.expiresAt);
        await m.addColumn(documents, documents.reminderDaysBefore);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'sift_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
