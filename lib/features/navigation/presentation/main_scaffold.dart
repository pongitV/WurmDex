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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 720;

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
      const SettingsScreen(),
    ];

    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleShortcuts,
      child: Scaffold(
        body: isDesktop
            ? Row(
                children: [
                  // Desktop Collapsible Sidebar
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) => setState(() => _currentIndex = index),
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const WobblyMenuIcon(
                            size: 48,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.appName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.search),
                        selectedIcon: const Icon(Icons.search),
                        label: Text(strings.navCatalog),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.catching_pokemon),
                        selectedIcon: const Icon(Icons.catching_pokemon),
                        label: Text(strings.navPokedex),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.style_outlined),
                        selectedIcon: const Icon(Icons.style),
                        label: Text(strings.navSets),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.folder_copy_outlined),
                        selectedIcon: const Icon(Icons.folder_copy),
                        label: Text(strings.navCollections),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.swap_horiz_outlined),
                        selectedIcon: const Icon(Icons.swap_horiz),
                        label: Text(strings.navTrades),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.bookmark_border),
                        selectedIcon: const Icon(Icons.bookmark),
                        label: Text(strings.navWishlist),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings),
                        label: Text(strings.navSettings),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: screens[_currentIndex]),
                ],
              )
            : screens[_currentIndex],
        // Mobile Bottom Navigation Bar
        bottomNavigationBar: isDesktop
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) => setState(() => _currentIndex = index),
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.search),
                    label: strings.navCatalog,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.catching_pokemon),
                    label: strings.navPokedex,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.style_outlined),
                    selectedIcon: const Icon(Icons.style),
                    label: strings.navSets,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.folder_copy_outlined),
                    selectedIcon: const Icon(Icons.folder_copy),
                    label: strings.navCollection,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.swap_horiz_outlined),
                    selectedIcon: const Icon(Icons.swap_horiz),
                    label: strings.navTrades,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bookmark_border),
                    selectedIcon: const Icon(Icons.bookmark),
                    label: strings.navWishlist,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: strings.navSettings,
                  ),
                ],
              ),
      ),
    );
  }
}
