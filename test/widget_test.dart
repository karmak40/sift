import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sift/data/models/document.dart';
import 'package:sift/providers/library_controller.dart';

void main() {
  // Full-app widget tests would need path_provider/sqlite platform channels
  // mocked (drift_flutter opens a real DB on startup) — out of scope here.
  // The real golden path (library, upload, detail, settings) is verified by
  // running the app (`flutter run`). This covers the pure-Dart filter/sort
  // logic the UI depends on, exercised through a real ProviderContainer.
  group('LibraryController.apply', () {
    late ProviderContainer container;
    late LibraryController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(libraryControllerProvider.notifier);
    });

    tearDown(() => container.dispose());

    Document doc(int id, String name, String cat, int size, DateTime date) {
      return Document(
        id: id,
        name: name,
        type: DocType.pdf,
        categoryId: cat,
        sizeBytes: size,
        addedAt: date,
        storageKey: '',
      );
    }

    test('filters by category', () {
      final docs = [
        doc(1, 'Tax Return.pdf', 'finance', 100, DateTime(2026, 1, 1)),
        doc(2, 'Lease.pdf', 'housing', 200, DateTime(2026, 2, 1)),
      ];
      controller.selectCategory('finance');
      final result = controller.apply(docs);
      expect(result.map((d) => d.id), [1]);
    });

    test('sorts by name ascending', () {
      final docs = [
        doc(1, 'Zebra.pdf', 'finance', 100, DateTime(2026, 1, 1)),
        doc(2, 'Apple.pdf', 'finance', 100, DateTime(2026, 1, 1)),
      ];
      controller.setSortOrder(SortOrder.name);
      final result = controller.apply(docs);
      expect(result.map((d) => d.name), ['Apple.pdf', 'Zebra.pdf']);
    });

    test('sorts by size descending', () {
      final docs = [
        doc(1, 'Small.pdf', 'finance', 100, DateTime(2026, 1, 1)),
        doc(2, 'Big.pdf', 'finance', 900, DateTime(2026, 1, 1)),
      ];
      controller.setSortOrder(SortOrder.size);
      final result = controller.apply(docs);
      expect(result.map((d) => d.id), [2, 1]);
    });
  });
}
