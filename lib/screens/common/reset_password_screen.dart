import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER ALANI (DÜZ & TAM GENİŞLİK) ---
            Container(
              height: size.height * 0.30, // Ekranın %30'u
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primaryColor, const Color(0xFF243B55)],
                ),
                // 🔥 KESİNLİKLE ROUNDED YOK (DÜZ)
                border: const Border(
                  bottom: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Geri Dön Butonu
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Ortadaki İkon ve Yazı
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🔥 YUVARLAK ARKA PLAN KALDIRILDI, SADECE İKON
                          const Icon(
                            Icons.lock_reset_rounded,
                            size: 70, // Biraz büyüttük ki daha net görünsün
                            color: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Şifre Sıfırlama",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900, // Kalın
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. FORM ALANI ---
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Şifrenizi mi unuttunuz?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "E-posta adresinizi girin, size yeni şifrenizi içeren bir e-posta göndereceğiz.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // E-MAIL INPUT (Modern Tasarım)
                  _buildModernTextField(
                    controller: _emailController,
                    label: "E-posta Adresi",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 30),

                  // GÖNDER BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: _primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_emailController.text.isEmpty) {
                                Fluttertoast.showToast(
                                  msg: "Lütfen e-posta giriniz",
                                  backgroundColor: Colors.orange,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                                return;
                              }

                              FocusScope.of(context).unfocus();

                              String? error = await authProvider.forgotPassword(
                                _emailController.text,
                              );

                              if (error == null) {
                                Fluttertoast.showToast(
                                  msg:
                                      "E-posta gönderildi! Lütfen gelen kutunuzu kontrol edin.",
                                  backgroundColor: Colors.green,
                                  toastLength: Toast.LENGTH_LONG,
                                );

                                // Başarılı olunca 2 saniye bekleyip geri at
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (context.mounted) Navigator.pop(context);
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg: error,
                                  backgroundColor: Colors.red,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              }
                            },
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
                              "GÖNDER",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 MODERN TEXTFIELD HELPER
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
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
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.transparent, // Container rengini kullanır
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
}
