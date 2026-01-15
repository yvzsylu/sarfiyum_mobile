import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/price_data.dart';
import '../services/base_api_service.dart';
import '../models/service_result.dart';
import '../models/multiplier_models.dart';

class GoldHubProvider with ChangeNotifier {
  HubConnection? _hubConnection;
  final _storage = const FlutterSecureStorage();
  final _api = BaseApiService(); // API servisi

  List<PriceData> _prices = [];
  List<PriceData> get prices => _prices;

  String _connectionStatus = 'Bağlantı Bekleniyor...';
  String get connectionStatus => _connectionStatus;

  bool _forceLogoutTriggered = false;
  bool get forceLogoutTriggered => _forceLogoutTriggered;

  final String _hubUrl = "https://sarfiyum.com/goldhub";

  // 🔥 FİLTRELEME HARİTASI (Key: KATEGORI_URUNADI, Value: ShowOnMobile)
  final Map<String, bool> _productVisibilityMap = {};
  bool _isConfigLoaded = false;

  // --- 1. KEY OLUŞTURUCU (STANDARTLAŞTIRMA) ---
  String _generateUniqueKey(String? category, String? name) {
    final cat = (category ?? "").trim().toUpperCase();
    final nm = (name ?? "").trim().toUpperCase();
    return "${cat}_$nm"; // Örn: MADEN_HAS ALTIN
  }

  // --- 2. ÜRÜN AYARLARINI YÜKLE ---
  Future<void> loadProductConfigurations() async {
    try {
      final response = await _api.get<List<dynamic>>("customer/product/list");

      if (response.isSuccess && response.data != null) {
        _productVisibilityMap.clear();

        final products = response.data!
            .map((e) => TenantProduct.fromJson(e))
            .toList();

        for (var p in products) {
          // Veritabanındaki 'CategoryName' ve 'Name' ile anahtar üret
          final uniqueKey = _generateUniqueKey(p.categoryName, p.name);
          _productVisibilityMap[uniqueKey] = p.showOnMobile;
        }

        _isConfigLoaded = true;

        // Config yüklendikten sonra mevcut listedeki yasaklıları temizle
        _refreshCurrentList();

        print(
          "✅ Mobil Konfigürasyonu Yüklendi. Ürün Sayısı: ${_productVisibilityMap.length}",
        );
        notifyListeners();
      }
    } catch (e) {
      print("Ürün ayarları yüklenemedi: $e");
    }
  }

  // Mevcut listeden gizli olanları temizler
  void _refreshCurrentList() {
    if (_prices.isEmpty) return;

    _prices.removeWhere((item) {
      final key = _generateUniqueKey(item.category, item.symbol);

      // Haritada varsa değerini al, yoksa (yeni ürünse) true kabul et
      final isVisible = _productVisibilityMap.containsKey(key)
          ? _productVisibilityMap[key]!
          : true;

      return !isVisible; // Görünür değilse (false ise) sil
    });

    notifyListeners();
  }

  Future<void> startConnection() async {
    if (_hubConnection?.state == HubConnectionState.Connected) return;

    final token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      _connectionStatus = 'Yetki Hatası (Token Yok)';
      notifyListeners();
      return;
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            skipNegotiation: true,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("ReceivePrices", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final List<dynamic> dataList = arguments[0] as List<dynamic>;
        _processData(dataList);
      }
    });

    _hubConnection?.onclose(({Exception? error}) {
      _connectionStatus = 'Bağlantı Koptu';
      if (error != null) {
        _forceLogoutTriggered = true;
      }
      notifyListeners();
    });

    try {
      await _hubConnection?.start();
      _connectionStatus = 'Bağlandı';
      _forceLogoutTriggered = false;
      print("✅ GoldHub Bağlantısı Başarılı");
      notifyListeners();
    } catch (e) {
      _connectionStatus = 'Bağlantı Hatası: $e';
      if (e.toString().contains("401") ||
          e.toString().contains("Unauthorized")) {
        _forceLogoutTriggered = true;
      }
      notifyListeners();
    }
  }

  // --- 3. VERİ İŞLEME VE FİLTRELEME ---
  void _processData(List<dynamic> rawData) {
    List<PriceData> incomingList = rawData
        .map((json) => PriceData.fromJson(json))
        .toList();

    for (var newItem in incomingList) {
      // 🔥 A. GÖRÜNÜRLÜK KONTROLÜ
      // SignalR'dan gelen 'category' ve 'symbol' ile anahtar oluştur
      final key = _generateUniqueKey(newItem.category, newItem.symbol);

      if (_isConfigLoaded) {
        // Haritada var mı? Varsa değerini al, yoksa true
        final isVisible = _productVisibilityMap.containsKey(key)
            ? _productVisibilityMap[key]!
            : true;

        // Eğer mobilde gösterilmesi kapalıysa, bu veriyi işleme
        if (!isVisible) continue;
      }

      // 🔥 B. LİSTE GÜNCELLEME (Kategori + Sembol Eşleşmesi)
      // Sadece sembol yetmez, kategori de tutmalı!
      var existingIndex = _prices.indexWhere(
        (p) => p.symbol == newItem.symbol && p.category == newItem.category,
      );

      if (existingIndex != -1) {
        var existingItem = _prices[existingIndex];

        // Alış (Bid) Değişimi
        if (newItem.bid != existingItem.bid) {
          if (newItem.bid > existingItem.bid) {
            newItem.bidFlashColor = Colors.green;
            newItem.isBidUp = true;
          } else {
            newItem.bidFlashColor = Colors.red;
            newItem.isBidUp = false;
          }
        } else {
          newItem.bidFlashColor = existingItem.bidFlashColor;
          newItem.isBidUp = existingItem.isBidUp;
        }

        // Satış (Ask) Değişimi
        if (newItem.ask != existingItem.ask) {
          if (newItem.ask > existingItem.ask) {
            newItem.askFlashColor = Colors.green;
            newItem.isAskUp = true;
          } else {
            newItem.askFlashColor = Colors.red;
            newItem.isAskUp = false;
          }
        } else {
          newItem.askFlashColor = existingItem.askFlashColor;
          newItem.isAskUp = existingItem.isAskUp;
        }

        _prices[existingIndex] = newItem;

        // Flash Temizleme
        if (newItem.bidFlashColor != null || newItem.askFlashColor != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
            // Index değişmiş olabilir, tekrar bul
            var currentIdx = _prices.indexWhere(
              (p) =>
                  p.symbol == newItem.symbol && p.category == newItem.category,
            );

            if (currentIdx != -1) {
              bool changed = false;
              if (_prices[currentIdx].bidFlashColor != null) {
                _prices[currentIdx].bidFlashColor = null;
                changed = true;
              }
              if (_prices[currentIdx].askFlashColor != null) {
                _prices[currentIdx].askFlashColor = null;
                changed = true;
              }
              if (changed) notifyListeners();
            }
          });
        }
      } else {
        // Yeni ürün (Filtreden geçtiği için ekliyoruz)
        _prices.add(newItem);
      }
    }

    // Sıralama
    _prices.sort(
      (a, b) => (a.orderIndex ?? 9999).compareTo(b.orderIndex ?? 9999),
    );

    notifyListeners();
  }

  void stopConnection() {
    _hubConnection?.stop();
    _forceLogoutTriggered = false;
  }
}
