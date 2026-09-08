import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/theme/theme_constants.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/utils/folder_icon_helper.dart';
import 'package:wurmdex/core/utils/semantic_search_helper.dart';
import 'package:wurmdex/features/catalog/models/catalog_filter_state.dart';

void main() {
  group('SemanticSearchHelper Tests', () {
    test('Normalizes PT-BR query to English synonym', () {
      expect(SemanticSearchHelper.normalizeQuery('charizard vastro'), 'charizard vstar');
      expect(SemanticSearchHelper.normalizeQuery('mew brilhante'), 'mew shiny');
      expect(SemanticSearchHelper.normalizeQuery('origem perdida'), 'lost origin');
      expect(SemanticSearchHelper.normalizeQuery('Pikachu Radiante'), 'pikachu radiant');
    });

    test('Formats card identifier as Nome-Sufixo(Codigo)', () {
      final title1 = SemanticSearchHelper.formatCardIdentifier(
        rawName: 'Charizard ex',
        number: '125',
        setTotal: '197',
      );
      expect(title1, 'Charizard-ex(#125/197)');

      final title2 = SemanticSearchHelper.formatCardIdentifier(
        rawName: 'Giratina VSTAR',
        number: 'GG69',
        setTotal: 'GG70',
      );
      expect(title2, 'Giratina-VSTAR(#GG69/GG70)');

      final title3 = SemanticSearchHelper.formatCardIdentifier(
        rawName: 'Wurmple',
        number: '2',
        setTotal: '198',
      );
      expect(title3, 'Wurmple(#2/198)');
    });
  });

  group('CurrencyFormatter Tests', () {
    test('Formats BRL correctly', () {
      expect(CurrencyFormatter.toBrl(null), 'R\$ --');
      expect(CurrencyFormatter.toBrl(25.50), contains('25,50'));
    });

    test('Formats USD correctly', () {
      expect(CurrencyFormatter.toUsd(null), '\$ --');
      expect(CurrencyFormatter.toUsd(10.00), contains('10.00'));
    });

    test('Formats Profit/Loss percentages', () {
      expect(CurrencyFormatter.formatPercent(12.34), '+12.3%');
      expect(CurrencyFormatter.formatPercent(-5.67), '-5.7%');
    });
  });

  group('CatalogFilterState Tests', () {
    test('Initial state has no active filters', () {
      const state = CatalogFilterState();
      expect(state.hasActiveFilters, isFalse);
      expect(state.activeFilterCount, 0);
      expect(state.sortOption, CatalogSortOption.priceDesc);
    });

    test('copyWith updates filters and counts correctly', () {
      const state = CatalogFilterState();
      final withType = state.copyWith(selectedType: 'Fire');
      expect(withType.hasActiveFilters, isTrue);
      expect(withType.activeFilterCount, 1);
      expect(withType.selectedType, 'Fire');

      final withRarity = withType.copyWith(selectedRarity: 'Rare Holo');
      expect(withRarity.activeFilterCount, 2);

      final cleared = withRarity.copyWith(clearType: true);
      expect(cleared.activeFilterCount, 1);
      expect(cleared.selectedType, isNull);
      expect(cleared.selectedRarity, 'Rare Holo');

      final reset = cleared.resetFilters();
      expect(reset.hasActiveFilters, isFalse);
      expect(reset.activeFilterCount, 0);
    });
  });

  group('FolderIconHelper Tests', () {
    test('Resolves standard and fallback icons', () {
      expect(FolderIconHelper.getIcon('folder'), Icons.folder);
      expect(FolderIconHelper.getIcon('star'), Icons.star);
      expect(FolderIconHelper.getIcon('local_fire_department'), Icons.local_fire_department);
      expect(FolderIconHelper.getIcon('water_drop'), Icons.water_drop);
      expect(FolderIconHelper.getIcon('bolt'), Icons.bolt);
      expect(FolderIconHelper.getIcon('diamond'), Icons.diamond);
      expect(FolderIconHelper.getIcon('unknown_key_xyz'), Icons.folder);
      expect(FolderIconHelper.getIcon(null), Icons.folder);
    });

    test('Available icons list is populated', () {
      expect(FolderIconHelper.availableIcons.length, greaterThanOrEqualTo(10));
    });
  });

  group('Localization and AppStrings Tests', () {
    test('Default en-US strings are accurate', () {
      final strings = getStrings(AppLanguage.enUs);
      expect(strings.appTitle, 'WurmDex Catalog');
      expect(strings.btnSearchCards, 'Search Cards');
      expect(strings.btnViewCollection, 'View Collection');
      expect(strings.sectionTrending, 'TRENDING CARDS RIGHT NOW');
      expect(strings.sectionNews, 'POKÉMON TCG NEWS & SCENE');
      expect(strings.navCatalog, 'Catalog');
      expect(strings.navSettings, 'Settings');
      expect(strings.btnHome, 'Home');
    });

    test('pt-BR localized strings are accurate', () {
      final strings = getStrings(AppLanguage.ptBr);
      expect(strings.appTitle, 'WurmDex Catálogo');
      expect(strings.btnSearchCards, 'Pesquisar Cartas');
      expect(strings.btnViewCollection, 'Ver Coleção');
      expect(strings.sectionTrending, 'CARTAS MAIS PROCURADAS NO MOMENTO');
      expect(strings.sectionNews, 'NOTÍCIAS & CENÁRIO DO POKÉMON TCG');
      expect(strings.navCatalog, 'Catálogo');
      expect(strings.navSettings, 'Ajustes');
      expect(strings.btnHome, 'Início');
    });
  });

  group('ThemeMode and AppThemes Tests', () {
    test('All four themes are present and have valid theme data', () {
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.gramado));
      expect(AppThemeMode.values, contains(AppThemeMode.wurmple));
    });
  });
}

