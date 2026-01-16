import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 🔥 Hata riskine karşı kaldırıldı, standart ikon kullanıldı.
import 'package:sarfiyum_mobile/providers/auth_provider.dart';

// Ekran Importları (Dosya yollarının projenizle aynı olduğundan emin olun)
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

  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Rol Kontrolü (User modelinizde isViewer getter'ı yoksa burayı user?.role == 'viewer' gibi güncelleyin)
    final bool isViewer = user?.isViewer ?? false;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // --- 1. HEADER (GRADIENT & GÖRSEL) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_primaryColor, const Color(0xFF243B55)],
              ),
            ),
            child: Row(
              children: [
                // Logo / Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: user?.tenantLogoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              "https://sarfiyum.com${user!.tenantLogoUrl}",
                              fit: BoxFit.contain,
                              width: 60,
                              height: 60,
                              errorBuilder: (c, o, s) => Text(
                                user?.fullName?.substring(0, 1) ?? "U",
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            user?.fullName?.substring(0, 1) ?? "U",
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                // İsim ve Firma
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? "Kullanıcı",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.tenantName ?? "Firma Bilgisi Yok",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. MENÜ LİSTESİ ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // --- GÖSTERGE PANELİ ---
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Gösterge Paneli',
                  onTap: () {
                    Navigator.pop(context); // Çekmeceyi kapat
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const UserDashboard()),
                    );
                  },
                ),

                // ===================================================
                // SENARYO A: VIEWER İSE (Sadece İletişim)
                // ===================================================
                if (isViewer) ...[
                  _buildDivider(),
                  _buildDrawerItem(
                    context,
                    icon:
                        Icons.chat_rounded, // FontAwesome yerine standart ikon
                    title: 'İletişim & Destek',
                    iconColor: Colors.green,
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
                // SENARYO B: YÖNETİCİ (USER) İSE
                // ===================================================
                if (!isViewer) ...[
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'Profilim',
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

                  _buildDivider(),
                  _buildSectionHeader("YÖNETİM"),

                  _buildDrawerItem(
                    context,
                    icon: Icons.tune_rounded,
                    title: 'Ürün & Çarpan',
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.category_rounded,
                    title: 'Kategoriler',
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: 'Kullanıcılar',
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

                  _buildDivider(),
                  _buildSectionHeader("YARDIM"),

                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Yardım Merkezi',
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.question_answer_rounded,
                    title: 'Sıkça Sorulan Sorular',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FaqsScreen()),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 10),

                // 🔥 GENEL AYARLAR (Viewer Değilse)
                if (!isViewer) ...[
                  _buildDivider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'Genel Ayarlar',
                    // Hafif renkli arka plan ile dikkat çeksin
                    tileColor: Colors.amber.shade50.withOpacity(0.5),
                    iconColor: Colors.amber.shade900,
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

                _buildDivider(),

                // --- ÇIKIŞ BUTONU ---
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Çıkış Yap',
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),

                // Alt boşluk
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? tileColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? _primaryColor.withOpacity(0.8),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF2C3E50),
          fontWeight: FontWeight.w700, // Kalın ve Okunaklı
          fontSize: 14,
        ),
      ),
      tileColor: tileColor, // İsteğe bağlı arka plan rengi
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
      height: 20,
      indent: 16,
      endIndent: 16,
    );
  }
}
