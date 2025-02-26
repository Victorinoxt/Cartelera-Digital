import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/logging_service.dart';
import '../config/server_config.dart';

final mediaApiServiceProvider = Provider<MediaApiService>((ref) => MediaApiService());

class MediaApiService {
  Future<List<String>> getImages() async {
    try {
      final response = await http.get(Uri.parse('${ServerConfig.apiUrl}/images'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          String imageUrl = item['imageUrl'] as String;
          // Asegurarse de que las URLs usen la IP correcta
          return imageUrl.replaceAll(
            'http://localhost:${ServerConfig.serverPort}',
            ServerConfig.baseUrl,
          );
        }).toList();
      } else {
        throw Exception('Error al obtener imágenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  String getImageUrl(String fileName) {
    return '${ServerConfig.uploadsUrl}/$fileName';
  }

  Future<void> refreshImages() async {
    try {
      await getImages();
    } catch (e) {
      throw Exception('Error al actualizar imágenes: $e');
    }
  }
}