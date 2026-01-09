import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "S.S.S.",
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
              height: 250,
              decoration: const BoxDecoration(color: Color(0xFF161A30)),
              child: Stack(
                children: [
                  Container(color: Color(0xFF161A30).withOpacity(0.3)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sıkça Sorulan Sorular",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Sarfiyum özellikleri, üyelik ve güvenlik hakkında merak ettiğiniz tüm cevaplar burada.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Arama
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Cevaplarda ara...",
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- AKORDİYON LİSTESİ (FAQ Data) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: faqList.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          category['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0D1B46),
                          ),
                        ),
                      ),

                      ...(category['faqs'] as List<Map<String, String>>).map((
                        faq,
                      ) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              faq['question']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                faq['answer']!,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),

            // --- ALT BİLGİ & İLETİŞİM ---
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    "Aradığınız soruyu bulamadınız mı?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Ekibimiz size yardımcı olmaktan memnuniyet duyacaktır.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => _launchWhatsapp(),
                    icon: const Icon(Icons.chat),
                    label: const Text("WhatsApp Destek"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
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

  // Angular'daki FaqData
  final List<Map<String, dynamic>> faqList = const [
    {
      'title': 'Genel & Güvenlik',
      'faqs': [
        {
          'question': 'Sarfiyum verilerimi nasıl saklıyor, güvenli mi?',
          'answer':
              'Evet, verileriniz banka düzeyinde şifreleme (SSL) ile korunmaktadır. Tüm stok ve cari verileriniz bulut sunucularımızda günlük olarak yedeklenir.',
        },
        {
          'question': 'Sistemi kullanmak için kurulum yapmam gerekir mi?',
          'answer':
              'Hayır, Sarfiyum tamamen bulut tabanlı bir SaaS projesidir. Tarayıcı üzerinden giriş yapabilirsiniz.',
        },
        {
          'question': 'İnternetim kesilirse ne olur?',
          'answer':
              'Sarfiyum bulut tabanlı çalıştığı için internet gerektirir. Mobil uyumluluğu sayesinde cep telefonunuzun internetiyle devam edebilirsiniz.',
        },
      ],
    },
    {
      'title': 'Destek & Üyelik',
      'faqs': [
        {
          'question': 'Fiyatlandırma nasıl çalışıyor?',
          'answer':
              'Aylık veya yıllık abonelik modellerimiz mevcuttur. İlk 14 gün ücretsiz deneyebilirsiniz.',
        },
      ],
    },
  ];
}
