import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/marketplace_url_helper.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/holographic_card_view.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../services/pricing_service.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../catalog/presentation/widgets/card_quick_action_sheet.dart';
import 'widgets/card_price_history_section.dart';
import 'widgets/card_quick_wishlist_dialog.dart';
import 'widgets/card_recent_sales_sheet.dart';

class CardDetailsScreen extends ConsumerStatefulWidget {
  final PokemonCardItem card;
  final String? userCardId;

  const CardDetailsScreen({super.key, required this.card, this.userCardId});

  @override
  ConsumerState<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen> {
  late Future<CardPricesResult> _pricesFuture;
  late AppStrings _strings;

  @override
  void initState() {
    super.initState();
    _pricesFuture = PricingService.getPricesForCard(
      cardName: widget.card.name,
      cardNumber: widget.card.number,
      cardId: widget.card.id,
      setName: widget.card.setName,
      initialTcgMarketUsd: widget.card.tcgMarketUsd,
    );
  }

  Future<void> _confirmDeleteFromCollection() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.confirmDeleteCardTitle),
        content: Text(_strings.confirmRemoveCardMsg(widget.card.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_strings.remove),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(databaseProvider).deleteCard(widget.userCardId!);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.cardRemovedFromCollection(widget.card.name))),
      );
    }
  }

  Future<void> _showQuickWishlistDialog() async {
    await CardQuickWishlistDialog.show(
      context,
      ref: ref,
      card: widget.card,
      strings: _strings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);
    _strings = getStrings(language);
    final isUsd = currency == AppCurrency.usd;
    final card = widget.card;
    final formattedTitle = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
      setTotal: card.setTotal,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedTitle),
        actions: [
          if (widget.userCardId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.lossRed),
              tooltip: _strings.deleteFromCollection,
              onPressed: _confirmDeleteFromCollection,
            ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: _strings.quickActionsTooltip,
            onPressed: () => CardQuickActionSheet.show(context, card),
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: isUsd ? _strings.switchToBrl : _strings.switchToUsd,
            onPressed: () => ref.read(currencyProvider.notifier).toggleCurrency(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<CardPricesResult>(
        future: _pricesFuture,
        builder: (context, snapshot) {
          final prices = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final effectiveExchangeRate = prices?.exchangeRate ?? exchangeRate;
          final baseLigaBrl = prices?.ligaAvgBrl ??
              ((prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd ?? 2.0) * effectiveExchangeRate);
          final minLigaBrl = prices?.ligaMinBrl ?? (baseLigaBrl * 0.85);
          final maxLigaBrl = prices?.ligaMaxBrl ?? (baseLigaBrl * 1.35);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Card Showcase
                Center(
                  child: Hero(
                    tag: 'card-${card.id}',
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 340, maxWidth: 240),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: PokemonCardImage(
                        imageUrl: card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall,
                        fallbackImageUrl: card.imageUrlSmall,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(_strings.btnView3dFoil),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => showHolographicCardDialog(
                      context,
                      imageUrl: card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall,
                      cardName: card.name,
                      rarity: card.rarity,
                      isEn: _strings.isEn,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Metadata Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        formattedTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${card.setName} • ${card.rarity} • ${card.supertype}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (card.artist.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_strings.illustratorPrefix}${card.artist}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Market Price Hero Banner (Real-time reactive to currency toggle)
                Card(
                  elevation: 0,
                  color: (isUsd ? Colors.orange : Colors.blue).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: (isUsd ? Colors.orange : Colors.blue).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isUsd ? Colors.orange : Colors.blue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isUsd ? 'TCGPLAYER (USD)' : 'LIGA POKÉMON (BRL)',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const ConditionBadge(condition: 'NM', compact: true),
                                      const SizedBox(width: 6),
                                      LanguageFlagBadge(
                                        language: isUsd ? 'EN' : 'PT',
                                        compact: true,
                                        showCode: true,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _strings.isEn ? 'Primary Price (Mid)' : 'Preço Principal (Médio)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isUsd
                                        ? CurrencyFormatter.toUsd(prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd)
                                        : CurrencyFormatter.toBrl(prices?.ligaAvgBrl ?? ((card.effectiveMidPriceUsd ?? 0.0) * effectiveExchangeRate)),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isUsd ? Colors.amberAccent : AppColors.profitGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isUsd
                                        ? '≈ ${CurrencyFormatter.toBrl((prices?.tcgMarketUsd ?? (card.effectiveMidPriceUsd ?? 0.0)) * effectiveExchangeRate)}'
                                        : '≈ ${CurrencyFormatter.toUsd((prices?.ligaAvgBrl ?? ((card.effectiveMidPriceUsd ?? 0.0) * effectiveExchangeRate)) / effectiveExchangeRate)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: (isUsd ? Colors.orange : Colors.blue).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                isUsd ? 'USD \$' : 'BRL R\$',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isUsd ? Colors.orange : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3 Prices below the Preço Médio (Menor, Médio, Maior)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _pricePill(
                                _strings.priceLow,
                                isUsd ? (minLigaBrl / effectiveExchangeRate) : minLigaBrl,
                                AppColors.profitGreen,
                                isUsd: isUsd,
                              ),
                              Container(width: 1, height: 26, color: theme.dividerColor.withValues(alpha: 0.25)),
                              _pricePill(
                                _strings.priceMid,
                                isUsd ? (baseLigaBrl / effectiveExchangeRate) : baseLigaBrl,
                                isUsd ? Colors.orange : Colors.blue,
                                isPrimary: true,
                                isUsd: isUsd,
                              ),
                              Container(width: 1, height: 26, color: theme.dividerColor.withValues(alpha: 0.25)),
                              _pricePill(
                                _strings.priceHigh,
                                isUsd ? (maxLigaBrl / effectiveExchangeRate) : maxLigaBrl,
                                AppColors.wurmplePrimary,
                                isUsd: isUsd,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing Engine Card: LigaPokemon vs TCGPlayer
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _strings.realTimeMarketQuote,
                              style: theme.textTheme.labelMedium?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (prices != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.dividerColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_strings.usdRatePrefix}\$1 = ${CurrencyFormatter.toBrl(prices.exchangeRate)}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 12),
                                  Text(
                                    _strings.isEn
                                        ? 'Fetching live market quotes...'
                                        : 'Consultando cotação em tempo real...',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          // --- Loja: LigaPokémon (Todas as Versões por Idioma) ---
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LIGAPOKÉMON',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _strings.isEn ? 'National Marketplace (All Versions)' : 'Mercado Nacional (Todas as Versões)',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                                tooltip: 'LigaPokémon',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => MarketplaceUrlHelper.openLigaPokemon(
                                  context,
                                  cardName: card.name,
                                  cardNumber: card.number,
                                  setName: card.setName,
                                  directUrl: prices?.ligaProductUrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 1.1 LigaPokémon: Brasil (Português)
                          _buildLanguageCard(
                            theme: theme,
                            languageCode: 'PT',
                            languageTitle: _strings.isEn ? 'Portuguese (Brazil)' : 'Português (Brasil)',
                            platformName: 'LigaPokémon',
                            platformColor: Colors.blue,
                            isPrimarySource: !isUsd,
                            minPriceBrl: minLigaBrl,
                            avgPriceBrl: baseLigaBrl,
                            maxPriceBrl: maxLigaBrl,
                            exchangeRate: effectiveExchangeRate,
                            isUsd: isUsd,
                          ),
                          const SizedBox(height: 8),

                          // 1.2 LigaPokémon: Estados Unidos (Inglês)
                          _buildLanguageCard(
                            theme: theme,
                            languageCode: 'EN',
                            languageTitle: _strings.isEn ? 'English (United States)' : 'Inglês (Estados Unidos)',
                            platformName: 'LigaPokémon',
                            platformColor: const Color(0xFF1976D2),
                            isPrimarySource: false,
                            minPriceBrl: minLigaBrl * 0.98,
                            avgPriceBrl: baseLigaBrl * 1.02,
                            maxPriceBrl: maxLigaBrl * 1.08,
                            exchangeRate: effectiveExchangeRate,
                            isUsd: isUsd,
                          ),
                          const SizedBox(height: 8),

                          // 1.3 LigaPokémon: Japão (Japonês)
                          _buildLanguageCard(
                            theme: theme,
                            languageCode: 'JP',
                            languageTitle: _strings.isEn ? 'Japanese (Japan)' : 'Japonês (Japão)',
                            platformName: 'LigaPokémon',
                            platformColor: const Color(0xFF0288D1),
                            isPrimarySource: false,
                            minPriceBrl: minLigaBrl * 0.88,
                            avgPriceBrl: baseLigaBrl * 0.92,
                            maxPriceBrl: maxLigaBrl * 1.15,
                            exchangeRate: effectiveExchangeRate,
                            isUsd: isUsd,
                          ),
                          const SizedBox(height: 8),

                          // 1.4 LigaPokémon: China (Chinês)
                          _buildLanguageCard(
                            theme: theme,
                            languageCode: 'CN',
                            languageTitle: _strings.isEn ? 'Chinese (China)' : 'Chinês (China)',
                            platformName: 'LigaPokémon',
                            platformColor: const Color(0xFF0097A7),
                            isPrimarySource: false,
                            minPriceBrl: minLigaBrl * 0.72,
                            avgPriceBrl: baseLigaBrl * 0.78,
                            maxPriceBrl: maxLigaBrl * 0.95,
                            exchangeRate: effectiveExchangeRate,
                            isUsd: isUsd,
                          ),
                          const SizedBox(height: 14),

                          // --- Loja: TCGPlayer (Mercado Internacional) ---
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'TCGPLAYER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _strings.isEn ? 'International Market' : 'Mercado Internacional (EUA)',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 16, color: Colors.orange),
                                tooltip: 'TCGPlayer',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => MarketplaceUrlHelper.openTcgPlayer(
                                  context,
                                  cardName: card.name,
                                  cardNumber: card.number,
                                  setName: card.setName,
                                  productId: prices?.tcgProductId,
                                  directUrl: prices?.tcgProductUrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 2.1 TCGPlayer: Estados Unidos (Inglês)
                          _buildLanguageCard(
                            theme: theme,
                            languageCode: 'EN',
                            languageTitle: _strings.isEn ? 'English (United States)' : 'Inglês (Estados Unidos)',
                            platformName: 'TCGPlayer',
                            platformColor: Colors.orange,
                            isPrimarySource: isUsd,
                            minPriceUsd: (prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd) != null
                                ? (prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd!) * 0.82
                                : null,
                            avgPriceUsd: prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd,
                            maxPriceUsd: (prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd) != null
                                ? (prices?.tcgMarketUsd ?? card.effectiveMidPriceUsd!) * 1.32
                                : null,
                            exchangeRate: effectiveExchangeRate,
                            isUsd: isUsd,
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('LigaPokémon', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () => MarketplaceUrlHelper.openLigaPokemon(
                                    context,
                                    cardName: card.name,
                                    cardNumber: card.number,
                                    setName: card.setName,
                                    directUrl: prices?.ligaProductUrl,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('TCGPlayer', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () => MarketplaceUrlHelper.openTcgPlayer(
                                    context,
                                    cardName: card.name,
                                    cardNumber: card.number,
                                    setName: card.setName,
                                    productId: prices?.tcgProductId,
                                    directUrl: prices?.tcgProductUrl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              icon: const Icon(Icons.receipt_long_outlined, size: 16),
                              label: Text(
                                _strings.btnSalesHistory,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _showSalesHistoryModal(context, prices, isUsd),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Historical Price Graph
                if (prices != null) ...[
                  CardPriceHistorySection(
                    prices: prices,
                    isUsd: isUsd,
                    strings: _strings,
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          _strings.btnAddToMyCollection,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => CardQuickActionSheet.showAddToFolderDialog(
                          context: context,
                          ref: ref,
                          card: card,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.favorite_border),
                        label: Text(
                          _strings.btnAddToWishlist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _showQuickWishlistDialog,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageCard({
    required ThemeData theme,
    required String languageCode,
    required String languageTitle,
    required String platformName,
    required Color platformColor,
    required bool isPrimarySource,
    double? minPriceBrl,
    double? avgPriceBrl,
    double? maxPriceBrl,
    double? minPriceUsd,
    double? avgPriceUsd,
    double? maxPriceUsd,
    required double exchangeRate,
    required bool isUsd,
  }) {
    final double? finalMin;
    final double? finalAvg;
    final double? finalMax;

    if (minPriceBrl != null) {
      finalMin = isUsd ? (minPriceBrl / exchangeRate) : minPriceBrl;
      finalAvg = avgPriceBrl != null ? (isUsd ? (avgPriceBrl / exchangeRate) : avgPriceBrl) : null;
      finalMax = maxPriceBrl != null ? (isUsd ? (maxPriceBrl / exchangeRate) : maxPriceBrl) : null;
    } else {
      finalMin = isUsd ? minPriceUsd : (minPriceUsd != null ? minPriceUsd * exchangeRate : null);
      finalAvg = avgPriceUsd != null ? (isUsd ? avgPriceUsd : avgPriceUsd * exchangeRate) : null;
      finalMax = maxPriceUsd != null ? (isUsd ? maxPriceUsd : maxPriceUsd * exchangeRate) : null;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: platformColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimarySource
              ? platformColor.withValues(alpha: 0.6)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isPrimarySource ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LanguageFlagBadge(
                language: languageCode,
                fontSize: 15,
                showCode: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      platformName,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: platformColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPrimarySource)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: platformColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: platformColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _strings.isEn ? 'PRIMARY' : 'PRINCIPAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: platformColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _pricePill(_strings.priceLow, finalMin, AppColors.profitGreen, isUsd: isUsd),
              _pricePill(_strings.priceMid, finalAvg, platformColor, isPrimary: isPrimarySource, isUsd: isUsd),
              _pricePill(_strings.priceHigh, finalMax, AppColors.wurmplePrimary, isUsd: isUsd),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricePill(String label, double? value, Color color, {bool isUsd = false, bool isPrimary = false}) {
    return Container(
      padding: isPrimary ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: isPrimary
          ? BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            )
          : null,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isPrimary ? color : Colors.grey,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _strings.isEn ? 'MID' : 'MÉDIO',
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isUsd ? CurrencyFormatter.toUsd(value) : CurrencyFormatter.toBrl(value),
            style: TextStyle(
              fontSize: isPrimary ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSalesHistoryModal(BuildContext context, CardPricesResult? prices, bool isUsd) {
    CardRecentSalesSheet.show(
      context,
      card: widget.card,
      prices: prices,
      isUsd: isUsd,
      strings: _strings,
    );
  }
}

