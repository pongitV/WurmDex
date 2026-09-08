import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

enum RestoreMode {
  replace,
  merge,
}

class FileStorageHelper {
  /// Exports all user data (folders, cards, wishlist, price snapshots) to a JSON string
  static Future<String> generateBackupJson(AppDatabase db) async {
    final folders = await db.getAllFolders();
    final cards = await db.getAllCards();
    final wishlist = await db.getAllWishlist();

    final backupMap = {
      'app': 'WurmDex',
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'folders': folders.map((f) => {
        'id': f.id,
        'name': f.name,
        'description': f.description,
        'colorTag': f.colorTag,
        'displayMode': f.displayMode,
        'createdAt': f.createdAt.toIso8601String(),
      }).toList(),
      'cards': cards.map((c) => {
        'id': c.id,
        'cardApiId': c.cardApiId,
        'name': c.name,
        'number': c.number,
        'setName': c.setName,
        'rarity': c.rarity,
        'imageUrl': c.imageUrl,
        'folderId': c.folderId,
        'condition': c.condition,
        'language': c.language,
        'finish': c.finish,
        'quantity': c.quantity,
        'purchasePriceBrl': c.purchasePriceBrl,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList(),
      'wishlist': wishlist.map((w) => {
        'id': w.id,
        'cardApiId': w.cardApiId,
        'name': w.name,
        'number': w.number,
        'setName': w.setName,
        'imageUrl': w.imageUrl,
        'targetPriceBrl': w.targetPriceBrl,
        'priority': w.priority,
        'notes': w.notes,
        'createdAt': w.createdAt.toIso8601String(),
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  /// Exports backup JSON to file via native file picker dialog or share sheet
  static Future<bool> exportBackup(AppDatabase db) async {
    try {
      final jsonString = await generateBackupJson(db);
      final timestamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      final fileName = 'wurmdex_backup_$timestamp.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        // Desktop: Native save file dialog
        final saveUri = await FilePicker.saveFile(
          dialogTitle: 'Salvar Backup WurmDex',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: bytes,
        );

        if (saveUri != null) {
          final filePath = saveUri.toFilePath();
          final file = File(filePath);
          await file.writeAsString(jsonString);
          return true;
        }
        return false;
      } else {
        // Mobile (Android / iOS): Save to temporary file and share/save via native action
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Backup WurmDex - $fileName',
          ),
        );
        return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
      }
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Imports and restores data from a selected .json file
  static Future<int> restoreBackup(AppDatabase db, RestoreMode mode) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return 0; // Cancelled
      }

      final file = files.first;
      String content = '';
      if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes);
      }

      if (content.isEmpty) return -1;

      final dynamic decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic> ||
          (decoded['app'] != 'WurmDex' && decoded['app'] != 'Yourdex')) {
        return -1; // Invalid payload
      }

      if (mode == RestoreMode.replace) {
        await db.clearAllUserData();
      }

      // Restore Folders
      final foldersData = decoded['folders'] as List<dynamic>? ?? [];
      for (final f in foldersData) {
        await db.insertFolder(
          FoldersCompanion(
            id: Value(f['id'] as String),
            name: Value(f['name'] as String),
            description: Value(f['description'] as String? ?? ''),
            colorTag: Value(f['colorTag'] as String? ?? '#7C3AED'),
            displayMode: Value(f['displayMode'] as String? ?? 'grid'),
            createdAt: Value(DateTime.tryParse(f['createdAt'] as String? ?? '') ?? DateTime.now()),
          ),
        );
      }

      // Restore Cards
      final cardsData = decoded['cards'] as List<dynamic>? ?? [];
      for (final c in cardsData) {
        await db.insertCard(
          UserCardsCompanion(
            id: Value(c['id'] as String),
            cardApiId: Value(c['cardApiId'] as String),
            name: Value(c['name'] as String),
            number: Value(c['number'] as String? ?? ''),
            setName: Value(c['setName'] as String? ?? ''),
            rarity: Value(c['rarity'] as String? ?? ''),
            imageUrl: Value(c['imageUrl'] as String),
            folderId: Value(c['folderId'] as String?),
            condition: Value(c['condition'] as String? ?? 'Near Mint'),
            language: Value(c['language'] as String? ?? 'PT'),
            finish: Value(c['finish'] as String? ?? 'Regular'),
            quantity: Value((c['quantity'] as num?)?.toInt() ?? 1),
            purchasePriceBrl: Value((c['purchasePriceBrl'] as num?)?.toDouble() ?? 0.0),
            createdAt: Value(DateTime.tryParse(c['createdAt'] as String? ?? '') ?? DateTime.now()),
          ),
        );
      }

      // Restore Wishlist
      final wishlistData = decoded['wishlist'] as List<dynamic>? ?? [];
      for (final w in wishlistData) {
        await db.insertWishlistItem(
          WishlistItemsCompanion(
            id: Value(w['id'] as String),
            cardApiId: Value(w['cardApiId'] as String),
            name: Value(w['name'] as String),
            number: Value(w['number'] as String? ?? ''),
            setName: Value(w['setName'] as String? ?? ''),
            imageUrl: Value(w['imageUrl'] as String),
            targetPriceBrl: Value((w['targetPriceBrl'] as num?)?.toDouble() ?? 0.0),
            priority: Value(w['priority'] as String? ?? 'Média'),
            notes: Value(w['notes'] as String? ?? ''),
            createdAt: Value(DateTime.tryParse(w['createdAt'] as String? ?? '') ?? DateTime.now()),
          ),
        );
      }

      return cardsData.length;
    } catch (e) {
      debugPrint('Restore error: $e');
      return -1;
    }
  }
}
