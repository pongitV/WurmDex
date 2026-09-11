import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/navigation/app_navigator.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/utils/marketplace_url_helper.dart';
import 'package:wurmdex/core/utils/semantic_search_helper.dart';
import 'package:wurmdex/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:wurmdex/core/widgets/condition_badge.dart';
import 'package:wurmdex/core/widgets/language_flag_badge.dart';
import 'package:wurmdex/core/widgets/pokemon_card_image.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';


class CardQuickActionSheet extends ConsumerWidget {
  final PokemonCardItem card;

  const CardQuickActionSheet({super.key, required this.card});

  static void show(BuildContext context, PokemonCardItem card) {
    showAppModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CardQuickActionSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final formattedTitle = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
      setTotal: card.setTotal,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BottomSheetDragHandle(bottomPadding: 16),
          // Card Title Header
          Row(
            children: [
              PokemonCardImage(
                imageUrl: card.imageUrlSmall,
                fallbackImageUrl: card.imageUrlLarge,
                width: 45,
                height: 62,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.setName} • ${card.rarity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Actions List
          ListTile(
            leading: const Icon(Icons.folder_special, color: AppColors.profitGreen),
            title: Text(strings.actionAddToCollection),
            subtitle: Text(strings.actionAddToCollectionSub),
            onTap: () {
              Navigator.pop(context);
              _showAddToFolderDialog(context, ref, strings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add, color: AppColors.wurmpleSecondary),
            title: Text(strings.actionAddToWishlist),
            subtitle: Text(strings.actionAddToWishlistSub),
            onTap: () {
              Navigator.pop(context);
              _showAddToWishlistDialog(context, ref, strings);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: theme.colorScheme.primary),
            title: Text(strings.actionViewDetails),
            subtitle: Text(strings.actionViewDetailsSub),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.toCardDetails(context, card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new, color: Colors.blue),
            title: Text(strings.openInLiga),
            subtitle: Text(strings.viewOffersBrazil),
            onTap: () {
              Navigator.pop(context);
              MarketplaceUrlHelper.openLigaPokemon(
                context,
                cardName: card.name,
                cardNumber: card.number,
                setName: card.setName,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new, color: Colors.orange),
            title: Text(strings.openInTcgPlayer),
            subtitle: Text(strings.viewMarketplaceInternational),
            onTap: () {
              Navigator.pop(context);
              MarketplaceUrlHelper.openTcgPlayer(
                context,
                cardName: card.name,
                cardNumber: card.number,
                setName: card.setName,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: AppColors.darkCyan),
            title: Text(strings.copyFormattedIdentifier),
            subtitle: Text(formattedTitle),
            onTap: () {
              Clipboard.setData(ClipboardData(text: formattedTitle));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.copiedCode(formattedTitle)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showAddToFolderDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    showAddToFolderDialog(context: context, ref: ref, card: card);
  }

  static void showAddToFolderDialog({
    required BuildContext context,
    required WidgetRef ref,
    required PokemonCardItem card,
    String? preselectedFolderId,
  }) {
    final appLang = ref.read(languageProvider);
    final strings = getStrings(appLang);
    final foldersAsync = ref.read(foldersStreamProvider);
    final db = ref.read(databaseProvider);

    String condition = 'Near Mint';
    String language = 'PT';
    String finish = 'Regular';
    int quantity = 1;
    double purchasePrice = 0.0;
    String? selectedFolderId = preselectedFolderId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final folders = foldersAsync.asData?.value ?? [];

          return AlertDialog(
            title: Text(strings.addCardTitle(card.name)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Folder Picker
                  DropdownButtonFormField<String?>(
                    decoration: InputDecoration(labelText: strings.labelSelectFolder),
                    initialValue: selectedFolderId,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(strings.labelGeneralCollectionNoFolder),
                      ),
                      ...folders.map((f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                          )),
                    ],
                    onChanged: (val) => setState(() => selectedFolderId = val),
                  ),
                  const SizedBox(height: 12),
                  // Condition
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: strings.labelCondition),
                    initialValue: condition,
                    items: [
                      const DropdownMenuItem(value: 'Mint', child: Text('Mint (M)')),
                      const DropdownMenuItem(value: 'Near Mint', child: Text('Near Mint (NM)')),
                      const DropdownMenuItem(value: 'Slightly Played', child: Text('Slightly Played (SP)')),
                      const DropdownMenuItem(value: 'Moderately Played', child: Text('Moderately Played (MP)')),
                      const DropdownMenuItem(value: 'Heavily Played', child: Text('Heavily Played (HP)')),
                      DropdownMenuItem(value: 'Damaged', child: Text(strings.isEn ? 'Damaged (DMG)' : 'Danificada (DMG)')),
                      DropdownMenuItem(value: 'Graduada (PSA 10)', child: Text(strings.isEn ? 'Graded (PSA 10)' : 'Graduada (PSA 10)')),
                      DropdownMenuItem(value: 'Graduada (PSA 9)', child: Text(strings.isEn ? 'Graded (PSA 9)' : 'Graduada (PSA 9)')),
                      DropdownMenuItem(value: 'Graduada (BGS 9.5)', child: Text(strings.isEn ? 'Graded (BGS 9.5)' : 'Graduada (BGS 9.5)')),
                      DropdownMenuItem(value: 'Graduada (CGC 10)', child: Text(strings.isEn ? 'Graded (CGC 10)' : 'Graduada (CGC 10)')),
                      DropdownMenuItem(value: 'Graduada', child: Text(strings.isEn ? 'Graded (Other)' : 'Graduada (Outra)')),
                    ],
                    onChanged: (val) => setState(() => condition = val!),
                  ),
                  const SizedBox(height: 12),
                  // Language & Finish Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: strings.labelLanguage),
                          initialValue: language,
                          items: [
                            const DropdownMenuItem(
                              value: 'PT',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇧🇷', style: TextStyle(fontSize: 14)),
                                  SizedBox(width: 6),
                                  Text('PT-BR'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'EN',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇺🇸', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(strings.isEn ? 'English' : 'Inglês'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'JP',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇯🇵', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(strings.isEn ? 'Japanese' : 'Japonês'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => language = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: strings.labelFinish),
                          initialValue: finish,
                          items: [
                            DropdownMenuItem(value: 'Regular', child: Text(strings.isEn ? 'Regular' : 'Normal')),
                            const DropdownMenuItem(value: 'Reverse Holo', child: Text('Reverse Holo')),
                            const DropdownMenuItem(value: 'Holofoil', child: Text('Holofoil')),
                            const DropdownMenuItem(value: 'Secret Rare', child: Text('Secret Rare')),
                          ],
                          onChanged: (val) => setState(() => finish = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Visual Preview: Quality & Country Flag Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          strings.isEn ? 'Card Badge Preview:' : 'Prévia dos Selos:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        ConditionBadge(condition: condition, compact: true),
                        const SizedBox(width: 6),
                        LanguageFlagBadge(language: language, compact: true, showCode: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price Paid & Quantity
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: strings.labelPurchasePriceBrl,
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) {
                            purchasePrice = CurrencyFormatter.parseCurrencyOrDefault(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          decoration: InputDecoration(labelText: strings.labelQuantity),
                          initialValue: '1',
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            quantity = int.tryParse(val) ?? 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  await db.insertCard(
                    UserCardsCompanion(
                      id: drift.Value(const Uuid().v4()),
                      cardApiId: drift.Value(card.id),
                      name: drift.Value(card.name),
                      number: drift.Value(card.number),
                      setName: drift.Value(card.setName),
                      rarity: drift.Value(card.rarity),
                      imageUrl: drift.Value(card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall),
                      folderId: drift.Value(selectedFolderId),
                      condition: drift.Value(condition),
                      language: drift.Value(language),
                      finish: drift.Value(finish),
                      quantity: drift.Value(quantity),
                      purchasePriceBrl: drift.Value(purchasePrice),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.cardAddedToCollection(card.name))),
                    );
                  }
                },
                child: Text(strings.saveToCollection),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddToWishlistDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    final db = ref.read(databaseProvider);
    double targetPrice = 0.0;
    String priority = 'Média';
    String folderName = 'Geral';
    String notes = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${strings.wishlistTitle}: ${card.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: strings.labelTargetPriceBrl,
                    prefixText: 'R\$ ',
                    helperText: strings.alertPriceDropHelper,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    targetPrice = CurrencyFormatter.parseCurrencyOrDefault(val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: folderName,
                  decoration: InputDecoration(
                    labelText: strings.wishlistFolderNameLabel,
                    prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                    isDense: true,
                  ),
                  onChanged: (val) => folderName = val.trim().isEmpty ? 'Geral' : val.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: strings.labelPriority),
                  initialValue: priority,
                  items: [
                    DropdownMenuItem(value: 'Baixa', child: Text(strings.priorityLow)),
                    DropdownMenuItem(value: 'Média', child: Text(strings.priorityMedium)),
                    DropdownMenuItem(value: 'Alta', child: Text(strings.priorityHigh)),
                  ],
                  onChanged: (val) => setState(() => priority = val!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: strings.notesObservationsLabel,
                    hintText: strings.notesObservationsHint,
                  ),
                  maxLines: 2,
                  onChanged: (val) => notes = val,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  await db.insertWishlistItem(
                    WishlistItemsCompanion(
                      id: drift.Value(const Uuid().v4()),
                      cardApiId: drift.Value(card.id),
                      name: drift.Value(card.name),
                      number: drift.Value(card.number),
                      setName: drift.Value(card.setName),
                      imageUrl: drift.Value(card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall),
                      targetPriceBrl: drift.Value(targetPrice),
                      priority: drift.Value(priority),
                      folderName: drift.Value(folderName),
                      notes: drift.Value(notes),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.cardAddedToWishlist(card.name))),
                    );
                  }
                },
                child: Text(strings.saveToWishlist),
              ),
            ],
          );
        },
      ),
    );
  }
}
