/// Tiny key/value contract `AppLockService` stores the salted PIN hash
/// through. Exists so the actual backend can differ per platform — see
/// `SecurePinStorage` and `PrefsPinStorage`.
abstract class PinStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}
