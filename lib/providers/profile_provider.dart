import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'; // FormData için gerekli
import '../services/base_api_service.dart';
import '../models/user_profile_dto.dart';
import '../models/service_result.dart';

class ProfileProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();
  final ImagePicker _picker = ImagePicker();

  UserProfileDto? userProfile;
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;

  // Profil Bilgilerini Çek
  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _api.get<dynamic>("customer/profile/info");

    if (result.isSuccess && result.data != null) {
      userProfile = UserProfileDto.fromJson(result.data);
    } else {
      errorMessage = result.errors?.first ?? "Profil yüklenemedi";
    }

    isLoading = false;
    notifyListeners();
  }

  // Logo Yükle
  Future<bool> uploadLogo() async {
    // 1. Galeriden resim seç
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return false; // Seçim iptal edildi

    // 2. Dosya boyutu kontrolü (Örn: 2MB)
    final bytes = await image.readAsBytes();
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      errorMessage = "Dosya boyutu 2MB'dan büyük olamaz!";
      notifyListeners();
      return false;
    }

    isUploading = true;
    notifyListeners();

    try {
      // 3. FormData Oluştur
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      // 4. API İsteği (BaseApiService post metodunun FormData desteklediğini varsayıyoruz)
      // Eğer BaseApiService FormData desteklemiyorsa Dio instance'ına ihtiyacın olabilir.
      final result = await _api.post<String>(
        "customer/profile/upload-logo",
        formData,
      );

      isUploading = false;

      if (result.isSuccess) {
        // Logoyu anlık güncelle (Cache'i kırmak için timestamp ekledik)
        if (userProfile != null) {
          userProfile!.tenantLogoUrl =
              "${result.data}?t=${DateTime.now().millisecondsSinceEpoch}";
        }
        notifyListeners();
        return true;
      } else {
        errorMessage = result.errors?.first ?? "Logo yüklenemedi";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isUploading = false;
      errorMessage = "Hata: $e";
      notifyListeners();
      return false;
    }
  }
}
