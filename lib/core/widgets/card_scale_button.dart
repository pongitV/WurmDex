import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../providers/card_scale_provider.dart';
import 'card_scale_dialog.dart';

/// Reusable Card Scale button (DRY).
///
/// Displays an [IconButton] with [Icons.aspect_ratio] that triggers
/// [showCardScaleBottomSheet] for either [CardScaleTarget.menu] or
/// [CardScaleTarget.collection].
class CardScaleButton extends ConsumerWidget {
  final CardScaleTarget target;
  final String? tooltip;
  final double iconSize;
  final Color? color;

  const CardScaleButton({
    super.key,
    this.target = CardScaleTarget.menu,
    this.tooltip,
    this.iconSize = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return IconButton(
      icon: Icon(Icons.aspect_ratio, size: iconSize, color: color),
      tooltip: tooltip ?? strings.scaleTooltip,
      onPressed: () => showCardScaleBottomSheet(context, initialTarget: target),
    );
  }
}
