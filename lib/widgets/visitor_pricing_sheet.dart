import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visitor_settings_provider.dart';
import '../utils/decimal_text_input_formatter.dart';

class VisitorPricingSheet extends StatefulWidget {
  final String visitorId;
  final String visitorName;

  const VisitorPricingSheet({
    super.key,
    required this.visitorId,
    required this.visitorName,
  });

  @override
  State<VisitorPricingSheet> createState() => _VisitorPricingSheetState();
}

class _VisitorPricingSheetState extends State<VisitorPricingSheet> {
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorSettingsProvider>().loadData(widget.visitorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitorSettingsProvider>();

    // 🔥 1. HAMLE: GestureDetector ile sarmalıyoruz
    // Bu sayede boşluğa tıklayınca klavye kapanacak ama sayfa kapanmayacak.
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Klavyeyi indir
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        // 🔥 2. HAMLE: Klavye payı bırakıyoruz
        // Bu sayede klavye açılınca "Kaydet" butonu klavyenin üstüne çıkar.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // HEADER
            _buildHeader(context),

            // LİSTE
            Expanded(
              child: provider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: _primaryColor),
                    )
                  : ListView.builder(
                      // Klavye açılınca liste sıkışacağı için alt boşluğu azalttık
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: provider.groupedItems.length,
                      itemBuilder: (ctx, index) {
                        String key = provider.groupedItems.keys.elementAt(
                          index,
                        );
                        List<MergedProductItem> items =
                            provider.groupedItems[key]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryHeader(key, items.length),
                            ...items.map(
                              (item) => _buildItemRow(item, provider),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),

            // KAYDET BUTONU
            _buildSaveFooter(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.price_change_rounded, color: _primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Özel Fiyatlandırma",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.visitorName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 28),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    MergedProductItem item,
    VisitorSettingsProvider provider,
  ) {
    bool hasSpecial = item.hasSpecialSetting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasSpecial ? Colors.amber.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSpecial ? Colors.amber.shade300 : Colors.grey.shade200,
          width: hasSpecial ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.product.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: hasSpecial
                      ? Colors.amber.shade900
                      : const Color(0xFF2C3E50),
                ),
              ),
              if (hasSpecial)
                InkWell(
                  onTap: () async {
                    await provider.resetSetting(
                      widget.visitorId,
                      item.product.id,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restart_alt_rounded,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Sıfırla",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  "Alış",
                  item.specialBuy,
                  item.product.buyMultiplier,
                  (val) => item.specialBuy = val,
                  Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  "Satış",
                  item.specialSell,
                  item.product.sellMultiplier,
                  (val) => item.specialSell = val,
                  Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  "Makas",
                  item.specialAddon,
                  item.product.addonAmount,
                  (val) => item.specialAddon = val,
                  Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    double? currentValue,
    double defaultValue,
    Function(double?) onChanged,
    Color color,
  ) {
    final displayValue = currentValue != null
        ? currentValue.toString().replaceAll('.', ',')
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 45,
          child: TextFormField(
            key: ValueKey("${label}_${itemKey(currentValue)}"),
            initialValue: displayValue,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalTextInputFormatter()],
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: defaultValue.toStringAsFixed(2).replaceAll('.', ','),
              hintStyle: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              filled: true,
              fillColor: currentValue != null
                  ? Colors.white
                  : const Color(0xFFF5F6FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: currentValue != null
                      ? color.withOpacity(0.5)
                      : Colors.grey.shade300,
                  width: currentValue != null ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isEmpty) {
                onChanged(null);
              } else {
                double? d = double.tryParse(val.replaceAll(',', '.'));
                if (d != null) onChanged(d);
              }
            },
          ),
        ),
      ],
    );
  }

  String itemKey(double? val) => val == null ? "null" : val.toString();

  Widget _buildSaveFooter(
    BuildContext context,
    VisitorSettingsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    bool success = await provider.saveAllSettings(
                      widget.visitorId,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ayarlar kaydedildi!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 24),
                      SizedBox(width: 10),
                      Text(
                        "DEĞİŞİKLİKLERİ KAYDET",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
