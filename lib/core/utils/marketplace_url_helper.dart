import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';

class MarketplaceUrlHelper {
  /// Opens LigaPokemon marketplace page for the specified card
  static Future<void> openLigaPokemon(BuildContext context, {required String cardName, AppLanguage? language}) async {
    final query = cardName.trim();
    final url = 'https://www.ligapokemon.com.br/?view=cards/card&card=${Uri.encodeComponent(query)}';
    await launchExternalUrl(context, url, platformName: 'LigaPokemon', language: language);
  }

  /// Opens TCGPlayer marketplace search for the specified card
  static Future<void> openTcgPlayer(BuildContext context, {required String cardName, String? cardNumber, AppLanguage? language}) async {
    final cleanName = cardName.trim();
    final cleanNum = cardNumber?.trim() ?? '';
    final query = cleanNum.isNotEmpty ? '$cleanName $cleanNum' : cleanName;
    final url = 'https://www.tcgplayer.com/search/pokemon/product?q=${Uri.encodeComponent(query)}';
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
