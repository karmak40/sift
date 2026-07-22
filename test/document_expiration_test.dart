import 'package:flutter_test/flutter_test.dart';
import 'package:sift/data/models/document.dart';

void main() {
  Document docWith({DateTime? expiresAt, int? reminderDaysBefore}) => Document(
    id: 1,
    name: 'Passport.pdf',
    type: DocType.pdf,
    categoryId: 'personal',
    sizeBytes: 100,
    addedAt: DateTime(2026, 1, 1),
    storageKey: 'key',
    expiresAt: expiresAt,
    reminderDaysBefore: reminderDaysBefore,
  );

  group('hasExpiration', () {
    test('false when no expiration date is set', () {
      expect(docWith().hasExpiration, isFalse);
    });

    test('true once an expiration date is set', () {
      expect(docWith(expiresAt: DateTime(2027, 1, 1)).hasExpiration, isTrue);
    });
  });

  group('reminderDate', () {
    test('null when there is no expiration date', () {
      expect(docWith().reminderDate, isNull);
    });

    test('defaults to 30 days before expiration', () {
      final doc = docWith(expiresAt: DateTime(2027, 3, 31));
      expect(doc.reminderDate, DateTime(2027, 3, 1));
    });

    test('honors a custom reminderDaysBefore', () {
      final doc = docWith(expiresAt: DateTime(2027, 3, 31), reminderDaysBefore: 7);
      expect(doc.reminderDate, DateTime(2027, 3, 24));
    });
  });

  group('isExpiringSoon', () {
    test('false with no expiration set at all', () {
      expect(docWith().isExpiringSoon(DateTime(2027, 1, 1)), isFalse);
    });

    test('false while still well before the reminder window', () {
      final doc = docWith(expiresAt: DateTime(2027, 6, 1), reminderDaysBefore: 30);
      expect(doc.isExpiringSoon(DateTime(2027, 1, 1)), isFalse);
    });

    test('true right at the start of the reminder window', () {
      final doc = docWith(expiresAt: DateTime(2027, 6, 1), reminderDaysBefore: 30);
      expect(doc.isExpiringSoon(DateTime(2027, 5, 2)), isTrue);
    });

    test('stays true after the document has already expired', () {
      final doc = docWith(expiresAt: DateTime(2027, 6, 1), reminderDaysBefore: 30);
      expect(doc.isExpiringSoon(DateTime(2027, 12, 25)), isTrue);
    });
  });

  group('copyWith expiration handling', () {
    test('clearExpiresAt wipes both the date and the reminder lead time', () {
      final doc = docWith(expiresAt: DateTime(2027, 1, 1), reminderDaysBefore: 14);

      final cleared = doc.copyWith(clearExpiresAt: true);

      expect(cleared.expiresAt, isNull);
      expect(cleared.reminderDaysBefore, isNull);
      expect(cleared.hasExpiration, isFalse);
    });

    test('setting a new expiresAt keeps the existing reminderDaysBefore if not overridden', () {
      final doc = docWith(expiresAt: DateTime(2027, 1, 1), reminderDaysBefore: 14);

      final updated = doc.copyWith(expiresAt: DateTime(2027, 6, 1));

      expect(updated.reminderDaysBefore, 14);
    });
  });
}
