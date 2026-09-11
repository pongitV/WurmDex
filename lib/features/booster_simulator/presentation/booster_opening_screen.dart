import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/holographic_card_view.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../sets/models/tcg_set_item.dart';
import '../models/booster_pack_config.dart';
import '../services/booster_generator_service.dart';
import 'widgets/booster_summary_view.dart';

enum BoosterStage {
  sealed,
  revealing,
  summary,
}

class BoosterOpeningScreen extends ConsumerStatefulWidget {
  final TcgSetItem set;
  final List<PokemonCardItem> allCards;
  final BoosterFormat initialFormat;

  const BoosterOpeningScreen({
    super.key,
    required this.set,
    required this.allCards,
    this.initialFormat = BoosterFormat.usa10,
  });

  @override
  ConsumerState<BoosterOpeningScreen> createState() => _BoosterOpeningScreenState();
}

class _BoosterOpeningScreenState extends ConsumerState<BoosterOpeningScreen>
    with SingleTickerProviderStateMixin {
  late BoosterFormat _format;
  BoosterStage _stage = BoosterStage.sealed;
  BoosterPackResult? _packResult;
  int _currentIndex = 0;
  late AnimationController _tearController;
  late Animation<double> _tearAnimation;

  @override
  void initState() {
    super.initState();
    _format = widget.initialFormat;
    _tearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _tearAnimation = CurvedAnimation(
      parent: _tearController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _tearController.dispose();
    super.dispose();
  }

  void _tearAndOpenPack({bool forceGod = false}) {
    final result = BoosterGeneratorService.generatePack(
      allCards: widget.allCards,
      setId: widget.set.id,
      setName: widget.set.name,
      format: _format,
      forceGodPack: forceGod,
    );

    setState(() {
      _packResult = result;
      _currentIndex = 0;
    });

    _tearController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _stage = BoosterStage.revealing;
        });
      }
    });
  }

  void _nextCard() {
    if (_packResult == null) return;
    if (_currentIndex < _packResult!.cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _stage = BoosterStage.summary;
      });
    }
  }

  void _resetPack() {
    _tearController.reset();
    setState(() {
      _stage = BoosterStage.sealed;
      _packResult = null;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final rate = ref.watch(exchangeRateProvider);
    final strings = getStrings(language);
    final isUsd = currency == AppCurrency.usd;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.boosterSimulatorTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          AppOverflowMenu(showCurrency: true),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: switch (_stage) {
            BoosterStage.sealed => _buildSealedPackView(strings),
            BoosterStage.revealing => _buildRevealingView(strings, isUsd, rate),
            BoosterStage.summary => _buildSummaryView(strings, isUsd, rate),
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STAGE 1: Sealed Booster Pack View
  // -------------------------------------------------------------
  Widget _buildSealedPackView(AppStrings strings) {
    final isGodPackEligible = BoosterGeneratorService.isGodPackEligible(widget.set.id, widget.set.name);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Format Selector Segmented Button
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formatChoiceButton(
                    title: strings.boosterFormatUsa10,
                    isSelected: _format == BoosterFormat.usa10,
                    onTap: () => setState(() => _format = BoosterFormat.usa10),
                  ),
                  const SizedBox(width: 6),
                  _formatChoiceButton(
                    title: strings.boosterFormatBrazil6,
                    isSelected: _format == BoosterFormat.brazil6,
                    onTap: () => setState(() => _format = BoosterFormat.brazil6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stylized Booster Pack Art Wrapper
            AnimatedBuilder(
              animation: _tearAnimation,
              builder: (context, child) {
                final tearVal = _tearAnimation.value;
                return Transform.scale(
                  scale: 1.0 - (tearVal * 0.15),
                  child: Opacity(
                    opacity: (1.0 - tearVal).clamp(0.0, 1.0),
                    child: Container(
                      width: 250,
                      height: 380,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isGodPackEligible
                              ? const [
                                  Color(0xFF3B1E54),
                                  Color(0xFF1E1035),
                                  Color(0xFF0F172A),
                                ]
                              : const [
                                  Color(0xFF2A1650),
                                  Color(0xFF140D28),
                                  Color(0xFF0F172A),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGodPackEligible
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                              : const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                          width: isGodPackEligible ? 2.5 : 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isGodPackEligible ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6))
                                .withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Metallic Fluting Top & Bottom
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              ),
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                              ),
                            ),
                          ),

                          // Pack Content Center
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.set.logoUrl != null && widget.set.logoUrl!.isNotEmpty)
                                  Flexible(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.set.logoUrl!,
                                      height: 110,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => const SizedBox(height: 80),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.catching_pokemon,
                                        size: 64,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.catching_pokemon,
                                    size: 72,
                                    color: Colors.amberAccent,
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.set.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    _format == BoosterFormat.usa10
                                        ? strings.boosterFormatUsa10
                                        : strings.boosterFormatBrazil6,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isGodPackEligible) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      strings.isEn ? 'God Pack Eligible Set' : 'Expansao c/ God Pack',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Action Button: Tear Booster
            SizedBox(
              width: 260,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _tearAndOpenPack(),
                icon: const Icon(Icons.flash_on, color: Colors.black),
                label: Text(
                  strings.tearBoosterButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  elevation: 8,
                  shadowColor: Colors.amberAccent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
            if (isGodPackEligible) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _tearAndOpenPack(forceGod: true),
                  icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
                  label: Text(
                    strings.testGodPack,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    backgroundColor: Colors.amber.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Simulation Notice Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                strings.boosterSimulationNotice,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatChoiceButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purpleAccent.withValues(alpha: 0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.purpleAccent) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STAGE 2: Revealing Cards One by One
  // -------------------------------------------------------------
  Widget _buildRevealingView(AppStrings strings, bool isUsd, double rate) {
    if (_packResult == null || _packResult!.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalCards = _packResult!.cards.length;
    final pull = _packResult!.cards[_currentIndex];
    final card = pull.card;
    final price = card.effectiveMidPriceUsd ?? card.tcgMarketUsd;
    final isLastCard = _currentIndex == totalCards - 1;
    final isGod = _packResult?.isGodPack == true;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // God Pack Fanfare Banner
            if (isGod) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.godPackDetected,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (_packResult?.godPackTheme != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _packResult!.godPackTheme!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Top Progress Tracker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                strings.revealingCardCount(_currentIndex + 1, totalCards),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Pull Badge (God Pack Hit, Chase, Reverse Holo, or Common/Uncommon)
            if (isGod)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.6),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Text(
                  'GOD PACK CHASE HIT!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            else if (pull.isChase)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Text(
                  'CHASE HIT!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            else if (pull.isReverseHolo)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Text(
                  'REVERSE FOIL',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),

            // Card Holographic Presentation
            GestureDetector(
              onTap: _nextCard,
              child: HolographicCardView(
                key: ValueKey('card-${card.id}-$_currentIndex'),
                imageUrl: card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall,
                width: 270,
                height: 378,
                enableGlow: isGod || pull.isChase || pull.isReverseHolo,
              ),
            ),
            const SizedBox(height: 16),

            // Card Details & Market Price (effective mid price)
            Text(
              card.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${card.rarity} • #${card.number}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              price != null
                  ? (isUsd
                      ? CurrencyFormatter.toUsd(price)
                      : CurrencyFormatter.toBrl(price * rate))
                  : (strings.isEn ? 'No quote' : 'Sem cotação'),
              style: const TextStyle(
                color: AppColors.profitGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Next Card / Summary Button
            SizedBox(
              width: 220,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _nextCard,
                icon: Icon(
                  isLastCard ? Icons.check_circle_outline : Icons.arrow_forward,
                  color: Colors.white,
                ),
                label: Text(
                  isLastCard ? strings.viewBoosterSummary : strings.nextCardButton,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastCard ? AppColors.profitGreen : const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STAGE 3: Summary Screen (Total Pack Value & Grid of Pulls)
  // -------------------------------------------------------------
  Widget _buildSummaryView(AppStrings strings, bool isUsd, double rate) {
    if (_packResult == null) {
      return const SizedBox.shrink();
    }

    return BoosterSummaryView(
      packResult: _packResult!,
      strings: strings,
      isUsd: isUsd,
      rate: rate,
      onReset: _resetPack,
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
