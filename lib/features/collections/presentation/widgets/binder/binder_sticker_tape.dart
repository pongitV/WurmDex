import 'package:flutter/material.dart';

/// Authentic adhesive tape sticker written with felt-tip marker (canetinha)
/// Dynamically sized to hug and grow with the folder name.
class BinderStickerTape extends StatelessWidget {
  final String name;

  const BinderStickerTape({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isNotEmpty ? name.trim() : 'WURMDEX';

    return Transform.rotate(
      angle: -0.016, // Subtle realistic ~ -0.9° natural tilt as if hand-taped
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFEEB), // warm off-white tape
              Color(0xFFFAF5DA), // masking tape beige
              Color(0xFFF2EAC0), // subtle paper fiber tint
            ],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFFD6C898),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 4.5,
              spreadRadius: 0.5,
              offset: const Offset(1.0, 2.0),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              blurRadius: 1.0,
              offset: const Offset(-0.5, -0.5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 2,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4B882).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontFamilyFallback: [
                      'Comic Sans MS',
                      'Caveat',
                      'Segoe Print',
                      'Chalkboard SE',
                      'Bradley Hand',
                      'Casual',
                      'cursive',
                    ],
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFF0D2561), // Classic permanent navy marker ink
                    shadows: [
                      Shadow(
                        color: Color(0x350D2561),
                        blurRadius: 1.2,
                        offset: Offset(0.3, 0.4),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 2,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4B882).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
