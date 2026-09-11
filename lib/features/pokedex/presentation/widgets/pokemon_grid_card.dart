import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/pokedex_entry.dart';

class PokemonGridCard extends StatelessWidget {
  final PokedexEntry pokemon;
  final VoidCallback onTap;

  const PokemonGridCard({
    super.key,
    required this.pokemon,
    required this.onTap,
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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  // Top row: #Number
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      pokemon.formattedNumber,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Pokémon Artwork with sprite fallback
                  Expanded(
                    child: Hero(
                      tag: 'pokemon_art_${pokemon.id}',
                      child: AppNetworkImage(
                        imageUrl: pokemon.artworkUrl,
                        fallbackImageUrl: pokemon.spriteUrl,
                        fit: BoxFit.contain,
                        fallbackIcon: Icons.catching_pokemon,
                        fallbackIconSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Pokémon Name
                  Text(
                    pokemon.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
            ),
          ),
        ),
    );
  }
}
