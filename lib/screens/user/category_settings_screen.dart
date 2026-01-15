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
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF161A30),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "Ürün kategorilerinin isimlerini buradan özelleştirebilirsiniz.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                        const Icon(
                          Icons.list_alt,
                          size: 48,
                          color: Colors.grey,
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
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final item = provider.categories[index];
                    return _buildCategoryCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF161A30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "${item.orderIndex}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF161A30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showEditDialog(context, item),
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF161A30)),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥🔥🔥 DÜZELTİLEN KISIM BURASI 🔥🔥🔥
  void _showEditDialog(BuildContext context, Category item) {
    final controller = TextEditingController(text: item.name);

    // 1. Provider'ı şimdiden alıyoruz (Dialog açılmadan önce)
    final provider = context.read<CategorySettingsProvider>();

    // 2. Messenger'ı şimdiden alıyoruz (Dialog açılmadan önce)
    // Bu sayede "context deactivated" hatası almayız çünkü context'i kullanmayacağız.
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Kategori Düzenle"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Kategori Adı",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF161A30),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final newName = controller.text.trim();

              // Dialogu kapat
              Navigator.pop(ctx);

              // 3. Yukarıda aldığımız 'provider'ı kullanıyoruz
              final success = await provider.updateCategoryName(
                item.id,
                newName,
              );

              // 4. Yukarıda aldığımız 'messenger'ı kullanıyoruz
              // context.mounted kontrolü yapmaya bile gerek kalmaz ama yine de yapalım.
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
