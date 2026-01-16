import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_drawer.dart'; // 🔥 CustomDrawer import edildi

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

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
          "S.S.S.",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Kalın Font
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
            // --- ÜST BANNER & ARAMA ALANI (DÜZ & GRADIENT) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // AppBar ile bütünlük sağlayan renkler
                  colors: [const Color(0xFF243B55), const Color(0xFF243B55)],
                ),
                // Alt çizgi efekti
                border: const Border(
                  bottom: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Sıkça Sorulan Sorular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sarfiyum özellikleri, üyelik ve güvenlik hakkında merak ettiğiniz tüm cevaplar burada.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // ARAMA ÇUBUĞU
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cevaplarda ara...",
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
                ],
              ),
            ),

            // --- SORU LISTESI (FAQ Data) ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final category = faqList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori Başlığı
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            category['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: _primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sorular
                    ...(category['faqs'] as List<Map<String, String>>).map((
                      faq,
                    ) {
                      return Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent, // Çizgiyi gizle
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                20,
                              ),
                              title: Text(
                                faq['question']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              iconColor: _primaryColor,
                              collapsedIconColor: Colors.grey,
                              children: [
                                Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                            indent: 20,
                            endIndent: 20,
                          ),
                        ],
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            // --- ALT BİLGİ & İLETİŞİM ---
            Container(
              width: double.infinity,
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    "Aradığınız soruyu bulamadınız mı?",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ekibimiz size yardımcı olmaktan memnuniyet duyacaktır.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWhatsapp(),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        "WhatsApp Destek",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  // FAQ Data
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
        {
          'question': 'Üyeliğimi istediğim zaman iptal edebilir miyim?',
          'answer':
              'Evet, taahhüt gerektirmeyen paketlerimizde dilediğiniz zaman üyeliğinizi sonlandırabilirsiniz.',
        },
      ],
    },
  ];
}
