import 'package:flutter/material.dart';
import '../../models/tcg_set_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

class SetListTile extends StatelessWidget {
  final TcgSetItem set;
  final VoidCallback onTap;
  final int ownedCount;

  const SetListTile({
    super.key,
    required this.set,
    required this.onTap,
    this.ownedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasProgress = ownedCount > 0 && (set.totalCards > 0 || set.officialCards > 0);
    final effectiveTotal = set.totalCards > 0 ? set.totalCards : set.officialCards;
    final ratio = hasProgress
        ? (ownedCount / (effectiveTotal > 0 ? effectiveTotal : 1)).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = hasProgress && ownedCount >= effectiveTotal;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: set.logoUrl != null && set.logoUrl!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: set.logoUrl!,
                        fit: BoxFit.contain,
                        errorWidget: _buildFallbackLogo(colorScheme),
                      )
                    : _buildFallbackLogo(colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.displayNameWithCount,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${set.year}'
                      '${set.releaseDate != null ? ' • ${set.releaseDate}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasProgress) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 3,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isComplete ? Colors.amber : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$ownedCount / $effectiveTotal (${(ratio * 100).toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? Colors.amber.shade700 : colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                hasProgress && isComplete ? Icons.verified : Icons.chevron_right,
                size: 20,
                color: hasProgress && isComplete
                    ? AppColors.profitGreen
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 20,
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 2),
          Text(
            set.id.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}