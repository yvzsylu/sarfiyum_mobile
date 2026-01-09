import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/viewer_provider.dart';
import '../../models/viewer_dtos.dart';

class ViewerEditScreen extends StatefulWidget {
  final String userId;
  const ViewerEditScreen({super.key, required this.userId});

  @override
  State<ViewerEditScreen> createState() => _ViewerEditScreenState();
}

class _ViewerEditScreenState extends State<ViewerEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isActive = true;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _loadData();
  }

  void _loadData() async {
    final user = await context.read<ViewerProvider>().getViewerById(
      widget.userId,
    );
    if (user != null) {
      _fullNameCtrl.text = user.fullName;
      _usernameCtrl.text = user.username;
      _emailCtrl.text = user.email;
      _isActive = user.isActive;
      setState(() => _isLoadingData = false);
    } else {
      if (mounted) Navigator.pop(context); // Veri gelmezse çık
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViewerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Düzenle"),
        backgroundColor: const Color(0xFF161A30), // Lacivert Header
        foregroundColor: Colors.white, // Beyaz Yazı
        elevation: 0,
        scrolledUnderElevation: 0, // 👈 ÖNEMLİ
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Aktif Pasif Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Hesap Aktif",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildTextField("Ad Soyad", _fullNameCtrl, Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Kullanıcı Adı",
                      _usernameCtrl,
                      Icons.alternate_email,
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
                      "Şifre Değiştir (Opsiyonel)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF161A30),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Değiştirmek istemiyorsanız boş bırakın.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),

                    _buildPasswordField("Yeni Şifre", _passwordCtrl),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("GÜNCELLE"),
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
      final dto = UpdateUserDto(
        id: widget.userId,
        fullName: _fullNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        isActive: _isActive,
        password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      );

      final success = await context.read<ViewerProvider>().updateViewer(dto);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kullanıcı güncellendi"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // (Helper widget'lar Add Screen ile aynı mantıkta buraya da eklenmeli veya ortak bir widget yapılabilir)
  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (val) =>
          (val == null || val.isEmpty) ? "$label zorunludur" : null,
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl, {
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (val) {
        if (isConfirm && val != _passwordCtrl.text) return "Şifreler uyuşmuyor";
        return null;
      },
    );
  }
}
