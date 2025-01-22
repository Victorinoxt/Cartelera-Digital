import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/cartelera.dart';
import '../config/server_config.dart';

final carteleraServiceProvider = Provider<CarteleraService>((ref) {
  return CarteleraService();
});

class CarteleraService {
  Future<List<Cartelera>> getCarteleras() async {
    try {
      final response = await http.get(Uri.parse('${ServerConfig.apiUrl}/carteleras'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Cartelera.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener carteleras: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<void> deleteCartelera(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ServerConfig.apiUrl}/carteleras/$id'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar cartelera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<void> addCartelera(Cartelera cartelera) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConfig.apiUrl}/carteleras'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cartelera.toJson()),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al agregar cartelera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
