import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/security/app_lock_service.dart';
import '../services/security/biometric_service.dart';
import '../services/security/prefs_pin_storage.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) => AppLockService(PrefsPinStorage()));

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

/// Whether App Lock is currently turned on. Settings screen calls
/// `ref.invalidate(appLockEnabledProvider)` after enabling/disabling so this
/// (and the lock gate that watches it) picks up the change immediately.
final appLockEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(appLockServiceProvider).isEnabled();
});

/// Whether this device can use biometric unlock at all — gates whether the
/// "Use biometric unlock" affordance shows up.
final biometricSupportedProvider = FutureProvider<bool>((ref) {
  return ref.watch(biometricServiceProvider).isSupported();
});

/// Ephemeral, in-memory only: true once the user has unlocked this app
/// session. Starts false on cold start and is reset to false whenever the
/// app is backgrounded (see `AppLockGate`), so re-opening the app always
/// asks again — that's the actual security property App Lock provides.
final isUnlockedProvider = StateProvider<bool>((ref) => false);
