import 'package:flutter/material.dart';

class FolderIconOption {
  final String key;
  final String label;
  final IconData icon;

  const FolderIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class FolderIconHelper {
  static const List<FolderIconOption> availableIcons = [
    FolderIconOption(key: 'folder', label: 'Pasta', icon: Icons.folder),
    FolderIconOption(key: 'star', label: 'Favoritas', icon: Icons.star),
    FolderIconOption(key: 'local_fire_department', label: 'Fogo', icon: Icons.local_fire_department),
    FolderIconOption(key: 'water_drop', label: 'Agua', icon: Icons.water_drop),
    FolderIconOption(key: 'bolt', label: 'Eletrico', icon: Icons.bolt),
    FolderIconOption(key: 'grass', label: 'Planta', icon: Icons.grass),
    FolderIconOption(key: 'psychology', label: 'Psiquico', icon: Icons.psychology),
    FolderIconOption(key: 'shield', label: 'Aco', icon: Icons.shield),
    FolderIconOption(key: 'military_tech', label: 'Competitivo', icon: Icons.military_tech),
    FolderIconOption(key: 'pest_control', label: 'Wurmple', icon: Icons.pest_control),
    FolderIconOption(key: 'emoji_events', label: 'Trofeu', icon: Icons.emoji_events),
    FolderIconOption(key: 'diamond', label: 'Raras', icon: Icons.diamond),
    FolderIconOption(key: 'inventory_2', label: 'Cofre', icon: Icons.inventory_2),
    FolderIconOption(key: 'sell', label: 'Trocas', icon: Icons.sell),
    FolderIconOption(key: 'bookmark', label: 'Destaques', icon: Icons.bookmark),
  ];

  static IconData getIcon(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) {
      return Icons.folder;
    }
    for (final opt in availableIcons) {
      if (opt.key == iconKey) {
        return opt.icon;
      }
    }
    return Icons.folder;
  }
}
