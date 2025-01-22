import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/content_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static const String baseUrl = 'http://192.168.100.13:3000';

  Future<List<ContentModel>> getCarteleras() async {
    try {
      print('Solicitando carteleras al servidor...');
      final response = await http.get(Uri.parse('$baseUrl/api/carteleras'));
      print('Respuesta del servidor (carteleras): ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Carteleras recibidas: ${data.length}');
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } else {
        print('Error al cargar carteleras: ${response.statusCode}');
        throw Exception('Error al cargar las carteleras');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener imágenes en monitoreo
  Future<List<ContentModel>> getMonitoringImages() async {
    try {
      print('Solicitando imágenes de monitoreo...');
      final response = await http.get(Uri.parse('$baseUrl/api/monitoring/images'));
      print('Respuesta del servidor (monitoreo): ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Imágenes de monitoreo recibidas: ${data.length}');
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } else {
        print('Error al cargar imágenes de monitoreo: ${response.statusCode}');
        throw Exception('Error al cargar las imágenes de monitoreo');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estado del monitoreo
  Future<List<Map<String, dynamic>>> getMonitoringStatus() async {
    try {
      print('Solicitando estado de monitoreo...');
      final response = await http.get(Uri.parse('$baseUrl/api/monitoring/status'));
      print('Respuesta del servidor (estado monitoreo): ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Estado de monitoreo recibido: ${data.length} items');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Error al cargar estado de monitoreo: ${response.statusCode}');
        throw Exception('Error al cargar el estado de monitoreo');
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
