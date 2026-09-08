import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';

enum PriceTrendDirection {
  surging,
  dropping,
  stable,
}

class MonitoredCardItem {
  final UserCard card;
  final String? folderName;
  final Color? folderColor;
  final double purchasePriceBrl;
  final double estimatedCurrentPriceBrl;
  final double nominalDifferenceBrl;
  final double percentageChange;
  final PriceTrendDirection trendDirection;

  const MonitoredCardItem({
    required this.card,
    this.folderName,
    this.folderColor,
    required this.purchasePriceBrl,
    required this.estimatedCurrentPriceBrl,
    required this.nominalDifferenceBrl,
    required this.percentageChange,
    required this.trendDirection,
  });

  bool get isSurging => trendDirection == PriceTrendDirection.surging;
  bool get isDropping => trendDirection == PriceTrendDirection.dropping;
  bool get isStable => trendDirection == PriceTrendDirection.stable;
}
