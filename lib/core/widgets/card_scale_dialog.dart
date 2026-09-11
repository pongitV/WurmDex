import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../providers/card_scale_provider.dart';
import '../providers/card_view_mode_provider.dart';
import '../providers/grid_composition_provider.dart';
import 'bottom_sheet_drag_handle.dart';

void showCardScaleBottomSheet(
  BuildContext context, {
  CardScaleTarget initialTarget = CardScaleTarget.menu,
  bool showGridComposition = true,
}) {
  showAppModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    builder: (ctx) => CardScaleSheetContent(
      initialTarget: initialTarget,
      showGridComposition: showGridComposition,
    ),
  );
}

class CardScaleSheetContent extends ConsumerStatefulWidget {
  final CardScaleTarget initialTarget;
  final bool showGridComposition;

  const CardScaleSheetContent({
    super.key,
    this.initialTarget = CardScaleTarget.menu,
    this.showGridComposition = true,
  });

  @override
  ConsumerState<CardScaleSheetContent> createState() => _CardScaleSheetContentState();
}

class _CardScaleSheetContentState extends ConsumerState<CardScaleSheetContent> {
  late CardScaleTarget _activeTarget;

  @override
  void initState() {
    super.initState();
    _activeTarget = widget.initialTarget;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final isMenu = _activeTarget == CardScaleTarget.menu;

    final scale = isMenu
        ? ref.watch(menuCardScaleProvider)
        : ref.watch(collectionCardScaleProvider);
    final percent = (scale * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BottomSheetDragHandle(bottomPadding: 14),

            // Target selector: Menu & Catálogo vs Coleção & Fichário
            SegmentedButton<CardScaleTarget>(
              segments: [
                ButtonSegment<CardScaleTarget>(
                  value: CardScaleTarget.menu,
                  icon: const Icon(Icons.dashboard_outlined, size: 18),
                  label: Text(strings.scaleMenuAndCatalog),
                ),
                ButtonSegment<CardScaleTarget>(
                  value: CardScaleTarget.collection,
                  icon: const Icon(Icons.auto_stories_outlined, size: 18),
                  label: Text(strings.scaleCollectionAndBinder),
                ),
              ],
              selected: {_activeTarget},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _activeTarget = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Header with percentage badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMenu ? strings.scaleMenuTitle : strings.scaleCollectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isMenu ? strings.scaleMenuDesc : strings.scaleCollectionDesc,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),

            // Slider with Minus and Plus buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: strings.tooltipZoomOut,
                  onPressed: scale > (isMenu ? 0.70 : 0.50)
                      ? () {
                          if (isMenu) {
                            ref.read(menuCardScaleProvider.notifier).zoomOut();
                          } else {
                            ref.read(collectionCardScaleProvider.notifier).zoomOut();
                          }
                        }
                      : null,
                ),
                Expanded(
                  child: Slider(
                    value: scale,
                    min: isMenu ? 0.70 : 0.50,
                    max: isMenu ? 1.50 : 1.30,
                    divisions: 16,
                    label: '$percent%',
                    onChanged: (val) {
                      if (isMenu) {
                        ref.read(menuCardScaleProvider.notifier).setScale(val);
                      } else {
                        ref.read(collectionCardScaleProvider.notifier).setScale(val);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: strings.tooltipZoomIn,
                  onPressed: scale < (isMenu ? 1.50 : 1.30)
                      ? () {
                          if (isMenu) {
                            ref.read(menuCardScaleProvider.notifier).zoomIn();
                          } else {
                            ref.read(collectionCardScaleProvider.notifier).zoomIn();
                          }
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Preset Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: isMenu
                  ? [
                      _buildPresetChip(ref, isMenu: true, label: strings.isEn ? 'Compact (90%)' : 'Compacto (90%)', targetScale: 0.90, currentScale: scale),
                      _buildPresetChip(ref, isMenu: true, label: strings.isEn ? 'Normal (100%)' : 'Normal (100%)', targetScale: 1.00, currentScale: scale),
                      _buildPresetChip(ref, isMenu: true, label: strings.isEn ? 'Comfortable (115%)' : 'Confortável (115%)', targetScale: 1.15, currentScale: scale),
                      _buildPresetChip(ref, isMenu: true, label: strings.isEn ? 'Large (130%)' : 'Grande (130%)', targetScale: 1.30, currentScale: scale),
                      _buildPresetChip(ref, isMenu: true, label: strings.isEn ? 'Maximum (145%)' : 'Máximo (145%)', targetScale: 1.45, currentScale: scale),
                    ]
                  : [
                      _buildPresetChip(ref, isMenu: false, label: strings.isEn ? 'Mini (60%)' : 'Mini (60%)', targetScale: 0.60, currentScale: scale),
                      _buildPresetChip(ref, isMenu: false, label: strings.isEn ? 'Compact (75%)' : 'Compacto (75%)', targetScale: 0.75, currentScale: scale),
                      _buildPresetChip(ref, isMenu: false, label: strings.isEn ? 'Medium (85%)' : 'Médio (85%)', targetScale: 0.85, currentScale: scale),
                      _buildPresetChip(ref, isMenu: false, label: strings.isEn ? 'Standard (100%)' : 'Padrão (100%)', targetScale: 1.00, currentScale: scale),
                      _buildPresetChip(ref, isMenu: false, label: strings.isEn ? 'Large (115%)' : 'Grande (115%)', targetScale: 1.15, currentScale: scale),
                    ],
            ),
            const SizedBox(height: 16),

            // Reset button (belongs to the Scale section, not the Grid section)
            OutlinedButton(
              onPressed: () {
                if (isMenu) {
                  ref.read(menuCardScaleProvider.notifier).reset();
                } else {
                  ref.read(collectionCardScaleProvider.notifier).reset();
                }
              },
              child: Text(
                isMenu
                    ? strings.btnResetMenuScale
                    : strings.btnResetCollectionScale,
              ),
            ),

            // ── Grid Columns section (only for grid views, not binder) ──────────
            if (widget.showGridComposition) ..._buildGridCompositionSection(context, theme, strings, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    WidgetRef ref, {
    required bool isMenu,
    required String label,
    required double targetScale,
    required double currentScale,
  }) {
    final isSelected = (currentScale - targetScale).abs() < 0.03;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) {
        if (isMenu) {
          ref.read(menuCardScaleProvider.notifier).setScale(targetScale);
        } else {
          ref.read(collectionCardScaleProvider.notifier).setScale(targetScale);
        }
      },
    );
  }

  List<Widget> _buildGridCompositionSection(
    BuildContext context,
    ThemeData theme,
    AppStrings strings,
    WidgetRef ref,
  ) {
    final currentComp = ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);
    final isList = viewMode == CardViewMode.list;

    final options = [
      (GridComposition.auto, strings.gridCompAuto, Icons.auto_awesome_mosaic_outlined),
      (GridComposition.two, '2×2', Icons.filter_2),
      (GridComposition.three, '3×3', Icons.filter_3),
      (GridComposition.four, '4×4', Icons.filter_4),
      (GridComposition.five, '5×5', Icons.filter_5),
      (GridComposition.six, '6×6', Icons.filter_6),
    ];

    return [
      const SizedBox(height: 20),
      Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), height: 1),
      const SizedBox(height: 16),
      Row(
        children: [
          Icon(Icons.grid_view_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            strings.isEn ? 'Grid Layout' : 'Layout da Grade',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isList ? strings.viewAsList : _compLabel(currentComp),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // View as List toggle
          ChoiceChip(
            avatar: Icon(Icons.view_list, size: 14),
            label: Text(strings.viewAsList, style: const TextStyle(fontSize: 12)),
            selected: isList,
            showCheckmark: false,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              ref.read(cardViewModeProvider.notifier).setMode(CardViewMode.list);
            },
          ),
          ...options.map((entry) {
            final (comp, label, icon) = entry;
            final isSelected = !isList && currentComp == comp;
            return ChoiceChip(
              avatar: Icon(icon, size: 14),
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                ref.read(cardViewModeProvider.notifier).setMode(CardViewMode.grid);
                ref.read(gridCompositionProvider.notifier).setComposition(comp);
              },
            );
          }),
        ],
      ),
    ];
  }

  String _compLabel(GridComposition comp) {
    switch (comp) {
      case GridComposition.two: return '2×2';
      case GridComposition.three: return '3×3';
      case GridComposition.four: return '4×4';
      case GridComposition.five: return '5×5';
      case GridComposition.six: return '6×6';
      case GridComposition.auto: return 'Auto';
    }
  }
}
