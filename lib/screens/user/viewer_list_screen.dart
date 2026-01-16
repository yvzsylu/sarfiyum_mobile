import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/viewer_provider.dart';
import '../../widgets/custom_drawer.dart';
import 'viewer_add_screen.dart';
import 'viewer_edit_screen.dart';

class ViewerListScreen extends StatefulWidget {
  const ViewerListScreen({super.key});

  @override
  State<ViewerListScreen> createState() => _ViewerListScreenState();
}

class _ViewerListScreenState extends State<ViewerListScreen> {
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewerProvider>().loadViewers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViewerProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "KULLANICILAR",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Kalın Font (Standart)
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(
          0xFF27AE60,
        ), // Ekleme için Yeşil tonu veya Tema rengi
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViewerAddScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // --- HEADER ALTINDAKİ BİLGİ ALANI (DÜZ & TAM GENİŞLİK) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
                  Icons.people_outline,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "Sisteme erişimi olan alt kullanıcıları buradan yönetebilirsiniz.",
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

          // --- LİSTE ALANI ---
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : provider.viewers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Henüz kullanıcı eklenmemiş.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: provider.viewers.length,
                    itemBuilder: (context, index) {
                      final item = provider.viewers[index];
                      return _buildUserCard(context, item, provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔥 MODERN KULLANICI KARTI
  Widget _buildUserCard(
    BuildContext context,
    dynamic item, // Viewer modeli
    ViewerProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Modern Gölge
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar (Baş Harfler)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.fullName.isNotEmpty
                      ? item.fullName.substring(0, 1).toUpperCase()
                      : "?",
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // İsim ve Kullanıcı Adı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.username, // veya item.email
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Aktif/Pasif Switch
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: item.isActive,
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green.shade100,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade200,
                  onChanged: (val) {
                    provider.updateStatus(item.id, val);
                  },
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Alt Bilgi ve Aksiyonlar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // E-posta bilgisi (veya rol)
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Butonlar
              Row(
                children: [
                  // Düzenle
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewerEditScreen(userId: item.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sil
                  InkWell(
                    onTap: () => _confirmDelete(context, provider, item.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ViewerProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Emin misiniz?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Bu kullanıcı silinecek ve işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await provider.deleteViewer(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Kullanıcı silindi"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }
}
