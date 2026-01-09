import 'package:flutter/material.dart';
import '../services/base_api_service.dart';
import '../models/viewer_dtos.dart';

class ViewerProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();
  final String _endpoint = "user/viewer";

  List<UserListDto> viewers = [];
  bool isLoading = false;
  String? errorMessage;

  // 1. Listeyi Getir
  Future<void> loadViewers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _api.get<List<dynamic>>("$_endpoint/list");

    if (result.isSuccess && result.data != null) {
      viewers = result.data!.map((json) => UserListDto.fromJson(json)).toList();
    } else {
      errorMessage = result.errors?.first ?? "Kullanıcılar yüklenemedi";
    }

    isLoading = false;
    notifyListeners();
  }

  // 2. ID ile Getir (Edit ekranı için)
  Future<UserDetailDto?> getViewerById(String id) async {
    // Burada loading'i global yapmıyoruz, ekran kendi içinde dönsün
    final result = await _api.get<dynamic>("$_endpoint/$id");

    if (result.isSuccess && result.data != null) {
      return UserDetailDto.fromJson(result.data);
    }
    return null;
  }

  // 3. Ekle
  Future<bool> createViewer(CreateUserDto dto) async {
    isLoading = true;
    notifyListeners();

    final result = await _api.post<String>("$_endpoint/create", dto.toJson());

    isLoading = false;

    if (result.isSuccess) {
      await loadViewers(); // Listeyi yenile
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Kullanıcı oluşturulamadı";
      notifyListeners();
      return false;
    }
  }

  // 4. Güncelle
  Future<bool> updateViewer(UpdateUserDto dto) async {
    isLoading = true;
    notifyListeners();

    final result = await _api.put<String>("$_endpoint/update", dto.toJson());

    isLoading = false;

    if (result.isSuccess) {
      await loadViewers(); // Listeyi yenile
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Güncelleme başarısız";
      notifyListeners();
      return false;
    }
  }

  // 5. Durum Değiştir (Aktif/Pasif)
  Future<bool> updateStatus(String id, bool isActive) async {
    // Optimistic Update: Önce UI'da değiştiriyoruz, hata olursa geri alacağız.
    final index = viewers.indexWhere((u) => u.id == id);
    if (index != -1) {
      viewers[index].isActive = isActive;
      notifyListeners();
    }

    // Backend isteği
    // Not: API [FromBody] bool bekliyorsa Flutter Dio'da direkt body olarak gönderiyoruz.
    final result = await _api.patch<String>("$_endpoint/status/$id", isActive);

    if (!result.isSuccess) {
      // Hata oldu, eski haline getir
      if (index != -1) {
        viewers[index].isActive = !isActive;
        errorMessage = "Durum değiştirilemedi";
        notifyListeners();
      }
      return false;
    }
    return true;
  }

  // 6. Sil
  Future<bool> deleteViewer(String id) async {
    isLoading = true;
    notifyListeners();

    final result = await _api.delete<String>("$_endpoint/$id");

    if (result.isSuccess) {
      viewers.removeWhere((u) => u.id == id);
      isLoading = false;
      notifyListeners();
      return true;
    } else {
      isLoading = false;
      errorMessage = result.errors?.first ?? "Silme işlemi başarısız";
      notifyListeners();
      return false;
    }
  }
}
