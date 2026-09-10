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

  String _getSelectedLabel() {
    if (selectedFolderId == null) {
      return strings.isEn ? 'Filter by Collection: All' : 'Filtrar por Coleção: Todas';
    }
    if (selectedFolderId == '__general__') {
      return strings.generalCollectionOnly;
    }
    final folder = folders.where((f) => f.id == selectedFolderId).firstOrNull;
    if (folder != null) {
      return folder.name;
    }
    return strings.isEn ? 'Filter by Collection' : 'Filtrar por Coleção';
  }

  void _showCollectionFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CollectionFilterSheet(
        folders: folders,
        selectedFolderId: selectedFolderId,
        onFolderSelected: onFolderSelected,
        strings: strings,
        cardCountsByFolder: cardCountsByFolder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFiltered = selectedFolderId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => _showCollectionFilterModal(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isFiltered
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFiltered
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 20,
                color: isFiltered ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getSelectedLabel(),
                  style: TextStyle(
                    fontWeight: isFiltered ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    color: isFiltered ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFiltered)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  tooltip: strings.isEn ? 'Clear Filter' : 'Limpar Filtro',
                  onPressed: () => onFolderSelected(null),
                )
              else
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionFilterSheet extends StatefulWidget {
  final List<Folder> folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onFolderSelected;
  final AppStrings strings;
  final Map<String?, int> cardCountsByFolder;

  const _CollectionFilterSheet({
    required this.folders,
    required this.selectedFolderId,
    required this.onFolderSelected,
    required this.strings,
    required this.cardCountsByFolder,
  });

  @override
  State<_CollectionFilterSheet> createState() => _CollectionFilterSheetState();
}

class _CollectionFilterSheetState extends State<_CollectionFilterSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAllCards = widget.cardCountsByFolder.values.fold<int>(0, (sum, val) => sum + val);
    final generalCount = widget.cardCountsByFolder[null] ?? 0;

    final filteredFolders = widget.folders.where((f) {
      if (_search.isEmpty) return true;
      return f.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      elevation: 16,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.collections_bookmark_outlined, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.strings.isEn ? 'Filter by Collection' : 'Filtrar por Coleção',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.strings.isEn ? 'Search collection...' : 'Buscar coleção...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _search = val.trim()),
            ),
          ),

          // List of Collections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                if (_search.isEmpty || 'todas all'.contains(_search.toLowerCase()))
                  _buildOption(
                    context: context,
                    title: widget.strings.allCollectionsChip,
                    count: totalAllCards,
                    icon: Icons.all_inclusive_rounded,
                    isSelected: widget.selectedFolderId == null,
                    onTap: () {
                      widget.onFolderSelected(null);
                      Navigator.pop(context);
                    },
                  ),
                if (_search.isEmpty || 'geral general'.contains(_search.toLowerCase()))
                  _buildOption(
                    context: context,
                    title: widget.strings.generalCollectionOnly,
                    count: generalCount,
                    icon: Icons.style_outlined,
                    isSelected: widget.selectedFolderId == '__general__',
                    onTap: () {
                      widget.onFolderSelected('__general__');
                      Navigator.pop(context);
                    },
                  ),
                if (filteredFolders.isNotEmpty) const Divider(height: 16),
                for (final folder in filteredFolders) ...[
                  _buildFolderOption(
                    context: context,
                    folder: folder,
                    count: widget.cardCountsByFolder[folder.id] ?? 0,
                    isSelected: widget.selectedFolderId == folder.id,
                    onTap: () {
                      widget.onFolderSelected(folder.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
                if (filteredFolders.isEmpty && _search.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        widget.strings.isEn ? 'No collections found' : 'Nenhuma coleção encontrada',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(
            icon,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
              ],
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildFolderOption({
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          title: Text(
            folder.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
              ],
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
