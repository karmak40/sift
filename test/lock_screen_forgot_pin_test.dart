import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/providers/app_lock_providers.dart';
import 'package:sift/services/security/biometric_service.dart';
import 'package:sift/ui/lock/lock_screen.dart';

/// Never touches a real platform channel — [isSupported] is false so the
/// normal "Use biometric unlock" button/auto-attempt stay out of the way,
/// and [authenticateWithDeviceCredential] returns whatever the test wants,
/// standing in for "the user did/didn't pass their device's own lock
/// screen."
class _FakeBiometricService extends BiometricService {
  _FakeBiometricService({required this.deviceCredentialResult});

  final bool deviceCredentialResult;

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> authenticateWithDeviceCredential({required String reason}) async =>
      deviceCredentialResult;
}

Future<ProviderContainer> pumpLockScreen(WidgetTester tester, {required bool deviceCredentialOk}) async {
  SharedPreferences.setMockInitialValues({});

  // The default 800x600 test surface is too small for the primer/PIN sheets
  // at their real content height and spuriously overflows — same fix used
  // by the other UI tests in this suite (e.g. splash_gate_test.dart).
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      biometricServiceProvider.overrideWithValue(
        _FakeBiometricService(deviceCredentialResult: deviceCredentialOk),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: LockScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('forgot PIN: verifying the device lets you set a new PIN and unlocks', (tester) async {
    final container = await pumpLockScreen(tester, deviceCredentialOk: true);

    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();
    expect(find.text('Verify it\'s you'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Now on pin_setup_sheet's "Set a PIN" step.
    expect(find.text('Set a PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '4321');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // "Confirm your PIN" step.
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '4321');
    await tester.tap(find.text('Save PIN'));
    await tester.pumpAndSettle();

    expect(container.read(isUnlockedProvider), isTrue);
    expect(await container.read(appLockServiceProvider).verifyPin('4321'), isTrue);
  });

  testWidgets('forgot PIN: failing device verification shows an explanation, stays locked', (
    tester,
  ) async {
    final container = await pumpLockScreen(tester, deviceCredentialOk: false);

    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Couldn\'t verify your device'), findsOneWidget);
    expect(container.read(isUnlockedProvider), isFalse);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
    expect(container.read(isUnlockedProvider), isFalse);
  });
}
