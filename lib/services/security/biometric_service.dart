import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Thin wrapper over `local_auth` (Face ID/Touch ID, Android biometric,
/// Windows Hello). Never throws — callers just get a bool, since "biometric
/// isn't available/enrolled/cancelled" should always fall back to the app's
/// own PIN, not surface a platform exception.
class BiometricService {
  BiometricService([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isSupported() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return canCheck || deviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
