import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';

class MarketplaceUrlHelper {
  /// Opens LigaPokemon marketplace page for the specified card (direct card tab)
  static Future<void> openLigaPokemon(
    BuildContext context, {
    required String cardName,
    String? cardNumber,
    String? setName,
    String? directUrl,
    AppLanguage? language,
  }) async {
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      await launchExternalUrl(context, directUrl.trim(), platformName: 'LigaPokemon', language: language);
      return;
    }

    final cleanName = cardName.trim();
    final cleanNum = cardNumber?.trim() ?? '';
    final cleanSet = setName?.trim() ?? '';

    // Direct card tab on LigaPokemon:
    // When ed and num are specified, LigaPokemon directly opens that specific card's page tab
    String url;
    if (cleanSet.isNotEmpty && cleanNum.isNotEmpty) {
      url = 'https://www.ligapokemon.com.br/?view=cards/card&card=${Uri.encodeComponent(cleanName)}&ed=${Uri.encodeComponent(cleanSet)}&num=${Uri.encodeComponent(cleanNum)}';
    } else if (cleanNum.isNotEmpty) {
      url = 'https://www.ligapokemon.com.br/?view=cards/card&card=${Uri.encodeComponent('$cleanName ($cleanNum)')}&num=${Uri.encodeComponent(cleanNum)}';
    } else {
      url = 'https://www.ligapokemon.com.br/?view=cards/card&card=${Uri.encodeComponent(cleanName)}';
    }
    await launchExternalUrl(context, url, platformName: 'LigaPokemon', language: language);
  }

  /// Opens TCGPlayer marketplace direct card product page
  static Future<void> openTcgPlayer(
    BuildContext context, {
    required String cardName,
    String? cardNumber,
    String? setName,
    int? productId,
    String? directUrl,
    AppLanguage? language,
  }) async {
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      await launchExternalUrl(context, directUrl.trim(), platformName: 'TCGPlayer', language: language);
      return;
    }

    // Direct product tab on TCGPlayer when productId is known
    if (productId != null && productId > 0) {
      final url = 'https://www.tcgplayer.com/product/$productId';
      await launchExternalUrl(context, url, platformName: 'TCGPlayer', language: language);
      return;
    }

    final cleanName = cardName.trim();
    final cleanNum = cardNumber?.trim() ?? '';
    final cleanSet = setName?.trim() ?? '';

    final queryParts = <String>[cleanName];
    if (cleanSet.isNotEmpty) queryParts.add(cleanSet);
    if (cleanNum.isNotEmpty) queryParts.add(cleanNum);
    final query = queryParts.join(' ');

    final url = 'https://www.tcgplayer.com/search/pokemon/product?productLineName=pokemon&q=${Uri.encodeComponent(query)}&view=grid';
    await launchExternalUrl(context, url, platformName: 'TCGPlayer', language: language);
  }

  /// Universal external link launcher with error snackbar and localized messaging
  static Future<bool> launchExternalUrl(
    BuildContext context,
    String urlString, {
    String platformName = 'Web',
    AppLanguage? language,
  }) async {
    final uri = Uri.tryParse(urlString.trim());
    if (uri == null) return false;

    final strings = getStrings(language ?? AppLanguage.enUs);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errOpenMarketplace(platformName))),
        );
      }
      return launched;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errOpenBrowser(platformName))),
        );
      }
      return false;
    }
  }
}
