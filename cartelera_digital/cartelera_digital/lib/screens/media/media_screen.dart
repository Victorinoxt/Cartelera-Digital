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
  MediaType? _selectedType;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    
    await _mediaService.loadImagesFromServer();
    
    if (!mounted) return;
    
    setState(() {
      _items = _mediaService.getItems();
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (!mounted) return;
    
    var filtered = _items;
    
    // Aplicar filtro de tipo
    if (_selectedType != null) {
      filtered = _organizationService.filterByType(
        filtered,
        _selectedType!,
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
    try {
      // Mostrar indicador de progreso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(width: 16),
                Text('Subiendo archivo...'),
              ],
            ),
            duration: Duration(seconds: 30), // Tiempo máximo de subida
          ),
        );
      }

      final item = await _mediaService.uploadFile();
      
      // Cerrar el SnackBar de progreso
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (item != null) {
        setState(() {
          _items = _mediaService.getItems();
          _applyFilters(); // Actualizar la lista filtrada
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo subido: ${item.title}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo subir el archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir el archivo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _deleteItem(String id) async {
    final success = await _mediaService.deleteItem(id);
    if (success) {
      setState(() {
        _items = _mediaService.getItems();
        _applyFilters();
      });
    }
    return success;
  }

  void _showPreview(MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => MediaPreviewDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra superior con búsqueda y botón de subida
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Campo de búsqueda
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar archivos...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Botón de subir archivo
                ElevatedButton.icon(
                  onPressed: _uploadFile,
                  icon: const Icon(Icons.upload),
                  label: const Text('Subir archivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Barra de filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                _filterButton('Todos', null),
                _filterButton('Imágenes', MediaType.image),
                _filterButton('Videos', MediaType.video),
              ],
            ),
          ),
          // Lista de archivos
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay archivos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return MediaItemCard(
                        item: _filteredItems[index],
                        onDelete: _deleteItem,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, MediaType? type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedType = isSelected ? null : type;
            _applyFilters();
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.grey[800],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
