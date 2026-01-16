import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../main.dart'; // 🔥 navigatorKey'e erişim için

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isViewer => _user?.isViewer ?? false;

  // --- 1. LOGIN ---
  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(username, password, 2);

      if (result.isSuccess && result.data != null) {
        final token = result.data!;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        _user = User.fromJwt(decodedToken, token);

        // Token'ı API istekleri için kaydet
        await SecureStorageService().saveToken(token);

        // Kullanıcı adı ve şifreyi bir sonraki giriş için sakla
        await SecureStorageService().saveCredentials(username, password);

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

  // --- 2. OTOMATİK GİRİŞ (App Açılışı) ---
  Future<bool> tryAutoLogin() async {
    final token = await SecureStorageService().getToken();

    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final tempUser = User.fromJwt(decodedToken, token);

      // Viewer ise token geçerli olsa bile otomatik içeri alma.
      if (tempUser.isViewer) {
        await SecureStorageService().deleteToken();
        return false;
      }

      _user = tempUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- 3. MANUEL LOGOUT (Butona Basınca) ---
  Future<void> logout() async {
    _user = null;
    _isLoading = false;
    // Sadece token'ı sil, kayıtlı şifreler kalsın
    await SecureStorageService().deleteToken();
    notifyListeners();
  }

  // --- 4. ARKA PLAN LOGOUT (Sadece Viewer) ---
  void logoutForBackground() {
    if (isViewer) {
      _user = null;
      SecureStorageService().deleteToken();
      notifyListeners();
    }
  }

  // 🔥 5. YETKİSİZ ERİŞİM / KICK LOGOUT (Dashboard ve API Tetikler) 🔥
  Future<void> handleUnauthorized() async {
    // Sadece kullanıcı varsa işlem yap (Zaten logout ise yapma)
    if (_user != null) {
      print("🔐 Oturum sonlandırılıyor (Force Logout / Kick)");

      _user = null;
      // Token'ı sil ki tekrar istek atamasın
      await SecureStorageService().deleteToken();

      // UI'ı güncelle
      notifyListeners();

      // 🔥 KESİN ÇÖZÜM: Global Key ile sayfayı zorla Login'e (Root) çevir.
      if (navigatorKey.currentState != null) {
        // Tüm geçmişi sil ve en başa (AuthWrapper -> Login) dön.
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
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
