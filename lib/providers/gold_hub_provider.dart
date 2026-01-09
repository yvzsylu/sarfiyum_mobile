import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/price_data.dart';

class GoldHubProvider with ChangeNotifier {
  HubConnection? _hubConnection;
  final _storage = const FlutterSecureStorage();

  List<PriceData> _prices = [];
  List<PriceData> get prices => _prices;

  String _connectionStatus = 'Bağlantı Bekleniyor...';
  String get connectionStatus => _connectionStatus;

  // Özel durum: Oturum zorla kapatıldı mı?
  bool _forceLogoutTriggered = false;
  bool get forceLogoutTriggered => _forceLogoutTriggered;

  final String _hubUrl = "https://sarfiyum.com/goldhub";

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

    // 🔥 BAĞLANTI KOPMA VE GÜVENLİK
    _hubConnection?.onclose(({Exception? error}) {
      _connectionStatus = 'Bağlantı Koptu';
      print("Hub Koptu: $error");

      // Eğer hata varsa ve sunucu bağlantıyı kestiyse (Abort)
      if (error != null) {
        _forceLogoutTriggered = true;
      }

      notifyListeners();
    });

    try {
      await _hubConnection?.start();
      _connectionStatus = 'Bağlandı';
      _forceLogoutTriggered = false; // Bağlanınca sıfırla
      print("✅ GoldHub Bağlantısı Başarılı");
      notifyListeners();
    } catch (e) {
      _connectionStatus = 'Bağlantı Hatası: $e';

      // 401 Hatası alırsak direkt logout tetikle
      if (e.toString().contains("401") ||
          e.toString().contains("Unauthorized")) {
        _forceLogoutTriggered = true;
      }

      print("Hub Hata: $e");
      notifyListeners();
    }
  }

  // --- VERİ İŞLEME VE GÜNCELLEME ---
  void _processData(List<dynamic> rawData) {
    List<PriceData> incomingList = rawData
        .map((json) => PriceData.fromJson(json))
        .toList();

    if (_prices.isEmpty) {
      _prices = incomingList;
    } else {
      for (var newItem in incomingList) {
        var existingIndex = _prices.indexWhere(
          (p) => p.symbol == newItem.symbol && p.category == newItem.category,
        );

        if (existingIndex != -1) {
          var existingItem = _prices[existingIndex];

          // --- 1. ALIŞ (BID) KONTROLÜ ---
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

          // --- 2. SATIŞ (ASK) KONTROLÜ ---
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

          // Zamanlayıcı (600ms sonra rengi temizle)
          if (newItem.bidFlashColor != null || newItem.askFlashColor != null) {
            Future.delayed(const Duration(milliseconds: 600), () {
              var currentIdx = _prices.indexWhere(
                (p) =>
                    p.symbol == newItem.symbol &&
                    p.category == newItem.category,
              );

              if (currentIdx != -1) {
                if (_prices[currentIdx].bidFlashColor != null) {
                  _prices[currentIdx].bidFlashColor = null;
                }
                if (_prices[currentIdx].askFlashColor != null) {
                  _prices[currentIdx].askFlashColor = null;
                }
                notifyListeners();
              }
            });
          }
        } else {
          _prices.add(newItem);
        }
      }
    }

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
