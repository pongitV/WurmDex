import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/pokedex_entry.dart';

/// Vertical list tile used by the WorldDex when the "View as List" option is active.
class PokemonListItem extends StatelessWidget {
  final PokedexEntry pokemon;
  final VoidCallback onTap;

  const PokemonListItem({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Pokémon thumbnail
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppNetworkImage(
                  imageUrl: pokemon.artworkUrl,
                  fallbackImageUrl: pokemon.spriteUrl,
                  fit: BoxFit.contain,
                  fallbackIcon: Icons.catching_pokemon,
                  fallbackIconSize: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${pokemon.formattedNumber} ${pokemon.name}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pokemon.types.join(' · ')}  •  Gen ${pokemon.generation}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}