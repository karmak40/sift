import '../models/category.dart';

/// Contract for reading/writing categories. Implemented today by
/// [DriftCategoryRepository]; a future `RemoteCategoryRepository` can
/// implement this same interface without any UI changes.
abstract class CategoryRepository {
  Stream<List<Category>> watchAll();

  Future<void> create(Category category);

  /// Renames/recolors an existing category in place. Documents already
  /// assigned to it keep their `categoryId` — only the category's own
  /// `name`/`hue` change.
  Future<void> update(Category category);

  Future<void> delete(String id);
}
