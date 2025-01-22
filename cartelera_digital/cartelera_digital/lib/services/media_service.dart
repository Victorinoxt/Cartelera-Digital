import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../config/server_config.dart';
import '../utils/logging_service.dart';

class MediaService {
  final List<MediaItem> _items = [];

  Future<void> loadImagesFromServer() async {
    try {
      final imagesUrl = ServerConfig.imagesUrl;
      final baseUrl = ServerConfig.baseUrl;
      LoggingService.info('Cargando imágenes desde: $imagesUrl');
      
      final response = await http.get(Uri.parse(imagesUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> images = json.decode(response.body);
        _items.clear();
        
        for (var image in images) {
          String imageUrl = image['imageUrl'] as String;
          // Asegurarse de que la URL sea absoluta
          if (!imageUrl.startsWith('http')) {
            imageUrl = '$baseUrl$imageUrl';
          }
          LoggingService.info('URL de imagen procesada: $imageUrl');
          
          _items.add(MediaItem(
            id: image['id'],
            title: image['title'] ?? 'Sin título',
            type: MediaType.image,
            path: imageUrl,
            duration: 0,
          ));
        }
        LoggingService.info('Imágenes cargadas del servidor: ${_items.length}');
      } else {
        LoggingService.error(
          'Error al cargar imágenes', 
          'Status: ${response.statusCode}, Body: ${response.body}'
        );
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error al cargar imágenes', 
        'Error: ${e.toString()}\nStackTrace: $stackTrace'
      );
    }
  }

  Future<MediaItem?> uploadFile() async {
    try {
      LoggingService.info('Iniciando selección de archivo...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov'],
      );

      if (result != null) {
        LoggingService.info('Archivo seleccionado: ${result.files.single.name}');
        File file = File(result.files.single.path!);
        final baseUrl = ServerConfig.baseUrl;
        final uploadUrl = '$baseUrl/api/upload';
        
        LoggingService.info('Subiendo archivo a: $uploadUrl');
        
        // Crear FormData para la subida
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        
        // Agregar el archivo al request
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'image',
          fileStream,
          length,
          filename: result.files.single.name,
        );
        request.files.add(multipartFile);
        
        LoggingService.info('Enviando request...');
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        LoggingService.info('Respuesta recibida: ${response.statusCode}');
        LoggingService.info('Contenido: ${response.body}');
        
        if (response.statusCode == 200) {
          var imageData = json.decode(response.body);
          LoggingService.info('Datos de imagen recibidos: $imageData');
          
          var newItem = MediaItem(
            id: imageData['id'],
            title: imageData['title'],
            type: MediaType.image,
            path: imageData['imageUrl'],
            duration: 0,
          );
          
          await addItem(newItem);
          await loadImagesFromServer(); // Recargar todas las imágenes
          return newItem;
        } else {
          LoggingService.error(
            'Error al subir archivo',
            'Status: ${response.statusCode}, Body: ${response.body}'
          );
        }
      } else {
        LoggingService.info('Selección de archivo cancelada');
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error al subir archivo',
        'Error: ${e.toString()}\nStackTrace: $stackTrace'
      );
    }
    return null;
  }

  List<MediaItem> getItems() {
    return List.from(_items);
  }

  Future<void> addItem(MediaItem item) async {
    if (!_items.any((existingItem) => existingItem.id == item.id)) {
      _items.add(item);
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      final baseUrl = ServerConfig.baseUrl;
      final url = '$baseUrl/api/images/$id';
      LoggingService.info('Intentando eliminar imagen: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      LoggingService.info('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        _items.removeWhere((item) => item.id == id);
        LoggingService.info('Imagen eliminada exitosamente: $id');
        await loadImagesFromServer(); // Recargar la lista después de eliminar
        return true;
      } else {
        final error = json.decode(response.body);
        LoggingService.error(
          'Error al eliminar imagen', 
          'Status: ${response.statusCode}, Error: ${error['error']}'
        );
        return false;
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error al eliminar imagen', 
        'Error: ${e.toString()}\nStackTrace: $stackTrace'
      );
      return false;
    }
  }

  Future<void> updateItem(MediaItem updatedItem) async {
    try {
      final baseUrl = ServerConfig.baseUrl;
      final response = await http.put(
        Uri.parse('$baseUrl/api/images/${updatedItem.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'title': updatedItem.title,
          'type': updatedItem.type.toString(),
          'path': updatedItem.path,
          'duration': updatedItem.duration,
        }),
      );

      if (response.statusCode == 200) {
        final index = _items.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        LoggingService.info('Imagen actualizada exitosamente: ${updatedItem.id}');
      } else {
        LoggingService.error(
          'Error al actualizar imagen', 
          'Status: ${response.statusCode}'
        );
      }
    } catch (e) {
      LoggingService.error('Error al actualizar imagen', e.toString());
    }
  }
}
