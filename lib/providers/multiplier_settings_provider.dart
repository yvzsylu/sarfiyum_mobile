import 'package:flutter/material.dart';
import '../services/base_api_service.dart';
import '../models/multiplier_models.dart';
import '../models/service_result.dart';

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

    // DTO'nun toJson metodunda showOnWeb/showOnMobile olduğundan emin ol
    final result = await _api.post("customer/product/create", dto.toJson());

    isLoading = false;

    if (result.isSuccess) {
      await loadData(); // Listeyi yenile
      notifyListeners();
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Oluşturulamadı";
      notifyListeners();
      return false;
    }
  }

  // --- 3. KATALOG LİSTESİNİ ÇEK ---
  Future<List<SystemCatalogItem>> getSystemCatalog() async {
    try {
      final dynamic response = await _api.get<dynamic>(
        "customer/product/catalog-list",
      );

      if (response is List) {
        return (response as List)
            .map((e) => SystemCatalogItem.fromJson(e))
            .toList();
      }

      if (response is ServiceResult) {
        if (response.isSuccess &&
            response.data != null &&
            response.data is List) {
          final list = response.data as List;
          return list.map((e) => SystemCatalogItem.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Katalog çekme hatası: $e");
      return [];
    }
  }

  // --- 4. ÜRÜN GÜNCELLEME (TOPLU) ---
  Future<bool> updateProducts(List<TenantProduct> products) async {
    isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> updatePayload = products.map((item) {
      if (item.categoryName == "Kredi Kartı") {
        item.buyMultiplier = 0;
      }
      return {
        "id": item.id,
        "name": item.name,
        "categoryId": item.categoryId,
        "sourceKey": item.sourceKey,
        "buyMultiplier": item.buyMultiplier,
        "sellMultiplier": item.sellMultiplier,
        "addonAmount": item.addonAmount,
        "isActive": item.isActive,
        // 🔥 GÜNCELLEME: Platform ayarları eklendi
        "showOnWeb": item.showOnWeb,
        "showOnMobile": item.showOnMobile,
      };
    }).toList();

    final result = await _api.put("customer/product/update-all", updatePayload);

    isLoading = false;

    if (result.isSuccess) {
      await loadData();
      notifyListeners();
      return true;
    } else {
      errorMessage = result.errors?.first ?? "Güncellenemedi";
      notifyListeners();
      return false;
    }
  }

  // --- 🔥 5. PLATFORM TOGGLE METODLARI (YENİ) ---
  Future<void> toggleWebStatus(String id) async {
    await _api.patch("customer/product/toggle-web/$id", {});
    // UI zaten optimistic update ile güncellendiği için burada loadData yapmaya gerek yok
    // ama istersen yapabilirsin.
  }

  Future<void> toggleMobileStatus(String id) async {
    await _api.patch("customer/product/toggle-mobile/$id", {});
  }

  // --- 6. SİLME ---
  Future<void> deleteProduct(String id) async {
    _removeProductFromLocal(id);
    await _api.delete("customer/product/$id");
  }

  // --- 7. SIRALAMA ---
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

  // --- YARDIMCI METODLAR ---
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
