import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Universal Pokémon Card Image widget.
///
/// Ensures the card image is displayed completely in its authentic form
/// without cutting or clipping the card corners, maintaining the official
/// physical aspect ratio (63:88).
class PokemonCardImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? heroTag;
  final Alignment alignment;
  final BorderRadiusGeometry? borderRadius;

  const PokemonCardImage({
    super.key,
    required this.imageUrl,
    this.fallbackImageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
    this.alignment = Alignment.center,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl.isNotEmpty
        ? imageUrl
        : (fallbackImageUrl ?? '');

    if (effectiveUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: effectiveUrl,
      fit: fit,
      alignment: alignment,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 180),
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(context),
      errorWidget: (context, url, error) {
        if (fallbackImageUrl != null &&
            fallbackImageUrl!.isNotEmpty &&
            fallbackImageUrl != effectiveUrl) {
          return CachedNetworkImage(
            imageUrl: fallbackImageUrl!,
            fit: fit,
            alignment: alignment,
            placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(context),
            errorWidget: (context, url, err) => errorWidget ?? _buildErrorWidget(context),
          );
        }
        return errorWidget ?? _buildErrorWidget(context);
      },
    );

    if (width != null || height != null) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      );
    }

    if (heroTag != null && heroTag!.isNotEmpty) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.dividerColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: (width != null && width! < 60) ? 20 : 32,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
