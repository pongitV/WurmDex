import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HolographicCardView extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final bool enableGlow;
  final VoidCallback? onTap;

  const HolographicCardView({
    super.key,
    required this.imageUrl,
    this.width = 260,
    this.height = 364,
    this.borderRadius = BorderRadius.zero,
    this.enableGlow = true,
    this.onTap,
  });

  @override
  State<HolographicCardView> createState() => _HolographicCardViewState();
}

class _HolographicCardViewState extends State<HolographicCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  late Animation<Offset> _resetAnimation;

  Offset _tilt = Offset.zero; // dx, dy between -1.0 and 1.0

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _resetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
        setState(() {
          _tilt = _resetAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPointerMove(Offset localPos, Size size) {
    _resetController.stop();
    final halfW = size.width / 2;
    final halfH = size.height / 2;
    final dx = ((localPos.dx - halfW) / halfW).clamp(-1.0, 1.0);
    final dy = ((localPos.dy - halfH) / halfH).clamp(-1.0, 1.0);
    setState(() {
      _tilt = Offset(dx, dy);
    });
  }

  void _onPointerExit() {
    _resetAnimation = Tween<Offset>(
      begin: _tilt,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    ));
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final dx = _tilt.dx;
    final dy = _tilt.dy;

    // Perspective transform
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0018) // perspective factor
      ..rotateX(-dy * 0.28) // tilt along X
      ..rotateY(dx * 0.28); // tilt along Y

    final gradientOffset = (dx + dy) * 0.5;

    return MouseRegion(
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          _onPointerMove(event.localPosition, box.size);
        }
      },
      onExit: (_) => _onPointerExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            _onPointerMove(details.localPosition, box.size);
          }
        },
        onPanEnd: (_) => _onPointerExit(),
        onPanCancel: () => _onPointerExit(),
        child: AnimatedBuilder(
          animation: _resetController,
          builder: (context, child) {
            return Transform(
              alignment: FractionalOffset.center,
              transform: transform,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: widget.enableGlow
                          ? Colors.cyanAccent.withValues(alpha: 0.15 + (_tilt.distance * 0.2).clamp(0.0, 0.35))
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 18 + (_tilt.distance * 12),
                      offset: Offset(dx * 12, dy * 12 + 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Card Image
                      CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade900,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade900,
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),

                      // Holographic Rainbow Foil Layer
                      Opacity(
                        opacity: (_tilt.distance * 0.55).clamp(0.08, 0.65),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: SweepGradient(
                              center: FractionalOffset(
                                (0.5 + dx * 0.3).clamp(0.0, 1.0),
                                (0.5 + dy * 0.3).clamp(0.0, 1.0),
                              ),
                              startAngle: 0.0,
                              endAngle: math.pi * 2,
                              colors: [
                                Colors.redAccent.withValues(alpha: 0.35),
                                Colors.amberAccent.withValues(alpha: 0.35),
                                Colors.limeAccent.withValues(alpha: 0.35),
                                Colors.greenAccent.withValues(alpha: 0.35),
                                Colors.cyanAccent.withValues(alpha: 0.35),
                                Colors.blueAccent.withValues(alpha: 0.35),
                                Colors.purpleAccent.withValues(alpha: 0.35),
                                Colors.pinkAccent.withValues(alpha: 0.35),
                                Colors.redAccent.withValues(alpha: 0.35),
                              ],
                              stops: const [
                                0.0,
                                0.12,
                                0.25,
                                0.38,
                                0.5,
                                0.62,
                                0.75,
                                0.88,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Diagonal Specular Rainbow Bands
                      Opacity(
                        opacity: (_tilt.distance * 0.45).clamp(0.05, 0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1.0 + gradientOffset, -1.0),
                              end: Alignment(1.0 + gradientOffset, 1.0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.25),
                                Colors.cyan.withValues(alpha: 0.3),
                                Colors.amber.withValues(alpha: 0.3),
                                Colors.purple.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.2, 0.35, 0.5, 0.65, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Specular Glare / Reflection Hotspot
                      Opacity(
                        opacity: (_tilt.distance * 0.6).clamp(0.05, 0.7),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(dx * 0.85, dy * 0.85),
                              radius: 0.75,
                              colors: [
                                Colors.white.withValues(alpha: 0.45),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.35, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Modal dialog to inspect card in high resolution with interactive 3D Foil effect
void showHolographicCardDialog(
  BuildContext context, {
  required String imageUrl,
  required String cardName,
  String? rarity,
  bool isEn = false,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (rarity != null && rarity.isNotEmpty)
                        Text(
                          rarity,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive Holographic Card
            Flexible(
              child: Center(
                child: HolographicCardView(
                  imageUrl: imageUrl,
                  width: 300,
                  height: 420,
                  enableGlow: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hint Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                isEn
                    ? 'Move cursor or drag to tilt the 3D foil effect'
                    : 'Mova o cursor ou arraste para inclinar o efeito foil 3D',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    },
  );
}
