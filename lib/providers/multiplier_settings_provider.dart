import 'package:flutter/material.dart';
import '../services/base_api_service.dart'; // BaseApiService yolunu kendine göre ayarla
import '../models/multiplier_models.dart'; // Modellerin olduğu dosya
import '../models/service_result.dart'; // ServiceResult modelin

class MultiplierSettingsProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();

  bool isLoading = false;
  String? errorMessage;

  // Veriler
  Map<String, List<TenantProduct>> groupedProducts = {};
  List<Category> categories = [];

  // --- 1. VERİLERİ YÜKLE ---
  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.get<List<dynamic>>("customer/product/list"),
        _api.get<List<dynamic>>("customer/product/categories"),
      ]);

      final productResult = results[0] as ServiceResult<List<dynamic>>;
      final categoryResult = results[1] as ServiceResult<List<dynamic>>;

      if (productResult.isSuccess && categoryResult.isSuccess) {
        categories = (categoryResult.data ?? [])
            .map((e) => Category.fromJson(e))
            .toList();

        final products = (productResult.data ?? [])
            .map((e) => TenantProduct.fromJson(e))
            .toList();

        _groupData(products);
      } else {
        errorMessage =
            productResult.errors?.first ??
            categoryResult.errors?.first ??
            "Veri yüklenemedi";
      }
    } catch (e) {
      errorMessage = "Beklenmedik hata: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. YENİ ÜRÜN EKLE ---
  Future<bool> createProduct(CreateProductDto dto) async {
    isLoading = true;
    notifyListeners();

    final result = await _api.post("customer/product/create", dto.toJson());

    isLoading = false;

    if (result.isSuccess) {
      await loadData();
      notifyListeners();
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Oluşturulamadı";
      notifyListeners();
      return false;
    }
  }

  // --- 3. ÜRÜN GÜNCELLEME (TEKLİ VEYA ÇOKLU - ANGULAR MANTIĞI) ---
  // Angular'daki saveEditedProduct ve saveAll burayı kullanır.
  // Tek bir ürün güncellenecekse liste içinde tek eleman gönderilir.
  Future<bool> updateProducts(List<TenantProduct> products) async {
    isLoading = true;
    notifyListeners();

    // DTO Dönüşümü ve Kredi Kartı Kontrolü
    List<Map<String, dynamic>> updatePayload = products.map((item) {
      // Eğer kategori "Kredi Kartı" ise alış çarpanını zorla 0 yapıyoruz
      if (item.categoryName == "Kredi Kartı") {
        item.buyMultiplier = 0;
      }

      // Backend'in beklediği UpdateTenantProductDto formatına çeviriyoruz
      return {
        "id": item.id,
        "name": item.name,
        "categoryId": item.categoryId, // Modelde categoryId olduğundan emin ol
        "sourceKey": item.sourceKey,
        "buyMultiplier": item.buyMultiplier,
        "sellMultiplier": item.sellMultiplier,
        "addonAmount": item.addonAmount,
        "isActive": item.isActive,
      };
    }).toList();

    // Angular'daki gibi 'update-all' endpointine atıyoruz
    final result = await _api.put("customer/product/update-all", updatePayload);

    isLoading = false;

    if (result.isSuccess) {
      await loadData(); // Listeyi yenile
      notifyListeners();
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Güncellenemedi";
      notifyListeners();
      return false;
    }
  }

  // --- 4. SİLME ---
  Future<void> deleteProduct(String id) async {
    _removeProductFromLocal(id); // UI'dan hemen sil

    await _api.delete("customer/product/$id");
    // Hata yönetimi gerekirse eklenebilir ama genelde silme işlemi başarılı kabul edilir.
  }

  // --- 5. SIRALAMA ---
  Future<void> updateSortOrder(String categoryName) async {
    if (!groupedProducts.containsKey(categoryName)) return;

    final items = groupedProducts[categoryName]!;

    List<Map<String, dynamic>> orderPayload = items.asMap().entries.map((
      entry,
    ) {
      return {"productId": entry.value.id, "newIndex": entry.key + 1};
    }).toList();

    await _api.patch("customer/product/reorder", orderPayload);
  }

  // --- LOCAL HELPERS ---
  void reorderLocalList(String category, int oldIndex, int newIndex) {
    if (!groupedProducts.containsKey(category)) return;
    final list = groupedProducts[category]!;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    notifyListeners();
    updateSortOrder(category);
  }

  void _groupData(List<TenantProduct> products) {
    groupedProducts.clear();
    for (var item in products) {
      // Backendden categoryName gelmezse veya null ise 'Diğer' yap
      String catName = item.categoryName.isNotEmpty
          ? item.categoryName
          : 'Diğer';

      if (!groupedProducts.containsKey(catName)) {
        groupedProducts[catName] = [];
      }
      groupedProducts[catName]!.add(item);
    }
    groupedProducts.forEach((key, list) {
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    });
  }

  void _removeProductFromLocal(String id) {
    groupedProducts.forEach((key, list) {
      list.removeWhere((item) => item.id == id);
    });
    notifyListeners();
  }
}
