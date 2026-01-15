import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/providers/tenant_settings_provider.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ayarları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenantSettingsProvider>().loadSettings();
    });
  }

  Future<void> _launchWhatsApp(String phone) async {
    // 1. Numarayı temizle (Sadece rakamlar)
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Başında 90 yoksa ekle (Türkiye standardı)
    if (!cleanPhone.startsWith('90') && cleanPhone.length == 10) {
      cleanPhone = '90$cleanPhone';
    }

    // 3. Linki oluştur
    final Uri url = Uri.parse(
      "https://wa.me/$cleanPhone?text=Merhaba,%20destek%20almak%20istiyorum.",
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Açılamadı';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp uygulaması bulunamadı.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<TenantSettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "İLETİŞİM",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: settings.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO ALANI ---
                    Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user?.tenantLogoUrl != null
                            ? Image.network(
                                "https://sarfiyum.com${user!.tenantLogoUrl}",
                                fit: BoxFit.contain,
                                errorBuilder: (c, o, s) => Icon(
                                  Icons.business,
                                  size: 50,
                                  color: _primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.business,
                                size: 50,
                                color: _primaryColor,
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- FİRMA ADI ---
                    Text(
                      user?.tenantName?.toUpperCase() ?? "SARFİYUM",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sorularınız destek için\naşağıdaki butona tıklayarak bize ulaşabilirsiniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- WHATSAPP BUTONU ---
                    if (settings.whatsappNumber != null &&
                        settings.whatsappNumber!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () =>
                              _launchWhatsApp(settings.whatsappNumber!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF25D366,
                            ), // WhatsApp Yeşili
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(
                              0xFF25D366,
                            ).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ikon eklemek istersen assets veya font_awesome kullanabilirsin
                              Icon(Icons.message_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                "WhatsApp ile Ulaşın",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Firma henüz bir iletişim numarası tanımlamamış.",
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
