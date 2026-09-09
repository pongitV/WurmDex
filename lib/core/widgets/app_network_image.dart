import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../network/app_image_headers.dart';

/// Reusable cached network image widget with standardized browser headers,
/// smooth fade animations, shimmer/progress loading, and graceful fallback handling.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Alignment alignment;
  final BorderRadiusGeometry? borderRadius;
  final String? heroTag;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fallbackImageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.fallbackIcon = Icons.inventory_2_outlined,
    this.fallbackIconSize = 28.0,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.heroTag,
  });

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl.trim();

    Widget content;
    if (effectiveUrl.isEmpty) {
      if (fallbackImageUrl != null && fallbackImageUrl!.trim().isNotEmpty) {
        content = _buildCachedImage(context, fallbackImageUrl!.trim(), null);
      } else {
        content = _buildFallback(context);
      }
    } else {
      content = _buildCachedImage(context, effectiveUrl, fallbackImageUrl?.trim());
    }

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    if (heroTag != null && heroTag!.isNotEmpty) {
      content = Hero(
        tag: heroTag!,
        child: content,
      );
    }

    if (width != null || height != null) {
      content = SizedBox(
        width: width,
        height: height,
        child: content,
      );
    }

    return content;
  }

  Widget _buildCachedImage(
    BuildContext context,
    String primaryUrl,
    String? fallbackUrl,
  ) {
    return CachedNetworkImage(
      imageUrl: primaryUrl,
      httpHeaders: AppImageHeaders.common,
      fit: fit,
      alignment: alignment,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 180),
      placeholder: (ctx, url) => _buildPlaceholder(ctx),
      errorWidget: (ctx, url, error) {
        if (fallbackUrl != null && fallbackUrl.isNotEmpty && fallbackUrl != primaryUrl) {
          return CachedNetworkImage(
            imageUrl: fallbackUrl,
            httpHeaders: AppImageHeaders.common,
            fit: fit,
            alignment: alignment,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder: (c, u) => _buildPlaceholder(c),
            errorWidget: (c, u, e) => _buildFallback(c),
          );
        }
        return _buildFallback(ctx);
      },
    );
  }
}
