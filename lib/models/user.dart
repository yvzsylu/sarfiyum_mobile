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

  // JWT Payload'ından User nesnesi üretir
  factory User.fromJwt(Map<String, dynamic> payload, String token) {
    return User(
      userId: payload['userId'],
      username: payload['sub'], // 'sub' genelde username'dir
      email: payload['email'],
      fullName: payload['fullName'],
      tenantId: payload['tenantId'],
      tenantName: payload['tenantName'],
      tenantLogoUrl: payload['tenantLogoUrl'], // Göreceli yol gelir: /uploads/logos/...
      subscriptionEndDate: payload['subscriptionEndDate'] != null 
          ? DateTime.tryParse(payload['subscriptionEndDate']) 
          : null,
      roles: _parseRoles(payload['roles']),
      token: token,
    );
  }

  // Role bazen "User" (String) bazen ["Admin", "User"] (List) gelebilir.
  static List<String> _parseRoles(dynamic roleData) {
    if (roleData == null) return ['Visitor'];
    
    if (roleData is List) {
      return roleData.map((e) => e.toString()).toList();
    } else if (roleData is String) {
      // Virgülle ayrılmış birden fazla rol gelme ihtimaline karşı (Admin,User gibi)
      if (roleData.contains(',')) {
        return roleData.split(',').map((e) => e.trim()).toList();
      }
      return [roleData];
    }
    return ['Visitor'];
  }
  
  // Profil fotosu için tam URL'i veren yardımcı get metodu
  String get fullLogoUrl {
    if (tenantLogoUrl == null) return "";
    return "https://sarfiyum.com$tenantLogoUrl";
  }
}