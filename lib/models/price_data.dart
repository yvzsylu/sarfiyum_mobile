import 'dart:ui';
import 'package:flutter/material.dart';

class PriceData {
  String symbol;
  String category;
  double bid; // Alış
  double ask; // Satış
  String description;
  String source;
  DateTime timestamp;
  int orderIndex;

  // --- UI Durumları (GÜNCELLENDİ) ---
  // Alış ve Satış için ayrı renk ve yön takibi
  Color? bidFlashColor; // Alış rengi (Yeşil/Kırmızı)
  Color? askFlashColor; // Satış rengi (Yeşil/Kırmızı)

  bool isBidUp; // Alış fiyatı arttı mı?
  bool isAskUp; // Satış fiyatı arttı mı?

  PriceData({
    required this.symbol,
    required this.category,
    required this.bid,
    required this.ask,
    required this.description,
    required this.source,
    required this.timestamp,
    required this.orderIndex,
    this.bidFlashColor,
    this.askFlashColor,
    this.isBidUp = false,
    this.isAskUp = false,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      symbol: json['symbol'] ?? '',
      category: json['category'] ?? '',
      bid: (json['bid'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}
