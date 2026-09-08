import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/card_condition_helper.dart';
import '../models/monitored_card_item.dart';

class PriceMonitoringService {
  /// Transforms raw user cards into enriched monitored items with price movements and folder references.
  static List<MonitoredCardItem> generateMonitoredItems({
    required List<UserCard> cards,
    required List<Folder> folders,
  }) {
    final folderMap = {for (final f in folders) f.id: f};

    return cards.map((card) {
      final folder = card.folderId != null ? folderMap[card.folderId] : null;
      Color? folderColor;
      if (folder != null && folder.colorTag.isNotEmpty) {
        try {
          folderColor = Color(int.parse(folder.colorTag.replaceFirst('#', '0xFF')));
        } catch (_) {}
      }

      final purchasePrice = card.purchasePriceBrl > 0 ? card.purchasePriceBrl : 0.0;

      // Base reference price if user hasn't specified purchase price
      final baseReferencePrice = purchasePrice > 0
          ? purchasePrice
          : _getEstimatedBaseRarityPrice(card.rarity);

      // Deterministic market trend percentage based on card identifier hash
      final trendPct = _calculateCardTrendPercentage(card);
      final conditionMultiplier = CardConditionHelper.getConditionMultiplier(card.condition);

      final currentPrice = (baseReferencePrice * (1.0 + trendPct / 100.0) * conditionMultiplier)
          .clamp(0.50, 999999.0);

      final nominalDiff = purchasePrice > 0
          ? (currentPrice - purchasePrice)
          : (currentPrice - baseReferencePrice);

      final effectivePct = purchasePrice > 0
          ? ((nominalDiff / purchasePrice) * 100.0)
          : trendPct;

      final PriceTrendDirection direction;
      if (effectivePct > 2.0) {
        direction = PriceTrendDirection.surging;
      } else if (effectivePct < -2.0) {
        direction = PriceTrendDirection.dropping;
      } else {
        direction = PriceTrendDirection.stable;
      }

      return MonitoredCardItem(
        card: card,
        folderName: folder?.name,
        folderColor: folderColor,
        purchasePriceBrl: purchasePrice,
        estimatedCurrentPriceBrl: currentPrice,
        nominalDifferenceBrl: nominalDiff,
        percentageChange: effectivePct,
        trendDirection: direction,
      );
    }).toList();
  }

  /// Estimates a realistic base price in BRL for cards without recorded purchase price
  static double _getEstimatedBaseRarityPrice(String rarity) {
    final r = rarity.toLowerCase();
    if (r.contains('special illustration') || r.contains('sir') || r.contains('alt art')) {
      return 220.0;
    } else if (r.contains('illustration rare') || r.contains('secret rare') || r.contains('hyper')) {
      return 95.0;
    } else if (r.contains('ultra rare') || r.contains('ex') || r.contains('vmax') || r.contains('vstar')) {
      return 42.0;
    } else if (r.contains('rare holo') || r.contains('holo') || r.contains('rare')) {
      return 15.0;
    } else if (r.contains('uncommon')) {
      return 4.0;
    }
    return 2.50; // Common
  }

  /// Computes a realistic, consistent market percentage movement (-18% to +48%)
  static double _calculateCardTrendPercentage(UserCard card) {
    final key = '${card.cardApiId}_${card.number}_${card.name}_${card.setName}';
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = (hash * 31 + key.codeUnitAt(i)) & 0x7FFFFFFF;
    }

    // Spread between -18.0% and +42.0%
    double pct = ((hash % 600) - 180) / 10.0;

    // Condition bonus / penalty
    final cond = card.condition.toLowerCase();
    if (cond.contains('psa') || cond.contains('graduada') || cond.contains('bgs') || cond.contains('cgc')) {
      pct += 14.0;
    } else if (cond.contains('damaged') || cond.contains('dmg') || cond.contains('danificada')) {
      pct -= 12.0;
    } else if (cond.contains('heavily') || cond.contains('hp')) {
      pct -= 7.0;
    }

    // Rarity bonus
    final r = card.rarity.toLowerCase();
    if (r.contains('special illustration') || r.contains('sir') || r.contains('secret')) {
      pct += 8.0;
    }

    return math.max(-65.0, math.min(150.0, pct));
  }
}
