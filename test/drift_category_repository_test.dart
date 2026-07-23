import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sift/data/local/database.dart';
import 'package:sift/data/models/category.dart';
import 'package:sift/data/repository/drift_category_repository.dart';

void main() {
  late AppDatabase db;
  late DriftCategoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftCategoryRepository(db);
  });

  tearDown(() => db.close());

  test('create then watchAll reflects the new category', () async {
    await repo.create(const Category(id: 'c1', name: 'Finance', hue: 150));

    final all = await repo.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.id, 'c1');
    expect(all.single.name, 'Finance');
    expect(all.single.hue, 150);
  });

  test('update renames and recolors an existing category in place', () async {
    await repo.create(const Category(id: 'c1', name: 'Finance', hue: 150));

    await repo.update(const Category(id: 'c1', name: 'Money', hue: 30));

    final all = await repo.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.id, 'c1');
    expect(all.single.name, 'Money');
    expect(all.single.hue, 30);
  });

  test('delete removes the category row', () async {
    await repo.create(const Category(id: 'c1', name: 'Finance', hue: 150));

    await repo.delete('c1');

    expect(await repo.watchAll().first, isEmpty);
  });
}
