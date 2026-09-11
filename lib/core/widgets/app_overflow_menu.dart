import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../providers/card_scale_provider.dart';
import '../providers/currency_provider.dart';
import 'card_scale_dialog.dart';

/// Reusable "three dots" overflow menu (DRY).
///
/// Consolidates the common secondary display controls (currency toggle,
/// card scale/grid and refresh) plus any screen-specific entries into a
/// single [PopupMenuButton]. Keeps AppBars clean and guarantees the overflow
/// menu is always present on the screen.
class AppOverflowMenu extends ConsumerWidget {
  /// When non-null, a single "Scale / Layout" entry is added that opens the
  /// scale sheet (scale slider + grid composition) targeting [scaleTarget].
  final CardScaleTarget? scaleTarget;

  /// Whether to show the currency (BRL / USD) switch entry.
  final bool showCurrency;

  /// Whether to show the refresh entry (requires [onRefresh]).
  final bool showRefresh;
  final VoidCallback? onRefresh;

  /// Extra screen-specific entries placed at the top of the menu. Their values
  /// are dispatched to [onExtraSelected].
  final List<PopupMenuEntry<String>> extraEntries;
  final ValueChanged<String>? onExtraSelected;

  const AppOverflowMenu({
    super.key,
    this.scaleTarget,
    this.showCurrency = true,
    this.showRefresh = false,
    this.onRefresh,
    this.extraEntries = const [],
    this.onExtraSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = getStrings(ref.watch(languageProvider));
    final isUsd = ref.watch(currencyProvider) == AppCurrency.usd;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: strings.moreOptionsTitle,
      onSelected: (val) {
        switch (val) {
          case 'scale':
            showCardScaleBottomSheet(
              context,
              initialTarget: scaleTarget!,
            );
          case 'currency':
            ref.read(currencyProvider.notifier).toggleCurrency();
          case 'refresh':
            onRefresh?.call();
          default:
            onExtraSelected?.call(val);
        }
      },
      itemBuilder: (context) {
        final builtIn = <PopupMenuEntry<String>>[];

        if (scaleTarget != null) {
          builtIn.add(
            PopupMenuItem(
              value: 'scale',
              child: Row(
                children: [
                  const Icon(Icons.aspect_ratio, size: 20),
                  const SizedBox(width: 10),
                  Text(strings.scaleLayoutTooltip),
                ],
              ),
            ),
          );
        }

        if (showCurrency) {
          builtIn.add(
            PopupMenuItem(
              value: 'currency',
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, size: 20),
                  const SizedBox(width: 10),
                  Text(isUsd ? strings.switchToBrl : strings.switchToUsd),
                ],
              ),
            ),
          );
        }

        if (showRefresh && onRefresh != null) {
          builtIn.add(
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 10),
                  Text(strings.refreshTooltip),
                ],
              ),
            ),
          );
        }

        return [...extraEntries, ...builtIn];
      },
    );
  }
}