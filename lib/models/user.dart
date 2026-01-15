class User {
  String? userId;
  String? username;
  String? email;
  String? fullName;
  String? tenantId;
  String? tenantName;
  String? tenantLogoUrl;
  DateTime? subscriptionEndDate;
  List<String>? roles;
  String? token;

  User({
    this.userId,
    this.username,
    this.email,
    this.fullName,
    this.tenantId,
    this.tenantName,
    this.tenantLogoUrl,
    this.subscriptionEndDate,
    this.roles,
    this.token,
  });

  factory User.fromJwt(Map<String, dynamic> payload, String token) {
    // 🔥 DEBUG İÇİN KONSOLA BASIYORUZ (Debug Console'a bak)
    print("---------------- JWT ANALİZİ ----------------");
    print("Gelen Payload: $payload");

    // Olası tüm rol anahtarlarını kontrol edelim
    var rawRoles =
        payload['roles'] ??
        payload['role'] ??
        payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    print("Ham Rol Verisi (Raw): $rawRoles");

    final parsedRoles = _parseRoles(rawRoles);
    print("İşlenmiş Roller (Parsed): $parsedRoles");
    print("---------------------------------------------");

    return User(
      userId: payload['userId'],
      username: payload['sub'],
      email: payload['email'],
      fullName: payload['fullName'],
      tenantId: payload['tenantId'],
      tenantName: payload['tenantName'],
      tenantLogoUrl: payload['tenantLogoUrl'],
      subscriptionEndDate: payload['subscriptionEndDate'] != null
          ? DateTime.tryParse(payload['subscriptionEndDate'])
          : null,
      roles: parsedRoles,
      token: token,
    );
  }

  // Yardımcı Getter (Büyük/Küçük harf duyarsız kontrol)
  bool get isViewer {
    if (roles == null) return false;
    return roles!.any((r) => r.toLowerCase() == 'viewer');
  }

  static List<String> _parseRoles(dynamic roleData) {
    if (roleData == null) return ['Visitor'];

    List<String> parsedList = [];

    if (roleData is List) {
      parsedList = roleData.map((e) => e.toString().trim()).toList();
    } else if (roleData is String) {
      if (roleData.contains(',')) {
        parsedList = roleData.split(',').map((e) => e.trim()).toList();
      } else {
        parsedList = [roleData.trim()];
      }
    }

    if (parsedList.isEmpty) return ['Visitor'];
    return parsedList;
  }

  String get fullLogoUrl {
    if (tenantLogoUrl == null) return "";
    return "https://sarfiyum.com$tenantLogoUrl";
  }
}
