import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logging_service.dart';
import '../config/config.dart';

// Definimos el provider como global y aseguramos que siempre devuelva una instancia
final mediaApiServiceProvider = Provider<MediaApiService>((ref) => MediaApiService());

class MediaApiService {
  // Actualizamos la URL para que coincida con tu servidor Node.js
  static const String _baseUrl = 'http://192.168.0.5:3000/api'; // Usar la IP correcta

  Future<String> uploadImage(File imageFile) async {
    try {
      LoggingService.info('Iniciando subida de imagen: ${imageFile.path}');
      
      // Crear la solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload')
      );

      // Agregar el archivo a la solicitud
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: imageFile.path.split('/').last
      );

      request.files.add(multipartFile);

      // Enviar la solicitud
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggingService.info('Imagen subida exitosamente: ${data['imageUrl']}');
        return data['imageUrl'];
      } else {
        LoggingService.error(
          'Error en la respuesta del servidor', 
          'Código: ${response.statusCode}, Respuesta: ${response.body}'
        );
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error en la subida: $e');
      throw Exception('Error en la subida: $e');
    }
  }

  // Método para verificar la conexión con la API
  Future<bool> checkConnection() async {
    try {
      LoggingService.info('Verificando conexión con la API...');
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      
      if (response.statusCode == 200) {
        LoggingService.info('Conexión exitosa con la API');
        return true;
      } else {
        LoggingService.error(
          'Error al conectar con la API', 
          'Código: ${response.statusCode}'
        );
        return false;
      }
    } catch (e) {
      LoggingService.error('Error al verificar conexión', e.toString());
      return false;
    }
  }
}