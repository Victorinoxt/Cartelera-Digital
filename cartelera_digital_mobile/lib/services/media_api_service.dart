import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/logging_service.dart';

final mediaApiServiceProvider = Provider<MediaApiService>((ref) => MediaApiService());

class MediaApiService {
  static const String _baseUrl = 'http://192.168.0.4:3000/api';

  Future<List<String>> getImages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/images'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item['imageUrl'] as String).toList();
      } else {
        throw Exception('Error al obtener imágenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<void> refreshImages() async {
    try {
      await getImages();
    } catch (e) {
      throw Exception('Error al actualizar imágenes: $e');
    }
  }
} 