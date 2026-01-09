import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Linkleri açmak için (pubspec.yaml'a eklemelisin: url_launcher)

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "YARDIM MERKEZİ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ÜST BANNER ALANI ---
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFF161A30), // Resim yoksa bu renk görünür
              ),
              child: Stack(
                children: [
                  // Siyah Perde (Opacity)
                  Container(color: Color(0xFF161A30).withOpacity(0.3)),

                  // İçerik
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Yardım Merkezi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Sarfiyum ile ilgili size nasıl yardımcı olabiliriz?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Arama Çubuğu
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Sorunuzu arayın...",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // WhatsApp Butonu
                          GestureDetector(
                            onTap: () => _launchWhatsapp(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                  ), // WhatsApp ikonu yerine chat
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      "Sorun mu yaşıyorsunuz? WhatsApp hattımızdan bize ulaşın.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- KARTLAR (HelpList) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true, // ScrollView içinde olduğu için şart
                physics:
                    const NeverScrollableScrollPhysics(), // Scroll'u dışarıya bırak
                itemCount: helpList.length,
                itemBuilder: (context, index) {
                  final item = helpList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: Colors.amber[800],
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsapp() async {
    final url = Uri.parse("https://wa.me/905399212391");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // Angular'daki HelpList Data
  final List<Map<String, dynamic>> helpList = const [
    {
      'title': 'Sarfiyum\'a Başlarken',
      'description': 'Hesap kurulumu, mağaza tanımlama ve ilk ayarlar rehberi.',
      'icon': Icons.rocket_launch,
    },
    {
      'title': 'Hesap Ayarları & Güvenlik',
      'description':
          'Şifre değişikliği, personel yetkilendirme ve rol atamaları.',
      'icon': Icons.security,
    },
    {
      'title': 'Teknik Destek & İletişim',
      'description':
          'Sistem hataları bildirme veya canlı destek talebi oluşturma.',
      'icon': Icons.headset_mic,
    },
  ];
}
