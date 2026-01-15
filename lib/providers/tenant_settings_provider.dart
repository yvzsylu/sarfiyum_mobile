import 'package:flutter/material.dart';
import '../services/base_api_service.dart';

class TenantSettingsProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();

  bool isLoading = false;
  String? errorMessage;
  String? whatsappNumber;

  // --- 1. AYARLARI YÜKLE ---
  Future<void> loadSettings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Backend'den tek bir nesne dönüyor (List değil)
      final result = await _api.get<dynamic>("customer/settings");

      if (result.isSuccess && result.data != null) {
        final data = result.data;

        // Backend DTO'suna göre mapping (Case-safe)
        if (data is Map<String, dynamic>) {
          whatsappNumber =
              data['whatsappNumber'] ??
              data['whatsAppNumber'] ??
              data['WhatsAppNumber'];
        }
      } else {
        errorMessage = result.errors?.first ?? "Ayarlar yüklenemedi";
      }
    } catch (e) {
      errorMessage = "Beklenmedik hata: $e";
      debugPrint("Settings Load Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. AYARLARI GÜNCELLE (YENİ EKLENEN KISIM) ---
  Future<bool> updateSettings(String number) async {
    isLoading = true;
    errorMessage = null; // Önceki hataları temizle
    notifyListeners();

    try {
      // Backend'e gönderilecek DTO yapısı
      final Map<String, dynamic> payload = {"whatsappNumber": number};

      // PUT isteği gönderiyoruz
      final result = await _api.put("customer/settings", payload);

      if (result.isSuccess) {
        // Başarılıysa local değişkeni de güncelle ki tekrar load yapmaya gerek kalmasın
        whatsappNumber = number;
        return true;
      } else {
        errorMessage = result.errors?.first ?? "Güncelleme başarısız.";
        return false;
      }
    } catch (e) {
      errorMessage = "Bir hata oluştu: $e";
      debugPrint("Settings Update Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
