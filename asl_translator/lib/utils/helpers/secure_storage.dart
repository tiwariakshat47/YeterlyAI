// In utils/helpers/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String email, String password, bool remember) async {
    if (remember) {
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'password', value: password);
      await _storage.write(key: 'remember_me', value: 'true');
    } else {
      await clearCredentials();
    }
  }

  static Future<bool> getRememberMeStatus() async {
    final status = await _storage.read(key: 'remember_me');
    return status == 'true';
  }

  static Future<Map<String, String?>> getCredentials() async {
    return {
      'email': await _storage.read(key: 'email'),
      'password': await _storage.read(key: 'password'),
      'remember_me': await _storage.read(key: 'remember_me'),
    };
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'remember_me');
  }
}
