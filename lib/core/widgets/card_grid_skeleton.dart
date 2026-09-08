import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Animated skeleton grid simulating Pokémon card loading state (DRY).
///
/// Features a gentle pulse animation maintaining the official physical
/// card aspect ratio (63:88), replacing generic circular spinners with
/// a premium native placeholder experience.
class CardGridSkeleton extends StatefulWidget {
  final int itemCount;
  final int crossAxisCount;
  final EdgeInsetsGeometry padding;

  const CardGridSkeleton({
    super.key,
    this.itemCount = 8,
    this.crossAxisCount = 3,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  State<CardGridSkeleton> createState() => _CardGridSkeletonState();
}

class _CardGridSkeletonState extends State<CardGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, _) {
        return GridView.builder(
          padding: widget.padding,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            childAspectRatio: AppConstants.cardGridItemAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: _opacityAnimation.value),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 10,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 8,
                            width: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
