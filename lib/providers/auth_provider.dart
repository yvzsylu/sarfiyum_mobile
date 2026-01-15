import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

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

        // 🔥 DEĞİŞİKLİK 1: Token'ı API istekleri için kaydediyoruz.
        await SecureStorageService().saveToken(token);

        // 🔥 DEĞİŞİKLİK 2: ROL FARK ETMEKSİZİN BİLGİLERİ KAYDET
        // İster User olsun, ister Viewer; "Çıkış Yap" dese bile
        // bir sonraki girişte bilgiler hazır olsun istiyoruz.
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
      // Login ekranına düşsün, bilgiler zaten dolu gelecek.
      if (tempUser.isViewer) {
        await SecureStorageService().deleteToken();
        return false;
      }

      // Normal User ise içeri al
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

    // 🔥 DEĞİŞİKLİK 3: Sadece Token'ı siliyoruz!
    // 'clearAll()' yaparsak kayıtlı şifreler de gider.
    // 'deleteToken()' yaparsak sadece oturum düşer, şifreler kalır.
    await SecureStorageService().deleteToken();

    notifyListeners();
  }

  // --- 4. ARKA PLAN LOGOUT (Sadece Viewer) ---
  void logoutForBackground() {
    if (isViewer) {
      _user = null;
      // Token'ı sil, oturum düşsün.
      SecureStorageService().deleteToken();
      notifyListeners();
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
