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
      backgroundColor: Colors.grey[100],
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "KULLANICILAR",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0, // 👈 ÖNEMLİ
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D1B46),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViewerAddScreen()),
          );
        },
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.viewers.isEmpty
          ? const Center(child: Text("Henüz kullanıcı eklenmemiş."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.viewers.length,
              itemBuilder: (context, index) {
                final item = provider.viewers[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar (Baş Harfler)
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF0D1B46,
                              ).withOpacity(0.1),
                              child: Text(
                                item.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF0D1B46),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // İsim ve Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    item.username,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Aktif/Pasif Switch
                            Switch(
                              value: item.isActive,
                              activeColor: Colors.green,
                              onChanged: (val) {
                                provider.updateStatus(item.id, val);
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.email,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              children: [
                                // Düzenle Butonu
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ViewerEditScreen(userId: item.id),
                                      ),
                                    );
                                  },
                                ),
                                // Sil Butonu
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(
                                    context,
                                    provider,
                                    item.id,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
        title: const Text("Emin misiniz?"),
        content: const Text("Bu kullanıcı silinecek ve işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await provider.deleteViewer(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kullanıcı silindi")),
                );
              }
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
