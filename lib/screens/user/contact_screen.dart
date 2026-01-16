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
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenantSettingsProvider>().loadSettings();
    });
  }

  Future<void> _launchWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanPhone.startsWith('90') && cleanPhone.length == 10) {
      cleanPhone = '90$cleanPhone';
    }
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
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "İLETİŞİM",
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
      body: settings.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER ALTINDAKİ BİLGİ ALANI (DÜZ & TAM GENİŞLİK) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      60,
                    ), // Alttan boşluk bıraktık (Stack için)
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
                    child: Column(
                      children: [
                        const Text(
                          "Bize Ulaşın",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sorularınız ve destek talepleriniz için aşağıdaki kanalları kullanabilirsiniz.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // --- KART ALANI (HEADER İLE İÇ İÇE GEÇEN GÖRÜNÜM) ---
                  Transform.translate(
                    offset: const Offset(0, -40), // Yukarı kaydır
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // --- LOGO ---
                            Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: user?.tenantLogoUrl != null
                                    ? Image.network(
                                        "https://sarfiyum.com${user!.tenantLogoUrl}",
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, o, s) => Icon(
                                          Icons.business_rounded,
                                          size: 50,
                                          color: _primaryColor,
                                        ),
                                      )
                                    : Icon(
                                        Icons.business_rounded,
                                        size: 50,
                                        color: _primaryColor,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // --- FİRMA ADI ---
                            Text(
                              user?.tenantName?.toUpperCase() ?? "SARFİYUM",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _primaryColor,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 20),

                            // --- WHATSAPP BUTONU ---
                            if (settings.whatsappNumber != null &&
                                settings.whatsappNumber!.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _launchWhatsApp(settings.whatsappNumber!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: const Color(
                                      0xFF25D366,
                                    ).withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // FontAwesome kullanıyorsan FaIcon ekle
                                      Icon(Icons.message_rounded, size: 24),
                                      SizedBox(width: 10),
                                      Text(
                                        "WhatsApp ile Ulaşın",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Firma henüz bir iletişim numarası tanımlamamış.",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontSize: 13,
                                          height: 1.4,
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
                  ),
                ],
              ),
            ),
    );
  }
}
