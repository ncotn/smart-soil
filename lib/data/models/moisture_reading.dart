import 'package:flutter/material.dart';

enum SoilStatus {
  dry,
  normal,
  wet,
}

class SoilReading {
  final double moisturePercentage;
  final int rawValue;
  final DateTime timestamp;
  final SoilStatus status;

  const SoilReading({
    required this.moisturePercentage,
    required this.rawValue,
    required this.timestamp,
    required this.status,
  });

  factory SoilReading.fromRaw({
    required int rawValue,
    required double moisturePercentage,
    DateTime? timestamp,
  }) {
    final status = statusFromPercentage(moisturePercentage);
    return SoilReading(
      moisturePercentage: moisturePercentage.clamp(0.0, 100.0),
      rawValue: rawValue,
      timestamp: timestamp ?? DateTime.now(),
      status: status,
    );
  }

  factory SoilReading.fromMap(Map<dynamic, dynamic> map) {
    final raw = (map['raw'] is num) ? (map['raw'] as num).toInt() : 2000;
    final pct = (map['percentage'] is num)
        ? (map['percentage'] as num).toDouble()
        : 50.0;
    final timeMillis = (map['timestamp'] is num)
        ? (map['timestamp'] as num).toInt()
        : DateTime.now().millisecondsSinceEpoch;

    return SoilReading(
      moisturePercentage: pct.clamp(0.0, 100.0),
      rawValue: raw,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timeMillis),
      status: statusFromPercentage(pct),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'raw': rawValue,
      'percentage': moisturePercentage,
      'status': status.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static SoilStatus statusFromPercentage(double pct) {
    if (pct < 35.0) return SoilStatus.dry;
    if (pct <= 75.0) return SoilStatus.normal;
    return SoilStatus.wet;
  }

  String get statusLabel {
    switch (status) {
      case SoilStatus.dry:
        return 'Dry Soil (Needs Water)';
      case SoilStatus.normal:
        return 'Optimal Moisture';
      case SoilStatus.wet:
        return 'Wet Soil (Saturated)';
    }
  }

  Color get statusColor {
    switch (status) {
      case SoilStatus.dry:
        return const Color(0xFFEF4444); // Amber/Red
      case SoilStatus.normal:
        return const Color(0xFF10B981); // Emerald Green
      case SoilStatus.wet:
        return const Color(0xFF3B82F6); // Vibrant Blue
    }
  }
}
