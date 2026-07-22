import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/database.dart';
import '../models/ai_summary.dart';
import '../models/document.dart';
import 'document_repository.dart';

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(this._db);

  final AppDatabase _db;

  Document _toModel(DocumentRow row) {
    return Document(
      id: row.id,
      name: row.name,
      type: DocType.fromLabel(row.type),
      categoryId: row.categoryId,
      sizeBytes: row.sizeBytes,
      addedAt: row.addedAt,
      storageKey: row.storageKey,
      ai: row.aiSummaryJson == null
          ? null
          : AiSummary.fromJson(
              jsonDecode(row.aiSummaryJson!) as Map<String, Object?>,
            ),
    );
  }

  @override
  Stream<List<Document>> watchAll() {
    return (_db.select(_db.documents)
          ..orderBy([(d) => OrderingTerm.desc(d.addedAt)]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<void> create({
    required String name,
    required DocType type,
    required String categoryId,
    required int sizeBytes,
    required String storageKey,
    AiSummary? ai,
    DateTime? addedAt,
  }) {
    return _db
        .into(_db.documents)
        .insert(
          DocumentsCompanion.insert(
            name: name,
            type: type.label,
            categoryId: categoryId,
            sizeBytes: sizeBytes,
            addedAt: addedAt ?? DateTime.now(),
            storageKey: storageKey,
            aiSummaryJson: Value(
              ai == null ? null : jsonEncode(ai.toJson()),
            ),
          ),
        );
  }

  @override
  Future<void> updateAiSummary(int id, AiSummary? ai) {
    return (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
      DocumentsCompanion(
        aiSummaryJson: Value(ai == null ? null : jsonEncode(ai.toJson())),
      ),
    );
  }

  @override
  Future<void> moveToCategory(List<int> ids, String categoryId) {
    return (_db.update(_db.documents)..where((d) => d.id.isIn(ids))).write(
      DocumentsCompanion(categoryId: Value(categoryId)),
    );
  }

  @override
  Future<void> delete(List<int> ids) {
    return (_db.delete(_db.documents)..where((d) => d.id.isIn(ids))).go();
  }
}
