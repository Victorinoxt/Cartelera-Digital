import 'package:flutter/material.dart';
import '../../../services/media_organization_service.dart';

class MediaOrganizationPanel extends StatelessWidget {
  final MediaCategory selectedCategory;
  final Function(MediaCategory) onCategoryChanged;
  final Function(String) onSearch;
  final VoidCallback onRefresh;

  const MediaOrganizationPanel({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organizar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategoryFilter(),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar archivos...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onSearch,
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      children: MediaCategory.values.map((category) {
        return FilterChip(
          label: Text(_getCategoryLabel(category)),
          selected: selectedCategory == category,
          onSelected: (selected) {
            if (selected) {
              onCategoryChanged(category);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar'),
          onPressed: onRefresh,
        ),
      ],
    );
  }

  String _getCategoryLabel(MediaCategory category) {
    switch (category) {
      case MediaCategory.images:
        return 'Imágenes';
      case MediaCategory.videos:
        return 'Videos';
      case MediaCategory.presentations:
        return 'Presentaciones';
      case MediaCategory.all:
        return 'Todos';
    }
  }
}
