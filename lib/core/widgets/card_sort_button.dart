import 'package:flutter/material.dart';
import '../../features/catalog/models/catalog_filter_state.dart';
import '../utils/card_sorting_helper.dart';
import 'app_sort_button.dart';

/// Card Sorting button (DRY).
///
/// Wraps [AppSortButton] specifically for [CatalogSortOption], maintaining
/// full backward compatibility across the app while reusing the unified sort UI.
class CardSortButton extends StatelessWidget {
  final CatalogSortOption currentOption;
  final ValueChanged<CatalogSortOption> onSelected;
  final bool isEn;
  final bool isCompact;

  const CardSortButton({
    super.key,
    required this.currentOption,
    required this.onSelected,
    required this.isEn,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppSortButton<CatalogSortOption>(
      currentOption: currentOption,
      onSelected: onSelected,
      isCompact: isCompact,
      tooltip: isEn ? 'Sort Cards' : 'Ordenar Cartas',
      options: CatalogSortOption.values.map((option) {
        return SortOptionItem<CatalogSortOption>(
          value: option,
          label: CardSortingHelper.getSortLabel(option, isEn),
          icon: CardSortingHelper.getSortIcon(option),
        );
      }).toList(),
    );
  }
}
