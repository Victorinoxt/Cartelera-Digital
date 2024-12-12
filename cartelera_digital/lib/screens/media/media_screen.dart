import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../services/media_service.dart';
import 'widgets/media_item_card.dart';
import 'widgets/media_preview_dialog.dart';
import 'widgets/media_organization_panel.dart';
import '../../../services/media_organization_service.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final MediaService _mediaService = MediaService();
  final MediaOrganizationService _organizationService = MediaOrganizationService();
  List<MediaItem> _items = [];
  List<MediaItem> _filteredItems = [];
  MediaCategory _selectedCategory = MediaCategory.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = _mediaService.getItems();
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = _items;
    
    // Aplicar filtro de categoría
    if (_selectedCategory != MediaCategory.all) {
      filtered = _organizationService.filterByCategory(
        filtered,
        _selectedCategory,
      );
    }
    
    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = _organizationService.searchMedia(
        filtered,
        _searchQuery,
      );
    }

    setState(() {
      _filteredItems = filtered;
    });
  }

  Future<void> _uploadFile() async {
    final item = await _mediaService.uploadFile();
    if (item != null) {
      setState(() {
        _items = _mediaService.getItems();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo subido: ${item.title}')),
        );
      }
    }
  }

  Future<void> _deleteItem(String id) async {
    await _mediaService.deleteItem(id);
    setState(() {
      _items = _mediaService.getItems();
    });
  }

  void _showPreview(MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => MediaPreviewDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Media',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: _uploadFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir Archivo'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MediaOrganizationPanel(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _applyFilters();
              });
            },
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
                _applyFilters();
              });
            },
            onRefresh: _loadItems,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text('No hay archivos multimedia'),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return MediaItemCard(
                        item: item,
                        onPreview: () => _showPreview(item),
                        onDelete: () => _deleteItem(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
