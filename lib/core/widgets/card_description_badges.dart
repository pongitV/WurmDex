import 'package:flutter/material.dart';

/// Shared, reusable description badges rendered by both the Wishlist and the
/// LigaRadar list cards, so the product/card description icons stay visually
/// identical instead of being recreated per screen.
///
/// Geometry intentionally matches [LanguageFlagBadge] / [ConditionBadge] /
/// [FolderBadge] for a balanced pill layout.

// Canonical badge metrics shared with ConditionBadge/FolderBadge/LanguageFlagBadge
// so every badge on the Wishlist and Radar screens renders at the exact same size.
const double _compactH = 4.5;
const double _compactV = 1.0;
const double _compactRadius = 4.0;
const double _compactBorder = 0.7;
const double _compactFont = 8.5;
const double _compactIcon = 9.5;

const double _normalH = 7.0;
const double _normalV = 2.5;
const double _normalRadius = 6.0;
const double _normalBorder = 1.0;
const double _normalFont = 10.5;
const double _normalIcon = 12.0;

/// Status badge: "In range", "Above range", "Below range", "Pending", "Out of
/// stock", etc. Colors and text come from each screen's status resolver.
class RangeStatusBadge extends StatelessWidget {
  final Color color;
  final String text;
  final bool compact;

  const RangeStatusBadge({
    super.key,
    required this.color,
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? _compactH : _normalH,
        vertical: compact ? _compactV : _normalV,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(
          compact ? _compactRadius : _normalRadius,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: compact ? _compactBorder : _normalBorder,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: compact ? _compactFont : _normalFont,
        ),
      ),
    );
  }
}

/// Deep-purple "Pre-sale" indicator used when the current offer is a pre-sale.
class PreSaleStatusBadge extends StatelessWidget {
  final String label;
  final bool compact;

  const PreSaleStatusBadge({
    super.key,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? _compactH : _normalH,
        vertical: compact ? _compactV : _normalV,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(
          compact ? _compactRadius : _normalRadius,
        ),
        border: Border.all(
          color: Colors.transparent,
          width: compact ? _compactBorder : _normalBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: compact ? _compactFont : _normalFont,
        ),
      ),
    );
  }
}

/// Neutral tag shown when the product already accepts pre-sale offers.
class PreSaleAcceptedBadge extends StatelessWidget {
  final String label;
  final bool compact;

  const PreSaleAcceptedBadge({
    super.key,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? _compactH : _normalH,
        vertical: compact ? _compactV : _normalV,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          compact ? _compactRadius : _normalRadius,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: compact ? _compactBorder : _normalBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? _compactFont : _normalFont,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Primary-colored tag identifying the collection/set the product belongs to.
class CollectionTagBadge extends StatelessWidget {
  final String name;
  final bool compact;

  const CollectionTagBadge({
    super.key,
    required this.name,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? _compactH : _normalH,
        vertical: compact ? _compactV : _normalV,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(
          compact ? _compactRadius : _normalRadius,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: compact ? _compactBorder : _normalBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: compact ? _compactIcon : _normalIcon,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            name,
            style: TextStyle(
              fontSize: compact ? _compactFont : _normalFont,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}