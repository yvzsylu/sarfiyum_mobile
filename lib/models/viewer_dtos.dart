// 1. LİSTELEME İÇİN
class UserListDto {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String? tenantId;
  final String? tenantName;
  bool isActive; // Mutable (Değiştirilebilir) yaptık çünkü switch ile değişecek
  final List<String> roles;

  UserListDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.tenantId,
    this.tenantName,
    required this.isActive,
    required this.roles,
  });

  factory UserListDto.fromJson(Map<String, dynamic> json) {
    return UserListDto(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      tenantId: json['tenantId'],
      tenantName: json['tenantName'],
      isActive: json['isActive'] ?? false,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}

// 2. EKLEME İÇİN
class CreateUserDto {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String roleId;
  final String? tenantId;

  CreateUserDto({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.roleId = 'dummy', // Backend otomatik atıyor demiştin
    this.tenantId = 'dummy',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'roleId': roleId,
      'tenantId': tenantId,
    };
  }
}

// 3. GÜNCELLEME İÇİN
class UpdateUserDto {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? password;
  final String roleId;
  final String? tenantId;
  final bool isActive;

  UpdateUserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.password,
    this.roleId = 'dummy',
    this.tenantId = 'dummy',
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roleId': roleId,
      'tenantId': tenantId,
      'isActive': isActive,
    };

    // Şifre boşsa gönderme (Backend null check yapıyorsa)
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    } else {
      data['password'] = null;
    }

    return data;
  }
}

// 4. DETAY İÇİN
class UserDetailDto {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final bool isActive;
  final String? tenantId;
  final List<String> roles;

  UserDetailDto({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.isActive,
    this.tenantId,
    required this.roles,
  });

  factory UserDetailDto.fromJson(Map<String, dynamic> json) {
    return UserDetailDto(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      isActive: json['isActive'] ?? false,
      tenantId: json['tenantId'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}
