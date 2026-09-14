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
  static String getShortCondition(String? condition, {String gradedShortLabel = 'Graduada'}) {
    if (condition == null || condition.trim().isEmpty) return 'NM';
    final raw = condition.trim();
    final lower = raw.toLowerCase();

    // Graded cards (PSA, BGS, CGC, ACE, or explicitly Graduada)
    if (isGradedCondition(raw)) {
      if (lower.startsWith('gradua')) return raw;
      return '$gradedShortLabel ($raw)';
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

  /// True when the condition is a graded / slabbed card (PSA, BGS, CGC, etc.).
  static bool isGradedCondition(String? condition) {
    if (condition == null || condition.trim().isEmpty) return false;
    final lower = condition.toLowerCase();
    return lower.contains('psa') ||
        lower.contains('bgs') ||
        lower.contains('cgc') ||
        lower.contains('ace') ||
        lower.contains('gradua') ||
        lower.contains('graded');
  }

  /// Returns 1.0. Fixed artificial multipliers have been removed per user instruction.
  /// The app retrieves actual condition-based prices directly from LigaPokémon.
  static double getConditionMultiplier(String? condition) => 1.0;

  /// Distinctive collector accent color for each condition badge
  static Color getConditionColor(String shortCondition) {
    final s = shortCondition.toUpperCase();
    if (s.contains('GRADUADA') || s.contains('GRADED') || s.contains('PSA') || s.contains('BGS') || s.contains('CGC')) {
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
