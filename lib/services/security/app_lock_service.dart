import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'pin_storage.dart';

/// Stores whether App Lock is on and the (salted, hashed — never plain-text)
/// PIN, through whichever [PinStorage] backend fits the platform (see
/// `SecurePinStorage`/`PrefsPinStorage`).
///
/// This is a device-lock PIN for a personal document vault, not a banking
/// credential — a salted SHA-256 hash is an appropriate amount of crypto for
/// that threat model, not an oversight.
class AppLockService {
  AppLockService(this._store);

  final PinStorage _store;

  static const _enabledKey = 'app_lock_enabled';
  static const _saltKey = 'app_lock_pin_salt';
  static const _hashKey = 'app_lock_pin_hash';

  Future<bool> isEnabled() async => (await _store.read(_enabledKey)) == 'true';

  /// Hashes and stores [pin], and marks App Lock as enabled. Call this both
  /// for first-time setup and for "change PIN" — it always overwrites.
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    await _store.write(_saltKey, salt);
    await _store.write(_hashKey, _hashPin(pin, salt));
    await _store.write(_enabledKey, 'true');
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _store.read(_saltKey);
    final storedHash = await _store.read(_hashKey);
    if (salt == null || storedHash == null) return false;
    return _hashPin(pin, salt) == storedHash;
  }

  /// Turns App Lock off and wipes the stored PIN — re-enabling later always
  /// starts from a fresh PIN, never a stale one.
  Future<void> disable() async {
    await _store.delete(_enabledKey);
    await _store.delete(_saltKey);
    await _store.delete(_hashKey);
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }
}
