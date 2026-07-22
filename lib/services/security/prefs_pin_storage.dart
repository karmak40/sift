import 'package:shared_preferences/shared_preferences.dart';

import 'pin_storage.dart';

/// Backs the PIN with `shared_preferences` rather than a hardware-backed OS
/// keystore (Android Keystore / iOS Keychain / Windows DPAPI).
///
/// The obvious "correct" choice would be `flutter_secure_storage`, but its
/// Windows native plugin requires the ATL (Active Template Library) Visual
/// Studio component, which isn't part of a default install — pulling in
/// that dependency at all means CMake tries to compile it for the Windows
/// target regardless of whether Dart code ever calls into it, so it isn't
/// something a runtime `Platform.isWindows` check can route around; the
/// package can't be a dependency of this project at all without either
/// installing that VS component or hitting this on every Windows build.
///
/// Given the PIN is a salted hash (never plain text) guarding a personal
/// document vault whose files are already unencrypted on disk — not a
/// banking credential — shared_preferences is a reasonable trade against
/// blocking the whole feature on a Visual Studio component install. If
/// hardware-backed storage matters later, swap this out for a
/// `SecurePinStorage` (`flutter_secure_storage`-backed) implementation of
/// [PinStorage] once that's set up, on whichever platforms want it.
class PrefsPinStorage implements PinStorage {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
