import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/marketplace_url_helper.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_network_image.dart';
import '../services/liga_scraper_service.dart';
import 'widgets/add_edit_liga_alert_dialog.dart';

enum LigaFilterType {
  all,
  inRange,
  preSale,
  active,
}

class LigaRadarScreen extends ConsumerStatefulWidget {
  const LigaRadarScreen({super.key});

  @override
  ConsumerState<LigaRadarScreen> createState() => _LigaRadarScreenState();
}

class _LigaRadarScreenState extends ConsumerState<LigaRadarScreen> {
  LigaFilterType _filterType = LigaFilterType.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isCheckingAll = false;
  final Set<String> _checkingItemIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCheckStaleAlerts();
    });
  }

  Future<void> _autoCheckStaleAlerts() async {
    final db = ref.read(databaseProvider);
    final alerts = await db.getAllActiveLigaAlerts();
    final stale = alerts.where((a) => a.lastCheckedAt == null || a.currentLowestPrice == null || a.imageUrl.isEmpty).toList();
    for (final alert in stale) {
      if (!mounted) break;
      _checkSingleItem(alert);
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AddEditLigaAlertDialog(
        db: db,
        strings: strings,
      ),
    );

    if (result == true && mounted) {
      _autoCheckStaleAlerts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.purchasePriceUpdatedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditDialog(LigaPriceAlert alert) async {
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    await showDialog<bool>(
      context: context,
      builder: (ctx) => AddEditLigaAlertDialog(
        db: db,
        strings: strings,
        existingAlert: alert,
      ),
    );
  }

  Future<void> _checkSingleItem(LigaPriceAlert alert) async {
    setState(() => _checkingItemIds.add(alert.id));
    final db = ref.read(databaseProvider);

    try {
      final result = await LigaScraperService.checkAlert(alert: alert, db: db, notify: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isInRange
                  ? '🎯 ${alert.title}: Disponível na faixa desejada!'
                  : '🔍 ${alert.title}: Menor preço atualizado.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingItemIds.remove(alert.id));
      }
    }
  }

  Future<void> _checkAllItems() async {
    if (_isCheckingAll) return;
    setState(() => _isCheckingAll = true);
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    try {
      final count = await LigaScraperService.checkAllActiveAlerts(db: db, notify: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.alertsCheckedSuccess(count)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingAll = false);
      }
    }
  }

  Future<void> _toggleActive(LigaPriceAlert alert) async {
    final db = ref.read(databaseProvider);
    final updated = alert.toCompanion(true).copyWith(
          isActive: drift.Value(!alert.isActive),
        );
    await db.updateLigaAlert(updated);
  }

  Future<void> _confirmDelete(LigaPriceAlert alert) async {
    final strings = getStrings(ref.read(languageProvider));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.deleteAlertTitle),
        content: Text('${strings.deleteAlertConfirm}\n\n"${alert.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteLigaAlert(alert.id);
    }
  }

  Future<void> _openExternalLiga(String url) =>
      MarketplaceUrlHelper.launchExternalUrl(context, url, platformName: 'LigaPokémon');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = getStrings(ref.watch(languageProvider));
    final alertsAsync = ref.watch(ligaAlertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.ligaRadarTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              strings.ligaRadarSubtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isCheckingAll
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: strings.btnCheckAllNow,
            onPressed: _isCheckingAll ? null : _checkAllItems,
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: theme.colorScheme.primary, size: 28),
            tooltip: strings.btnAddAlert,
            onPressed: _openAddDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppEmptyState(
                      icon: Icons.radar,
                      title: strings.emptyRadarTitle,
                      message: strings.emptyRadarSubtitle,
                    ),
                  ],
                ),
              ),
            );
          }

          // Compute KPIs
          final totalMonitored = alerts.length;
          final totalInRange = alerts.where((a) => a.isAvailableInRange && a.isActive).length;
          final totalPreSale = alerts.where((a) => a.isPreSale).length;

          // Filter items
          final filtered = alerts.where((a) {
            if (_searchQuery.isNotEmpty) {
              if (!a.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
                return false;
              }
            }
            switch (_filterType) {
              case LigaFilterType.inRange:
                return a.isAvailableInRange;
              case LigaFilterType.preSale:
                return a.isPreSale;
              case LigaFilterType.active:
                return a.isActive;
              case LigaFilterType.all:
                return true;
            }
          }).toList();

          return Column(
            children: [
              // Top KPI cards
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        theme: theme,
                        label: strings.kpiMonitoredTotal,
                        value: '$totalMonitored',
                        icon: Icons.bookmark_outline,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        theme: theme,
                        label: strings.kpiInRangeTotal,
                        value: '$totalInRange',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        theme: theme,
                        label: strings.kpiPreSaleTotal,
                        value: '$totalPreSale',
                        icon: Icons.calendar_today_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings.filterProductsHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(strings.filterAllAlerts),
                      selected: _filterType == LigaFilterType.all,
                      onSelected: (_) => setState(() => _filterType = LigaFilterType.all),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      label: Text(strings.filterInRangeAlerts),
                      selected: _filterType == LigaFilterType.inRange,
                      onSelected: (_) => setState(() => _filterType = LigaFilterType.inRange),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(strings.filterPreSaleAlerts),
                      selected: _filterType == LigaFilterType.preSale,
                      onSelected: (_) => setState(() => _filterType = LigaFilterType.preSale),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(strings.filterActiveAlerts),
                      selected: _filterType == LigaFilterType.active,
                      onSelected: (_) => setState(() => _filterType = LigaFilterType.active),
                    ),
                  ],
                ),
              ),

              // Monitored items list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          strings.noFilterMatch,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final alert = filtered[index];
                          final isChecking = _checkingItemIds.contains(alert.id);
                          return _buildAlertCard(theme, strings, alert, isChecking);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildKpiCard({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    ThemeData theme,
    AppStrings strings,
    LigaPriceAlert alert,
    bool isChecking,
  ) {
    final price = alert.currentLowestPrice;
    final priceText = (price != null && price > 0)
        ? CurrencyFormatter.toBrl(price)
        : (alert.lastCheckedAt == null ? strings.statusPending : strings.statusOutOfStock);
    final minText = alert.minTargetPrice > 0 ? CurrencyFormatter.toBrl(alert.minTargetPrice) : 'R\$ 0';
    final maxText = alert.maxTargetPrice > 0 ? CurrencyFormatter.toBrl(alert.maxTargetPrice) : strings.noPriceCeiling;
    final storeName = alert.currentStoreName.isNotEmpty
        ? alert.currentStoreName
        : (price != null && price > 0 ? strings.marketplaceFallback : strings.statusOutOfStock);

    Color statusColor;
    String statusText;
    if (alert.isAvailableInRange) {
      statusColor = Colors.green;
      statusText = strings.statusInRange;
    } else if (price != null && price > 0) {
      if (alert.minTargetPrice > 0 && price < alert.minTargetPrice) {
        statusColor = Colors.blue;
        statusText = strings.statusBelowRange;
      } else {
        statusColor = Colors.amber.shade800;
        statusText = strings.statusAboveRange;
      }
    } else {
      statusColor = Colors.grey;
      statusText = alert.lastCheckedAt == null ? strings.statusPending : strings.statusOutOfStock;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.isAvailableInRange ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alert.isAvailableInRange ? Colors.green.shade400 : theme.colorScheme.outlineVariant,
          width: alert.isAvailableInRange ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Image, Title, Pre-Sale & Status Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail / Icon
                Stack(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: alert.isAvailableInRange ? Colors.green.shade300 : theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppNetworkImage(
                        imageUrl: alert.imageUrl,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(12),
                        fallbackIcon: Icons.inventory_2_outlined,
                        fallbackIconSize: 32,
                      ),
                    ),
                    if (alert.isPreSale)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            strings.statusPreSale.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Title and badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),

                          // Pre-Sale Indicator if current offer is pre-sale
                          if (alert.isPreSale)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                strings.statusPreSale.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                          // Allow Pre-Sale Tag
                          if (alert.allowPreSale && !alert.isPreSale)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                strings.preSaleAcceptedTag,
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Active Switch
                Switch(
                  value: alert.isActive,
                  onChanged: (_) => _toggleActive(alert),
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price & Store Monitoring Section (Barra de Destaque do Preço & Loja)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: alert.isAvailableInRange
                    ? Colors.green.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: alert.isAvailableInRange
                      ? Colors.green.withValues(alpha: 0.4)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Lowest Price Column
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.price_check,
                                    size: 14,
                                    color: alert.isAvailableInRange ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      strings.currentLowestPriceHeader,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                        color: alert.isAvailableInRange ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  priceText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: alert.isAvailableInRange
                                        ? Colors.green.shade700
                                        : (price != null && price > 0 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                        // Store Name Column
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      strings.storeSellerHeader,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.4,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Text(
                                  storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Target range footer
                  Row(
                    children: [
                      Icon(Icons.tune, size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        strings.targetRangeLabelText,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '$minText - $maxText',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Botão para abrir oferta no navegador
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openExternalLiga(alert.targetUrl),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(
                        strings.openOfferInBrowser,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: alert.isAvailableInRange
                            ? const Color(0xFF1B5E20)
                            : (theme.brightness == Brightness.dark
                                ? theme.colorScheme.primary
                                : const Color(0xFF1565C0)),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Bottom Actions Bar
            Row(
              children: [
                Text(
                  alert.lastCheckedAt != null
                      ? '${strings.lastCheckedPrefix}${alert.lastCheckedAt!.hour.toString().padLeft(2, '0')}:${alert.lastCheckedAt!.minute.toString().padLeft(2, '0')}'
                      : '${strings.lastCheckedPrefix}${strings.neverChecked}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                const Spacer(),

                // Check single item now button
                IconButton(
                  icon: isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                  tooltip: strings.refreshTooltip,
                  onPressed: isChecking ? null : () => _checkSingleItem(alert),
                ),

                // Open in Liga button
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20, color: Colors.blue),
                  tooltip: strings.openInLiga,
                  onPressed: () => _openExternalLiga(alert.targetUrl),
                ),

                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Editar',
                  onPressed: () => _openEditDialog(alert),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  tooltip: strings.remove,
                  onPressed: () => _confirmDelete(alert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
