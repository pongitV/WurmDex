import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated glowing holographic shimmer overlay for highlighting a card
/// when revealed by the search bar.
class CardShimmerGlow extends StatefulWidget {
  final Widget child;
  final bool isGlowing;
  final Duration duration;
  final VoidCallback? onCompleted;

  const CardShimmerGlow({
    super.key,
    required this.child,
    required this.isGlowing,
    this.duration = const Duration(milliseconds: 2200),
    this.onCompleted,
  });

  @override
  State<CardShimmerGlow> createState() => _CardShimmerGlowState();
}

class _CardShimmerGlowState extends State<CardShimmerGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.isGlowing) {
      _controller.forward(from: 0.0).then((_) => widget.onCompleted?.call());
    }
  }

  @override
  void didUpdateWidget(covariant CardShimmerGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing && !oldWidget.isGlowing) {
      _controller.forward(from: 0.0).then((_) => widget.onCompleted?.call());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating && !widget.isGlowing) {
          return child!;
        }

        final t = _controller.value;
        // Intensity pulses and fades out towards the end
        final intensity = math.sin(t * math.pi);
        // Sweep shine angle
        final shineOffset = -1.5 + (3.0 * t);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer golden-cyan glowing aura
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.75 * intensity),
                    blurRadius: 18 * intensity,
                    spreadRadius: 4 * intensity,
                  ),
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.45 * intensity),
                    blurRadius: 28 * intensity,
                    spreadRadius: 2 * intensity,
                  ),
                ],
              ),
              child: child,
            ),

            // Diagonal holographic light beam shimmer
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Transform.rotate(
                  angle: 0.25,
                  child: FractionallySizedBox(
                    widthFactor: 2.2,
                    heightFactor: 1.8,
                    alignment: Alignment(shineOffset, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.amberAccent.withValues(alpha: 0.25 * intensity),
                            Colors.white.withValues(alpha: 0.85 * intensity),
                            Colors.cyanAccent.withValues(alpha: 0.35 * intensity),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.42, 0.50, 0.58, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
