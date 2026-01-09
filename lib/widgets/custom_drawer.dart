import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/screens/user/faqs_screen.dart';
import 'package:sarfiyum_mobile/screens/user/help_center_screen.dart';
import 'package:sarfiyum_mobile/screens/user/multiplier_settings_screen.dart';
import 'package:sarfiyum_mobile/screens/user/profile_screen.dart';
import 'package:sarfiyum_mobile/screens/user/viewer_list_screen.dart';
import 'package:sarfiyum_mobile/screens/common/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    // isAdmin değişkeni ilerde menü gizlemek için kullanılabilir
    final bool isAdmin = user?.roles?.contains('Admin') ?? false;

    return Drawer(
      // Drawer'ın genel arka planı
      backgroundColor: const Color(0xFF161A30),
      child: Column(
        children: [
          // 1. HEADER (Sabit Alan)
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            accountName: Text(user?.fullName ?? "Kullanıcı"),
            accountEmail: Text(user?.tenantName ?? "Firma Bilgisi Yok"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.tenantLogoUrl != null
                  ? NetworkImage("https://sarfiyum.com${user!.tenantLogoUrl}")
                  : null,
              child: user?.tenantLogoUrl == null
                  ? Text(
                      user?.fullName?.substring(0, 1) ?? "U",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF161A30), // Lacivert kurumsal renk
            ),
          ),

          // 2. LİSTE ALANI
          Expanded(
            child: Container(
              color: const Color(0xFFEEEEEE), // Menü arka planı
              child: Column(
                children: [
                  // --- ORTAK MENÜLER ---
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Gösterge Paneli'),
                    onTap: () {
                      // 1. Drawer'ı kapat
                      Navigator.pop(context);

                      // 2. 🔥 Stack'i temizle ve en alt sayfaya (Dashboard) in
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF0D1B46)),
                    title: const Text('Profilim'),
                    onTap: () {
                      Navigator.pop(context); // Drawer kapat

                      // 🔥 Önce Dashboard'a in (temizlik)
                      Navigator.of(context).popUntil((route) => route.isFirst);

                      // Sonra sayfayı aç
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  // --- YÖNETİM MENÜLERİ ---
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "YÖNETİM",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.tune, color: Color(0xFF161A30)),
                    title: const Text(
                      'Çarpan Ayarları',
                      style: TextStyle(color: Color(0xFF161A30)),
                    ),
                    tileColor: Colors.blue.shade50,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst); // 🔥 Temizlik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MultiplierSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.people, color: Color(0xFF0D1B46)),
                    title: const Text('Kullanıcılar'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst); // 🔥 Temizlik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewerListScreen(),
                        ),
                      );
                    },
                  ),

                  // --- DİĞER ARAÇLAR ---
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "YARDIM",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF0D1B46),
                    ),
                    title: const Text('Yardım Merkezi'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst); // 🔥 Temizlik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.question_answer,
                      color: Color(0xFF0D1B46),
                    ),
                    title: const Text('Sıkça Sorulan Sorular'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst); // 🔥 Temizlik
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FaqsScreen()),
                      );
                    },
                  ),

                  const Spacer(),
                  const Divider(),

                  // --- ÇIKIŞ BUTONU ---
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      // Drawer'ı kapat
                      Navigator.pop(context);

                      // API isteğini bekle
                      await authProvider.logout();

                      // Tüm sayfaları sil ve Login ekranını aç
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
