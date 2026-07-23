import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sift/data/models/category.dart';
import 'package:sift/data/repository/category_repository.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/providers/core_providers.dart';
import 'package:sift/ui/category/new_category_sheet.dart';

class _FakeCategoryRepository implements CategoryRepository {
  Category? updated;
  bool createCalled = false;

  @override
  Stream<List<Category>> watchAll() => Stream.value(const []);

  @override
  Future<void> create(Category category) async => createCalled = true;

  @override
  Future<void> update(Category category) async => updated = category;

  @override
  Future<void> delete(String id) async {}
}

void main() {
  testWidgets('edit sheet pre-fills the existing name/hue and writes an update, not a create', (
    tester,
  ) async {
    final fakeRepo = _FakeCategoryRepository();
    // Deliberately not the first swatch hue, so a test that accidentally
    // defaults to "new category" behavior (starting from the first swatch)
    // instead of pre-filling from `editing` would be caught.
    const existing = Category(id: 'c1', name: 'Finance', hue: 340);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [categoryRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showEditCategorySheet(context, existing),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.editCategoryTitle), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Finance');

    await tester.enterText(find.byType(TextField), 'Money');
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    expect(fakeRepo.createCalled, isFalse);
    expect(fakeRepo.updated?.id, 'c1');
    expect(fakeRepo.updated?.name, 'Money');
    expect(fakeRepo.updated?.hue, 340);
  });
}
