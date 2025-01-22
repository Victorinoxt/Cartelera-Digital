import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../models/media_item.dart';
import 'logging_service.dart';

final mediaApiServiceProvider = Provider((ref) => MediaApiService());

class MediaApiService {
  // Verificar conexión con el servidor
  Future<bool> checkConnection() async {
    try {
      final baseUrl = await ServerConfig.baseUrl;
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      LoggingService.info('Response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      LoggingService.error('Error al verificar conexión', e.toString());
      return false;
    }
  }

  // Subir una imagen
  Future<MediaItem?> uploadImage(File file) async {
    try {
      final baseUrl = await ServerConfig.baseUrl;
      final uploadUrl = '$baseUrl/api/upload';
      LoggingService.info('Subiendo imagen a: $uploadUrl');

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        LoggingService.info('Imagen subida exitosamente');
        final data = response.body;
        // Aquí deberías parsear la respuesta y crear un MediaItem
        return null; // Por ahora retornamos null
      } else {
        LoggingService.error(
          'Error al subir imagen',
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      LoggingService.error('Error al subir imagen', e.toString());
      return null;
    }
  }

  // Subir un archivo
  Future<MediaItem?> uploadFile(File file) async {
    try {
      final baseUrl = await ServerConfig.baseUrl;
      final uri = Uri.parse('$baseUrl/api/upload');
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        LoggingService.info('Archivo subido exitosamente');
        return null; // Por ahora retornamos null, pero podríamos parsear la respuesta
      } else {
        LoggingService.error(
          'Error al subir archivo',
          'Status: ${response.statusCode}, Body: $responseData',
        );
        return null;
      }
    } catch (e) {
      LoggingService.error('Error al subir archivo', e.toString());
      return null;
    }
  }

  // Eliminar una imagen
  Future<bool> deleteImage(String id) async {
    try {
      final baseUrl = await ServerConfig.baseUrl;
      final response = await http.delete(Uri.parse('$baseUrl/api/images/$id'));
      return response.statusCode == 200;
    } catch (e) {
      LoggingService.error('Error al eliminar imagen', e.toString());
      return false;
    }
  }

  // Obtener todas las imágenes
  Future<List<MediaItem>> getImages() async {
    try {
      final baseUrl = await ServerConfig.baseUrl;
      final response = await http.get(Uri.parse('$baseUrl/api/images'));
      
      if (response.statusCode == 200) {
        // Aquí deberías parsear la respuesta y crear una lista de MediaItem
        return [];
      } else {
        LoggingService.error(
          'Error al obtener imágenes',
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      LoggingService.error('Error al obtener imágenes', e.toString());
      return [];
    }
  }
}