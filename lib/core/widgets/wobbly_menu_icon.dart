import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_constants.dart';
import '../theme/theme_provider.dart';
import '../../features/easter_egg/presentation/wurmple_clicker_dialog.dart';

/// An elegant, stylized modern menu icon with a playful 2-second wobble animation when tapped.
class WobblyMenuIcon extends ConsumerStatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final String? tooltip;

  const WobblyMenuIcon({
    super.key,
    this.child,
    this.onTap,
    this.onLongPress,
    this.size = 28,
    this.tooltip,
  });

  @override
  ConsumerState<WobblyMenuIcon> createState() => WobblyMenuIconState();
}

class WobblyMenuIconState extends ConsumerState<WobblyMenuIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void triggerWobble() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    String iconAsset;
    ClickerCharacter character;

    switch (themeMode) {
      case AppThemeMode.lugia:
        iconAsset = 'assets/images/characters/249.png';
        character = ClickerCharacter.lugia;
        break;
      case AppThemeMode.lugiaShiny:
        iconAsset = 'assets/images/characters/249_shiny.png';
        character = ClickerCharacter.lugiaShiny;
        break;
      case AppThemeMode.darkLugia:
        iconAsset = 'assets/images/characters/dark_lugia.png';
        character = ClickerCharacter.darkLugia;
        break;
      case AppThemeMode.wurmpleShiny:
        iconAsset = 'assets/images/menu/wurmple_shiny_menu.png';
        character = ClickerCharacter.wurmpleShiny;
        break;
      default:
        iconAsset = 'assets/images/menu/wurmple_menu.png';
        character = ClickerCharacter.wurmple;
        break;
    }

    final defaultChild = widget.child ??
        SizedBox(
          width: widget.size > 36 ? 58 : widget.size * 1.4,
          height: widget.size,
          child: Image.asset(
            iconAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                StylizedMenuBadge(size: widget.size),
          ),
        );

    Widget content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating) {
          return child!;
        }

        final t = _controller.value;
        // Energetic 2-second playful wobble equation:
        // 7 full wobble cycles (14*pi) with cartoon squash, stretch, and joyful hopping
        final envelope = (1.0 - t) * (1.0 - (0.25 * t));
        final angle = math.sin(t * 14 * math.pi) * 0.42 * envelope;
        final hop = -10.0 * (math.sin(t * 7 * math.pi)).abs() * envelope;
        final squash = 1.0 + (math.cos(t * 14 * math.pi) * 0.20 * envelope);
        final stretch = 1.0 - (math.cos(t * 14 * math.pi) * 0.20 * envelope);

        return Transform.translate(
          offset: Offset(0, hop),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..rotateZ(angle)
              ..scaleByDouble(squash, stretch, 1.0, 1.0),
            child: child,
          ),
        );
      },
      child: defaultChild,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      content = Tooltip(
        message: widget.tooltip!,
        child: content,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        triggerWobble();
        widget.onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        triggerWobble();
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        } else {
          WurmpleClickerDialog.show(context, character: character);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
    );
  }
}

/// An elegant, stylized geometric menu badge with staggered rounded pill bars and accent styling.
class StylizedMenuBadge extends StatelessWidget {
  final double size;

  const StylizedMenuBadge({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final padding = (size * 0.22).clamp(4.0, 12.0);
    final radius = (size * 0.30).clamp(6.0, 16.0);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.30),
          width: (size * 0.035).clamp(1.0, 2.0),
        ),
      ),
      child: CustomPaint(
        painter: _StylizedMenuPainter(color: primaryColor),
      ),
    );
  }
}

class _StylizedMenuPainter extends CustomPainter {
  final Color color;

  const _StylizedMenuPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final barThickness = (size.height * 0.18).clamp(2.0, 5.0);
    final cornerRadius = Radius.circular(barThickness / 2);
    final spacing = (size.height - (barThickness * 3)) / 2;

    // Bar 1: Top bar (65% width)
    final y1 = 0.0;
    final topBarWidth = size.width * 0.65;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y1, topBarWidth, barThickness),
        cornerRadius,
      ),
      paint,
    );

    // Accent dot aligned with top bar
    final dotRadius = barThickness / 2;
    canvas.drawCircle(
      Offset(size.width - dotRadius, y1 + dotRadius),
      dotRadius,
      paint,
    );

    // Bar 2: Middle bar (full 100% width)
    final y2 = barThickness + spacing;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y2, size.width, barThickness),
        cornerRadius,
      ),
      paint,
    );

    // Bar 3: Bottom bar (82% width)
    final y3 = (barThickness + spacing) * 2;
    final bottomBarWidth = size.width * 0.82;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y3, bottomBarWidth, barThickness),
        cornerRadius,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StylizedMenuPainter oldDelegate) =>
      oldDelegate.color != color;
}
