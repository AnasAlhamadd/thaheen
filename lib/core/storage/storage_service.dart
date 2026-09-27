import 'package:shared_preferences/shared_preferences.dart';

/// Abstract storage service wrapper around local key-value store.
abstract class StorageService {
  /// Reads a string value for the given [key].
  Future<String?> getString(String key);

  /// Saves a string [value] for the given [key].
  Future<bool> setString(String key, String value);

  /// Removes the value stored under [key].
  Future<bool> remove(String key);

  /// Clears all entries from storage.
  Future<bool> clear();
}

/// SharedPreferences implementation of [StorageService].
class SharedPreferencesStorageService implements StorageService {
  final SharedPreferences _prefs;

  /// Creates a [SharedPreferencesStorageService] backed by [SharedPreferences].
  const SharedPreferencesStorageService(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }
}
