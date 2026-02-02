import 'package:flutter/material.dart';
import '../services/base_api_service.dart';
import '../models/visitor_setting_models.dart';
import '../models/multiplier_models.dart';
import '../models/service_result.dart';

class VisitorSettingsProvider with ChangeNotifier {
  final BaseApiService _api = BaseApiService();

  bool isLoading = false;
  String? errorMessage;

  List<TenantProduct> allProducts = [];
  List<VisitorProductSettingResponse> userSettings = [];

  // UI'da göstereceğimiz gruplanmış liste
  Map<String, List<MergedProductItem>> groupedItems = {};

  // --- 1. VERİLERİ YÜKLE ---
  Future<void> loadData(String visitorId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.get<List<dynamic>>("customer/product/list"),
        _api.get<List<dynamic>>("customer/visitorsettings/list/$visitorId"),
      ]);

      final productResult = results[0] as ServiceResult<List<dynamic>>;
      final settingResult = results[1] as ServiceResult<List<dynamic>>;

      if (productResult.isSuccess) {
        allProducts = (productResult.data ?? [])
            .map((e) => TenantProduct.fromJson(e))
            .toList();
      }

      if (settingResult.isSuccess) {
        userSettings = (settingResult.data ?? [])
            .map((e) => VisitorProductSettingResponse.fromJson(e))
            .toList();
      }

      _mergeAndGroup();
    } catch (e) {
      debugPrint("Hata loadData: $e");
      errorMessage = "Veriler yüklenirken hata oluştu.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mergeAndGroup() {
    groupedItems.clear();

    for (var product in allProducts) {
      // Backend'den gelen ayarı bul (Yoksa boş bir nesne oluştur)
      var setting = userSettings.firstWhere(
        (s) => s.tenantProductId == product.id,
        orElse: () =>
            VisitorProductSettingResponse(tenantProductId: product.id),
      );

      var mergedItem = MergedProductItem(
        product: product,
        specialBuy: setting.specialBuyMultiplier,
        specialSell: setting.specialSellMultiplier,
        specialAddon: setting.specialAddonAmount,
      );

      String cat = product.categoryName.isNotEmpty
          ? product.categoryName
          : "Diğer";
      if (!groupedItems.containsKey(cat)) {
        groupedItems[cat] = [];
      }
      groupedItems[cat]!.add(mergedItem);
    }

    // Sıralama (OrderIndex'e göre)
    groupedItems.forEach((key, list) {
      list.sort((a, b) => a.product.orderIndex.compareTo(b.product.orderIndex));
    });
  }

  // --- 2. TOPLU KAYDETME (CRITICAL FIX) ---
  Future<bool> saveAllSettings(String visitorId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Tüm kategorilerdeki tüm ürünleri tek listeye indiriyoruz
      List<MergedProductItem> allItems = groupedItems.values
          .expand((x) => x)
          .toList();

      // Sadece "Özel Ayarı Olan" ürünleri filtrele.
      // Boş olanlar için istek atıp sunucuyu yormaya gerek yok (Zaten defaulttalar).
      // Eğer bir ayarı silmek istiyorsa kullanıcı zaten "Sıfırla" butonuna basar.
      List<MergedProductItem> itemsToSave = allItems
          .where((item) => item.hasSpecialSetting)
          .toList();

      if (itemsToSave.isEmpty) {
        isLoading = false;
        notifyListeners();
        return true; // Kaydedilecek bir şey yok, başarılı sayalım.
      }

      // Backend Upsert metodun tekil çalışıyor, bu yüzden Future.wait ile paralel istek atıyoruz.
      List<Future> futures = [];

      for (var item in itemsToSave) {
        final dto = VisitorProductSettingDto(
          visitorId: visitorId,
          tenantProductId: item.product.id,
          specialBuyMultiplier: item.specialBuy,
          specialSellMultiplier: item.specialSell,
          specialAddonAmount: item.specialAddon,
        );

        // BaseApi post isteği
        futures.add(_api.post("customer/visitorsettings/upsert", dto.toJson()));
      }

      // Tüm isteklerin bitmesini bekle
      await Future.wait(futures);

      // İşlem bitince verileri tazeleyelim ki her şey senkron olsun
      await loadData(visitorId);

      return true;
    } catch (e) {
      debugPrint("Hata saveAll: $e");
      errorMessage = "Kaydetme sırasında hata oluştu.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 3. SIFIRLAMA (DELETE) ---
  Future<bool> resetSetting(String visitorId, String productId) async {
    // isLoading yapmıyoruz ki ekran titremesin, kullanıcı sildiğini hemen görsün.
    final result = await _api.delete(
      "customer/visitorsettings/delete/$visitorId/$productId",
    );

    if (result.isSuccess) {
      // Başarılıysa, UI listesindeki (local state) ilgili item'ı temizle
      _clearLocalItem(productId);
      return true;
    } else {
      errorMessage = "Sıfırlama başarısız.";
      notifyListeners();
      return false;
    }
  }

  void _clearLocalItem(String productId) {
    // Tüm grupları gez, ilgili ürünü bul ve değerlerini null yap
    groupedItems.forEach((key, list) {
      try {
        var item = list.firstWhere((x) => x.product.id == productId);
        item.specialBuy = null;
        item.specialSell = null;
        item.specialAddon = null;
      } catch (e) {
        // Eleman bu grupta yok, devam et
      }
    });
    notifyListeners();
  }
}

// UI Yardımcı Modeli
class MergedProductItem {
  final TenantProduct product;
  double? specialBuy;
  double? specialSell;
  double? specialAddon;

  MergedProductItem({
    required this.product,
    this.specialBuy,
    this.specialSell,
    this.specialAddon,
  });

  // Eğer herhangi biri doluysa (null değilse), bu ürün "Özel Ayarlı" demektir.
  bool get hasSpecialSetting =>
      specialBuy != null || specialSell != null || specialAddon != null;
}
