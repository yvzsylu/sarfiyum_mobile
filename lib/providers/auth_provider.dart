import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get userRole => _user?.roles?.firstOrNull;

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 🔥 DEĞİŞİKLİK: Servise 3. parametre olarak 2 (Mobile) gönderiyoruz.
      final result = await _authService.login(username, password, 2);

      if (result.isSuccess && result.data != null) {
        final token = result.data!;

        await _storage.write(key: 'jwt_token', value: token);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        _user = User.fromJwt(decodedToken, token);

        return null; // Başarılı
      } else {
        if (result.errors != null && result.errors!.isNotEmpty) {
          return result.errors!.join("\n");
        } else {
          return "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.";
        }
      }
    } catch (e) {
      return "Sistem hatası: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // App açılınca otomatik giriş
  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _user = User.fromJwt(decodedToken, token);
      notifyListeners();
    }
  }

  // void logout() async {  <-- ESKİSİ (Bunu değiştir)
  Future<void> logout() async {
    // <-- YENİSİ (Future<void> yap)
    _user = null;
    _isLoading = false;

    // Sadece token'ı değil, varsa her şeyi sil (Daha güvenli)
    // await _storage.delete(key: 'jwt_token');
    await _storage.deleteAll();

    notifyListeners();
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(email);

      if (result.isSuccess) {
        return null;
      } else {
        return result.errors?.join("\n") ?? "İşlem başarısız oldu.";
      }
    } catch (e) {
      return "Bağlantı hatası: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
