import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/content_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Ajusta según tu API

  Future<List<ContentModel>> getCarteleras() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/carteleras'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las carteleras');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
