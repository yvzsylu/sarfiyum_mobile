class UserProfileDto {
  // Kullanıcı Bilgileri
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? phoneNumber;
  final bool isUserActive;
  final List<String> roles;

  // Tenant (Firma) Bilgileri
  final String? tenantId;
  final String? tenantName;
  final String? tenantTaxNumber;
  final String? tenantPhoneNumber;
  final String? tenantWebsite;
  String? tenantLogoUrl; // Değiştirilebilir (Upload sonrası)
  final bool isTenantActive;
  final DateTime? tenantCreatedAt;

  // Adres
  final String? tenantCity;
  final String? tenantDistrict;
  final String? tenantCountry;
  final String? tenantZipCode;
  final String? tenantFullAddress;

  UserProfileDto({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.isUserActive,
    required this.roles,
    this.tenantId,
    this.tenantName,
    this.tenantTaxNumber,
    this.tenantPhoneNumber,
    this.tenantWebsite,
    this.tenantLogoUrl,
    this.isTenantActive = false,
    this.tenantCreatedAt,
    this.tenantCity,
    this.tenantDistrict,
    this.tenantCountry,
    this.tenantZipCode,
    this.tenantFullAddress,
  });

  // JSON'dan Model Üretme
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      isUserActive: json['isUserActive'] ?? false,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      tenantId: json['tenantId'],
      tenantName: json['tenantName'],
      tenantTaxNumber: json['tenantTaxNumber'],
      tenantPhoneNumber: json['tenantPhoneNumber'],
      tenantWebsite: json['tenantWebsite'],
      tenantLogoUrl: json['tenantLogoUrl'],
      isTenantActive: json['isTenantActive'] ?? false,
      tenantCreatedAt: json['tenantCreatedAt'] != null
          ? DateTime.parse(json['tenantCreatedAt'])
          : null,
      tenantCity: json['tenantCity'],
      tenantDistrict: json['tenantDistrict'],
      tenantCountry: json['tenantCountry'],
      tenantZipCode: json['tenantZipCode'],
      tenantFullAddress: json['tenantFullAddress'],
    );
  }

  // Baş harfleri alan getter (UI mantığı)
  String get initials {
    if (fullName.isEmpty) return '';
    var names = fullName.trim().split(' ');
    if (names.length > 1) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return names[0].substring(0, (names[0].length >= 2 ? 2 : 1)).toUpperCase();
  }
}
