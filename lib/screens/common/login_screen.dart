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
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // Şifre her zaman gizli
  final bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
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
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. LOGO ALANI
              Image.asset(
                "assets/images/sarfiyumlogo.png",
                height: 60, // Biraz büyüttük
              ),

              const SizedBox(height: 20),

              // 2. BAŞLIKLAR
              Text(
                "Hoş Geldiniz",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900, // Kalın
                  color: _primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Hesabınıza giriş yapın",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // 3. KULLANICI ADI (Modern Input)
              _buildModernTextField(
                controller: _userController,
                label: "Kullanıcı Adı",
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 20),

              // 4. ŞİFRE ALANI (Modern Input)
              _buildModernTextField(
                controller: _passController,
                label: "Şifre",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),

              // ŞİFREMİ UNUTTUM
              Align(
                alignment: Alignment.centerRight,
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
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 5. GİRİŞ BUTONU (Modern Stil)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: _primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleLogin(authProvider),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "GİRİŞ YAP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "v1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 MODERN TEXTFIELD HELPER
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Hafif gri zemin
        borderRadius: BorderRadius.circular(16),
        // Hafif gölge
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          filled: true,
          fillColor: Colors.transparent, // Container rengi kullanılsın
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // 🔥 GİRİŞ VE YÖNLENDİRME FONKSİYONU (AYNEN KORUNDU)
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
        Widget targetScreen;

        if (roles.any((r) => r.toLowerCase() == 'admin')) {
          targetScreen = const AdminDashboard();
        } else if (roles.any(
          (r) => r.toLowerCase() == 'user' || r.toLowerCase() == 'viewer',
        )) {
          targetScreen = const UserDashboard();
        } else {
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
