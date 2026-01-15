import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton Yapısı
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // --- VIEWER İÇİN (Kullanıcı Adı & Şifre Saklama) ---
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'saved_username', value: username);
    await _storage.write(key: 'saved_password', value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    String? username = await _storage.read(key: 'saved_username');
    String? password = await _storage.read(key: 'saved_password');
    return {'username': username, 'password': password};
  }

  // 🔥 EKSİK OLAN FONKSİYON BURAYA EKLENDİ 🔥
  Future<void> clearCredentials() async {
    await _storage.delete(key: 'saved_username');
    await _storage.delete(key: 'saved_password');
  }

  // --- USER İÇİN (Token Saklama) ---
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // --- GENEL TEMİZLİK ---
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
