import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences sharedPreferences;

  LocalStorageImpl(this.sharedPreferences);

  @override
  Future<void> saveString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return sharedPreferences.getString(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await sharedPreferences.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return sharedPreferences.getInt(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await sharedPreferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return sharedPreferences.getBool(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    await sharedPreferences.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return sharedPreferences.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return sharedPreferences.containsKey(key);
  }
}

// Keys for common storage items
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String isFirstTime = 'is_first_time';
  static const String theme = 'theme';
  static const String language = 'language';
}
