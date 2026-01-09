import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sarfiyum_mobile/providers/gold_hub_provider.dart';
import 'package:sarfiyum_mobile/providers/auth_provider.dart';
import 'package:sarfiyum_mobile/models/price_data.dart';
import 'package:sarfiyum_mobile/widgets/custom_drawer.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();

    // Bağlantıyı başlat ve dinleyici ekle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goldProvider = Provider.of<GoldHubProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      goldProvider.startConnection();

      // 🔥 LOGOUT DİNLEYİCİSİ
      goldProvider.addListener(() {
        if (goldProvider.forceLogoutTriggered) {
          // 1. Uyarı Ver
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Oturumunuz başka bir cihazda açıldığı için sonlandırıldı.",
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // 2. Çıkış Yap
          authProvider.logout();
          goldProvider.stopConnection();

          // Not: AuthWrapper (Main.dart) user null olunca otomatik Login'e atacaktır.
        }
      });
    });
  }

  // --- YARDIMCI FONKSİYONLAR ---
  bool _isUsd(PriceData p) {
    final s = p.symbol.toUpperCase();
    return s.contains('USD') || s.contains('DOLAR');
  }

  bool _isEur(PriceData p) {
    final s = p.symbol.toUpperCase();
    return s.contains('EUR') || s.contains('EURO');
  }

  int _getCategoryPriority(String category) {
    switch (category) {
      case 'Maden':
        return 1;
      case 'Bilezik':
        return 2;
      case 'Ata & Reşat':
        return 3;
      case 'Kredi Kartı':
        return 4;
      default:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldProvider = Provider.of<GoldHubProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Header Verileri
    final usdData = goldProvider.prices.firstWhere(
      (p) => _isUsd(p),
      orElse: () => PriceData(
        symbol: 'Dolar/TRY',
        bid: 0,
        ask: 0,
        category: 'Döviz',
        description: '',
        source: '',
        timestamp: DateTime.now(),
        orderIndex: 0,
      ),
    );

    final eurData = goldProvider.prices.firstWhere(
      (p) => _isEur(p),
      orElse: () => PriceData(
        symbol: 'Euro/TRY',
        bid: 0,
        ask: 0,
        category: 'Döviz',
        description: '',
        source: '',
        timestamp: DateTime.now(),
        orderIndex: 0,
      ),
    );

    // Liste Filtreleme
    List<PriceData> filteredList = goldProvider.prices.where((p) {
      bool isHeaderItem = _isUsd(p) || _isEur(p);
      bool isCurrencyCategory = p.category == 'Döviz';
      if (isHeaderItem || isCurrencyCategory) return false;
      return true;
    }).toList();

    // Sıralama
    filteredList.sort((a, b) {
      int priorityA = _getCategoryPriority(a.category);
      int priorityB = _getCategoryPriority(b.category);
      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      return (a.orderIndex ?? 9999).compareTo(b.orderIndex ?? 9999);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(
          authProvider.user?.tenantName?.toUpperCase() ?? "SARFİYUM",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 1. HEADER ALANI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 10,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF161A30), Color(0xFF161A30)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDynamicHeaderItem(usdData),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildDynamicHeaderItem(eurData),
              ],
            ),
          ),

          // 2. TABLO BAŞLIKLARI
          Container(
            color: const Color(0xFF222831),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

          // 3. LİSTE
          Expanded(
            child: goldProvider.prices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      bool showHeader = index == 0;

                      if (!showHeader) {
                        final prevItem = filteredList[index - 1];
                        if (item.category != prevItem.category)
                          showHeader = true;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) _buildCategoryHeader(item.category),
                          _buildPriceRow(item),
                          const Divider(height: 1, color: Colors.grey),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String categoryName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color.fromARGB(255, 182, 187, 196),
      child: Text(
        categoryName.toUpperCase(),
        style: const TextStyle(
          color: Color.fromARGB(255, 22, 26, 48),
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDynamicHeaderItem(PriceData item) {
    final formatter = NumberFormat("#,##0.0000", "tr_TR");
    String priceStr = formatter.format(item.ask);

    Color arrowColor = item.askFlashColor ?? Colors.white;
    IconData icon = item.isAskUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    Color finalIconColor = item.askFlashColor != null
        ? arrowColor
        : Colors.transparent;

    String title = item.symbol;
    if (_isUsd(item))
      title = 'DOLAR';
    else if (_isEur(item))
      title = 'EURO';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              priceStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(icon, color: finalIconColor, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(PriceData item) {
    final formatter = NumberFormat("#,##0.00", "tr_TR");
    final displayAsk = formatter.format(item.ask);
    final bool isCC = (item.category == 'Kredi Kartı');
    final displayBid = isCC ? "" : formatter.format(item.bid);

    Color bgColor = (item.askFlashColor != null || item.bidFlashColor != null)
        ? (item.askFlashColor ?? item.bidFlashColor ?? Colors.blue).withOpacity(
            0.15,
          )
        : Colors.white;

    Color bidColor = item.bidFlashColor ?? const Color(0xFF161A30);
    Color askColor = item.askFlashColor ?? const Color(0xFF161A30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                if (item.description.isNotEmpty &&
                    item.description != item.symbol)
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
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
                  displayBid,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: bidColor,
                  ),
                ),
                if (!isCC)
                  Icon(
                    item.isBidUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: item.bidFlashColor ?? Colors.transparent,
                    size: 20,
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
                  displayAsk,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: askColor,
                  ),
                ),
                Icon(
                  item.isAskUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: item.askFlashColor ?? Colors.transparent,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
