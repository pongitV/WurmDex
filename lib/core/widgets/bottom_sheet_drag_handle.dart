import 'package:flutter/material.dart';

/// Reusable Drag Handle for modal bottom sheets (DRY).
class BottomSheetDragHandle extends StatelessWidget {
  final double width;
  final double height;
  final double bottomPadding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const BottomSheetDragHandle({
    super.key,
    this.width = 40.0,
    this.height = 4.0,
    this.bottomPadding = 16.0,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: width,
        height: height,
        margin: margin ?? EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: color ?? theme.dividerColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

/// Standardized helper to display bottom sheets across WurmDex.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  Color? backgroundColor,
  bool enableDrag = true,
  bool showDragHandle = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor ?? Colors.transparent,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    builder: builder,
  );
}
