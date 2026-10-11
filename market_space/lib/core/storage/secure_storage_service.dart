import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

class FlutterSecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage secureStorage;

  FlutterSecureStorageServiceImpl({
    required this.secureStorage,
  });

  @override
  Future<String?> read(String key) async {
    return secureStorage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return secureStorage.containsKey(key: key);
  }
}

class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _secureVault = {};

  @override
  Future<String?> read(String key) async {
    return _secureVault[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _secureVault[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _secureVault.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _secureVault.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _secureVault.containsKey(key);
  }
}
