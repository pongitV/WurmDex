import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/card_pricing_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../catalog/models/pokemon_card_item.dart';
import '../../../catalog/services/pokemon_catalog_service.dart';

class TradeCardItem {
  final String id;
  final String name;
  final String number;
  final String setName;
  final String imageUrl;
  final double basePriceBrl;
  final double? minPriceBrl;
  final double? maxPriceBrl;
  final double valueBrl;
  final String condition;
  final String rarity;
  final PokemonCardItem? catalogCard;

  const TradeCardItem({
    required this.id,
    required this.name,
    required this.number,
    required this.setName,
    required this.imageUrl,
    required this.basePriceBrl,
    this.minPriceBrl,
    this.maxPriceBrl,
    required this.valueBrl,
    this.condition = 'Near Mint',
    this.rarity = '',
    this.catalogCard,
  });

  TradeCardItem copyWith({
    String? id,
    String? name,
    String? number,
    String? setName,
    String? imageUrl,
    double? basePriceBrl,
    double? minPriceBrl,
    double? maxPriceBrl,
    double? valueBrl,
    String? condition,
    String? rarity,
    PokemonCardItem? catalogCard,
  }) {
    return TradeCardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      setName: setName ?? this.setName,
      imageUrl: imageUrl ?? this.imageUrl,
      basePriceBrl: basePriceBrl ?? this.basePriceBrl,
      minPriceBrl: minPriceBrl ?? this.minPriceBrl,
      maxPriceBrl: maxPriceBrl ?? this.maxPriceBrl,
      valueBrl: valueBrl ?? this.valueBrl,
      condition: condition ?? this.condition,
      rarity: rarity ?? this.rarity,
      catalogCard: catalogCard ?? this.catalogCard,
    );
  }

  PokemonCardItem toPokemonCardItem({double exchangeRate = 5.60}) {
    if (catalogCard != null) {
      return catalogCard!;
    }
    final rate = exchangeRate > 0 ? exchangeRate : 5.60;
    return PokemonCardItem(
      id: id,
      name: name,
      number: number,
      setId: setName.toLowerCase().replaceAll(' ', '-'),
      setName: setName,
      rarity: rarity.isNotEmpty ? rarity : 'Rare',
      imageUrlSmall: imageUrl,
      imageUrlLarge: imageUrl,
      types: const ['Colorless'],
      supertype: 'Pokémon',
      artist: '',
      tcgMarketUsd: valueBrl > 0
          ? valueBrl / rate
          : (basePriceBrl > 0 ? basePriceBrl / rate : 0),
    );
  }
}

Future<TradeCardItem?> showTradeCardSelector(
  BuildContext context, {
  required double exchangeRate,
  bool allowCollection = true,
}) {
  return showDialog<TradeCardItem>(
    context: context,
    builder: (ctx) => _TradeCardSelectorDialog(
      exchangeRate: exchangeRate,
      allowCollection: allowCollection,
    ),
  );
}

class _TradeCardSelectorDialog extends ConsumerStatefulWidget {
  final double exchangeRate;
  final bool allowCollection;

  const _TradeCardSelectorDialog({
    required this.exchangeRate,
    required this.allowCollection,
  });

  @override
  ConsumerState<_TradeCardSelectorDialog> createState() => _TradeCardSelectorDialogState();
}

class _TradeCardSelectorDialogState extends ConsumerState<_TradeCardSelectorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<PokemonCardItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.allowCollection ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchOnline(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final isEn = ref.read(languageProvider) == AppLanguage.enUs;
    final res = await PokemonCatalogService.searchCards(query: query, isEn: isEn);
    if (mounted) {
      setState(() {
        _searchResults = res;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.dlgAddCardToTrade,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.allowCollection)
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: strings.tabMyCollection),
                  Tab(text: strings.tabSearchCatalog),
                ],
              ),
            const SizedBox(height: 12),

            Expanded(
              child: widget.allowCollection
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCollectionTab(theme, strings),
                        _buildOnlineSearchTab(theme, strings),
                      ],
                    )
                  : _buildOnlineSearchTab(theme, strings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionTab(ThemeData theme, AppStrings strings) {
    final allCardsAsync = ref.watch(userCardsStreamProvider);

    return allCardsAsync.when(
      data: (cards) {
        if (cards.isEmpty) {
          return AppEmptyState(
            icon: Icons.style_outlined,
            title: strings.noCardsInCollection,
          );
        }

        return ListView.separated(
          itemCount: cards.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final card = cards[index];
            final basePrice = CardPricingHelper.getCachedOrEstimatedPriceBrl(
              cardApiId: card.cardApiId,
              cardName: card.name,
              cardNumber: card.number,
              setName: card.setName,
              purchasePriceBrl: card.purchasePriceBrl,
              rarity: card.rarity,
              condition: card.condition,
              exchangeRate: widget.exchangeRate,
            );
            final price = card.purchasePriceBrl > 0 ? card.purchasePriceBrl : basePrice;

            return ListTile(
              dense: true,
              leading: PokemonCardImage(
                imageUrl: card.imageUrl,
                width: 32,
                height: 44,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(4),
              ),
              title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      card.setName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ConditionBadge(condition: card.condition, compact: true),
                ],
              ),
              trailing: Text(
                CurrencyFormatter.toBrl(price),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                final quotes = await CardPricingHelper.getOrFetchPriceQuotes(
                  cardApiId: card.cardApiId,
                  cardName: card.name,
                  cardNumber: card.number,
                  setName: card.setName,
                  exchangeRate: widget.exchangeRate,
                );
                final effectiveBase = card.purchasePriceBrl > 0 ? card.purchasePriceBrl : quotes.avgBrl;
                final cardCond = card.condition.isNotEmpty ? card.condition : 'Near Mint';
                final effectiveValue = CardPricingHelper.getPriceForCondition(
                  cardApiId: card.cardApiId,
                  cardName: card.name,
                  cardNumber: card.number,
                  setName: card.setName,
                  basePriceBrl: effectiveBase,
                  minPriceBrl: quotes.minBrl,
                  maxPriceBrl: quotes.maxBrl,
                  condition: cardCond,
                );
                final catalogCard = PokemonCardItem(
                  id: card.cardApiId.isNotEmpty ? card.cardApiId : card.id,
                  name: card.name,
                  number: card.number,
                  setId: card.setName.toLowerCase().replaceAll(' ', '-'),
                  setName: card.setName,
                  rarity: card.rarity,
                  imageUrlSmall: card.imageUrl,
                  imageUrlLarge: card.imageUrl,
                  types: const ['Colorless'],
                  supertype: 'Pokémon',
                  artist: '',
                  tcgMarketUsd: effectiveValue > 0 ? effectiveValue / widget.exchangeRate : 0,
                );
                final item = TradeCardItem(
                  id: card.id,
                  name: card.name,
                  number: card.number,
                  setName: card.setName,
                  imageUrl: card.imageUrl,
                  basePriceBrl: effectiveBase,
                  minPriceBrl: quotes.minBrl,
                  maxPriceBrl: quotes.maxBrl,
                  valueBrl: effectiveValue,
                  condition: cardCond,
                  rarity: card.rarity,
                  catalogCard: catalogCard,
                );
                if (context.mounted) Navigator.pop(context, item);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('${strings.isEn ? "Error" : "Erro"}: $err')),
    );
  }

  Widget _buildOnlineSearchTab(ThemeData theme, AppStrings strings) {
    return Column(
      children: [
        AppSearchBar(
          controller: _searchController,
          hintText: strings.searchCardByNameHint,
          padding: EdgeInsets.zero,
          suffix: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _searchOnline(_searchController.text),
          ),
          onSubmitted: _searchOnline,
        ),
        const SizedBox(height: 10),

        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? AppEmptyState(
                      icon: Icons.search,
                      title: strings.typeCardNameEnter,
                    )
                  : ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final card = _searchResults[index];
                        final title = SemanticSearchHelper.formatCardIdentifier(
                          rawName: card.name,
                          number: card.number,
                          setTotal: card.setTotal,
                        );
                        final baseUsd = card.effectiveMidPriceUsd ?? 0.0;
                        final valBrl = baseUsd > 0
                            ? CardPricingHelper.convertUsdToRealisticBrl(baseUsd, widget.exchangeRate)
                            : 0.0;

                        return ListTile(
                          dense: true,
                          leading: PokemonCardImage(
                            imageUrl: card.imageUrlSmall,
                            width: 32,
                            height: 44,
                            fit: BoxFit.contain,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${card.setName} • ${card.rarity}'),
                          trailing: Text(
                            valBrl > 0 ? CurrencyFormatter.toBrl(valBrl) : 'R\$ --',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () async {
                            final quotes = await CardPricingHelper.getOrFetchPriceQuotes(
                              cardApiId: card.id,
                              cardName: card.name,
                              cardNumber: card.number,
                              setName: card.setName,
                              knownMarketUsd: card.hasExplicitPrice ? card.effectiveMidPriceUsd : null,
                              exchangeRate: widget.exchangeRate,
                            );
                            final item = TradeCardItem(
                              id: card.id,
                              name: card.name,
                              number: card.number,
                              setName: card.setName,
                              imageUrl: card.imageUrlSmall,
                              basePriceBrl: quotes.avgBrl,
                              minPriceBrl: quotes.minBrl,
                              maxPriceBrl: quotes.maxBrl,
                              valueBrl: quotes.avgBrl,
                              condition: 'Near Mint',
                              rarity: card.rarity,
                              catalogCard: card,
                            );
                            if (context.mounted) Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
