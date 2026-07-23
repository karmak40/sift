import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/main.dart';
import 'package:sift/providers/app_init_provider.dart';
import 'package:sift/providers/data_providers.dart';
import 'package:sift/ui/lock/app_lock_gate.dart';
import 'package:sift/ui/onboarding/onboarding_screen.dart';
import 'package:sift/ui/splash/splash_screen.dart';

Future<void> _pumpGate(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Bypass the real Drift-backed category seeding — SplashGate only
        // cares whether appInitProvider is done, not what it seeded.
        appInitProvider.overrideWith((ref) async {}),
        // Routing past onboarding reaches HomeShell, which watches these —
        // stub them out so this test never opens a real drift database (its
        // query-stream cancellation schedules a timer that outlives a widget
        // test's fake-async zone and trips the "no pending timers" check).
        categoriesProvider.overrideWith((ref) => Stream.value(const [])),
        documentsProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: SplashGate(),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the splash screen immediately on cold start', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpGate(tester);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

    // Flush the pending minimum-duration timer so the test can tear down
    // cleanly instead of tripping the "no pending timers" invariant.
    await tester.pump(SplashScreen.duration);
    await tester.pump();
  });

  testWidgets('falls through to onboarding once the splash duration elapses, on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpGate(tester);

    await tester.pump(SplashScreen.duration);
    await tester.pump();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('skips onboarding straight to the locked/home shell when already seen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await _pumpGate(tester);

    await tester.pump(SplashScreen.duration);
    await tester.pump();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppLockGate), findsOneWidget);
  });
}
