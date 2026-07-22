import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/services/security/app_lock_service.dart';
import 'package:sift/services/security/prefs_pin_storage.dart';

void main() {
  late AppLockService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = AppLockService(PrefsPinStorage());
  });

  test('is disabled with no PIN set', () async {
    expect(await service.isEnabled(), isFalse);
  });

  test('setPin() enables the lock and the same PIN then verifies', () async {
    await service.setPin('1234');

    expect(await service.isEnabled(), isTrue);
    expect(await service.verifyPin('1234'), isTrue);
  });

  test('verifyPin() rejects a wrong PIN', () async {
    await service.setPin('1234');

    expect(await service.verifyPin('0000'), isFalse);
  });

  test('verifyPin() with no PIN set never throws and returns false', () async {
    expect(await service.verifyPin('1234'), isFalse);
  });

  test('setPin() overwrites a previous PIN — only the new one verifies', () async {
    await service.setPin('1111');
    await service.setPin('2222');

    expect(await service.verifyPin('1111'), isFalse);
    expect(await service.verifyPin('2222'), isTrue);
  });

  test('disable() turns off the lock and wipes the PIN', () async {
    await service.setPin('1234');

    await service.disable();

    expect(await service.isEnabled(), isFalse);
    expect(await service.verifyPin('1234'), isFalse);
  });

  test('re-setting the same PIN produces a different stored hash (random salt)', () async {
    await service.setPin('1234');
    final prefs = await SharedPreferences.getInstance();
    final hash1 = prefs.getString('app_lock_pin_hash');

    await service.setPin('1234');
    final hash2 = prefs.getString('app_lock_pin_hash');

    expect(hash1, isNotNull);
    expect(hash1, isNot(equals(hash2)));
    // ...but the PIN itself still verifies correctly against the new salt.
    expect(await service.verifyPin('1234'), isTrue);
  });
}
