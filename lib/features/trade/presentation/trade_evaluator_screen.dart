import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_action_fab.dart';
import '../../../../core/widgets/app_filter_modal.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../../core/widgets/app_screen_title.dart';
import '../../../../core/widgets/app_sort_button.dart';
import 'widgets/trade_card_selector_dialog.dart';

enum TradeFilterMode { all, yourOnly, theirOnly }
enum TradeSortMode { valueDesc, valueAsc, nameAsc }

class TradeEvaluatorScreen extends ConsumerStatefulWidget {
  const TradeEvaluatorScreen({super.key});

  @override
  ConsumerState<TradeEvaluatorScreen> createState() => _TradeEvaluatorScreenState();
}

class _TradeEvaluatorScreenState extends ConsumerState<TradeEvaluatorScreen> {
  final List<TradeCardItem> _yourCards = [];
  final List<TradeCardItem> _theirCards = [];
  TradeFilterMode _filterMode = TradeFilterMode.all;
  TradeSortMode _sortMode = TradeSortMode.valueDesc;

  List<TradeCardItem> _getSortedCards(List<TradeCardItem> cards) {
    final list = List<TradeCardItem>.from(cards);
    switch (_sortMode) {
      case TradeSortMode.valueDesc:
        list.sort((a, b) => b.valueBrl.compareTo(a.valueBrl));
        break;
      case TradeSortMode.valueAsc:
        list.sort((a, b) => a.valueBrl.compareTo(b.valueBrl));
        break;
      case TradeSortMode.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    return list;
  }

  void _showFilterDialog(AppStrings strings) {
    TradeFilterMode tempMode = _filterMode;
    AppFilterModalDialog.show(
      context: context,
      title: strings.tradeFilterTitle,
      hasActiveFilters: _filterMode != TradeFilterMode.all,
      strings: strings,
      onClear: () => setState(() => _filterMode = TradeFilterMode.all),
      onApply: () => setState(() => _filterMode = tempMode),
      children: [
        StatefulBuilder(
          builder: (ctx, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.tradeFilterAll),
                      selected: tempMode == TradeFilterMode.all,
                      onSelected: (_) => setModalState(() => tempMode = TradeFilterMode.all),
                    ),
                    FilterChip(
                      label: Text(strings.tradeFilterYour),
                      selected: tempMode == TradeFilterMode.yourOnly,
                      onSelected: (_) => setModalState(() => tempMode = TradeFilterMode.yourOnly),
                    ),
                    FilterChip(
                      label: Text(strings.tradeFilterTheir),
                      selected: tempMode == TradeFilterMode.theirOnly,
                      onSelected: (_) => setModalState(() => tempMode = TradeFilterMode.theirOnly),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  double get _yourTotal => _yourCards.fold(0.0, (acc, c) => acc + c.valueBrl);
  double get _theirTotal => _theirCards.fold(0.0, (acc, c) => acc + c.valueBrl);

  void _addYourCard(double exchangeRate) async {
    final item = await showTradeCardSelector(context, exchangeRate: exchangeRate, allowCollection: true);
    if (item != null) {
      setState(() => _yourCards.add(item));
    }
  }

  void _addTheirCard(double exchangeRate) async {
    final item = await showTradeCardSelector(context, exchangeRate: exchangeRate, allowCollection: false);
    if (item != null) {
      setState(() => _theirCards.add(item));
    }
  }

  void _copyTradeSummary(AppStrings strings, bool isUsd, double exchangeRate) {
    final diff = _theirTotal - _yourTotal;
    final buffer = StringBuffer();
    final header = strings.tradeEvaluationHeader;
    buffer.writeln('=== $header (WurmDex) ===');
    buffer.writeln('\n${strings.tradeLeftLabel} ${strings.tradeYouSend} (${strings.cardsCount(_yourCards.length)}):');
    for (final c in _yourCards) {
      final priceStr = isUsd
          ? CurrencyFormatter.toUsd(c.valueBrl / exchangeRate)
          : CurrencyFormatter.toBrl(c.valueBrl);
      buffer.writeln(' - ${c.name} (${c.setName}) : $priceStr');
    }
    final yourTotalStr = isUsd
        ? CurrencyFormatter.toUsd(_yourTotal / exchangeRate)
        : CurrencyFormatter.toBrl(_yourTotal);
    buffer.writeln('${strings.totalSent}: $yourTotalStr');

    buffer.writeln('\n${strings.tradeRightLabel} ${strings.tradeYouReceive} (${strings.cardsCount(_theirCards.length)}):');
    for (final c in _theirCards) {
      final priceStr = isUsd
          ? CurrencyFormatter.toUsd(c.valueBrl / exchangeRate)
          : CurrencyFormatter.toBrl(c.valueBrl);
      buffer.writeln(' - ${c.name} (${c.setName}) : $priceStr');
    }
    final theirTotalStr = isUsd
        ? CurrencyFormatter.toUsd(_theirTotal / exchangeRate)
        : CurrencyFormatter.toBrl(_theirTotal);
    buffer.writeln('${strings.totalReceived}: $theirTotalStr');

    final diffStr = isUsd
        ? CurrencyFormatter.toUsd(diff.abs() / exchangeRate)
        : CurrencyFormatter.toBrl(diff.abs());
    buffer.writeln('\n${strings.tradeDifferencePrefix}${diff >= 0 ? '+' : '-'}$diffStr');
    if (_yourTotal > 0) {
      final pct = ((diff / _yourTotal) * 100).abs();
      if (pct <= 5) {
        buffer.writeln('Status: ${strings.tradeStatusBalanced}');
      } else if (diff > 0) {
        buffer.writeln('Status: ${strings.tradeAdvantageous}');
      } else {
        buffer.writeln('Status: ${strings.tradeUnfavorable}');
      }
    }
    buffer.writeln('\nGenerated by WurmDex');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.tradeSummaryCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final strings = getStrings(language);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final isUsd = currency == AppCurrency.usd;
    final diff = _theirTotal - _yourTotal;
    final totalSum = _yourTotal + _theirTotal;
    final diffPct = _yourTotal > 0 ? ((diff / _yourTotal) * 100) : 0.0;

    final diffFormatted = isUsd
        ? CurrencyFormatter.toUsd(diff.abs() / exchangeRate)
        : CurrencyFormatter.toBrl(diff.abs());

    Color statusColor;
    String statusText;
    if (totalSum == 0) {
      statusColor = Colors.grey;
      statusText = strings.tradePromptAddCards;
    } else if (diffPct.abs() <= 5) {
      statusColor = AppColors.profitGreen;
      statusText = strings.tradeStatusBalanced;
    } else if (diff > 0) {
      statusColor = AppColors.darkCyan;
      statusText = '${strings.tradeAdvantageous} (+$diffFormatted)';
    } else {
      statusColor = AppColors.warningYellow;
      statusText = '${strings.tradeUnfavorable} (-$diffFormatted)';
    }

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.tradesTitle),
        actions: [
          AppFilterButton(
            activeFilterCount: _filterMode != TradeFilterMode.all ? 1 : 0,
            tooltip: strings.tradeFilterTitle,
            isFilledTonal: false,
            onPressed: () => _showFilterDialog(strings),
          ),
          AppSortButton<TradeSortMode>(
            currentOption: _sortMode,
            isCompact: true,
            tooltip: strings.tradeSortTitle,
            onSelected: (val) => setState(() => _sortMode = val),
            options: [
              SortOptionItem(
                value: TradeSortMode.valueDesc,
                label: strings.tradeSortValueDesc,
                icon: Icons.arrow_downward,
              ),
              SortOptionItem(
                value: TradeSortMode.valueAsc,
                label: strings.tradeSortValueAsc,
                icon: Icons.arrow_upward,
              ),
              SortOptionItem(
                value: TradeSortMode.nameAsc,
                label: strings.tradeSortNameAsc,
                icon: Icons.sort_by_alpha,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              setState(() {});
              ref.read(exchangeRateProvider.notifier).refreshRate();
            },
          ),
          const AppOverflowMenu(showCurrency: true),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.tradesTitle,
        sheetTitle: strings.tradesTitle,
        actions: [
          AppFabAction(
            icon: Icons.add_circle_outline,
            title: strings.isEn ? 'Add to Your Offer' : 'Adicionar ao que Você Envia',
            subtitle: strings.youSendTitle,
            onTap: () => _addYourCard(exchangeRate),
          ),
          AppFabAction(
            icon: Icons.add_circle,
            title: strings.isEn ? 'Add to What You Get' : 'Adicionar ao que Você Recebe',
            subtitle: strings.youGetTitle,
            onTap: () => _addTheirCard(exchangeRate),
          ),
          if (_yourCards.isNotEmpty || _theirCards.isNotEmpty) ...[
            AppFabAction(
              icon: Icons.copy_all_outlined,
              title: strings.btnCopyTrade,
              subtitle: strings.copyTradeSummaryTooltip,
              onTap: () => _copyTradeSummary(strings, isUsd, exchangeRate),
            ),
            AppFabAction(
              icon: Icons.delete_sweep_outlined,
              title: strings.btnClearTrade,
              subtitle: strings.reset,
              isDestructive: true,
              onTap: () {
                setState(() {
                  _yourCards.clear();
                  _theirCards.clear();
                });
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Equity Banner Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.3))),
            ),
            child: Column(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statusColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (totalSum > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${strings.tradeDifferencePrefix}${diff >= 0 ? '+' : '-'}$diffFormatted (${CurrencyFormatter.formatPercent(diffPct)})',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ],
            ),
          ),

          // Two-Column Trade Board: Left = Send (Offer), Right = Receive (Get)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: You Send (Cartas a enviar)
                if (_filterMode != TradeFilterMode.theirOnly)
                  Expanded(
                    child: _buildTradeColumn(
                      context: context,
                      strings: strings,
                      title: strings.youSendTitle,
                      subtitle: strings.youSendSubtitle,
                      total: _yourTotal,
                      cards: _getSortedCards(_yourCards),
                      accentColor: theme.colorScheme.primary,
                      isUsd: isUsd,
                      exchangeRate: exchangeRate,
                      onAdd: () => _addYourCard(exchangeRate),
                      onRemove: (idx) {
                        final sorted = _getSortedCards(_yourCards);
                        final item = sorted[idx];
                        setState(() => _yourCards.remove(item));
                      },
                    ),
                  ),
                if (_filterMode == TradeFilterMode.all)
                  const VerticalDivider(width: 1, thickness: 1),
                // Right Column: You Receive (Cartas a ganhar)
                if (_filterMode != TradeFilterMode.yourOnly)
                  Expanded(
                    child: _buildTradeColumn(
                      context: context,
                      strings: strings,
                      title: strings.youGetTitle,
                      subtitle: strings.youGetSubtitle,
                      total: _theirTotal,
                      cards: _getSortedCards(_theirCards),
                      accentColor: AppColors.profitGreen,
                      isUsd: isUsd,
                      exchangeRate: exchangeRate,
                      onAdd: () => _addTheirCard(exchangeRate),
                      onRemove: (idx) {
                        final sorted = _getSortedCards(_theirCards);
                        final item = sorted[idx];
                        setState(() => _theirCards.remove(item));
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeColumn({
    required BuildContext context,
    required AppStrings strings,
    required String title,
    required String subtitle,
    required double total,
    required List<TradeCardItem> cards,
    required Color accentColor,
    required bool isUsd,
    required double exchangeRate,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    final theme = Theme.of(context);
    final totalDisplay = isUsd
        ? CurrencyFormatter.toUsd(total / exchangeRate)
        : CurrencyFormatter.toBrl(total);

    return Column(
      children: [
        // Column Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: theme.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: $totalDisplay',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.add, size: 18),
                tooltip: strings.btnAddCard,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cards List
        Expanded(
          child: cards.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 36, color: theme.dividerColor),
                        const SizedBox(height: 8),
                        Text(
                          strings.noCardsAdded,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: onAdd,
                          child: Text(strings.btnAdd),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final cardValStr = isUsd
                        ? CurrencyFormatter.toUsd(card.valueBrl / exchangeRate)
                        : CurrencyFormatter.toBrl(card.valueBrl);

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: card.imageUrl,
                            width: 28,
                            height: 38,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(width: 28, height: 38),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                        title: Text(
                          card.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          card.setName,
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cardValStr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              tooltip: strings.remove,
                              onPressed: () => onRemove(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
