import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/ui/widgets/permission_primer.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Pumps a button that calls [ensurePermissionPrimed] on tap, taps it, and
  /// returns the still-pending Future — the caller then interacts with the
  /// sheet (tap Continue/Not now) and awaits this Future for the result.
  Future<Future<bool>> pumpAndTrigger(WidgetTester tester) async {
    late Future<bool> primerFuture;
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            primerFuture = ensurePermissionPrimed(
              context,
              prefsKey: 'test_permission',
              icon: Icons.camera_alt,
              title: 'Test title',
              message: 'Test message',
            );
          },
          child: const Text('trigger'),
        ),
      ),
    ));
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    return primerFuture;
  }

  testWidgets('shows the primer sheet the first time, not yet primed', (tester) async {
    await pumpAndTrigger(tester);
    expect(find.text('Test title'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('declining ("Not now") returns false and does not persist', (tester) async {
    final future1 = await pumpAndTrigger(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(await future1, isFalse);
    expect(await isPermissionPrimed('test_permission'), isFalse);

    // Triggering again shows the sheet again, since declining didn't persist.
    await pumpAndTrigger(tester);
    expect(find.text('Test title'), findsOneWidget);
  });

  testWidgets('continuing returns true and persists so it never shows again', (tester) async {
    final future1 = await pumpAndTrigger(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(await future1, isTrue);
    expect(await isPermissionPrimed('test_permission'), isTrue);

    // Triggering again resolves true immediately with no sheet shown.
    final future2 = await pumpAndTrigger(tester);
    expect(await future2, isTrue);
    expect(find.text('Test title'), findsNothing);
    expect(find.text('Test message'), findsNothing);
  });
}
