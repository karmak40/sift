import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sift/services/security/biometric_service.dart';

/// Runs on a real device/desktop so `local_auth`'s platform channel (WinRT
/// UserConsentVerifier on Windows, BiometricPrompt on Android, LAContext on
/// iOS) is actually exercised. Doesn't assert a specific true/false result —
/// whether biometric hardware is enrolled varies by machine — the thing
/// this proves is that the call completes without throwing.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BiometricService.isSupported() completes without throwing', (tester) async {
    final result = await BiometricService().isSupported();
    // ignore: avoid_print
    print('BiometricService.isSupported() => $result');
    expect(result, isA<bool>());
  });
}
