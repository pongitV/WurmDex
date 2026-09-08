import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';

class MonitoringCollectionSelector extends StatelessWidget {
  final List<Folder> folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onFolderSelected;
  final AppStrings strings;
  final Map<String?, int> cardCountsByFolder;

  const MonitoringCollectionSelector({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    required this.onFolderSelected,
    required this.strings,
    required this.cardCountsByFolder,
  });

  @override
  Widget build(BuildContext context) {
    final totalAllCards = cardCountsByFolder.values.fold<int>(0, (sum, val) => sum + val);
    final generalCount = cardCountsByFolder[null] ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1. Todas as Coleções
          _buildChip(
            context: context,
            label: '${strings.allCollectionsChip} ($totalAllCards)',
            icon: Icons.all_inclusive,
            isSelected: selectedFolderId == null,
            onTap: () => onFolderSelected(null),
          ),
          const SizedBox(width: 8),

          // 2. Coleção Geral (Sem Pasta)
          _buildChip(
            context: context,
            label: '${strings.generalCollectionOnly} ($generalCount)',
            icon: Icons.style_outlined,
            isSelected: selectedFolderId == '__general__',
            onTap: () => onFolderSelected('__general__'),
          ),

          // 3. User Folders
          for (final folder in folders) ...[
            const SizedBox(width: 8),
            _buildFolderChip(
              context: context,
              folder: folder,
              count: cardCountsByFolder[folder.id] ?? 0,
              isSelected: selectedFolderId == folder.id,
              onTap: () => onFolderSelected(folder.id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildFolderChip({
    required BuildContext context,
    required Folder folder,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    Color dotColor = theme.colorScheme.primary;
    if (folder.colorTag.isNotEmpty) {
      try {
        dotColor = Color(int.parse(folder.colorTag.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }

    return FilterChip(
      selected: isSelected,
      label: Text('${folder.name} ($count)'),
      avatar: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
      onSelected: (_) => onTap(),
    );
  }
}
