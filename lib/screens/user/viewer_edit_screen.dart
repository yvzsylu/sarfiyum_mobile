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
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isActive = true;
  bool _isLoadingData = true;
  bool _obscurePass = true; // Şifre görünürlüğü için

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
      backgroundColor: Colors.white, // Arka plan beyaz
      appBar: AppBar(
        title: const Text(
          "KULLANICI DÜZENLE",
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
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
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
                        colors: [
                          const Color(0xFF243B55),
                          const Color(0xFF243B55),
                        ],
                      ),
                      border: const Border(
                        bottom: BorderSide(color: Colors.white10, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "Kullanıcı bilgilerini ve erişim durumunu buradan güncelleyebilirsiniz.",
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
                            // Aktif/Pasif Durumu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Hesap Durumu",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _isActive ? "Aktif" : "Pasif",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Switch(
                                      value: _isActive,
                                      activeColor: Colors.green,
                                      onChanged: (val) =>
                                          setState(() => _isActive = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 30),

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
                              "Şifre Değiştir (Opsiyonel)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Değiştirmek istemiyorsanız boş bırakın.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                                        "GÜNCELLE",
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
      obscureText: _obscurePass, // Değişken kullanılıyor
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
      validator: (val) {
        if (isConfirm && val != _passwordCtrl.text) return "Şifreler uyuşmuyor";
        // Düzenleme ekranında şifre zorunlu değil (boş bırakılabilir)
        return null;
      },
    );
  }
}
