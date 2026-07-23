import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sift/l10n/app_localizations.dart';

/// Pumps a bare `MaterialApp` in [locale] and hands the resolved
/// [AppLocalizations] to [build] — used to check real translated strings
/// render, not just that a key exists in the template ARB.
Future<void> _pumpWithLocale(
  WidgetTester tester,
  Locale locale,
  Widget Function(AppLocalizations l10n) build,
) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(builder: (context) => build(AppLocalizations.of(context)!)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('bottom nav labels translate per locale', () {
    final expected = {
      const Locale('en'): 'Library',
      const Locale('ru'): 'Библиотека',
      const Locale('uk'): 'Бібліотека',
      const Locale('de'): 'Bibliothek',
    };

    for (final entry in expected.entries) {
      testWidgets('${entry.key.languageCode} -> "${entry.value}"', (tester) async {
        await _pumpWithLocale(tester, entry.key, (l10n) => Text(l10n.navLibrary));
        expect(find.text(entry.value), findsOneWidget);
      });
    }
  });

  group('Russian plural forms (one/few/many)', () {
    testWidgets('fileCount picks the right grammatical form per count', (tester) async {
      await _pumpWithLocale(tester, const Locale('ru'), (l10n) => Text(l10n.fileCount(1)));
      expect(find.text('1 файл'), findsOneWidget);

      await _pumpWithLocale(tester, const Locale('ru'), (l10n) => Text(l10n.fileCount(2)));
      expect(find.text('2 файла'), findsOneWidget);

      await _pumpWithLocale(tester, const Locale('ru'), (l10n) => Text(l10n.fileCount(5)));
      expect(find.text('5 файлов'), findsOneWidget);
    });
  });

  group('Ukrainian plural forms (one/few/many)', () {
    testWidgets('fileCount picks the right grammatical form per count', (tester) async {
      await _pumpWithLocale(tester, const Locale('uk'), (l10n) => Text(l10n.fileCount(1)));
      expect(find.text('1 файл'), findsOneWidget);

      await _pumpWithLocale(tester, const Locale('uk'), (l10n) => Text(l10n.fileCount(3)));
      expect(find.text('3 файли'), findsOneWidget);

      await _pumpWithLocale(tester, const Locale('uk'), (l10n) => Text(l10n.fileCount(9)));
      expect(find.text('9 файлів'), findsOneWidget);
    });
  });

  group('German plural forms (one/other)', () {
    testWidgets('fileCount picks singular vs plural', (tester) async {
      await _pumpWithLocale(tester, const Locale('de'), (l10n) => Text(l10n.fileCount(1)));
      expect(find.text('1 Datei'), findsOneWidget);

      await _pumpWithLocale(tester, const Locale('de'), (l10n) => Text(l10n.fileCount(4)));
      expect(find.text('4 Dateien'), findsOneWidget);
    });
  });

  testWidgets('placeholder interpolation substitutes real values', (tester) async {
    await _pumpWithLocale(
      tester,
      const Locale('en'),
      (l10n) => Text(l10n.deleteDocumentConfirmTitle('passport.pdf')),
    );
    expect(find.text('Delete "passport.pdf"?'), findsOneWidget);
  });
}
