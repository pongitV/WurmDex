import 'package:flutter/material.dart';

/// CustomPainter that paints the front curved arch of the binder ring with realistic chrome/polymer shading.
/// The ring arches out of the page holes, curving forward in 3D and looping back through the opposing hole.
class RingFrontArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2.0, 2.0, size.width - 4.0, size.height - 4.0);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(11.0));

    // Shadow under the front arch cast onto the hole and paper
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawRRect(rrect.shift(const Offset(0.0, 2.0)), shadowPaint);

    // Matte dark polymer ring body (clean, non-metallic, smooth finish)
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF37474F),
        Color(0xFF263238),
        Color(0xFF1E272C),
      ],
      stops: [0.0, 0.45, 1.0],
    );

    final strokePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BinderSingleRing extends StatelessWidget {
  final bool backOnly;
  final bool frontOnly;

  const BinderSingleRing({
    super.key,
    this.backOnly = false,
    this.frontOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    const double ringW = 24.0;
    const double ringH = 26.0;

    if (backOnly) {
      // Rear segment of the ring mounted to the spine under the page paper (matte charcoal polymer)
      return Container(
        width: ringW,
        height: ringH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF263238),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    if (frontOnly) {
      // Front curved loop of the ring emerging through the holes over the sheets
      return Container(
        width: ringW,
        height: ringH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.transparent,
            width: 3.5,
          ),
        ),
        child: CustomPaint(
          size: const Size(ringW, ringH),
          painter: RingFrontArchPainter(),
        ),
      );
    }

    // Full ring (fallback)
    return Container(
      width: ringW,
      height: ringH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: const Color(0xFF263238),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF141719),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
