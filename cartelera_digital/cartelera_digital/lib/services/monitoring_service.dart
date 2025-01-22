import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../models/upload_status.dart';
import '../services/logging_service.dart';
import '../config/env_config.dart';

final monitoringServiceProvider = Provider((ref) => MonitoringService());

class MonitoringService {
  String get baseUrl => EnvConfig.serverUrl;
  final List<UploadStatus> _uploadStatus = [];
  final List<MediaItem> _monitoringImages = [];

  String _normalizeImageUrl(String path) {
    if (path.startsWith('http')) return path;
    
    // Limpiar la ruta de cualquier codificación previa
    String decodedPath = Uri.decodeComponent(path);
    // Asegurarse de que la ruta no tenga doble slash
    decodedPath = decodedPath.startsWith('/') ? decodedPath.substring(1) : decodedPath;
    // Codificar solo una vez
    String encodedPath = Uri.encodeComponent(decodedPath);
    
    final url = '$baseUrl/$encodedPath';
    LoggingService.info('URL normalizada: $url');
    return url;
  }

  // Obtener imágenes de monitoreo
  Future<List<MediaItem>> getMonitoringImages() async {
    try {
      final url = Uri.parse('${EnvConfig.serverUrl}/api/monitoring/images');
      LoggingService.info('Fetching images from: $url');
      
      final response = await http.get(url);
      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _monitoringImages.clear();
        
        for (var item in data) {
          final String rawPath = item['path'] ?? '';
          // Remover el prefijo /monitoring/ si existe
          final String cleanPath = rawPath.startsWith('/monitoring/') 
              ? rawPath.substring('/monitoring/'.length) 
              : rawPath;
          
          final imagePath = _normalizeImageUrl('monitoring/$cleanPath');
          LoggingService.info('Processing image path: $imagePath');
          
          _monitoringImages.add(MediaItem(
            id: item['id'] ?? '',
            title: item['title'] ?? '',
            path: imagePath,
            type: MediaType.image,
            duration: 0,
            metadata: item['metadata'] ?? {},
          ));
        }
        return _monitoringImages;
      } else {
        throw Exception('Error al cargar imágenes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      LoggingService.error('Error en getMonitoringImages', e);
      throw Exception('Error al cargar imágenes: $e');
    }
  }

  // Obtener el estado de las subidas
  Future<List<UploadStatus>> getUploadStatus() async {
    try {
      final response = await http.get(Uri.parse('${EnvConfig.serverUrl}/api/monitoring/status'));
      LoggingService.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _uploadStatus.clear();
        
        for (var item in data) {
          _uploadStatus.add(UploadStatus.fromJson(item));
        }
        return _uploadStatus;
      } else {
        throw Exception('Error al cargar estado: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error en getUploadStatus', e);
      throw Exception('Error al cargar estado: $e');
    }
  }

  // Enviar una imagen a monitoreo
  Future<bool> addToMonitoring(MediaItem item) async {
    try {
      LoggingService.info('Enviando a monitoreo: ${item.title}');
      LoggingService.info('Path de la imagen: ${item.path}');
      
      final response = await http.post(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/images'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': item.id,
          'title': item.title,
          'imageUrl': item.path,
          'type': item.type == MediaType.video ? 'video' : 'image',
          'metadata': {
            'status': 'active',
            'createdAt': DateTime.now().toIso8601String(),
          },
        }),
      );

      LoggingService.info('Response status: ${response.statusCode}');
      LoggingService.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _monitoringImages.add(MediaItem(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          path: _normalizeImageUrl(data['path'] ?? ''),
          type: MediaType.image,
          duration: 0,
          metadata: data['metadata'] ?? {},
        ));
        return true;
      } else {
        throw Exception('Error al enviar a monitoreo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      LoggingService.error('Error en addToMonitoring', e);
      throw Exception('Error al enviar a monitoreo: $e');
    }
  }

  // Actualizar estado de una imagen en monitoreo
  Future<bool> updateMonitoringStatus(String id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.serverUrl}/api/monitoring/status/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      LoggingService.error('Error al actualizar estado', e);
      return false;
    }
  }
}
