import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarfiyum_mobile/models/multiplier_models.dart';
import 'package:sarfiyum_mobile/providers/multiplier_settings_provider.dart';
import 'package:sarfiyum_mobile/utils/decimal_text_input_formatter.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class MultiplierSettingsScreen extends StatefulWidget {
  const MultiplierSettingsScreen({super.key});

  @override
  State<MultiplierSettingsScreen> createState() =>
      _MultiplierSettingsScreenState();
}

class _MultiplierSettingsScreenState extends State<MultiplierSettingsScreen> {
  // Tema Renkleri
  final Color _primaryColor = const Color(0xFF161A30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MultiplierSettingsProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MultiplierSettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "AYARLAR",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // --- 1. HEADER ALANI ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ürün & Çarpan Yönetimi",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // BUTONLAR GRUBU
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildHeaderButton(
                          icon: Icons.playlist_add_rounded,
                          label: "Katalogdan\nEkle",
                          color: Colors.blueAccent,
                          onPressed: () =>
                              _showCatalogDialog(context, provider),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildHeaderButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: "Özel Ürün\nEkle",
                          color: Colors.white,
                          textColor: _primaryColor,
                          onPressed: () =>
                              _showAddProductDialog(context, provider),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildHeaderButton(
                          icon: Icons.save_rounded,
                          label: "Tümünü\nKaydet",
                          color: const Color(0xFF27AE60),
                          isLoading: provider.isLoading,
                          onPressed: provider.isLoading
                              ? null
                              : () => _confirmSaveAll(context, provider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. LİSTE ALANI ---
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.groupedProducts.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  );
                }

                if (provider.groupedProducts.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Henüz hiç ürün eklenmemiş.",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  color: _primaryColor,
                  onRefresh: () => provider.loadData(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
                    children: [
                      ...provider.groupedProducts.entries.map((entry) {
                        return _buildCategoryGroup(
                          context,
                          provider,
                          entry.key,
                          entry.value,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER BUTON ---
  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: EdgeInsets.zero,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: textColor,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: textColor,
                  ),
                ),
              ],
            ),
    );
  }

  // --- LİSTE GRUBU ---
  Widget _buildCategoryGroup(
    BuildContext context,
    MultiplierSettingsProvider provider,
    String categoryName,
    List<TenantProduct> products,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 10),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${products.length}",
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade50),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                onReorder: (old, newIdx) =>
                    provider.reorderLocalList(categoryName, old, newIdx),
                itemBuilder: (context, index) => _buildProductRow(
                  context,
                  provider,
                  products[index],
                  Key(products[index].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🔥 GÜNCELLENEN ROW: RENK VE DURUM MANTIĞI DÜZELTİLDİ ---
  Widget _buildProductRow(
    BuildContext context,
    MultiplierSettingsProvider provider,
    TenantProduct item,
    Key key,
  ) {
    bool isCreditCard = item.categoryName == "Kredi Kartı";

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ReorderableDragStartListener(
                index: 0,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.drag_indicator, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item.isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 🔥 PLATFORM ICONLARI (DÜZELTİLDİ)
                    Row(
                      children: [
                        _buildPlatformToggleIcon(
                          icon: Icons.language,
                          isPlatformEnabled:
                              item.showOnWeb, // Platform açık mı?
                          isProductActive:
                              item.isActive, // Ürün genel olarak aktif mi?
                          activeColor: Colors.blueAccent,
                          onTap: () {
                            // Ürün pasifse işlem yapma (İsteğe bağlı, tıklanınca açılmasını istersen burayı değiştirme)
                            if (!item.isActive) return;
                            setState(() => item.showOnWeb = !item.showOnWeb);
                            provider.toggleWebStatus(item.id);
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildPlatformToggleIcon(
                          icon: Icons.phone_iphone,
                          isPlatformEnabled:
                              item.showOnMobile, // Platform açık mı?
                          isProductActive:
                              item.isActive, // Ürün genel olarak aktif mi?
                          activeColor: Colors.orange,
                          onTap: () {
                            if (!item.isActive) return;
                            setState(
                              () => item.showOnMobile = !item.showOnMobile,
                            );
                            provider.toggleMobileStatus(item.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  activeColor: Colors.green,
                  value: item.isActive,
                  onChanged: (val) => setState(() => item.isActive = val),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                onSelected: (val) {
                  if (val == 'edit')
                    _showEditProductDialog(context, provider, item);
                  if (val == 'delete')
                    _confirmDelete(context, provider, item.id);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text("Düzenle"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Sil", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              if (!isCreditCard)
                Expanded(
                  child: _buildCompactInput(
                    "Alış",
                    item.buyMultiplier,
                    (v) => item.buyMultiplier = v,
                    Colors.green,
                    enabled: item.isActive, // Pasifse disable et
                  ),
                ),
              if (!isCreditCard) const SizedBox(width: 10),
              Expanded(
                child: _buildCompactInput(
                  "Satış",
                  item.sellMultiplier,
                  (v) => item.sellMultiplier = v,
                  Colors.red,
                  enabled: item.isActive,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactInput(
                  "Makas",
                  item.addonAmount,
                  (v) => item.addonAmount = v,
                  Colors.blue,
                  suffix: "₺",
                  enabled: item.isActive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 🔥 DÜZELTİLMİŞ IKON BUTONU ---
  // Mantık: Ürün pasifse -> Her zaman sönük (Gri).
  // Ürün aktifse -> showOn... true ise renkli, false ise gri.
  Widget _buildPlatformToggleIcon({
    required IconData icon,
    required bool isPlatformEnabled,
    required bool isProductActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    // Görünüm mantığı
    final bool isVisuallyActive = isProductActive && isPlatformEnabled;

    // Renkleri belirle
    final Color bgColor = isVisuallyActive
        ? activeColor.withOpacity(0.1)
        : Colors.grey.shade100;
    final Color iconColor = isVisuallyActive
        ? activeColor
        : Colors.grey.shade400;
    final Color borderColor = isVisuallyActive
        ? activeColor.withOpacity(0.3)
        : Colors.grey.shade300;

    return InkWell(
      onTap:
          onTap, // Pasifken tıklamayı engellemek istersen: isProductActive ? onTap : null
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }

  Widget _buildCompactInput(
    String label,
    double val,
    Function(double) onChange,
    Color color, {
    String? suffix,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 35,
          child: TextFormField(
            key: ValueKey(val),
            initialValue: val.toString().replaceAll('.', ','),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalTextInputFormatter()],
            enabled: enabled, // 🔥 Pasiflik eklendi
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: enabled ? color : Colors.grey, // Pasifse gri yap
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: !enabled,
              fillColor: !enabled ? Colors.grey.shade100 : null,
              suffixText: suffix,
              suffixStyle: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            onChanged: (v) {
              if (v.isNotEmpty) {
                double? d = double.tryParse(v.replaceAll(',', '.'));
                if (d != null) onChange(d);
              }
            },
          ),
        ),
      ],
    );
  }

  // --- ONAY MODALLARI ---
  void _confirmDelete(
    BuildContext context,
    MultiplierSettingsProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silmek istiyor musunuz?"),
        content: const Text("Bu işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _confirmSaveAll(
    BuildContext context,
    MultiplierSettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kaydet"),
        content: const Text("Tüm değişiklikler yayınlansın mı?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              List<TenantProduct> all = provider.groupedProducts.values
                  .expand((x) => x)
                  .toList();
              provider.updateProducts(all).then((success) {
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kaydedildi"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Evet"),
          ),
        ],
      ),
    );
  }

  // --- MANUEL EKLEME MODALI ---
  void _showAddProductDialog(
    BuildContext context,
    MultiplierSettingsProvider provider,
  ) {
    final nameCtrl = TextEditingController();
    final buyCtrl = TextEditingController(text: "1,0000");
    final sellCtrl = TextEditingController(text: "1,0000");
    final addonCtrl = TextEditingController(text: "0,00");

    bool showOnWeb = true;
    bool showOnMobile = true;

    if (provider.categories.isEmpty) return;

    String selectedCategory = provider.categories.first.id;
    const String fixedSourceKey = "ALTIN";

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final selectedCatObj = provider.categories.firstWhere(
              (c) => c.id == selectedCategory,
              orElse: () => provider.categories.first,
            );
            final isCreditCard = selectedCatObj.name == "Kredi Kartı";

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Yeni Ürün Oluştur",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildModernDropdown(
                        value: selectedCategory,
                        items: provider.categories,
                        onChanged: (val) =>
                            setStateModal(() => selectedCategory = val!),
                        label: "Kategori",
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        label: "Ürün Adı",
                        controller: nameCtrl,
                        hint: "Örn: 22 Ayar Halhal",
                      ),

                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Endeks: $fixedSourceKey\nYeni ürünler varsayılan olarak Has Altın'a endekslenir.",
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          if (!isCreditCard)
                            Expanded(
                              child: _buildModernTextField(
                                label: "Alış Çarpanı",
                                controller: buyCtrl,
                                isNumber: true,
                                centerText: true,
                              ),
                            ),
                          if (!isCreditCard) const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernTextField(
                              label: "Satış Çarpanı",
                              controller: sellCtrl,
                              isNumber: true,
                              centerText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        label: "Ek Makas (TL)",
                        controller: addonCtrl,
                        isNumber: true,
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text(
                                "Web",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dense: true,
                              activeColor: Colors.blueAccent,
                              contentPadding: EdgeInsets.zero,
                              value: showOnWeb,
                              onChanged: (val) =>
                                  setStateModal(() => showOnWeb = val),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text(
                                "Mobil",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dense: true,
                              activeColor: Colors.orange,
                              contentPadding: EdgeInsets.zero,
                              value: showOnMobile,
                              onChanged: (val) =>
                                  setStateModal(() => showOnMobile = val),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            double buy =
                                double.tryParse(
                                  buyCtrl.text.replaceAll(',', '.'),
                                ) ??
                                1.0;
                            double sell =
                                double.tryParse(
                                  sellCtrl.text.replaceAll(',', '.'),
                                ) ??
                                1.0;
                            double addon =
                                double.tryParse(
                                  addonCtrl.text.replaceAll(',', '.'),
                                ) ??
                                0.0;

                            final dto = CreateProductDto(
                              name: nameCtrl.text,
                              categoryId: selectedCategory,
                              sourceKey: fixedSourceKey,
                              buyMultiplier: isCreditCard ? 0 : buy,
                              sellMultiplier: sell,
                              addonAmount: addon,
                              showOnWeb: showOnWeb,
                              showOnMobile: showOnMobile,
                            );

                            provider.createProduct(dto).then((success) {
                              if (success) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Oluşturuldu!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          },
                          child: const Text(
                            "OLUŞTUR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  // --- DÜZENLEME MODALI ---
  void _showEditProductDialog(
    BuildContext context,
    MultiplierSettingsProvider provider,
    TenantProduct existingProduct,
  ) {
    final nameCtrl = TextEditingController(text: existingProduct.name);
    final buyCtrl = TextEditingController(
      text: existingProduct.buyMultiplier.toString().replaceAll('.', ','),
    );
    final sellCtrl = TextEditingController(
      text: existingProduct.sellMultiplier.toString().replaceAll('.', ','),
    );
    final addonCtrl = TextEditingController(
      text: existingProduct.addonAmount.toString().replaceAll('.', ','),
    );

    String selectedCategory = "";
    if (existingProduct.categoryId.isNotEmpty) {
      selectedCategory = existingProduct.categoryId;
    } else {
      try {
        selectedCategory = provider.categories
            .firstWhere((c) => c.name == existingProduct.categoryName)
            .id;
      } catch (e) {
        if (provider.categories.isNotEmpty)
          selectedCategory = provider.categories.first.id;
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final selectedCatObj = provider.categories.firstWhere(
              (c) => c.id == selectedCategory,
              orElse: () => provider.categories.first,
            );
            final isCreditCard = selectedCatObj.name == "Kredi Kartı";

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ürünü Düzenle",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModernDropdown(
                        value: selectedCategory,
                        items: provider.categories,
                        onChanged: (v) =>
                            setStateModal(() => selectedCategory = v!),
                        label: "Kategori",
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        label: "Ürün Adı",
                        controller: nameCtrl,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (!isCreditCard)
                            Expanded(
                              child: _buildModernTextField(
                                label: "Alış",
                                controller: buyCtrl,
                                isNumber: true,
                                centerText: true,
                              ),
                            ),
                          if (!isCreditCard) const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernTextField(
                              label: "Satış",
                              controller: sellCtrl,
                              isNumber: true,
                              centerText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildModernTextField(
                        label: "Ek Makas",
                        controller: addonCtrl,
                        isNumber: true,
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text(
                                "Web",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dense: true,
                              activeColor: Colors.blueAccent,
                              contentPadding: EdgeInsets.zero,
                              value: existingProduct.showOnWeb,
                              onChanged: (val) => setStateModal(
                                () => existingProduct.showOnWeb = val,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text(
                                "Mobil",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dense: true,
                              activeColor: Colors.orange,
                              contentPadding: EdgeInsets.zero,
                              value: existingProduct.showOnMobile,
                              onChanged: (val) => setStateModal(
                                () => existingProduct.showOnMobile = val,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            double buy =
                                double.tryParse(
                                  buyCtrl.text.replaceAll(',', '.'),
                                ) ??
                                0.0;
                            double sell =
                                double.tryParse(
                                  sellCtrl.text.replaceAll(',', '.'),
                                ) ??
                                0.0;
                            double addon =
                                double.tryParse(
                                  addonCtrl.text.replaceAll(',', '.'),
                                ) ??
                                0.0;

                            existingProduct.name = nameCtrl.text;
                            existingProduct.categoryId = selectedCategory;
                            existingProduct.buyMultiplier = isCreditCard
                                ? 0
                                : buy;
                            existingProduct.sellMultiplier = sell;
                            existingProduct.addonAmount = addon;

                            provider.updateProducts([existingProduct]).then((
                              s,
                            ) {
                              if (s) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Güncellendi"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          },
                          child: const Text(
                            "GÜNCELLE",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (c, a, s, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
    );
  }

  // --- KATALOG MODALI ---
  void _showCatalogDialog(
    BuildContext context,
    MultiplierSettingsProvider provider,
  ) {
    List<SystemCatalogItem> allItems = [];
    List<SystemCatalogItem> filteredItems = [];
    bool isDialogLoading = true;
    String selectedCategory = provider.categories.isNotEmpty
        ? provider.categories.first.id
        : "";

    provider.getSystemCatalog().then((items) {
      allItems = items;
      filteredItems = items;
      isDialogLoading = false;
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            if (isDialogLoading && allItems.isEmpty) {
              provider.getSystemCatalog().then((res) {
                if (context.mounted) {
                  setStateModal(() {
                    allItems = res;
                    filteredItems = res;
                    isDialogLoading = false;
                  });
                }
              });
            } else if (!isDialogLoading && allItems.isEmpty) {
              Future.delayed(const Duration(milliseconds: 50), () {
                if (allItems.isNotEmpty && context.mounted) {
                  setStateModal(() {
                    filteredItems = allItems;
                    isDialogLoading = false;
                  });
                }
              });
            }

            void filterList(String query) {
              setStateModal(() {
                if (query.isEmpty) {
                  filteredItems = allItems;
                } else {
                  filteredItems = allItems
                      .where(
                        (item) =>
                            item.name.toLowerCase().contains(
                              query.toLowerCase(),
                            ) ||
                            item.sourceKey.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                      )
                      .toList();
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: SizedBox(
                width: double.maxFinite,
                height: 600,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Katalogdan Ekle",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernDropdown(
                            value: selectedCategory,
                            items: provider.categories,
                            onChanged: (val) =>
                                setStateModal(() => selectedCategory = val!),
                            label: "Hedef Kategori",
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: filterList,
                            decoration: InputDecoration(
                              hintText: "Ürün Ara (Dolar, Çeyrek...)",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: _primaryColor,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: isDialogLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: _primaryColor,
                              ),
                            )
                          : filteredItems.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 40,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Sonuç bulunamadı",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: filteredItems.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Material(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      if (selectedCategory.isEmpty) return;
                                      final dto = CreateProductDto(
                                        name: item.name,
                                        categoryId: selectedCategory,
                                        sourceKey: item.sourceKey,
                                        buyMultiplier: 1.0,
                                        sellMultiplier: 1.0,
                                        addonAmount: 0,
                                        showOnWeb: true,
                                        showOnMobile: true,
                                      );
                                      provider.createProduct(dto).then((
                                        success,
                                      ) {
                                        if (success) {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text("${item.name} eklendi"),
                                                ],
                                              ),
                                              backgroundColor: const Color(
                                                0xFF27AE60,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              item.name.isNotEmpty
                                                  ? item.name[0]
                                                  : "?",
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item.sourceKey,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontFamily: 'monospace',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.add_circle_rounded,
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
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
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isNumber = false,
    bool centerText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumber ? [DecimalTextInputFormatter()] : [],
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required List<Category> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              items: items
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
