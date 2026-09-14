import 'package:flutter/material.dart';
import 'wobbly_menu_icon.dart';

/// Reusable universal screen title widget.
///
/// Features the interactive Wurmple mascot on the left with consistent
/// typography matching the main screen header across all screens.
/// Uses FittedBox with scaleDown so it adapts to any screen width or
/// dense AppBar action count without overflowing.
class AppScreenTitle extends StatelessWidget {
  final String title;

  const AppScreenTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WobblyMenuIcon(size: 24),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
