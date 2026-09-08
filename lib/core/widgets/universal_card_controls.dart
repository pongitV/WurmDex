import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/catalog/models/catalog_filter_state.dart';
import '../providers/card_scale_provider.dart';
import 'card_sort_button.dart';
import 'grid_composition_button.dart';
import 'quick_currency_toggle.dart';

/// Universal Card Controls component (DRY).
///
/// Combines the Currency Button, Sort Button, and Grid Composition Switcher
/// (2x2, 3x3, 4x4, etc.) into a cohesive, reusable control bar for AppBars
/// or screen toolbars across the entire WurmDex application.
class UniversalCardControls extends ConsumerWidget {
  /// Currently selected sorting option (if null, sort button is omitted).
  final CatalogSortOption? currentSort;

  /// Callback when user picks a new sorting option.
  final ValueChanged<CatalogSortOption>? onSortChanged;

  /// Whether current language is English (for sort button labels).
  final bool isEn;

  /// Whether to show the grid composition switcher button.
  final bool showGridComposition;

  /// Whether to show the currency toggle button.
  final bool showCurrency;

  /// Target for fine-tuning scale sheet.
  final CardScaleTarget scaleTarget;

  /// Additional action widgets to include at the end or beginning.
  final List<Widget>? extraActions;

  /// Whether to display controls in an expanded toolbar format with labels or compact icon format for AppBars.
  final bool isToolbar;

  const UniversalCardControls({
    super.key,
    this.currentSort,
    this.onSortChanged,
    this.isEn = false,
    this.showGridComposition = true,
    this.showCurrency = true,
    this.scaleTarget = CardScaleTarget.menu,
    this.extraActions,
    this.isToolbar = false,
  });

  /// Factory helper that returns a list of action widgets ready for `AppBar.actions`.
  static List<Widget> appBarActions({
    CatalogSortOption? currentSort,
    ValueChanged<CatalogSortOption>? onSortChanged,
    bool isEn = false,
    bool showGridComposition = true,
    bool showCurrency = true,
    CardScaleTarget scaleTarget = CardScaleTarget.menu,
    List<Widget>? extraActions,
  }) {
    return [
      if (showCurrency) const QuickCurrencyToggle(),
      if (showGridComposition)
        GridCompositionButton(scaleTarget: scaleTarget),
      if (currentSort != null && onSortChanged != null)
        CardSortButton(
          currentOption: currentSort,
          onSelected: onSortChanged,
          isEn: isEn,
        ),
      ...?extraActions,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCurrency) ...[
          const QuickCurrencyToggle(),
          const SizedBox(width: 4),
        ],
        if (showGridComposition) ...[
          GridCompositionButton(
            showLabel: isToolbar,
            scaleTarget: scaleTarget,
          ),
          const SizedBox(width: 4),
        ],
        if (currentSort != null && onSortChanged != null) ...[
          CardSortButton(
            currentOption: currentSort!,
            onSelected: onSortChanged!,
            isEn: isEn,
          ),
          const SizedBox(width: 4),
        ],
        ...?extraActions,
      ],
    );
  }
}
