import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/tcg_set_item.dart';

class SetCardWidget extends StatelessWidget {
  final TcgSetItem set;
  final VoidCallback onTap;
  final int ownedCount;
  final bool isEn;

  const SetCardWidget({
    super.key,
    required this.set,
    required this.onTap,
    this.ownedCount = 0,
    this.isEn = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top row: Year badge
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${set.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Set Logo
              Expanded(
                child: Hero(
                  tag: 'set_logo_${set.id}',
                  child: set.logoUrl != null && set.logoUrl!.isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: set.logoUrl!,
                          fit: BoxFit.contain,
                          errorWidget: _buildFallbackLogo(colorScheme),
                        )
                      : _buildFallbackLogo(colorScheme),
                ),
              ),

              const SizedBox(height: 8),

              // Set Name with (X) prints count
              Text(
                set.displayNameWithCount,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (ownedCount > 0 && (set.totalCards > 0 || set.officialCards > 0)) ...[
                Builder(
                  builder: (context) {
                    final effectiveTotal = set.totalCards > 0 ? set.totalCards : set.officialCards;
                    final ratio = (ownedCount / (effectiveTotal > 0 ? effectiveTotal : 1)).clamp(0.0, 1.0);
                    final isComplete = ownedCount >= effectiveTotal;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4,
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
                            color: isComplete
                                ? Colors.amber.shade700
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ] else if (set.releaseDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  set.releaseDate!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
            size: 36,
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            set.id.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
