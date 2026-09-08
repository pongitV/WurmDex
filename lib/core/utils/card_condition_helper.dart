import 'package:flutter/material.dart';

class CardConditionHelper {
  /// Converts any raw condition string into a clean short standard abbreviation
  /// e.g.:
  /// - 'Near Mint' -> 'NM'
  /// - 'Slightly Played' -> 'SP'
  /// - 'Moderately Played' -> 'MP'
  /// - 'Heavily Played' -> 'HP'
  /// - 'Damaged' -> 'DMG'
  /// - 'Mint' -> 'MINT'
  /// - 'PSA 10' -> 'Graduada (PSA 10)'
  /// - 'Graduada (10)' -> 'Graduada (10)'
  /// - 'BGS 9.5' -> 'Graduada (BGS 9.5)'
  /// Defaults to 'NM' (industry market reference standard) if empty or null.
  static String getShortCondition(String? condition) {
    if (condition == null || condition.trim().isEmpty) return 'NM';
    final raw = condition.trim();
    final lower = raw.toLowerCase();

    // Graded cards (PSA, BGS, CGC, ACE, or explicitly Graduada)
    if (lower.contains('psa') ||
        lower.contains('bgs') ||
        lower.contains('cgc') ||
        lower.contains('ace') ||
        lower.contains('gradua') ||
        lower.contains('graded')) {
      if (raw.toLowerCase().startsWith('graduada')) {
        return raw;
      }
      return 'Graduada ($raw)';
    }

    if (lower == 'near mint' || lower == 'nm' || lower == 'near_mint') {
      return 'NM';
    }
    if (lower == 'slightly played' ||
        lower == 'sp' ||
        lower == 'ex' ||
        lower == 'excellent' ||
        lower == 'lightly played' ||
        lower == 'lp') {
      return 'SP';
    }
    if (lower == 'moderately played' || lower == 'mp' || lower == 'good') {
      return 'MP';
    }
    if (lower == 'heavily played' || lower == 'hp' || lower == 'played') {
      return 'HP';
    }
    if (lower == 'damaged' ||
        lower == 'dmg' ||
        lower == 'danificada' ||
        lower == 'poor') {
      return 'DMG';
    }
    if (lower == 'mint' || lower == 'gem mint' || lower == 'perfeita') {
      return 'MINT';
    }

    return raw;
  }

  /// Price multiplier relative to Near Mint (NM standard reference = 1.0)
  static double getConditionMultiplier(String? condition) {
    final short = getShortCondition(condition).toUpperCase();
    if (short.contains('GRADUADA')) {
      if (short.contains('10')) return 3.5;
      if (short.contains('9.5')) return 2.2;
      if (short.contains('9')) return 1.8;
      if (short.contains('8')) return 1.3;
      return 2.0;
    }
    switch (short) {
      case 'MINT':
        return 1.10;
      case 'NM':
        return 1.0;
      case 'SP':
        return 0.85;
      case 'MP':
        return 0.70;
      case 'HP':
        return 0.50;
      case 'DMG':
        return 0.30;
      default:
        return 1.0;
    }
  }

  /// Distinctive collector accent color for each condition badge
  static Color getConditionColor(String shortCondition) {
    final s = shortCondition.toUpperCase();
    if (s.contains('GRADUADA') || s.contains('PSA') || s.contains('BGS') || s.contains('CGC')) {
      return const Color(0xFFFFB300); // Collector Gold
    }
    switch (s) {
      case 'MINT':
        return const Color(0xFF00E676); // Mint Emerald
      case 'NM':
        return const Color(0xFF4CAF50); // Near Mint Green
      case 'SP':
        return const Color(0xFF03A9F4); // Slightly Played Sky Blue
      case 'MP':
        return const Color(0xFFFF9800); // Moderately Played Amber
      case 'HP':
        return const Color(0xFFFF5722); // Heavily Played Deep Orange
      case 'DMG':
        return const Color(0xFFE53935); // Damaged Crimson
      default:
        return const Color(0xFF90A4AE); // Slate Grey
    }
  }
}
