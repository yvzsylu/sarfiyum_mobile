import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sarfiyum_mobile/screens/common/reset_password_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:sarfiyum_mobile/services/secure_storage_service.dart';

// Dashboard importları
import 'package:sarfiyum_mobile/screens/user/user_dashboard.dart';
import 'package:sarfiyum_mobile/screens/admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // 🔥 Şifre gösterme özelliği iptal, her zaman gizli.
  final bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz kayıtlı bilgileri kontrol et
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    // Viewer için kayıtlı bilgileri doldur
    final credentials = await SecureStorageService().getCredentials();
    if (credentials['username'] != null && credentials['password'] != null) {
      if (mounted) {
        setState(() {
          _userController.text = credentials['username']!;
          _passController.text = credentials['password']!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. LOGO ALANI
                Image.asset("assets/images/sarfiyumlogo.png", height: 40),

                const SizedBox(height: 10),

                // 2. ALT BAŞLIK
                Text(
                  "Hesabınıza giriş yapın",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),

                // 3. KULLANICI ADI
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF222831),
                    ),
                    labelText: "Kullanıcı Adı",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF222831),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. ŞİFRE ALANI (GÖZ İKONU YOK)
                TextField(
                  controller: _passController,
                  obscureText: _obscureText, // Hep true
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF222831),
                    ),
                    // suffixIcon kaldırıldı
                    labelText: "Şifre",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF222831),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 5. GİRİŞ BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161A30),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleLogin(authProvider),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "GİRİŞ YAP",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // 6. ŞİFREMİ UNUTTUM
                Align(
                  alignment: Alignment.topCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Şifrenizi mi unuttunuz?",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "v1.0.0",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 GİRİŞ VE YÖNLENDİRME FONKSİYONU
  // 🔥 GÜNCELLENMİŞ NAVIGASYON MANTIĞI
  Future<void> _handleLogin(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();

    String? error = await authProvider.login(
      _userController.text.trim(),
      _passController.text.trim(),
    );

    if (error == null) {
      Fluttertoast.showToast(
        msg: "Giriş Başarılı, Yönlendiriliyorsunuz...",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (mounted && authProvider.user != null) {
        final roles = authProvider.user!.roles ?? [];

        // Debug için konsola basalım
        print("➡️ Yönlendirme Kontrolü - Roller: $roles");

        Widget targetScreen;

        // 1. ADMIN KONTROLÜ
        if (roles.any((r) => r.toLowerCase() == 'admin')) {
          print("➡️ Admin tespit edildi -> AdminDashboard");
          targetScreen = const AdminDashboard();
        }
        // 2. USER veya VIEWER KONTROLÜ (Büyük/Küçük harf duyarsız)
        else if (roles.any(
          (r) => r.toLowerCase() == 'user' || r.toLowerCase() == 'viewer',
        )) {
          print("➡️ User/Viewer tespit edildi -> UserDashboard");
          targetScreen = const UserDashboard();
        }
        // 3. FALLBACK (Hata olmaması için, giriş yaptıysa UserDashboard'ı varsayılan yapalım)
        else {
          print(
            "➡️ Tanımsız Rol (Visitor?) -> Varsayılan olarak UserDashboard açılıyor.",
          );
          // Eskiden VisitorDashboard idi, şimdi UserDashboard yapalım ki sayfa açılsın.
          targetScreen = const UserDashboard();
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => targetScreen),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }
}
