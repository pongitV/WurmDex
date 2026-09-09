import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../../../core/widgets/wobbly_menu_icon.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../../collections/presentation/collections_screen.dart';
import '../../pokedex/presentation/pokedex_screen.dart';
import '../../sets/presentation/sets_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import '../../trade/presentation/trade_evaluator_screen.dart';
import '../../monitoring/presentation/liga_radar_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleShortcuts(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        // Ctrl+F: Focus Catalog Search
        setState(() => _currentIndex = 0);
        _searchFocusNode.requestFocus();
      } else if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyB) {
        // Ctrl+B: Quick Backup Export
        final db = ref.read(databaseProvider);
        final strings = getStrings(ref.read(languageProvider));
        FileStorageHelper.exportBackup(db).then((success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? strings.backupExportSuccess : strings.backupExportFailed)),
            );
          }
        });
      }
    }
  }

  int get _mobileNavSelectedIndex {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 6) return 1;
    return 2;
  }

  bool _isMoreScreen(int index) => index != 0 && index != 6;

  IconData _getMoreScreenIcon(int index) {
    switch (index) {
      case 1:
        return Icons.catching_pokemon;
      case 2:
        return Icons.style_outlined;
      case 3:
        return Icons.folder_copy_outlined;
      case 4:
        return Icons.swap_horiz_outlined;
      case 5:
        return Icons.bookmark_border;
      case 7:
        return Icons.settings_outlined;
      default:
        return Icons.grid_view_outlined;
    }
  }

  IconData _getMoreScreenSelectedIcon(int index) {
    switch (index) {
      case 1:
        return Icons.catching_pokemon;
      case 2:
        return Icons.style;
      case 3:
        return Icons.folder_copy;
      case 4:
        return Icons.swap_horiz;
      case 5:
        return Icons.bookmark;
      case 7:
        return Icons.settings;
      default:
        return Icons.grid_view_rounded;
    }
  }

  String _getMoreScreenLabel(int index, AppStrings strings) {
    switch (index) {
      case 1:
        return strings.navPokedex;
      case 2:
        return strings.navSets;
      case 3:
        return strings.navCollections;
      case 4:
        return strings.navTrades;
      case 5:
        return strings.navWishlist;
      case 7:
        return strings.navSettings;
      default:
        return strings.navMore;
    }
  }

  void _onMobileNavSelected(int barIndex) {
    if (barIndex == 0) {
      setState(() => _currentIndex = 0);
    } else if (barIndex == 1) {
      setState(() => _currentIndex = 6);
    } else {
      _showMoreBottomSheet(context);
    }
  }

  void _showMoreBottomSheet(BuildContext context) {
    final strings = getStrings(ref.read(languageProvider));
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final isWide = screenWidth >= 600;
        final crossAxisCount = isWide ? 3 : 2;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const WobblyMenuIcon(size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.moreOptionsTitle,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                strings.moreOptionsSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: strings.close,
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: isWide ? 1.8 : 1.42,
                      children: [
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 1,
                      icon: Icons.catching_pokemon,
                      selectedIcon: Icons.catching_pokemon,
                      title: strings.navPokedex,
                      subtitle: strings.descPokedex,
                      theme: theme,
                    ),
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 2,
                      icon: Icons.style_outlined,
                      selectedIcon: Icons.style,
                      title: strings.navSets,
                      subtitle: strings.descSets,
                      theme: theme,
                    ),
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 3,
                      icon: Icons.folder_copy_outlined,
                      selectedIcon: Icons.folder_copy,
                      title: strings.navCollections,
                      subtitle: strings.descCollections,
                      theme: theme,
                    ),
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 5,
                      icon: Icons.bookmark_border,
                      selectedIcon: Icons.bookmark,
                      title: strings.navWishlist,
                      subtitle: strings.descWishlist,
                      theme: theme,
                    ),
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 4,
                      icon: Icons.swap_horiz_outlined,
                      selectedIcon: Icons.swap_horiz,
                      title: strings.navTrades,
                      subtitle: strings.descTrades,
                      theme: theme,
                    ),
                    _buildMoreGridItem(
                      context: sheetContext,
                      index: 7,
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      title: strings.navSettings,
                      subtitle: strings.descSettings,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }

  Widget _buildMoreGridItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final primaryColor = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() => _currentIndex = index);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.2)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      size: 22,
                      color: isSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, size: 18, color: primaryColor),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? primaryColor : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CatalogScreen(
        searchFocusNode: _searchFocusNode,
        onNavigateToCollections: () => setState(() => _currentIndex = 3),
      ),
      const PokedexScreen(),
      const SetsScreen(),
      const CollectionsScreen(),
      const TradeEvaluatorScreen(),
      const WishlistScreen(),
      const LigaRadarScreen(),
      const SettingsScreen(),
    ];

    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleShortcuts,
      child: Scaffold(
        body: screens[_currentIndex],
        // Unified Bottom Navigation Bar: Catalog, Radar and More (identical across Windows exe and Android apk)
        bottomNavigationBar: NavigationBar(
          selectedIndex: _mobileNavSelectedIndex,
          onDestinationSelected: _onMobileNavSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.search),
              selectedIcon: const Icon(Icons.search),
              label: strings.navCatalog,
            ),
            NavigationDestination(
              icon: const Icon(Icons.radar_outlined),
              selectedIcon: const Icon(Icons.radar),
              label: strings.navLigaRadar,
            ),
            NavigationDestination(
              icon: Icon(_isMoreScreen(_currentIndex)
                  ? _getMoreScreenIcon(_currentIndex)
                  : Icons.grid_view_outlined),
              selectedIcon: Icon(_isMoreScreen(_currentIndex)
                  ? _getMoreScreenSelectedIcon(_currentIndex)
                  : Icons.grid_view_rounded),
              label: _isMoreScreen(_currentIndex)
                  ? _getMoreScreenLabel(_currentIndex, strings)
                  : strings.navMore,
            ),
          ],
        ),
      ),
    );
  }
}


