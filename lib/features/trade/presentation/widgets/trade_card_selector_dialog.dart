import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
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
  final double valueBrl;

  const TradeCardItem({
    required this.id,
    required this.name,
    required this.number,
    required this.setName,
    required this.imageUrl,
    required this.valueBrl,
  });
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
            final price = card.purchasePriceBrl > 0 ? card.purchasePriceBrl : 15.0;

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
              onTap: () {
                final item = TradeCardItem(
                  id: card.id,
                  name: card.name,
                  number: card.number,
                  setName: card.setName,
                  imageUrl: card.imageUrl,
                  valueBrl: price,
                );
                Navigator.pop(context, item);
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
                        final valBrl = card.tcgMarketUsd != null ? (card.tcgMarketUsd! * widget.exchangeRate) : 10.0;

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
                            CurrencyFormatter.toBrl(valBrl),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            final item = TradeCardItem(
                              id: card.id,
                              name: card.name,
                              number: card.number,
                              setName: card.setName,
                              imageUrl: card.imageUrlSmall,
                              valueBrl: valBrl,
                            );
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
