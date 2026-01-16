import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_drawer.dart'; // 🔥 CustomDrawer import edilmeli

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 🔥 1. DRAWER EKLENDİ
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "YARDIM MERKEZİ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        // 🔥 2. GERİ BUTONU YERİNE MENÜ İKONU EKLENDİ
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), // 3 Çizgi
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ÜST BANNER ALANI (DÜZ & GRADIENT) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF243B55), const Color(0xFF243B55)],
                ),
                border: const Border(
                  bottom: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Size nasıl yardımcı olabiliriz?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sarfiyum hakkında merak ettiğiniz her şey burada.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // ARAMA ÇUBUĞU
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Sorunuzu arayın...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: _primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // WHATSAPP BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWhatsapp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        "WhatsApp Destek Hattı",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- KARTLAR LİSTESİ (DÜZ YAPI) ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: helpList.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final item = helpList[index];
                return _buildHelpItem(item);
              },
            ),

            // Alt boşluk
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 🔥 LİSTE ELEMANI
  Widget _buildHelpItem(Map<String, dynamic> item) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon Kutusu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF161A30).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: const Color(0xFF161A30),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Yazılar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Ok İşareti
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _launchWhatsapp() async {
    final url = Uri.parse("https://wa.me/905399212391");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Data
  final List<Map<String, dynamic>> helpList = const [
    {
      'title': 'Sarfiyum\'a Başlarken',
      'description': 'Hesap kurulumu, mağaza tanımlama ve ilk ayarlar rehberi.',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'title': 'Hesap Ayarları & Güvenlik',
      'description':
          'Şifre değişikliği, personel yetkilendirme ve rol atamaları.',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Teknik Destek & İletişim',
      'description':
          'Sistem hataları bildirme veya canlı destek talebi oluşturma.',
      'icon': Icons.headset_mic_rounded,
    },
    {
      'title': 'Ödeme ve Faturalandırma',
      'description': 'Abonelik paketleri, ödeme geçmişi ve fatura detayları.',
      'icon': Icons.receipt_long_rounded,
    },
  ];
}
