import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/viewer_provider.dart';
import '../../models/viewer_dtos.dart';

class ViewerAddScreen extends StatefulWidget {
  const ViewerAddScreen({super.key});

  @override
  State<ViewerAddScreen> createState() => _ViewerAddScreenState();
}

class _ViewerAddScreenState extends State<ViewerAddScreen> {
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViewerProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // Arka plan beyaz
      appBar: AppBar(
        title: const Text(
          "YENİ KULLANICI",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Kalın Font
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        // 🔥 HEADER GRADIENT
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryColor, const Color(0xFF243B55)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ALTINDAKİ BİLGİ ALANI (DÜZ & TAM GENİŞLİK) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // AppBar ile bütünlük sağlayan renkler
                  colors: [const Color(0xFF243B55), const Color(0xFF243B55)],
                ),
                // Düz çizgi
                border: const Border(
                  bottom: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 28,
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "Sisteme erişim sağlayacak yeni bir alt kullanıcı oluşturun.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- FORM ALANI ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  // Modern Gölge
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kişisel Bilgiler",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "Ad Soyad",
                        _fullNameCtrl,
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "Kullanıcı Adı",
                        _usernameCtrl,
                        Icons.alternate_email_rounded,
                        minLength: 3,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "E-Posta",
                        _emailCtrl,
                        Icons.email_outlined,
                        isEmail: true,
                      ),

                      const SizedBox(height: 25),
                      const Divider(),
                      const SizedBox(height: 15),

                      const Text(
                        "Güvenlik",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildPasswordField("Şifre", _passwordCtrl),
                      const SizedBox(height: 15),
                      _buildPasswordField(
                        "Şifre Tekrar",
                        _confirmPassCtrl,
                        isConfirm: true,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: _primaryColor.withOpacity(0.4),
                          ),
                          onPressed: provider.isLoading ? null : _submit,
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "KAYDET",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final dto = CreateUserDto(
        fullName: _fullNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final success = await context.read<ViewerProvider>().createViewer(dto);

      if (success && mounted) {
        Navigator.pop(context); // Listeye dön
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kullanıcı oluşturuldu"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ViewerProvider>().errorMessage ?? "Hata",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isEmail = false,
    int minLength = 0,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "$label zorunludur";
        if (minLength > 0 && value.length < minLength)
          return "En az $minLength karakter olmalı";
        if (isEmail && !value.contains('@'))
          return "Geçerli bir e-posta giriniz";
        return null;
      },
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl, {
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: _obscurePass,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: _primaryColor.withOpacity(0.7),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePass
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePass = !_obscurePass),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (isConfirm && value != _passwordCtrl.text)
          return "Şifreler uyuşmuyor";
        if (!isConfirm && (value == null || value.length < 6))
          return "Şifre en az 6 karakter olmalı";
        return null;
      },
    );
  }
}
