import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that wobbles/jiggles playfully for 2 seconds when tapped.
class WobblyMenuIcon extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  const WobblyMenuIcon({
    super.key,
    this.child,
    this.onTap,
    this.size = 28,
    this.tooltip,
  });

  @override
  State<WobblyMenuIcon> createState() => WobblyMenuIconState();
}

class WobblyMenuIconState extends State<WobblyMenuIcon>
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
    final defaultChild = widget.child ??
        Image.asset(
          'assets/images/wurmple.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
    );
  }
}
