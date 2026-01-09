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
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Geri dön
        ),
        title: const Text(
          "Şifre Sıfırlama",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Sola yaslı
          children: [
            const Text(
              "Şifrenizi mi unuttunuz?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF161A30),
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

            // E-MAIL INPUT
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF161A30),
                ),
                labelText: "E-posta Adresi",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF161A30),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // GÖNDER BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161A30),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (_emailController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Lütfen e-posta giriniz",
                            backgroundColor: Colors.orange,
                            toastLength: Toast.LENGTH_SHORT, // DÜZELTİLDİ
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
                            toastLength: Toast
                                .LENGTH_LONG, // DÜZELTİLDİ (Eskisi: length)
                          );

                          // İstersen başarılı olunca 2 saniye bekleyip login ekranına geri atabilirsin:
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) Navigator.pop(context);
                          });
                        } else {
                          Fluttertoast.showToast(
                            msg: error,
                            backgroundColor: Colors.red,
                            toastLength: Toast.LENGTH_LONG, // DÜZELTİLDİ
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "GÖNDER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
