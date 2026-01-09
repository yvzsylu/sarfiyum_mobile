import '../models/service_result.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  // Login: String döner (Token)
  // 🔥 DEĞİŞİKLİK: clientSource parametresi eklendi
  Future<ServiceResult<String>> login(
    String username,
    String password,
    int clientSource,
  ) async {
    return await post<String>(
      "auth/login",
      {
        "username": username,
        "password": password,
        "clientSource": clientSource, // 🔥 Backend'e gönderiliyor (Mobile = 2)
      },
      // Backend data olarak direkt string (token) dönüyor
      fromJson: (json) => json as String,
    );
  }

  // Şifre Sıfırlama İsteği
  Future<ServiceResult<String>> resetPassword(String email) async {
    return await post<String>("auth/reset-password", {
      "email": email,
    }, fromJson: (data) => data.toString());
  }
}
