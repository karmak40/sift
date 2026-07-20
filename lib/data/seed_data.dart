import 'models/category.dart';
import 'models/document.dart';
import 'repository/category_repository.dart';
import 'repository/document_repository.dart';

/// Populates a handful of demo categories/documents on first run so the
/// library isn't empty. Real AI summaries are never generated here — the
/// demo docs simply start without one, same as any freshly uploaded file.
Future<void> seedIfEmpty(
  CategoryRepository categories,
  DocumentRepository documents,
) async {
  final existingCats = await categories.watchAll().first;
  if (existingCats.isNotEmpty) return;

  const seedCategories = [
    Category(id: 'finance', name: 'Finance', hue: 150),
    Category(id: 'health', name: 'Health', hue: 30),
    Category(id: 'housing', name: 'Housing', hue: 280),
    Category(id: 'personal', name: 'Personal', hue: 90),
    Category(id: 'travel', name: 'Travel', hue: 210),
  ];
  for (final c in seedCategories) {
    await categories.create(c);
  }

  final seedDocs = <(String, DocType, String, int, int)>[
    ('Tax Return 2025.pdf', DocType.pdf, 'finance', 2400000, 108),
    ('Apartment Lease.docx', DocType.doc, 'housing', 840000, 138),
    ('Passport Scan.jpg', DocType.img, 'personal', 3100000, 178),
    ('Blood Test Results.pdf', DocType.pdf, 'health', 1100000, 42),
    ('Budget 2026.xlsx', DocType.xls, 'finance', 512000, 19),
    ('Flight Itinerary.pdf', DocType.pdf, 'travel', 220000, 5),
    ('Car Insurance.pdf', DocType.pdf, 'finance', 1800000, 151),
    ('Recipe Collection.docx', DocType.doc, 'personal', 640000, 221),
    ('Vaccination Card.jpg', DocType.img, 'health', 900000, 79),
    ('Trip Plan Japan.pptx', DocType.ppt, 'travel', 6700000, 5),
  ];
  final now = DateTime.now();
  for (final (name, type, catId, size, daysAgo) in seedDocs) {
    await documents.create(
      name: name,
      type: type,
      categoryId: catId,
      sizeBytes: size,
      storageKey: '',
      addedAt: now.subtract(Duration(days: daysAgo)),
    );
  }
}
