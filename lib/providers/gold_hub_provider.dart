import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 🔥 Token decode için gerekli
import '../models/price_data.dart';
import '../services/base_api_service.dart';
import '../models/service_result.dart';
import '../models/multiplier_models.dart';

class GoldHubProvider with ChangeNotifier {
  HubConnection? _hubConnection;
  final _storage = const FlutterSecureStorage();
  final _api = BaseApiService();

  List<PriceData> _prices = [];
  List<PriceData> get prices => _prices;

  String _connectionStatus = 'Bağlantı Bekleniyor...';
  String get connectionStatus => _connectionStatus;

  // 🔥 Logout Tetikleyicisi
  bool _forceLogoutTriggered = false;
  bool get forceLogoutTriggered => _forceLogoutTriggered;

  final String _hubUrl = "https://sarfiyum.com/goldhub";

  // 🔥 FİLTRELEME HARİTASI
  final Map<String, bool> _productVisibilityMap = {};
  bool _isConfigLoaded = false;

  // --- 0. STATE SIFIRLAMA ---
  void resetState() {
    _forceLogoutTriggered = false;
    _prices = [];
    _connectionStatus = 'Bağlantı Bekleniyor...';
    stopConnection();
    notifyListeners();
  }

  // --- 1. KEY OLUŞTURUCU ---
  String _generateUniqueKey(String? category, String? name) {
    final cat = (category ?? "").trim().toUpperCase();
    final nm = (name ?? "").trim().toUpperCase();
    return "${cat}_$nm";
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
          final uniqueKey = _generateUniqueKey(p.categoryName, p.name);
          _productVisibilityMap[uniqueKey] = p.showOnMobile;
        }

        _isConfigLoaded = true;
        _refreshCurrentList();
        notifyListeners();
      }
    } catch (e) {
      print("Ürün ayarları yüklenemedi: $e");
    }
  }

  void _refreshCurrentList() {
    if (_prices.isEmpty) return;
    _prices.removeWhere((item) {
      final key = _generateUniqueKey(item.category, item.symbol);
      final isVisible = _productVisibilityMap.containsKey(key)
          ? _productVisibilityMap[key]!
          : true;
      return !isVisible;
    });
    notifyListeners();
  }

  Future<void> startConnection() async {
    _forceLogoutTriggered = false;

    if (_hubConnection?.state == HubConnectionState.Connected) {
      await stopConnection();
    }

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
            skipNegotiation:
                true, // Angular kodunda da muhtemelen true veya defaulttur, şimdilik böyle kalsın.
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // 1. Fiyatları Dinle
    _hubConnection?.on("ReceivePrices", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final List<dynamic> dataList = arguments[0] as List<dynamic>;
        _processData(dataList);
      }
    });

    // =================================================================
    // 🔥 2. CONCURRENT SESSION CONTROL (ForceCheckSession) - AYNI ANGULAR GİBİ
    // =================================================================
    _hubConnection?.on("ForceCheckSession", (arguments) async {
      if (arguments != null && arguments.length >= 2) {
        final serverSessionId = arguments[0] as String;
        final serverClientSource = arguments[1] as String;

        // a. Bu mesaj Mobile (2) için mi? (Web=1, Mobile=2)
        // Eğer string "Mobile" veya "2" geliyorsa işle. "Web" ise umursama.
        if (serverClientSource != 'Mobile' && serverClientSource != '2') {
          return;
        }

        print(
          "🔔 Sunucudan Mobile için oturum kontrolü geldi: $serverSessionId",
        );

        // b. Token'ı al ve bendeki SessionId ile karşılaştır
        final currentToken = await _storage.read(key: 'jwt_token');
        if (currentToken == null) return;

        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(currentToken);
          // Token içindeki claim ismi backend'de 'SessionId'
          final mySessionId =
              decodedToken['SessionId'] ?? decodedToken['sessionId'];

          // c. Eğer Backend'den gelen ID ile bendeki ID farklıysa -> ATILMALIYIM
          if (mySessionId != null && mySessionId != serverSessionId) {
            print(
              "⛔ ID Uyuşmazlığı! Benimki: $mySessionId, Sunucu: $serverSessionId. Atılıyorum...",
            );
            _forceLogoutTriggered = true;
            notifyListeners();
          }
        } catch (e) {
          print("Session check token decode hatası: $e");
        }
      }
    });
    // =================================================================

    // 3. Bağlantı Koptuğunda
    _hubConnection?.onclose(({Exception? error}) {
      _connectionStatus = 'Bağlantı Koptu';
      print("⚠️ SignalR Bağlantısı Koptu. Hata: $error");

      if (error != null) {
        final errStr = error.toString();
        if (errStr.contains("401") || errStr.contains("Unauthorized")) {
          _forceLogoutTriggered = true;
        }
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
      print("❌ SignalR Start Hatası: $e");

      if (e.toString().contains("401") ||
          e.toString().contains("Unauthorized") ||
          e.toString().contains("User is not authorized")) {
        print("🚨 Session Reddedildi: Force Logout Tetikleniyor...");
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
      final key = _generateUniqueKey(newItem.category, newItem.symbol);

      if (_isConfigLoaded) {
        final isVisible = _productVisibilityMap.containsKey(key)
            ? _productVisibilityMap[key]!
            : true;
        if (!isVisible) continue;
      }

      var existingIndex = _prices.indexWhere(
        (p) => p.symbol == newItem.symbol && p.category == newItem.category,
      );

      if (existingIndex != -1) {
        var existingItem = _prices[existingIndex];

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

        if (newItem.bidFlashColor != null || newItem.askFlashColor != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
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
        _prices.add(newItem);
      }
    }

    _prices.sort(
      (a, b) => (a.orderIndex ?? 9999).compareTo(b.orderIndex ?? 9999),
    );

    notifyListeners();
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      await _hubConnection?.stop();
    }
    _forceLogoutTriggered = false;
  }
}
