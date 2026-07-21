import 'package:shared_preferences/shared_preferences.dart';

const _customPathPrefsKey = 'io_file_storage_custom_base_path';

/// Persists the user's chosen "where should my files live" folder
/// (Windows-only feature today, see the Storage section in Settings). A
/// null/missing value means "use the default app-data folder" — see
/// [IoFileStorageService].
class StorageLocationService {
  Future<String?> getCustomBasePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customPathPrefsKey);
  }

  Future<void> setCustomBasePath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_customPathPrefsKey);
    } else {
      await prefs.setString(_customPathPrefsKey, path);
    }
  }
}
