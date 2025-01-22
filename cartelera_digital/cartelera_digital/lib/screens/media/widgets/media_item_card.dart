import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/media_item.dart';
import '../../../services/monitoring_service.dart';
import '../../../utils/logging_service.dart';

class MediaItemCard extends ConsumerWidget {
  final MediaItem item;
  final Future<bool> Function(String) onDelete;

  const MediaItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showPreview(context),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenedor de la imagen
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  image: item.type == MediaType.image
                      ? DecorationImage(
                          image: NetworkImage(item.path),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.type != MediaType.image
                    ? Center(
                        child: Icon(
                          _getIconForType(item.type),
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      )
                    : null,
              ),
            ),
            // Información del archivo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Solo mostrar el botón de monitoreo para imágenes
                  if (item.type == MediaType.image) ...[
                    IconButton(
                      icon: const Icon(Icons.mobile_screen_share, size: 20),
                      onPressed: () => _handleMonitoringAdd(context, ref),
                      tooltip: 'Enviar a monitoreo',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _handleDelete(context),
                    tooltip: 'Eliminar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.movie;
    }
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(item.title),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: item.type == MediaType.image
                    ? InteractiveViewer(
                        child: Image.network(
                          item.path,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Vista previa no disponible para ${_getTypeText().toLowerCase()}',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeText() {
    switch (item.type) {
      case MediaType.image:
        return 'Imagen';
      case MediaType.video:
        return 'Video';
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar "${item.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (await onDelete(item.id)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.title} eliminado correctamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al eliminar el archivo'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleMonitoringAdd(BuildContext context, WidgetRef ref) async {
    try {
      LoggingService.info('Enviando a monitoreo: ${item.title}');
      LoggingService.info('Path de la imagen: ${item.path}');
      
      final monitoringService = ref.read(monitoringServiceProvider);
      final result = await monitoringService.addToMonitoring(item);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result 
              ? '${item.title} enviado a monitoreo correctamente'
              : 'Error al enviar a monitoreo'),
            backgroundColor: result ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      LoggingService.error('Error al enviar a monitoreo', e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar a monitoreo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
