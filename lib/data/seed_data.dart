import 'models/category.dart';
import 'repository/category_repository.dart';

/// Populates a handful of default categories on first run so the upload
/// flow has somewhere to file a document. No demo/mock documents are
/// created — the library starts empty and only ever shows documents the
/// user has actually uploaded.
Future<void> seedIfEmpty(CategoryRepository categories) async {
  final existingCats = await categories.watchAll().first;
  if (existingCats.isNotEmpty) return;

  const defaultCategories = [
    Category(id: 'finance', name: 'Finance', hue: 150),
    Category(id: 'health', name: 'Health', hue: 30),
    Category(id: 'housing', name: 'Housing', hue: 280),
    Category(id: 'personal', name: 'Personal', hue: 90),
    Category(id: 'travel', name: 'Travel', hue: 210),
  ];
  for (final c in defaultCategories) {
    await categories.create(c);
  }
}
