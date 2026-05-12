import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<bool> containsKey({required String key});
}

class SecureStorageImpl implements SecureStorage {
  static final IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
  );

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  SecureStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          FlutterSecureStorage(
            iOptions: _iosOptions,
            aOptions: _androidOptions,
          );

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(
      key: key,
      value: value,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll(iOptions: _iosOptions, aOptions: _androidOptions);
  }
}
