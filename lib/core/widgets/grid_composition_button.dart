import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../providers/card_scale_provider.dart';
import '../providers/grid_composition_provider.dart';
import 'card_scale_dialog.dart';

/// Universal button to switch grid composition (Auto, 2x2, 3x3, 4x4, 5x5, 6x6).
class GridCompositionButton extends ConsumerWidget {
  final bool showLabel;
  final CardScaleTarget scaleTarget;

  const GridCompositionButton({
    super.key,
    this.showLabel = false,
    this.scaleTarget = CardScaleTarget.menu,
  });

  IconData _getIcon(GridComposition composition) {
    switch (composition) {
      case GridComposition.two:
        return Icons.filter_2;
      case GridComposition.three:
        return Icons.filter_3;
      case GridComposition.four:
        return Icons.filter_4;
      case GridComposition.five:
        return Icons.filter_5;
      case GridComposition.six:
        return Icons.filter_6;
      case GridComposition.auto:
        return Icons.auto_awesome_mosaic_outlined;
    }
  }

  String _getLabel(GridComposition composition, AppStrings strings) {
    switch (composition) {
      case GridComposition.two:
        return strings.gridComp2x2;
      case GridComposition.three:
        return strings.gridComp3x3;
      case GridComposition.four:
        return strings.gridComp4x4;
      case GridComposition.five:
        return strings.gridComp5x5;
      case GridComposition.six:
        return strings.gridComp6x6;
      case GridComposition.auto:
        return strings.gridCompAuto;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentComposition = ref.watch(gridCompositionProvider);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return PopupMenuButton<GridComposition>(
      initialValue: currentComposition,
      tooltip: strings.gridCompositionTooltip,
      onSelected: (composition) {
        HapticFeedback.selectionClick();
        ref.read(gridCompositionProvider.notifier).setComposition(composition);
      },
      icon: showLabel
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(currentComposition),
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getLabel(currentComposition, strings),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            )
          : Icon(
              _getIcon(currentComposition),
              size: 20,
              color: currentComposition == GridComposition.auto
                  ? null
                  : colorScheme.primary,
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<GridComposition>>[];

        for (final comp in GridComposition.values) {
          final isSelected = comp == currentComposition;
          items.add(
            PopupMenuItem<GridComposition>(
              value: comp,
              child: Row(
                children: [
                  Icon(
                    _getIcon(comp),
                    size: 18,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getLabel(comp, strings),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }

        // Add fine-tune scale option at the bottom
        items.add(const PopupMenuDivider());
        items.add(
          PopupMenuItem<GridComposition>(
            enabled: false,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                showCardScaleBottomSheet(context, initialTarget: scaleTarget);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      strings.gridCompFineTune,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        return items;
      },
    );
  }
}
