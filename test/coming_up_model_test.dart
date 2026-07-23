import 'package:flutter_test/flutter_test.dart';
import 'package:sift/data/models/document.dart';
import 'package:sift/ui/coming_up/coming_up_model.dart';

void main() {
  final now = DateTime(2026, 6, 1, 10, 30); // a fixed "today" with a time-of-day

  Document doc({int id = 1, DateTime? expiresAt}) => Document(
    id: id,
    name: 'doc-$id.pdf',
    type: DocType.pdf,
    categoryId: 'personal',
    sizeBytes: 100,
    addedAt: DateTime(2026, 1, 1),
    storageKey: 'k$id',
    expiresAt: expiresAt,
  );

  group('bucketFor', () {
    test('null when the document has no expiry', () {
      expect(bucketFor(doc(), now), isNull);
    });

    test('null when expiry is beyond the 90-day horizon', () {
      expect(bucketFor(doc(expiresAt: DateTime(2026, 10, 1)), now), isNull);
    });

    test('overdue when already past, regardless of how long ago', () {
      expect(bucketFor(doc(expiresAt: DateTime(2026, 5, 20)), now), ExpiryBucket.overdue);
      expect(bucketFor(doc(expiresAt: DateTime(2020, 1, 1)), now), ExpiryBucket.overdue);
    });

    test('today counts as this week, not overdue (ignores time-of-day)', () {
      expect(bucketFor(doc(expiresAt: DateTime(2026, 6, 1, 8)), now), ExpiryBucket.thisWeek);
    });

    test('boundaries: 7 days is this week, 8 is this month', () {
      expect(bucketFor(doc(expiresAt: DateTime(2026, 6, 8)), now), ExpiryBucket.thisWeek);
      expect(bucketFor(doc(expiresAt: DateTime(2026, 6, 9)), now), ExpiryBucket.thisMonth);
    });

    test('boundaries: 30 days is this month, 31 is coming up', () {
      expect(bucketFor(doc(expiresAt: DateTime(2026, 7, 1)), now), ExpiryBucket.thisMonth);
      expect(bucketFor(doc(expiresAt: DateTime(2026, 7, 2)), now), ExpiryBucket.comingUp);
    });
  });

  group('comingUpEntries', () {
    test('excludes no-expiry and beyond-horizon docs, sorts soonest first', () {
      final docs = [
        doc(id: 1, expiresAt: DateTime(2026, 7, 1)), // this month
        doc(id: 2), // no expiry -> excluded
        doc(id: 3, expiresAt: DateTime(2026, 5, 1)), // overdue
        doc(id: 4, expiresAt: DateTime(2027, 1, 1)), // beyond horizon -> excluded
        doc(id: 5, expiresAt: DateTime(2026, 6, 3)), // this week
      ];

      final entries = comingUpEntries(docs, now);

      expect(entries.map((e) => e.document.id), [3, 5, 1]); // soonest expiry first
      expect(entries.map((e) => e.bucket), [
        ExpiryBucket.overdue,
        ExpiryBucket.thisWeek,
        ExpiryBucket.thisMonth,
      ]);
    });
  });

  group('comingUpCounts', () {
    test('empty when nothing is coming up', () {
      expect(comingUpCounts(const []), isEmpty);
    });

    test('counts per bucket in urgency order, omitting empty buckets', () {
      final docs = [
        doc(id: 1, expiresAt: DateTime(2026, 5, 1)), // overdue
        doc(id: 2, expiresAt: DateTime(2026, 6, 20)), // this month
        doc(id: 3, expiresAt: DateTime(2026, 6, 25)), // this month
      ];
      // MapEntry has no value equality, so compare via records instead.
      final counts = comingUpCounts(comingUpEntries(docs, now)).map((e) => (e.key, e.value));
      expect(counts, [(ExpiryBucket.overdue, 1), (ExpiryBucket.thisMonth, 2)]);
    });
  });

  group('relativeExpiry', () {
    test('today / tomorrow / yesterday', () {
      expect(relativeExpiry(doc(expiresAt: DateTime(2026, 6, 1, 23)), now).kind, ExpiryPhraseKind.today);
      expect(relativeExpiry(doc(expiresAt: DateTime(2026, 6, 2)), now).kind, ExpiryPhraseKind.tomorrow);
      expect(relativeExpiry(doc(expiresAt: DateTime(2026, 5, 31)), now).kind, ExpiryPhraseKind.yesterday);
    });

    test('near-future in days, then weeks, then months', () {
      final inDays = relativeExpiry(doc(expiresAt: DateTime(2026, 6, 5)), now);
      expect(inDays.kind, ExpiryPhraseKind.inDays);
      expect(inDays.amount, 4);

      final inWeeks = relativeExpiry(doc(expiresAt: DateTime(2026, 6, 21)), now);
      expect(inWeeks.kind, ExpiryPhraseKind.inWeeks);
      expect(inWeeks.amount, 3);

      final inMonths = relativeExpiry(doc(expiresAt: DateTime(2026, 8, 1)), now);
      expect(inMonths.kind, ExpiryPhraseKind.inMonths);
      expect(inMonths.amount, 2);
    });

    test('past shows how long ago', () {
      final daysAgo = relativeExpiry(doc(expiresAt: DateTime(2026, 5, 22)), now);
      expect(daysAgo.kind, ExpiryPhraseKind.daysAgo);
      expect(daysAgo.amount, 10);
    });
  });
}
