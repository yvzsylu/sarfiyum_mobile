import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔥 Provider importu şart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sarfiyum_mobile/providers/tenant_settings_provider.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class TenantSettingsScreen extends StatefulWidget {
  const TenantSettingsScreen({super.key});

  @override
  State<TenantSettingsScreen> createState() => _TenantSettingsScreenState();
}

class _TenantSettingsScreenState extends State<TenantSettingsScreen> {
  final TextEditingController _phoneController = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '(###) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Provider'dan veriyi çek
      final provider = context.read<TenantSettingsProvider>();
      await provider.loadSettings();

      if (provider.whatsappNumber != null) {
        String raw = provider.whatsappNumber!;
        if (raw.startsWith('90')) raw = raw.substring(2);
        _phoneController.text = maskFormatter.maskText(raw);
      }
    });
  }

  Future<void> _save() async {
    String unmasked = maskFormatter.getUnmaskedText();

    if (unmasked.length != 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen geçerli bir numara giriniz.")),
        );
      }
      return;
    }

    String finalNumber = "90$unmasked";

    // 🔥 BURASI HATA VERİYORSA:
    // 1. Dosyanın tepesinde import 'package:provider/provider.dart'; var mı?
    // 2. TenantSettingsProvider dosyasını kaydettin mi?
    final success = await context.read<TenantSettingsProvider>().updateSettings(
      finalNumber,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ayarlar başarıyla kaydedildi."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<TenantSettingsProvider>().errorMessage ??
                  "Hata oluştu",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantSettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("GENEL AYARLAR"),
        backgroundColor: const Color(0xFF161A30),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          // 🔥 DÜZELTİLDİ: MainAxisAlignment -> CrossAxisAlignment
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Firma İletişim Bilgileri",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF161A30),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Mobil uygulamada müşterilerinizin size ulaşacağı WhatsApp numarasını buradan belirleyebilirsiniz.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "WhatsApp Hattı",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  if (provider.isLoading && _phoneController.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Column(
                      // 🔥 DÜZELTİLDİ: MainAxisAlignment -> CrossAxisAlignment
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Telefon Numarası",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          inputFormatters: [maskFormatter],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "(5XX) XXX XX XX",
                            prefixText: "+90 ",
                            prefixStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "Başında 0 olmadan giriniz.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF161A30),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 10),
                                Text("Değişiklikleri Kaydet"),
                              ],
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
}
