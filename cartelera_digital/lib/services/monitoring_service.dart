import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../models/upload_status.dart';
import '../services/logging_service.dart';
import '../config/env_config.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'package:path/path.dart' as path;

final monitoringServiceProvider = Provider((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return MonitoringService(socketService);
});

class MonitoringService {
  String get baseUrl => EnvConfig.serverUrl;
  final List<UploadStatus> _uploadStatus = [];
  final List<MediaItem> _monitoringImages = [];
  final _api = ApiService();
  final String _apiUrl = EnvConfig.monitoringApiUrl;
  bool _isSyncing = false;
  final SocketService _socketService;

  MonitoringService(this._socketService) {
    _initializeSocket();
  }

  void _initializeSocket() {
    try {
      final socket = _socketService.socket;
      socket.on('monitoring_updated', (data) {
        _handleMonitoringUpdate(data);
      });
    } catch (e) {
      LoggingService.error(
          'Error al inicializar socket en MonitoringService', e);
    }
  }

  void _handleMonitoringUpdate(dynamic data) {
    try {
      if (data != null && data is Map) {
        LoggingService.info('Recibida actualización de monitoreo');

        // Actualizar imágenes de monitoreo
        if (data['monitoringImages'] != null) {
          _monitoringImages.clear();
          for (var item in data['monitoringImages']) {
            final String rawPath = item['path'] ?? '';
            final imagePath = _normalizeImageUrl(rawPath);

            _monitoringImages.add(MediaItem(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              path: imagePath,
              type: MediaType.image,
              metadata: {
                ...item['metadata'] ?? {},
                'status': item['status'] ?? 'pending',
              },
            ));
          }
          LoggingService.info(
              'Imágenes de monitoreo actualizadas: ${_monitoringImages.length}');
        }

        // Actualizar estado de subidas
        if (data['uploadStatus'] != null) {
          _uploadStatus.clear();
          for (var status in data['uploadStatus']) {
            _uploadStatus.add(UploadStatus(
              id: status['id'] ?? '',
              fileName: status['fileName'] ?? '',
              state: _parseUploadState(status['status'] ?? 'pending'),
              timestamp: DateTime.tryParse(status['timestamp'] ?? '') ??
                  DateTime.now(),
              fileType: status['type'] ?? 'image',
              progress: (status['progress'] ?? 0).toDouble(),
              metadata: status['metadata'] ?? {},
            ));
          }
          LoggingService.info(
              'Estados de subida actualizados: ${_uploadStatus.length}');
        }

        // Si hay una nueva imagen, notificar
        if (data['newImage'] != null) {
          LoggingService.info(
              'Nueva imagen agregada a monitoreo: ${data['newImage']['id']}');
        }
      }
    } catch (e) {
      LoggingService.error('Error al procesar actualización de monitoreo', e);
    }
  }

  UploadState _parseUploadState(String state) {
    switch (state.toLowerCase()) {
      case 'completed':
        return UploadState.completed;
      case 'active':
        return UploadState.inProgress;
      case 'failed':
        return UploadState.failed;
      default:
        return UploadState.pending;
    }
  }

  String _normalizeImageUrl(String path) {
    final baseUrl = EnvConfig.serverUrl;
    return '$baseUrl/${path.replaceAll('%2F', '/')}';
  }

  // Obtener imágenes de monitoreo
  Future<List<MediaItem>> getMonitoringImages() async {
    try {
      LoggingService.info('Obteniendo imágenes de monitoreo...');
      final response = await _api.get('/monitoring/images');
      final List<dynamic> data = json.decode(response.body);
      _monitoringImages.clear();

      for (var item in data) {
        final String rawPath = item['path'] ?? '';
        final imagePath = _normalizeImageUrl(rawPath);

        _monitoringImages.add(MediaItem(
          id: item['id'] ?? '',
          title: item['title'] ?? '',
          path: imagePath,
          type: MediaType.image,
          metadata: {
            ...item['metadata'] ?? {},
            'status': item['status'] ?? 'pending',
          },
        ));
      }

      LoggingService.info(
          'Imágenes de monitoreo obtenidas: ${_monitoringImages.length}');
      return _monitoringImages;
    } catch (e) {
      LoggingService.error('Error al obtener imágenes', e);
      return [];
    }
  }

  // Obtener estado de subidas
  Future<List<UploadStatus>> getUploadStatus() async {
    try {
      final response = await _api.get('/monitoring/status');
      final List<dynamic> data = json.decode(response.body);
      _uploadStatus.clear();

      for (var item in data) {
        _uploadStatus.add(UploadStatus(
          id: item['id'] ?? '',
          fileName: item['title'] ?? '',
          state: _parseUploadState(item['status'] ?? 'pending'),
          timestamp:
              DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
          fileType: 'image',
          progress: 1.0,
          metadata: item['metadata'] ?? {},
        ));
      }
      return _uploadStatus;
    } catch (e) {
      LoggingService.error('Error al obtener estado de subidas', e);
      return [];
    }
  }

  // Enviar una imagen a monitoreo
  Future<bool> addToMonitoring(MediaItem item) async {
    try {
      LoggingService.info('Iniciando envío a monitoreo: ${item.title}');
      LoggingService.info('Path de la imagen: ${item.path}');
      LoggingService.info('ID de la imagen: ${item.id}');

      // Extraer el nombre del archivo de la ruta
      final fileName = path.basename(item.path);
      LoggingService.info('Nombre del archivo: $fileName');

      // Construir la URL de la imagen
      final imageUrl = item.path.startsWith('http')
          ? item.path
          : '${EnvConfig.serverUrl}/uploads/${Uri.encodeComponent(fileName)}';

      LoggingService.info('URL de imagen construida: $imageUrl');

      // Verificar que la URL sea válida
      if (!imageUrl.startsWith('http')) {
        throw Exception('URL de imagen inválida: $imageUrl');
      }

      final requestBody = {
        'id': item.id,
        'title': item.title,
        'imageUrl': imageUrl,
        'type': item.type == MediaType.video ? 'video' : 'image',
        'metadata': {
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'originalPath': item.path,
        },
      };

      LoggingService.info('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/images'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        LoggingService.info('Respuesta decodificada: $data');

        // Verificar que la respuesta contiene los datos necesarios
        if (data['id'] == null) {
          throw Exception('ID no encontrado en la respuesta');
        }

        // Crear el objeto MediaItem con los datos de la respuesta
        final newMonitoringItem = MediaItem(
          id: data['id'],
          title: data['title'] ?? item.title,
          path: data['path'] != null
              ? _normalizeImageUrl(data['path'])
              : imageUrl,
          type: MediaType.image,
          metadata: {
            ...data['metadata'] ?? {},
            'status': data['status'] ?? 'active',
          },
        );

        // Agregar a la lista local
        _monitoringImages.add(newMonitoringItem);

        LoggingService.info(
            'Imagen agregada exitosamente: ${newMonitoringItem.id}');
        return true;
      } else {
        final error =
            json.decode(response.body)['error'] ?? 'Error desconocido';
        LoggingService.error('Error del servidor', error);
        throw Exception('Error del servidor: $error');
      }
    } catch (e, stack) {
      LoggingService.error('Error en addToMonitoring', e);
      rethrow;
    }
  }

  // Actualizar estado de una imagen en monitoreo
  Future<bool> updateMonitoringStatus(String id, String status) async {
    try {
      LoggingService.info('Actualizando estado de imagen $id a $status');

      // Verificar si la imagen existe localmente
      final imageExists = _monitoringImages.any((img) => img.id == id);
      if (!imageExists) {
        LoggingService.error('Imagen no encontrada localmente', 'ID: $id');
        throw Exception('Imagen no encontrada en la lista local');
      }

      final response = await http.patch(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/images/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode(
            {'status': status, 'timestamp': DateTime.now().toIso8601String()}),
      );

      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Actualizar el estado en la lista local
        final index = _monitoringImages.indexWhere((img) => img.id == id);
        if (index != -1) {
          _monitoringImages[index] = _monitoringImages[index].copyWith(
            metadata: {
              ..._monitoringImages[index].metadata,
              'status': status,
              'lastUpdated': DateTime.now().toIso8601String(),
            },
          );
          LoggingService.info('Estado actualizado localmente para imagen $id');
        }

        LoggingService.info('Estado actualizado exitosamente en el servidor');
        return true;
      } else {
        final error = json.decode(response.body);
        LoggingService.error(
          'Error al actualizar estado en el servidor',
          'Status: ${response.statusCode}, Error: ${error['error']}, Details: ${error['details']}',
        );

        // Si la imagen no existe en el servidor, la eliminamos localmente
        if (response.statusCode == 404) {
          _monitoringImages.removeWhere((img) => img.id == id);
          LoggingService.info(
              'Imagen eliminada de la lista local por no existir en el servidor');
        }

        throw Exception(
            'Error al actualizar estado: ${response.statusCode} - ${error['error']}');
      }
    } catch (e) {
      LoggingService.error('Error al actualizar estado', e);
      rethrow;
    }
  }

  Future<void> uploadToMobile(MediaItem image) async {
    try {
      LoggingService.info('Procesando imagen: ${image.id}');

      // Primero actualizamos el estado a processing
      await updateMonitoringStatus(image.id, 'processing');

      // Extraer el nombre del archivo de la URL original
      final fileName = path.basename(image.path);
      LoggingService.info('Nombre del archivo: $fileName');

      // Obtener la URL de la imagen original desde monitoring
      final monitoringImage = _monitoringImages.firstWhere(
        (img) => img.id == image.id,
        orElse: () => throw Exception('Imagen no encontrada en monitoreo'),
      );

      LoggingService.info('URL de imagen original: ${monitoringImage.path}');

      final requestBody = {
        'id': image.id,
        'title': image.title,
        'imageUrl': monitoringImage.path, // Usamos la URL de monitoreo
        'type': 'image',
        'metadata': {
          ...image.metadata,
          'uploadedAt': DateTime.now().toIso8601String(),
          'status': 'active',
          'originalMonitoringPath': monitoringImage.path,
        },
      };

      LoggingService.info(
          'Enviando datos a móvil: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${EnvConfig.serverUrl}/api/mobile/images'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Actualizar el estado a completed
        await updateMonitoringStatus(image.id, 'completed');
        LoggingService.info('Imagen subida exitosamente a móvil');
      } else {
        // Si hay error, actualizar el estado a failed
        await updateMonitoringStatus(image.id, 'failed');
        final error =
            json.decode(response.body)['error'] ?? 'Error desconocido';
        throw Exception('Error al subir imagen: $error');
      }
    } catch (e) {
      LoggingService.error('Error general al subir a móvil', e);
      // Asegurarnos de que el estado se actualice a failed en caso de error
      try {
        await updateMonitoringStatus(image.id, 'failed');
      } catch (updateError) {
        LoggingService.error(
            'Error al actualizar estado a failed', updateError);
      }
      rethrow;
    }
  }

  Future<bool> deleteMonitoringImage(String id) async {
    try {
      LoggingService.info('Eliminando imagen de monitoreo: $id');

      final response = await http.delete(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/$id'),
      );

      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Eliminar la imagen de la lista local
        _monitoringImages.removeWhere((img) => img.id == id);
        LoggingService.info('Imagen eliminada exitosamente');
        return true;
      } else {
        final error =
            json.decode(response.body)['error'] ?? 'Error desconocido';
        throw Exception(
            'Error al eliminar imagen: ${response.statusCode} - $error');
      }
    } catch (e) {
      LoggingService.error('Error al eliminar imagen', e);
      rethrow;
    }
  }

  Future<bool> deleteMultipleImages(List<String> ids) async {
    try {
      LoggingService.info('Eliminando múltiples imágenes: ${ids.length}');

      final response = await http.post(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/delete-multiple'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': ids}),
      );

      if (response.statusCode == 200) {
        LoggingService.info('Imágenes eliminadas exitosamente');
        return true;
      } else {
        throw Exception('Error al eliminar imágenes: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al eliminar imágenes', e);
      return false;
    }
  }
}
