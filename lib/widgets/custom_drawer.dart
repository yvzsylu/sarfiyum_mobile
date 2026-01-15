import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/screens/user/category_settings_screen.dart';
import 'package:sarfiyum_mobile/screens/user/faqs_screen.dart';
import 'package:sarfiyum_mobile/screens/user/help_center_screen.dart';
import 'package:sarfiyum_mobile/screens/user/multiplier_settings_screen.dart';
import 'package:sarfiyum_mobile/screens/user/profile_screen.dart';
import 'package:sarfiyum_mobile/screens/user/viewer_list_screen.dart';
import 'package:sarfiyum_mobile/screens/common/login_screen.dart';
import 'package:sarfiyum_mobile/screens/user/contact_screen.dart';
import 'package:sarfiyum_mobile/screens/user/user_dashboard.dart';
import 'package:sarfiyum_mobile/screens/user/tenant_settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Rol Kontrolü
    final bool isViewer = user?.isViewer ?? false;

    return Drawer(
      backgroundColor: const Color(0xFF161A30),
      child: Column(
        children: [
          // --- 1. HEADER (HERKES GÖRÜR) ---
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            accountName: Text(user?.fullName ?? "Kullanıcı"),
            accountEmail: Text(user?.tenantName ?? "Firma Bilgisi Yok"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.tenantLogoUrl != null
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.network(
                        "https://sarfiyum.com${user!.tenantLogoUrl}",
                        fit: BoxFit.contain,
                        errorBuilder: (c, o, s) => Text(
                          user?.fullName?.substring(0, 1) ?? "U",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      user?.fullName?.substring(0, 1) ?? "U",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 24,
                      ),
                    ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF161A30)),
          ),

          // --- 2. MENÜ LİSTESİ ---
          Expanded(
            child: Container(
              color: const Color(0xFFEEEEEE),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- GÖSTERGE PANELİ (HERKES İÇİN) ---
                  ListTile(
                    leading: const Icon(
                      Icons.dashboard,
                      color: Color(0xFF161A30),
                    ),
                    title: const Text('Gösterge Paneli'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserDashboard(),
                        ),
                      );
                    },
                  ),

                  // ===================================================
                  // SENARYO A: VIEWER İSE (Sadece İletişim)
                  // ===================================================
                  if (isViewer) ...[
                    const Divider(),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                      ),
                      title: const Text('İletişim & Destek'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  // ===================================================
                  // SENARYO B: USER (Yönetici) İSE (Yönetim Menüleri)
                  // ===================================================
                  if (!isViewer) ...[
                    // Profil
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF0D1B46),
                      ),
                      title: const Text('Profilim'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // YÖNETİM BAŞLIĞI
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        "YÖNETİM",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Not: Genel Ayarlar buradan kaldırıldı, aşağıya taşındı.
                    ListTile(
                      leading: const Icon(Icons.tune, color: Color(0xFF161A30)),
                      title: const Text('Ürün & Çarpan'),
                      tileColor: Colors.blue.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MultiplierSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.list_alt_rounded,
                        color: Color(0xFF161A30),
                      ),
                      title: const Text('Kategoriler'),
                      tileColor: Colors.blue.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategorySettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.people,
                        color: Color(0xFF0D1B46),
                      ),
                      title: const Text('Kullanıcılar'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewerListScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // YARDIM BAŞLIĞI
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        "YARDIM",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FaqsScreen()),
                        );
                      },
                    ),
                  ],

                  // Sayfanın altını doldurmak için boşluk
                  const SizedBox(height: 20),

                  // 🔥 GENEL AYARLAR: BURAYA TAŞINDI
                  // Sadece Viewer değilse görünür. Çıkış Yap'ın hemen üzerinde.
                  if (!isViewer) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: Color(0xFF161A30),
                      ),
                      title: const Text('Genel Ayarlar'),
                      // Dikkat çekmesi için hafif farklı bir renk
                      tileColor: Colors.amber.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TenantSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  const Divider(),

                  // --- ÇIKIŞ BUTONU (Herkes Görür) ---
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
