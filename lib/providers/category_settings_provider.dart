import 'package:flutter/material.dart';
import '../services/base_api_service.dart';
import '../models/multiplier_models.dart';
import '../models/service_result.dart';

class CategorySettingsProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();

  bool isLoading = false;
  String? errorMessage;
  List<Category> categories = [];

  // --- 1. KATEGORİLERİ YÜKLE ---
  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.get<List<dynamic>>("customer/category/list");
      final categoryResult = result as ServiceResult<List<dynamic>>;

      if (categoryResult.isSuccess) {
        categories = (categoryResult.data ?? [])
            .map((e) => Category.fromJson(e))
            .toList();
        categories.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      } else {
        errorMessage =
            categoryResult.errors?.first ?? "Kategoriler yüklenemedi";
      }
    } catch (e) {
      errorMessage = "Hata: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. KATEGORİ İSMİ GÜNCELLE ---
  Future<bool> updateCategoryName(String id, String newName) async {
    isLoading = true;
    notifyListeners();

    final String endpoint = "customer/category/update/$id";
    final Map<String, dynamic> body = {"name": newName};

    try {
      // Backend { "data": "Mesaj" } döndüğü için <String> kullanıyoruz.
      final result = await _api.put<String>(endpoint, body);

      isLoading = false;

      if (result.isSuccess) {
        // Listeyi yerel olarak güncelle
        final index = categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          final oldItem = categories[index];
          categories[index] = Category(
            id: oldItem.id,
            name: newName,
            orderIndex: oldItem.orderIndex,
          );
        }

        notifyListeners();
        return true;
      } else {
        errorMessage = result.errors?.first ?? "Güncelleme başarısız.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Hata: $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
