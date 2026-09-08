import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../models/booster_pack_config.dart';

class BoosterSummaryView extends StatelessWidget {
  final BoosterPackResult packResult;
  final AppStrings strings;
  final bool isUsd;
  final double rate;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const BoosterSummaryView({
    super.key,
    required this.packResult,
    required this.strings,
    required this.isUsd,
    required this.rate,
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final totalUsd = packResult.totalMarketUsd;
    final totalBrl = totalUsd * rate;
    final isGod = packResult.isGodPack;

    // Find the highest value card pull using effective mid price
    BoosterCardPull? bestPull;
    for (final p in packResult.cards) {
      final pPrice = p.card.effectiveMidPriceUsd ?? p.card.tcgMarketUsd ?? 0.0;
      final bestPrice = bestPull != null ? (bestPull.card.effectiveMidPriceUsd ?? bestPull.card.tcgMarketUsd ?? 0.0) : 0.0;
      if (bestPull == null || pPrice > bestPrice) {
        bestPull = p;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // God Pack Badge Banner in Summary
          if (isGod) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    packResult.godPackTheme ?? strings.godPackDetected,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Total Estimated Pack Value Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isGod
                    ? const [
                        Color(0xFF2E1065),
                        Color(0xFF1E1B4B),
                        Color(0xFF0F172A),
                      ]
                    : const [
                        Color(0xFF1E1B4B),
                        Color(0xFF0F172A),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isGod
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                    : Colors.purpleAccent.withValues(alpha: 0.4),
                width: isGod ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isGod ? const Color(0xFFF59E0B) : Colors.purpleAccent).withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  strings.totalPackValueTitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isUsd ? CurrencyFormatter.toUsd(totalUsd) : CurrencyFormatter.toBrl(totalBrl),
                  style: const TextStyle(
                    color: AppColors.profitGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUsd
                      ? '≈ ${CurrencyFormatter.toBrl(totalBrl)}'
                      : '≈ ${CurrencyFormatter.toUsd(totalUsd)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    strings.boosterSimulationNotice,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Best Pull Highlight
          if (bestPull != null && ((bestPull.card.effectiveMidPriceUsd ?? bestPull.card.tcgMarketUsd ?? 0.0) > 0)) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  PokemonCardImage(
                    imageUrl: bestPull.card.imageUrlSmall,
                    width: 50,
                    height: 70,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                strings.bestPullBadge,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bestPull.card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          bestPull.card.rarity,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isUsd
                        ? CurrencyFormatter.toUsd(bestPull.card.effectiveMidPriceUsd ?? bestPull.card.tcgMarketUsd)
                        : CurrencyFormatter.toBrl(((bestPull.card.effectiveMidPriceUsd ?? bestPull.card.tcgMarketUsd) ?? 0.0) * rate),
                    style: const TextStyle(
                      color: AppColors.profitGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Cards Grid
          Text(
            '${strings.isEn ? 'Pulled Cards' : 'Cartas Obtidas'} (${packResult.cards.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: packResult.cards.length,
            itemBuilder: (context, index) {
              final pull = packResult.cards[index];
              final card = pull.card;
              final price = card.effectiveMidPriceUsd ?? card.tcgMarketUsd;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isGod
                        ? Colors.amber.withValues(alpha: 0.85)
                        : pull.isChase
                            ? Colors.amber.withValues(alpha: 0.7)
                            : pull.isReverseHolo
                                ? Colors.cyanAccent.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.1),
                    width: (isGod || pull.isChase || pull.isReverseHolo) ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: PokemonCardImage(
                        imageUrl: card.imageUrlSmall,
                        fit: BoxFit.contain,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            price != null
                                ? (isUsd
                                    ? CurrencyFormatter.toUsd(price)
                                    : CurrencyFormatter.toBrl(price * rate))
                                : '-',
                            style: const TextStyle(
                              color: AppColors.profitGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  label: Text(strings.close),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.openAnotherBoosterButton),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
