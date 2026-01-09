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
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "AYARLAR",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // 👈 ÖNEMLİ
      ),
      body: Column(
        children: [
          // --- 1. HEADER ALANI ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF161A30), Color(0xFF161A30)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ürün & Çarpan Yönetimi",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),

                // BUTONLAR
                Row(
                  children: [
                    // YENİ ÜRÜN EKLE
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showAddProductDialog(context, provider),
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF0D1B46),
                        ),
                        label: const Text("Yeni Ürün"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D1B46),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // TÜMÜNÜ KAYDET
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => _confirmSaveAll(context, provider),
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          provider.isLoading
                              ? "Kaydediliyor..."
                              : "Tümünü Kaydet",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. LİSTE ALANI ---
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.groupedProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.groupedProducts.isEmpty) {
                  return Center(child: Text("Hata: ${provider.errorMessage}"));
                }

                if (provider.groupedProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz hiç ürün eklenmemiş.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadData(),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 12,
                      right: 12,
                      bottom: 50,
                    ),
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

  // --- WIDGET PARÇALARI ---

  Widget _buildCategoryGroup(
    BuildContext context,
    MultiplierSettingsProvider provider,
    String categoryName,
    List<TenantProduct> products,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B46).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${products.length}",
                style: const TextStyle(
                  color: Color(0xFF0D1B46),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0D1B46),
              ),
            ),
          ],
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              onReorder: (oldIndex, newIndex) {
                provider.reorderLocalList(categoryName, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = products[index];
                return _buildProductRow(context, provider, item, Key(item.id));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(
    BuildContext context,
    MultiplierSettingsProvider provider,
    TenantProduct item,
    Key key,
  ) {
    bool isCreditCard = item.categoryName == "Kredi Kartı";

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ÜST KISIM
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ReorderableDragStartListener(
                index: 0,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  activeColor: Colors.green,
                  value: item.isActive,
                  onChanged: (val) {
                    setState(() => item.isActive = val);
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item.name,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ürün Adı",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 5,
                    ),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: item.isActive ? Colors.black87 : Colors.grey,
                  ),
                  onChanged: (val) => item.name = val,
                ),
              ),

              // DÜZENLEME BUTONU
              InkWell(
                onTap: () => _showEditProductDialog(context, provider, item),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, color: Color(0xFF0D1B46), size: 22),
                ),
              ),

              // SİLME BUTONU
              InkWell(
                onTap: () => _confirmDelete(context, provider, item.id),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 10, thickness: 0.5),

          // ALT KISIM (INPUTLAR)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                if (!isCreditCard) ...[
                  Expanded(
                    child: _buildNumberInput(
                      label: "Alış Çarpanı",
                      value: item.buyMultiplier,
                      onChanged: (val) => item.buyMultiplier = val,
                      enabled: item.isActive,
                      color: Colors.green.shade800,
                      bgColor: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _buildNumberInput(
                    label: "Satış Çarpanı",
                    value: item.sellMultiplier,
                    onChanged: (val) => item.sellMultiplier = val,
                    enabled: item.isActive,
                    color: Colors.red.shade800,
                    bgColor: Colors.red.shade50,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberInput(
                    label: "Makas (TL)",
                    value: item.addonAmount,
                    onChanged: (val) => item.addonAmount = val,
                    enabled: item.isActive,
                    color: Colors.blue.shade800,
                    bgColor: Colors.blue.shade50,
                    suffix: "₺",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required Function(double) onChanged,
    bool enabled = true,
    Color color = Colors.black,
    Color bgColor = Colors.white,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: enabled ? bgColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? color.withOpacity(0.3) : Colors.grey.shade300,
            ),
          ),
          child: TextFormField(
            initialValue: value.toString().replaceAll('.', ','),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalTextInputFormatter()],
            enabled: enabled,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 8),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
            ),
            onChanged: (val) {
              if (val.isEmpty) return;
              double? parsed = double.tryParse(val.replaceAll(',', '.'));
              if (parsed != null) onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  // --- MODAL FONKSİYONLARI ---

  // 1. SİLME ONAYI
  void _confirmDelete(
    BuildContext context,
    MultiplierSettingsProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silmek istiyor musunuz?"),
        content: const Text("Bu ürün kalıcı olarak silinecektir."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteProduct(id);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  // 2. TÜMÜNÜ KAYDETME ONAYI
  void _confirmSaveAll(
    BuildContext context,
    MultiplierSettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kaydetmek istiyor musunuz?"),
        content: const Text("Değişiklikler canlı fiyatlara yansıyacaktır."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);

              // Provider'daki tüm listeyi düzleştirip updateProducts metoduna yolluyoruz
              List<TenantProduct> allProducts = provider.groupedProducts.values
                  .expand((element) => element)
                  .toList();

              provider.updateProducts(allProducts).then((success) {
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Tüm ayarlar başarıyla kaydedildi"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
            child: const Text("Evet, Yayınla"),
          ),
        ],
      ),
    );
  }

  // 3. YENİ ÜRÜN EKLE (Source Key SABİT ALTIN)
  void _showAddProductDialog(
    BuildContext context,
    MultiplierSettingsProvider provider,
  ) {
    final nameCtrl = TextEditingController();
    final buyCtrl = TextEditingController(text: "1,0000");
    final sellCtrl = TextEditingController(text: "1,0000");
    final addonCtrl = TextEditingController(text: "0,00");

    if (provider.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori listesi yüklenemedi.")),
      );
      return;
    }

    String selectedCategory = provider.categories.first.id;
    const String fixedSourceKey = "ALTIN"; // Sabit Değer
    const String fixedSourceLabel = "Has Altın (ALTIN)"; // Görünen Değer

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final selectedCatObj = provider.categories.firstWhere(
              (c) => c.id == selectedCategory,
              orElse: () => provider.categories.first,
            );
            final isCreditCard = selectedCatObj.name == "Kredi Kartı";

            return AlertDialog(
              backgroundColor: Colors.white, // Arka planı beyaz yapar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_circle, color: Color(0xFF0D1B46)),
                  SizedBox(width: 10),
                  Text(
                    "Yeni Ürün Ekle",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(),
                      ),
                      items: provider.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setStateModal(() => selectedCategory = val!);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ürün Adı",
                        hintText: "Örn: 22 Ayar Halhal",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // SABİT ENDEKS ALANI (Read Only)
                    TextFormField(
                      initialValue: fixedSourceLabel,
                      readOnly: true,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Endeks",
                        helperText:
                            "Yeni ürünler varsayılan olarak Has Altın endekslidir.",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (!isCreditCard)
                          Expanded(
                            child: TextField(
                              controller: buyCtrl,
                              decoration: const InputDecoration(
                                labelText: "Alış",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [DecimalTextInputFormatter()],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (!isCreditCard) const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: sellCtrl,
                            decoration: const InputDecoration(
                              labelText: "Satış",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: addonCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ek Makas (TL)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [DecimalTextInputFormatter()],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "İptal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161A30),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    double buy =
                        double.tryParse(buyCtrl.text.replaceAll(',', '.')) ??
                        1.0;
                    double sell =
                        double.tryParse(sellCtrl.text.replaceAll(',', '.')) ??
                        1.0;
                    double addon =
                        double.tryParse(addonCtrl.text.replaceAll(',', '.')) ??
                        0.0;

                    final dto = CreateProductDto(
                      name: nameCtrl.text,
                      categoryId: selectedCategory,
                      sourceKey: fixedSourceKey,
                      buyMultiplier: isCreditCard ? 0 : buy,
                      sellMultiplier: sell,
                      addonAmount: addon,
                    );

                    provider.createProduct(dto).then((success) {
                      if (success) Navigator.pop(ctx);
                    });
                  },
                  child: const Text("Oluştur"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 4. DÜZENLEME MODALI (Angular Mantığı ile Update)
  void _showEditProductDialog(
    BuildContext context,
    MultiplierSettingsProvider provider,
    TenantProduct existingProduct,
  ) {
    // Controller'ları mevcut verilerle doldur
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

    // Kategori Seçimi (categoryId yoksa name'den bulmaya çalış)
    String selectedCategory = "";
    if (existingProduct.categoryId.isNotEmpty) {
      selectedCategory = existingProduct.categoryId;
    } else {
      // Fallback: Name ile eşleştir
      try {
        selectedCategory = provider.categories
            .firstWhere((c) => c.name == existingProduct.categoryName)
            .id;
      } catch (e) {
        if (provider.categories.isNotEmpty)
          selectedCategory = provider.categories.first.id;
      }
    }

    // Endeks Seçimi (Değiştirilemez - Sadece Görünür)
    String currentSourceKey = existingProduct.sourceKey.isNotEmpty
        ? existingProduct.sourceKey
        : "ALTIN";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final selectedCatObj = provider.categories.firstWhere(
              (c) => c.id == selectedCategory,
              orElse: () => provider.categories.first,
            );
            final isCreditCard = selectedCatObj.name == "Kredi Kartı";

            return AlertDialog(
              backgroundColor: Colors.white, // Arka planı beyaz yapar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF0D1B46)),
                  SizedBox(width: 10),
                  Text(
                    "Ürünü Düzenle",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(),
                      ),
                      items: provider.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setStateModal(() => selectedCategory = val!);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ürün Adı",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ENDEKS (SABİT - Angular'daki gibi disabled select yerine disabled input)
                    TextFormField(
                      initialValue: currentSourceKey,
                      readOnly: true,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Endeks",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (!isCreditCard)
                          Expanded(
                            child: TextField(
                              controller: buyCtrl,
                              decoration: const InputDecoration(
                                labelText: "Alış",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [DecimalTextInputFormatter()],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (!isCreditCard) const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: sellCtrl,
                            decoration: const InputDecoration(
                              labelText: "Satış",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: addonCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ek Makas (TL)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [DecimalTextInputFormatter()],
                    ),
                    const SizedBox(height: 15),

                    // AKTİF/PASİF SWİTCH
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ürün Yayında (Aktif)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: existingProduct.isActive,
                            onChanged: (val) {
                              setStateModal(
                                () => existingProduct.isActive = val,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Vazgeç",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B46),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Verileri Hazırla
                    double buy =
                        double.tryParse(buyCtrl.text.replaceAll(',', '.')) ??
                        0.0;
                    double sell =
                        double.tryParse(sellCtrl.text.replaceAll(',', '.')) ??
                        0.0;
                    double addon =
                        double.tryParse(addonCtrl.text.replaceAll(',', '.')) ??
                        0.0;

                    // Güncellenecek nesneyi oluştur (Angular mantığı: mevcut nesneyi güncelle)
                    existingProduct.name = nameCtrl.text;
                    existingProduct.categoryId = selectedCategory;
                    existingProduct.buyMultiplier = isCreditCard ? 0 : buy;
                    existingProduct.sellMultiplier = sell;
                    existingProduct.addonAmount = addon;
                    // isActive zaten yukarıda güncellendi

                    // Angular'daki saveEditedProduct() gibi, tek bir elemanı liste olarak updateProducts'a atıyoruz.
                    provider.updateProducts([existingProduct]).then((success) {
                      if (success) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ürün başarıyla güncellendi"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  },
                  child: const Text("Güncelle"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
