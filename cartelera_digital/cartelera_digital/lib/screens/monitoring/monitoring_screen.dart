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

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'todos';

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoreo de Contenido'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(monitoringControllerProvider.notifier).refreshStatus(),
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: _showStatistics,
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Subir'),
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

  void _showImageDetails(MediaItem image) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Detalles del Contenido',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    image.path,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, 
                                              size: 64, 
                                              color: Colors.grey[400]
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Error al cargar la imagen',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDetailRow(
                              'Título',
                              image.title,
                              Icons.title,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Estado',
                              _getStatusText(image.metadata['status'] ?? 'active'),
                              _getStatusIcon(image.metadata['status'] ?? 'active'),
                              _getStatusColor(image.metadata['status'] ?? 'active'),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Fecha de Publicación',
                              DateTime.now().toString().split(' ')[0],
                              Icons.calendar_today,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Tipo de Contenido',
                              'Imagen',
                              Icons.image,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Actualizar Estado'),
                                  onPressed: () {
                                    // Implementar actualización de estado
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                  onPressed: () {
                                    // Implementar edición
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, [Color? iconColor]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: iconColor ?? Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: filteredImages.length,
        itemBuilder: (context, index) {
          final image = filteredImages[index];
          return Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showImageDetails(image),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          image.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                image.metadata['status'] ?? 'active'
                              ).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(
                                    image.metadata['status'] ?? 'active'
                                  ),
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(
                                    image.metadata['status'] ?? 'active'
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          image.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publicado: ${DateTime.now().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStatistics() {
    final state = ref.read(monitoringControllerProvider);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estadísticas de Monitoreo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total de Imágenes',
                    state.monitoringImages.length,
                    Icons.image,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'En Monitoreo',
                    state.inProgressUploads,
                    Icons.track_changes,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Completados Hoy',
                    state.completedUploads,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Future<void> _handleUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        await ref.read(monitoringControllerProvider.notifier).uploadFile(file);
      }
    } catch (e) {
      LoggingService.error('Error al seleccionar archivo', e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
