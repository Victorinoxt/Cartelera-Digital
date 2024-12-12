import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/monitoring_controller.dart';
import '../../models/upload_status.dart';
import '../../models/monitoring_state.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  @override
  Widget build(BuildContext context) {
    final monitoringState = ref.watch(monitoringControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Subidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(monitoringControllerProvider.notifier).refreshStatus(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(monitoringState),
          Expanded(
            child: _buildUploadList(monitoringState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(context),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildStatusHeader(MonitoringState state) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusCard('Pendientes', state.pendingUploads),
            _buildStatusCard('En Proceso', state.inProgressUploads),
            _buildStatusCard('Completados', state.completedUploads),
            _buildStatusCard('Con Error', state.failedUploads),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(title),
      ],
    );
  }

  Widget _buildUploadList(MonitoringState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.hasError) {
      return Center(child: Text(state.errorMessage ?? 'Error desconocido'));
    }

    return ListView.builder(
      itemCount: state.uploads.length,
      itemBuilder: (context, index) {
        final upload = state.uploads[index];
        return _buildUploadCard(upload);
      },
    );
  }

  Widget _buildUploadCard(UploadStatus upload) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getIconForFileType(upload.fileType)),
        title: Text(upload.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: upload.progress),
            Text('${(upload.progress * 100).toStringAsFixed(1)}%'),
          ],
        ),
        trailing: Text(_getStatusText(upload.state)),
      ),
    );
  }

  IconData _getIconForFileType(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image': return Icons.image;
      case 'video': return Icons.video_file;
      case 'document': return Icons.description;
      default: return Icons.file_present;
    }
  }

  String _getStatusText(UploadState state) {
    switch (state) {
      case UploadState.pending: return 'Pendiente';
      case UploadState.inProgress: return 'En Proceso';
      case UploadState.completed: return 'Completado';
      case UploadState.failed: return 'Error';
      default: return 'Desconocido';
    }
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir Archivo'),
        content: const Text('¿Desea subir un nuevo archivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleUpload();
            },
            child: const Text('Subir'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpload() async {
    // Implementar la lógica de subida
  }
}