class VisitorProductSettingDto {
  String visitorId;
  String tenantProductId;
  double? specialBuyMultiplier;
  double? specialSellMultiplier;
  double? specialAddonAmount;

  VisitorProductSettingDto({
    required this.visitorId,
    required this.tenantProductId,
    this.specialBuyMultiplier,
    this.specialSellMultiplier,
    this.specialAddonAmount,
  });

  Map<String, dynamic> toJson() => {
    "visitorId": visitorId,
    "tenantProductId": tenantProductId,
    // Eğer değer null ise null gönder, Backend bunu "Varsayılan" olarak algılar.
    "specialBuyMultiplier": specialBuyMultiplier,
    "specialSellMultiplier": specialSellMultiplier,
    "specialAddonAmount": specialAddonAmount,
  };
}

class VisitorProductSettingResponse {
  String tenantProductId;
  double? specialBuyMultiplier;
  double? specialSellMultiplier;
  double? specialAddonAmount;

  VisitorProductSettingResponse({
    required this.tenantProductId,
    this.specialBuyMultiplier,
    this.specialSellMultiplier,
    this.specialAddonAmount,
  });

  factory VisitorProductSettingResponse.fromJson(Map<String, dynamic> json) {
    return VisitorProductSettingResponse(
      tenantProductId: json["tenantProductId"] ?? "",
      specialBuyMultiplier: (json["specialBuyMultiplier"] as num?)?.toDouble(),
      specialSellMultiplier: (json["specialSellMultiplier"] as num?)
          ?.toDouble(),
      specialAddonAmount: (json["specialAddonAmount"] as num?)?.toDouble(),
    );
  }
}
