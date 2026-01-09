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
      appBar: AppBar(
        title: const Text("Yeni Kullanıcı Ekle"),
        backgroundColor: const Color(0xFF161A30), // Lacivert Header
        foregroundColor: Colors.white, // Beyaz Yazı
        elevation: 0,
        scrolledUnderElevation: 0, // 👈 ÖNEMLİ
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Ad Soyad", _fullNameCtrl, Icons.person),
              const SizedBox(height: 15),
              _buildTextField(
                "Kullanıcı Adı",
                _usernameCtrl,
                Icons.alternate_email,
                minLength: 3,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "E-Posta",
                _emailCtrl,
                Icons.email,
                isEmail: true,
              ),
              const SizedBox(height: 25),
              const Text(
                "Güvenlik",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF161A30),
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
                    backgroundColor: const Color(0xFF0D1B46),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("KAYDET"),
                ),
              ),
            ],
          ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscurePass = !_obscurePass),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
