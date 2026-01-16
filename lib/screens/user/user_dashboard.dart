import 'dart:async'; // Timer için
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sarfiyum_mobile/providers/gold_hub_provider.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/providers/category_settings_provider.dart';
import 'package:sarfiyum_mobile/models/price_data.dart';
import 'package:sarfiyum_mobile/models/multiplier_models.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';
import 'package:sarfiyum_mobile/services/secure_storage_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedCategoryIndex = 0;

  // 🔥 Token Süresi Sayacı
  Timer? _tokenExpirationTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final goldProvider = Provider.of<GoldHubProvider>(context, listen: false);
      final catProvider = Provider.of<CategorySettingsProvider>(
        context,
        listen: false,
      );

      // 1. STATE SIFIRLAMA
      goldProvider.resetState();
      goldProvider.addListener(_handleHubChanges);

      // 2. TOKEN SÜRESİ KONTROLÜ
      _checkTokenExpiration();

      // 3. VERİLERİ YÜKLE
      await goldProvider.loadProductConfigurations();

      catProvider.loadCategories().then((_) {
        if (mounted && catProvider.categories.isNotEmpty) {
          _initTabController(catProvider.categories.length);
        }
      });

      // 4. BAĞLANTIYI BAŞLAT
      goldProvider.startConnection();
    });
  }

  // Token ve Logout işlemleri
  void _checkTokenExpiration() async {
    final token = await SecureStorageService().getToken();
    if (token != null) {
      if (JwtDecoder.isExpired(token)) {
        _forceLogout("Token süresi dolmuş");
        return;
      }
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final duration = expirationDate.difference(DateTime.now());
      _tokenExpirationTimer?.cancel();
      _tokenExpirationTimer = Timer(duration, () {
        _forceLogout("Token süresi (1 dk) doldu");
      });
    }
  }

  void _forceLogout(String reason) {
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).handleUnauthorized();
    }
  }

  void _handleHubChanges() {
    if (!mounted) return;
    final goldProvider = Provider.of<GoldHubProvider>(context, listen: false);
    if (goldProvider.forceLogoutTriggered) {
      goldProvider.removeListener(_handleHubChanges);
      _forceLogout("SignalR Kick");
    }
  }

  void _initTabController(int length) {
    if (!mounted) return;
    setState(() {
      _tabController = TabController(length: length, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          setState(() {
            _selectedCategoryIndex = _tabController!.index;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tokenExpirationTimer?.cancel();
    try {
      final goldProvider = Provider.of<GoldHubProvider>(context, listen: false);
      goldProvider.removeListener(_handleHubChanges);
      goldProvider.stopConnection();
    } catch (_) {}
    _tabController?.dispose();
    super.dispose();
  }

  PriceData _getHeaderData(List<PriceData> prices, String type) {
    return prices.firstWhere(
      (p) {
        final s = p.symbol.toUpperCase();
        return type == 'USD'
            ? (s.contains('USD') || s.contains('DOLAR'))
            : (s.contains('EUR') || s.contains('EURO'));
      },
      orElse: () => PriceData(
        symbol: type == 'USD' ? 'Dolar/TRY' : 'Euro/TRY',
        bid: 0,
        ask: 0,
        category: 'Döviz',
        description: '',
        source: '',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldProvider = context.watch<GoldHubProvider>();
    final catProvider = context.watch<CategorySettingsProvider>();
    final user = Provider.of<AuthProvider>(context).user;

    final usdData = _getHeaderData(goldProvider.prices, 'USD');
    final eurData = _getHeaderData(goldProvider.prices, 'EUR');

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user?.tenantLogoUrl != null) ...[
              Container(
                height: 32,
                width: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  "https://sarfiyum.com${user!.tenantLogoUrl}",
                  fit: BoxFit.contain,
                  errorBuilder: (c, o, s) =>
                      const Icon(Icons.business, size: 20),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                user?.tenantName?.toUpperCase() ?? "SARFİYUM",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. HEADER ALANI
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF161A30), Color(0xFF243B55)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildHeaderItem(usdData)),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(child: _buildHeaderItem(eurData)),
              ],
            ),
          ),

          // 2. İÇERİK
          Expanded(
            child: catProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : catProvider.categories.isEmpty
                ? const Center(child: Text("Kategori bulunamadı."))
                : _buildTabContent(catProvider.categories, goldProvider.prices),
          ),

          // 3. ALT SEKMELER (TAB BAR)
          if (!catProvider.isLoading &&
              catProvider.categories.isNotEmpty &&
              _tabController != null)
            _buildBottomTabBar(catProvider.categories),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTabContent(
    List<Category> categories,
    List<PriceData> allPrices,
  ) {
    if (_tabController == null) return const SizedBox();

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: categories.map((category) {
        final categoryList = allPrices.where((p) {
          return p.categoryIndex == category.orderIndex;
        }).toList();

        final uniqueMap = <String, PriceData>{};
        for (var item in categoryList) {
          uniqueMap[item.symbol] = item;
        }
        final uniqueList = uniqueMap.values.toList();

        uniqueList.sort(
          (a, b) => (a.orderIndex ?? 9999).compareTo(b.orderIndex ?? 9999),
        );

        return _buildPriceList(uniqueList, category.name);
      }).toList(),
    );
  }

  Widget _buildPriceList(List<PriceData> prices, String categoryName) {
    if (prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              "$categoryName verisi bekleniyor...",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // TABLO BAŞLIĞI
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Birim ⇅",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 3, // Oranı biraz artırdık rahat sığsın
                child: Text(
                  "Alış",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 3, // Oranı biraz artırdık rahat sığsın
                child: Text(
                  "Satış",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // LİSTE ELEMANLARI
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: prices.length,
            separatorBuilder: (c, i) => Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              return _buildPriceCard(prices[index]);
            },
          ),
        ),
      ],
    );
  }

  // 🔥 TAB BAR ALANI (ÇİZGİ KALDIRILDI)
  Widget _buildBottomTabBar(List<Category> categories) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          isScrollable: false, // 5 Eşit parça
          // 🔥 ÇİZGİYİ KALDIRAN KISIM BURASI
          indicator: const BoxDecoration(), // Boş dekorasyon = Çizgi yok
          dividerColor: Colors.transparent, // Alt ayraç rengi şeffaf

          labelColor: const Color(0xFF161A30),
          unselectedLabelColor: Colors.grey,
          labelPadding: EdgeInsets.zero,
          onTap: (index) {
            setState(() => _selectedCategoryIndex = index);
          },
          tabs: categories.map((cat) {
            return Tab(
              height: 70,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      cat.name.replaceAll('i', 'İ').toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🔥 ÜRÜN KARTI (Oklar ve Overflow Hatası Giderilmiş Hali)
  Widget _buildPriceCard(PriceData item) {
    final bool isCurrency = item.category.contains("Döviz");
    final formatter = NumberFormat(
      isCurrency ? "#,##0.000" : "#,##0.00",
      "tr_TR",
    );

    Color bgColor = Colors.white;
    if (item.askFlashColor != null || item.bidFlashColor != null) {
      Color flash =
          item.askFlashColor ?? item.bidFlashColor ?? Colors.transparent;
      bgColor = flash.withOpacity(0.1);
    }

    bool isCreditCard = item.category.contains("Kredi");

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          // 1. SOL: SEMBOL
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                if (item.description != item.symbol &&
                    item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 2. ORTA: ALIŞ FİYATI + OK (Hatasız)
          Expanded(
            flex: 3, // Flex artırıldı, yer açıldı
            child: _buildPriceCell(
              priceText: isCreditCard ? "" : formatter.format(item.bid),
              // Eğer modelde bid için ayrı yön varsa onu kullan, yoksa genel yönü kullan
              isUp: item.isAskUp,
              hasArrow: !isCreditCard,
            ),
          ),

          // 3. SAĞ: SATIŞ FİYATI + OK (Hatasız)
          Expanded(
            flex: 3, // Flex artırıldı, yer açıldı
            child: _buildPriceCell(
              priceText: formatter.format(item.ask),
              isUp: item.isAskUp,
              hasArrow: true,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 YENİ: Fiyat ve Ok Hücresini Çizen Yardımcı Metod (Kod tekrarını ve hataları önler)
  Widget _buildPriceCell({
    required String priceText,
    required bool isUp,
    required bool hasArrow,
  }) {
    // Renk ve İkon Seçimi
    Color trendColor = isUp ? Colors.green : Colors.red;
    IconData trendIcon = isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    // Fiyat Rengi
    Color valueColor = const Color(0xFF2C3E50);

    return FittedBox(
      // 🔥 FittedBox: Yazı sığmazsa otomatik küçülür, "flowed by pixels" hatasını çözer.
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            priceText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: valueColor,
            ),
          ),
          if (hasArrow && priceText.isNotEmpty) ...[
            const SizedBox(width: 2),
            Icon(trendIcon, color: trendColor, size: 24),
          ],
        ],
      ),
    );
  }

  // Header Tasarımı (Değişmedi)
  Widget _buildHeaderItem(PriceData item) {
    final formatter = NumberFormat("#,##0.000", "tr_TR");

    Color iconColor = Colors.grey;
    if (item.isAskUp)
      iconColor = Colors.greenAccent;
    else if (!item.isAskUp)
      iconColor = Colors.redAccent;

    IconData icon = item.isAskUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    String title = item.symbol;
    if (title.contains('USD') || title.contains('Dolar'))
      title = 'DOLAR';
    else if (title.contains('EUR') || title.contains('Euro'))
      title = 'EURO';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatter.format(item.ask),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: iconColor, size: 28),
          ],
        ),
      ],
    );
  }
}
