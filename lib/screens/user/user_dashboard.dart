import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sarfiyum_mobile/providers/gold_hub_provider.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/providers/category_settings_provider.dart';
import 'package:sarfiyum_mobile/models/price_data.dart';
import 'package:sarfiyum_mobile/models/multiplier_models.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final goldProvider = Provider.of<GoldHubProvider>(context, listen: false);
      final catProvider = Provider.of<CategorySettingsProvider>(
        context,
        listen: false,
      );

      // 🔥 1. ÖNCE AYARLARI YÜKLE (Filtreleme için kritik)
      await goldProvider.loadProductConfigurations();

      // 2. KATEGORİLERİ YÜKLE
      catProvider.loadCategories().then((_) {
        if (mounted && catProvider.categories.isNotEmpty) {
          _initTabController(catProvider.categories.length);
        }
      });

      // 3. EN SON HUB BAŞLAT
      goldProvider.startConnection();
    });
  }

  void _initTabController(int length) {
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
    final authProvider = context.watch<AuthProvider>();
    final catProvider = context.watch<CategorySettingsProvider>();
    final user = authProvider.user;

    final usdData = _getHeaderData(goldProvider.prices, 'USD');
    final eurData = _getHeaderData(goldProvider.prices, 'EUR');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          // 1. HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF161A30),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderItem(usdData),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildHeaderItem(eurData),
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

          // 3. ALT SEKMELER
          if (!catProvider.isLoading &&
              catProvider.categories.isNotEmpty &&
              _tabController != null)
            _buildBottomTabBar(catProvider.categories),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    List<Category> categories,
    List<PriceData> allPrices,
  ) {
    if (_tabController == null) return const SizedBox();

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: categories.map((category) {
        // 1. Bu kategoriye ait ürünleri filtrele (Backend index'ine göre)
        final categoryList = allPrices.where((p) {
          return p.categoryIndex == category.orderIndex;
        }).toList();

        // 2. Aynı sembol tekrarını önle (Unique Map)
        // Provider zaten filtrelediği için burada extra gizleme mantığına gerek yok
        final uniqueMap = <String, PriceData>{};
        for (var item in categoryList) {
          uniqueMap[item.symbol] = item;
        }
        final uniqueList = uniqueMap.values.toList();

        // 3. Sırala
        uniqueList.sort(
          (a, b) => (a.orderIndex ?? 99).compareTo(b.orderIndex ?? 99),
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
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF222831),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Birim",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Alış",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Satış",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            itemCount: prices.length,
            separatorBuilder: (c, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildPriceCard(prices[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTabBar(List<Category> categories) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFF161A30),
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicator: const BoxDecoration(),
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          onTap: (index) {
            setState(() => _selectedCategoryIndex = index);
          },
          tabs: categories.asMap().entries.map((entry) {
            int idx = entry.key;
            Category cat = entry.value;
            bool isSelected = idx == _selectedCategoryIndex;
            bool isLast = idx == categories.length - 1;

            return Tab(
              height: 75,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          right: BorderSide(color: Colors.white24, width: 0.5),
                        ),
                ),
                child: Center(
                  child: Text(
                    cat.name.replaceAll('i', 'İ').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w500,
                      fontSize: 13,
                      height: 1.1,
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

  Widget _buildPriceCard(PriceData item) {
    final formatter = NumberFormat("#,##0.00", "tr_TR");

    Color bgColor = (item.askFlashColor != null || item.bidFlashColor != null)
        ? (item.askFlashColor ?? item.bidFlashColor ?? Colors.blue).withOpacity(
            0.1,
          )
        : Colors.white;

    Color bidColor = item.bidFlashColor ?? const Color(0xFF161A30);
    Color askColor = item.askFlashColor ?? const Color(0xFF161A30);

    // Kredi kartı kontrolü (İsime veya kategoriye göre)
    bool isCreditCard = item.category.contains("Kredi");

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF161A30),
                  ),
                ),
                if (item.description != item.symbol &&
                    item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isCreditCard ? "" : formatter.format(item.bid),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: bidColor,
                  ),
                ),
                if (!isCreditCard)
                  Icon(
                    item.isBidUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: item.bidFlashColor ?? Colors.transparent,
                    size: 18,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatter.format(item.ask),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: askColor,
                  ),
                ),
                Icon(
                  item.isAskUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: item.askFlashColor ?? Colors.transparent,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(PriceData item) {
    final formatter = NumberFormat("#,##0.0000", "tr_TR");
    Color color = item.askFlashColor ?? Colors.white;
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
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              formatter.format(item.ask),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              icon,
              color: item.askFlashColor != null ? color : Colors.transparent,
              size: 24,
            ),
          ],
        ),
      ],
    );
  }
}
