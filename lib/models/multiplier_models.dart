class Category {
  final String id;
  final String name;
  final int orderIndex;

  Category({required this.id, required this.name, required this.orderIndex});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}

class TenantProduct {
  String id;
  String name;
  String categoryId;
  String categoryName;
  String sourceKey;
  double buyMultiplier;
  double sellMultiplier;
  double addonAmount;
  bool isActive;
  int orderIndex;

  // 🔥 YENİ ALANLAR (Platform Görünürlüğü)
  bool showOnWeb;
  bool showOnMobile;

  TenantProduct({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.sourceKey,
    this.buyMultiplier = 1.0,
    this.sellMultiplier = 1.0,
    this.addonAmount = 0.0,
    this.isActive = true,
    this.orderIndex = 0,
    this.showOnWeb = true, // Varsayılan true
    this.showOnMobile = true, // Varsayılan true
  });

  factory TenantProduct.fromJson(Map<String, dynamic> json) {
    return TenantProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? 'DİĞER',
      sourceKey: json['sourceKey'] ?? 'ALTIN',
      // API'den string veya int gelebilir, güvenli dönüşüm:
      buyMultiplier: _toDouble(json['buyMultiplier']) ?? 1.0,
      sellMultiplier: _toDouble(json['sellMultiplier']) ?? 1.0,
      addonAmount: _toDouble(json['addonAmount']) ?? 0.0,
      isActive: json['isActive'] ?? true,
      orderIndex: json['orderIndex'] ?? 999,
      // 🔥 JSON Parsing
      showOnWeb: json['showOnWeb'] ?? true,
      showOnMobile: json['showOnMobile'] ?? true,
    );
  }

  // "UpdateTenantProductDto" karşılığı (Toplu güncelleme için)
  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'sourceKey': sourceKey,
      'buyMultiplier': buyMultiplier,
      'sellMultiplier': sellMultiplier,
      'addonAmount': addonAmount,
      'isActive': isActive,
      // 🔥 Update Payload'una eklendi
      'showOnWeb': showOnWeb,
      'showOnMobile': showOnMobile,
    };
  }

  // Yardımcı metod: Sayı dönüşümü
  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val.replaceAll(',', '.'));
    return null;
  }
}

// "CreateTenantProductDto" karşılığı
class CreateProductDto {
  String name;
  String categoryId;
  String sourceKey;
  double buyMultiplier;
  double sellMultiplier;
  double addonAmount;
  int orderIndex;

  // 🔥 YENİ ALANLAR
  bool showOnWeb;
  bool showOnMobile;

  CreateProductDto({
    required this.name,
    required this.categoryId,
    required this.sourceKey,
    this.buyMultiplier = 1.0,
    this.sellMultiplier = 1.0,
    this.addonAmount = 0.0,
    this.orderIndex = 99,
    this.showOnWeb = true,
    this.showOnMobile = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'sourceKey': sourceKey,
      'buyMultiplier': buyMultiplier,
      'sellMultiplier': sellMultiplier,
      'addonAmount': addonAmount,
      'orderIndex': orderIndex,
      // 🔥 Create Payload'una eklendi
      'showOnWeb': showOnWeb,
      'showOnMobile': showOnMobile,
    };
  }
}

class SystemCatalogItem {
  final String sourceKey;
  final String name;

  SystemCatalogItem({required this.sourceKey, required this.name});

  factory SystemCatalogItem.fromJson(Map<String, dynamic> json) {
    return SystemCatalogItem(
      sourceKey: json['sourceKey'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
