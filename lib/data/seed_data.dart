import '../services/current_localizations.dart';
import 'models/category.dart';
import 'repository/category_repository.dart';

/// Populates a handful of default categories on first run so the upload
/// flow has somewhere to file a document. No demo/mock documents are
/// created — the library starts empty and only ever shows documents the
/// user has actually uploaded.
///
/// Names are localized to whatever language is active at the moment of
/// first run (see `AppLocaleController`) — after that they're just regular
/// user data the user is free to rename, same as any other category.
Future<void> seedIfEmpty(CategoryRepository categories) async {
  final existingCats = await categories.watchAll().first;
  if (existingCats.isNotEmpty) return;

  final l10n = currentLocalizations();
  final defaultCategories = [
    Category(id: 'finance', name: l10n.financeCategory, hue: 150),
    Category(id: 'health', name: l10n.healthCategory, hue: 30),
    Category(id: 'housing', name: l10n.housingCategory, hue: 280),
    Category(id: 'personal', name: l10n.personalCategory, hue: 90),
    Category(id: 'travel', name: l10n.travelCategory, hue: 210),
  ];
  for (final c in defaultCategories) {
    await categories.create(c);
  }
}
