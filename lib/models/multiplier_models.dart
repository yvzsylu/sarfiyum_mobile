class Category {
  final String id;
  final String name;
  final int orderIndex;

  Category({
    required this.id,
    required this.name,
    required this.orderIndex,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
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
  });

  factory TenantProduct.fromJson(Map<String, dynamic> json) {
    return TenantProduct(
      id: json['id'],
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

  CreateProductDto({
    required this.name,
    required this.categoryId,
    required this.sourceKey,
    this.buyMultiplier = 1.0,
    this.sellMultiplier = 1.0,
    this.addonAmount = 0.0,
    this.orderIndex = 99,
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
    };
  }
}