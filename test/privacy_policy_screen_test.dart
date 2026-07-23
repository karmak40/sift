import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/ui/settings/privacy_policy_screen.dart';

void main() {
  testWidgets('renders the real PRIVACY.md content, parsed into headings/bullets', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: PrivacyPolicyScreen(),
    ));
    // rootBundle.loadString is real async I/O, same as the app icon
    // generator — needs runAsync to actually resolve under flutter_test.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    // The '# ' title heading, rendered without its markdown marker.
    expect(find.text('Sift Privacy Policy'), findsOneWidget);
    // A '## ' subheading.
    expect(find.text('What Sift stores, and where'), findsOneWidget);
    // A bulleted, originally-**bold**-prefixed line, with the markers
    // stripped rather than left in literally — this is also the sanity
    // check that the bundled PRIVACY.md asset has real content, since it's
    // asserting on an exact sentence from the file, not just a heading.
    expect(
      find.textContaining('Documents, categories, expiration dates, and AI-summary text'),
      findsOneWidget,
    );
    expect(find.textContaining('**'), findsNothing);
  });
}
