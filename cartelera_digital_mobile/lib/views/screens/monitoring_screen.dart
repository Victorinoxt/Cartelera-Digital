import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/content_model.dart';
import '../../providers/monitoring_provider.dart';
import '../widgets/monitoring_card.dart';
import '../../providers/upload_provider.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    ref.read(monitoringProvider.notifier).refreshMonitoringData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monitoringData = ref.watch(monitoringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Contenido'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar contenido...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Todos'),
                  Tab(text: 'Activos'),
                  Tab(text: 'Completados'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Botón de estadísticas
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showStatistics(),
            tooltip: 'Estadísticas',
          ),
          // Botón de actualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(monitoringProvider.notifier).refreshMonitoringData();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: monitoringData.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  ref.read(monitoringProvider.notifier).refreshMonitoringData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadOptions(),
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Subir Contenido'),
      ),
    );
  }

  Widget _buildContent(List<ContentModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay contenido en monitoreo',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(monitoringProvider.notifier).refreshMonitoringData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    // Filtrar por búsqueda
    final filteredItems = items
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        // Todos los items
        _buildContentList(filteredItems),
        // Items activos
        _buildContentList(filteredItems
            .where((item) => true)
            .toList()), // Ajustar según tu lógica de estado
        // Items completados
        _buildContentList(filteredItems
            .where((item) => true)
            .toList()), // Ajustar según tu lógica de estado
      ],
    );
  }

  Widget _buildContentList(List<ContentModel> contents) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        return MonitoringCard(
          content: content,
          onTap: () => _showMonitoringDetails(content),
        );
      },
    );
  }

  void _showMonitoringDetails(ContentModel content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de arrastre
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Imagen
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(content.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Información detallada
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(content.id),
                                  ),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Estado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'En monitoreo',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Acciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.refresh,
                                label: 'Actualizar',
                                onTap: () {
                                  // Implementar actualización
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.stop_circle_outlined,
                                label: 'Detener',
                                onTap: () {
                                  // Implementar detener monitoreo
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.delete_outline,
                                label: 'Eliminar',
                                onTap: () {
                                  // Implementar eliminación
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _uploadFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de Galería'),
              onTap: () {
                Navigator.pop(context);
                _uploadFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Subir Archivo'),
              onTap: () {
                Navigator.pop(context);
                _uploadFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatistics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Barra de arrastre
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas de Monitoreo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          _buildStatCard(
                            icon: Icons.image,
                            title: 'Total de Contenido',
                            value: '24',
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            icon: Icons.monitor_heart,
                            title: 'En Monitoreo',
                            value: '12',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            icon: Icons.check_circle,
                            title: 'Completados',
                            value: '8',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Actividad Reciente',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildActivityItem(
                            'Imagen agregada al monitoreo',
                            '2 minutos atrás',
                          ),
                          _buildActivityItem(
                            'Contenido actualizado',
                            '15 minutos atrás',
                          ),
                          _buildActivityItem(
                            'Monitoreo completado',
                            '1 hora atrás',
                          ),
                        ],
                      ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFromCamera() async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final content = await uploadService.uploadFromCamera();

      if (content != null) {
        _showUploadSuccess(content);
      } else {
        _showUploadError('No se pudo subir la imagen');
      }
    } catch (e) {
      _showUploadError('Error al tomar la foto: $e');
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final content = await uploadService.uploadFromGallery();

      if (content != null) {
        _showUploadSuccess(content);
      } else {
        _showUploadError('No se pudo subir la imagen');
      }
    } catch (e) {
      _showUploadError('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _uploadFile() async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final content = await uploadService.uploadFile();

      if (content != null) {
        _showUploadSuccess(content);
      } else {
        _showUploadError('No se pudo subir el archivo');
      }
    } catch (e) {
      _showUploadError('Error al subir el archivo: $e');
    }
  }

  void _showUploadSuccess(ContentModel content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subida Exitosa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                content.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text('¿Deseas agregar "${content.title}" al monitoreo?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addToMonitoring(content);
            },
            child: const Text('Sí, agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addToMonitoring(ContentModel content) async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final success = await uploadService.sendToMonitoring(content);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contenido agregado al monitoreo'),
              backgroundColor: Colors.green,
            ),
          );
          // Actualizar la lista
          ref.read(monitoringProvider.notifier).refreshMonitoringData();
        }
      } else {
        if (mounted) {
          _showUploadError('No se pudo agregar al monitoreo');
        }
      }
    } catch (e) {
      if (mounted) {
        _showUploadError('Error al agregar al monitoreo: $e');
      }
    }
  }

  void _showUploadError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
