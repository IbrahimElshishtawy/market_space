import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<double?> getDouble(String key);
  Future<void> setDouble(String key, double value);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesServiceImpl implements PreferencesService {
  final SharedPreferences sharedPreferences;

  SharedPreferencesServiceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<String?> getString(String key) async {
    return sharedPreferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return sharedPreferences.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await sharedPreferences.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return sharedPreferences.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await sharedPreferences.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return sharedPreferences.getDouble(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await sharedPreferences.setDouble(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.clear();
  }
}

class InMemoryPreferencesService implements PreferencesService {
  final Map<String, dynamic> _inMemoryStorage = {};

  @override
  Future<String?> getString(String key) async {
    return _inMemoryStorage[key] as String?;
  }

  @override
  Future<void> setString(String key, String value) async {
    _inMemoryStorage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _inMemoryStorage[key] as bool?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _inMemoryStorage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return _inMemoryStorage[key] as int?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _inMemoryStorage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _inMemoryStorage[key] as double?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _inMemoryStorage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _inMemoryStorage.remove(key);
  }

  @override
  Future<void> clear() async {
    _inMemoryStorage.clear();
  }
}
