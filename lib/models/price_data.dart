import 'package:flutter/material.dart';

class PriceData {
  String symbol;
  double bid;
  double ask;
  String category;
  String description;
  String source;
  DateTime timestamp;

  // 🔥 BU ALANLAR EKLENMELİ
  int? orderIndex;
  int? categoryIndex; // Hub'dan gelen "Maden mi Döviz mi?" bilgisini tutar

  // UI Renkleri
  Color? bidFlashColor;
  Color? askFlashColor;
  bool isBidUp;
  bool isAskUp;

  PriceData({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.category,
    required this.description,
    required this.source,
    required this.timestamp,
    this.orderIndex,
    this.categoryIndex, // Constructor'a eklendi
    this.bidFlashColor,
    this.askFlashColor,
    this.isBidUp = false,
    this.isAskUp = false,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      symbol: json['symbol'] ?? '',
      bid: (json['bid'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),

      // 🔥 JSON EŞLEŞTİRMESİ
      orderIndex: json['orderIndex'],
      categoryIndex: json['categoryIndex'], // Burası ÇOK ÖNEMLİ
    );
  }
}
