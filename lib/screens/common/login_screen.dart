import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sarfiyum_mobile/screens/common/reset_password_screen.dart';
import '../../providers/auth_provider.dart';

// 🔥 ÖNEMLİ: Dashboard ekranının olduğu dosyayı import ettik.
// Eğer dosya yolun farklıysa (örneğin main.dart ise) burayı düzelt.
import 'package:sarfiyum_mobile/screens/user/user_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _obscureText = true;

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

                // 4. ŞİFRE ALANI
                TextField(
                  controller: _passController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF222831),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
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
                        : () async {
                            // Klavyeyi kapat
                            FocusScope.of(context).unfocus();

                            // Giriş işlemini başlat
                            String? error = await authProvider.login(
                              _userController.text,
                              _passController.text,
                            );

                            // Hata yoksa (Giriş Başarılı)
                            if (error == null) {
                              Fluttertoast.showToast(
                                msg: "Giriş Başarılı, Yönlendiriliyorsunuz...",
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );

                              // 🔥 YÖNLENDİRME KODU BURADA 🔥
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const UserDashboard(),
                                  ),
                                );
                              }
                            } else {
                              // Hata varsa
                              Fluttertoast.showToast(
                                msg: error,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                              );
                            }
                          },
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

                // VERSİYON
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
}
