import 'package:drift/drift.dart';

import '../local/database.dart';
import '../models/category.dart';
import 'category_repository.dart';

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._db);

  final AppDatabase _db;

  Category _toModel(CategoryRow row) =>
      Category(id: row.id, name: row.name, hue: row.hue);

  @override
  Stream<List<Category>> watchAll() {
    return _db.select(_db.categories).watch().map(
      (rows) => rows.map(_toModel).toList(),
    );
  }

  @override
  Future<void> create(Category category) {
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            hue: category.hue,
          ),
        );
  }

  @override
  Future<void> update(Category category) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(category.id))).write(
      CategoriesCompanion(name: Value(category.name), hue: Value(category.hue)),
    );
  }

  @override
  Future<void> delete(String id) {
    return (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}
