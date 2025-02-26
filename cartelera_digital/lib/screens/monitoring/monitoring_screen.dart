import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../controllers/monitoring_controller.dart';
import '../../models/upload_status.dart';
import '../../models/monitoring_state.dart';
import '../../models/media_item.dart';
import '../../services/api_service.dart';
import '../../widgets/image_upload_widget.dart';
import '../../utils/logging_service.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_colors.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'todos';
  Set<String> selectedImages = {};
  bool isSelectionMode = false;

  final List<String> _statusFilters = [
    'todos',
    'active',
    'pending',
    'completed',
    'failed',
  ];

  String _getFilterText(String status) {
    switch (status.toLowerCase()) {
      case 'todos':
        return 'Todos';
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      case 'failed':
        return 'Fallido';
      default:
        return 'Todos';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.play_circle; // Activo por defecto
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blue; // Activo por defecto
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      case 'failed':
        return 'Fallido';
      default:
        return 'Activo'; // Activo por defecto
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monitoringControllerProvider);
    final controller = ref.read(monitoringControllerProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoreo de Contenido'),
          actions: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isSelectionMode = !isSelectionMode;
                    if (!isSelectionMode) {
                      selectedImages.clear();
                    }
                  });
                },
                icon: Icon(isSelectionMode ? Icons.close : Icons.upload_file),
                label: Text(
                  isSelectionMode ? 'Cancelar selección' : 'Seleccionar para subir',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelectionMode ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            if (selectedImages.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await controller.uploadToMobile(selectedImages.toList());
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contenido sincronizado correctamente')),
                      );
                      setState(() {
                        isSelectionMode = false;
                        selectedImages.clear();
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al sincronizar: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.sync),
                label: Text('Subir ${selectedImages.length} elementos'),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.image), text: 'Imágenes'),
              Tab(icon: Icon(Icons.list), text: 'Estado'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatusHeader(state),
            const SizedBox(height: 16),
            if (isSelectionMode)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blue.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Selecciona las imágenes que deseas subir a la aplicación móvil',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.hasError
                          ? _buildErrorWidget(state.errorMessage)
                          : _buildImagesGrid(state),
                  _buildUploadList(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar contenido...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_getFilterText(status)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : 'todos';
                      });
                    },
                    avatar: Icon(
                      _getStatusIcon(status == 'todos' ? 'active' : status),
                      size: 16,
                      color: isSelected ? Colors.white : _getStatusColor(status == 'todos' ? 'active' : status),
                    ),
                    backgroundColor: Colors.grey[100],
                    selectedColor: _getStatusColor(status == 'todos' ? 'active' : status),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(MonitoringState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusCard(
              'Completados',
              state.completedUploads,
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(width: 8),
            _buildStatusCard(
              'En Progreso',
              state.inProgressUploads,
              Colors.blue,
              Icons.refresh,
            ),
            const SizedBox(width: 8),
            _buildStatusCard(
              'Pendientes',
              state.pendingUploads,
              Colors.orange,
              Icons.pending,
            ),
            const SizedBox(width: 8),
            _buildStatusCard(
              'Fallidos',
              state.failedUploads,
              Colors.red,
              Icons.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(MediaItem image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                title: Text(image.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    image.path,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estado: ${_getStatusText(image.status)}',
                      style: TextStyle(
                        color: _getStatusColor(image.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isSelectionMode)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isSelectionMode = true;
                            selectedImages.add(image.id);
                          });
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Subir esta imagen'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesGrid(MonitoringState state) {
    final filteredImages = state.monitoringImages.where((image) {
      final matchesSearch = image.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'todos' || 
                          (image.metadata['status'] ?? 'active') == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 84, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No hay contenido en monitoreo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sube nuevo contenido usando el botón +',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredImages.length,
            itemBuilder: (context, index) {
              final image = filteredImages[index];
              final isSelected = selectedImages.contains(image.id);
              
              return Card(
                elevation: isSelected ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: isSelectionMode
                      ? () {
                          setState(() {
                            if (isSelected) {
                              selectedImages.remove(image.id);
                            } else {
                              selectedImages.add(image.id);
                            }
                          });
                        }
                      : () => _showImagePreview(image),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Indicador de estado
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(image.status).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(image.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Botón de eliminar
                      if (!isSelectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                              onPressed: () => _showDeleteConfirmation(image),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              tooltip: 'Eliminar imagen',
                            ),
                          ),
                        ),
                      // Checkbox de selección
                      if (isSelectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.blue, size: 20)
                                  : const SizedBox(width: 20, height: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Barra de acciones para selección múltiple
          if (isSelectionMode && selectedImages.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '${selectedImages.length} seleccionadas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showDeleteMultipleConfirmation(),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Eliminar seleccionadas',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Diálogo de confirmación para eliminar una imagen
  void _showDeleteConfirmation(MediaItem image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: Text('¿Estás seguro de que deseas eliminar "${image.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(monitoringControllerProvider.notifier).deleteImage(image.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación para eliminar múltiples imágenes
  void _showDeleteMultipleConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imágenes'),
        content: Text('¿Estás seguro de que deseas eliminar ${selectedImages.length} imágenes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(monitoringControllerProvider.notifier)
                .deleteMultipleImages(selectedImages.toList());
              setState(() {
                selectedImages.clear();
                isSelectionMode = false;
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadList(MonitoringState state) {
    if (state.uploads.isEmpty) {
      return const Center(
        child: Text('No hay subidas recientes'),
      );
    }

    return ListView.builder(
      itemCount: state.uploads.length,
      itemBuilder: (context, index) {
        final upload = state.uploads[index];
        return Card(
          child: ListTile(
            leading: Icon(
              _getStatusIcon(_getUploadStateString(upload.state)),
              color: _getStatusColor(_getUploadStateString(upload.state)),
            ),
            title: Text(upload.fileName),
            subtitle: Text(_getStatusText(_getUploadStateString(upload.state))),
            trailing: Text(
              upload.timestamp.toString().split('.')[0], // Convertir DateTime a String y quitar los microsegundos
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getUploadStateString(UploadState state) {
    switch (state) {
      case UploadState.completed:
        return 'completed';
      case UploadState.inProgress:
        return 'active';
      case UploadState.pending:
        return 'pending';
      case UploadState.failed:
        return 'failed';
    }
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Error desconocido',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(monitoringControllerProvider.notifier).refreshStatus();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
