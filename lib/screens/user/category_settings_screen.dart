import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarfiyum_mobile/models/multiplier_models.dart';
import 'package:sarfiyum_mobile/providers/category_settings_provider.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({super.key});

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategorySettingsProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "KATEGORİ AYARLARI",
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
      ),
      body: Column(
        children: [
          // --- HEADER ALTINDAKİ BİLGİ ALANI (DÜZ & SAĞA SOLA DAYALI) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // AppBar ile bütünlük sağlayan renkler
                colors: [const Color(0xFF243B55), const Color(0xFF243B55)],
              ),
              // 🔥 DÜZELTME: BorderRadius kaldırıldı (Dashboard tarzı düz yapı)
              border: const Border(
                bottom: BorderSide(
                  color: Colors.white10,
                  width: 1,
                ), // Hafif alt çizgi
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "Ürün kategorilerinin isimlerini buradan özelleştirebilirsiniz.",
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
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  );
                }
                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Hata: ${provider.errorMessage}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => provider.loadCategories(),
                          child: const Text("Tekrar Dene"),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Kategori bulunamadı.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () => provider.loadCategories(),
                          child: const Text("Yenile"),
                        ),
                      ],
                    ),
                  );
                }

                // Liste elemanları arasında padding 0 yapılarak sağa sola dayalı görünüm desteklenir
                return ListView.separated(
                  padding: EdgeInsets
                      .zero, // 🔥 Liste padding sıfırlandı (Dashboard gibi)
                  itemCount: provider.categories.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final item = provider.categories[index];
                    return _buildCategoryItem(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 LİSTE ELEMANI (Dashboard Listesi Tarzında)
  Widget _buildCategoryItem(BuildContext context, Category item) {
    return Container(
      color: Colors.white, // Kart yerine düz zemin
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Sıra Numarası Kutusu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: Text(
              "${item.orderIndex}",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Kategori Adı
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),

          // Düzenle Butonu
          InkWell(
            onTap: () => _showEditDialog(context, item),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.edit_rounded, color: _primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 EDIT DIALOG
  void _showEditDialog(BuildContext context, Category item) {
    final controller = TextEditingController(text: item.name);
    final provider = context.read<CategorySettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Kategori Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Kategori Adı",
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final newName = controller.text.trim();

              Navigator.pop(ctx);

              final success = await provider.updateCategoryName(
                item.id,
                newName,
              );

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Kategori güncellendi"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }
}
