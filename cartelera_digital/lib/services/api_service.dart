import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chart_data.dart';
import 'logging_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../config/env_config.dart';
import '../config/server_config.dart';
import 'dart:async';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final String _baseUrl = EnvConfig.externalApiUrl;
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ChartData>> getChartData(String tipo, DateTime? fecha) async {
    try {
      final queryParams = <String, String>{
        'fecha_final': _formatDate(fecha ?? DateTime.now()),
      };

      final uri = Uri.parse('$_baseUrl${EnvConfig.planificadorEndpoint}')
          .replace(queryParameters: queryParams);

      LoggingService.info('Fetching chart data from: $uri');

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La solicitud tardó demasiado en completarse');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        switch (tipo) {
          case 'ot_status':
            // Contar órdenes por etiqueta
            final Map<String, int> countByStatus = {};
            for (var item in data) {
              final status = item['etiqueta'] as String;
              countByStatus[status] = (countByStatus[status] ?? 0) + 1;
            }

            final total = data.length;
            if (total == 0) return [];

            return [
              ChartData(
                category: 'Completadas',
                value: (countByStatus['C'] ?? 0).toDouble(),
                color: Colors.green,
                title: '${((countByStatus['C'] ?? 0) / total * 100).round()}%',
              ),
              ChartData(
                category: 'En Proceso',
                value: (countByStatus['P'] ?? 0).toDouble(),
                color: Colors.blue,
                title: '${((countByStatus['P'] ?? 0) / total * 100).round()}%',
              ),
              ChartData(
                category: 'Pendientes',
                value: (countByStatus['TN'] ?? 0).toDouble(),
                color: Colors.orange,
                title: '${((countByStatus['TN'] ?? 0) / total * 100).round()}%',
              ),
            ];

          case 'ot_rendimiento':
            // Lista de colores para las barras
            final List<Color> colors = [
              Colors.blue.shade500,
              Colors.purple.shade500,
              Colors.green.shade500,
              Colors.orange.shade500,
              Colors.red.shade500,
            ];
            
            // Agrupar por técnico y contar
            final Map<String, int> countByTecnico = {};
            for (var item in data) {
              final tecnico = '${item['nombre']} ${item['apellido']}';
              countByTecnico[tecnico] = (countByTecnico[tecnico] ?? 0) + 1;
            }

            // Ordenar por cantidad de órdenes (descendente)
            final sortedTecnicos = countByTecnico.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // Tomar los top 5 técnicos
            return sortedTecnicos.take(5).map((entry) {
              final index = sortedTecnicos.indexOf(entry);
              final porcentaje = (entry.value / data.length * 100).toStringAsFixed(1);
              
              return ChartData(
                category: '${entry.key}\n(${porcentaje}%)',
                value: entry.value.toDouble(),
                color: colors[index % colors.length],
                title: '${entry.value} OTs',
              );
            }).toList();

          default:
            throw Exception('Tipo de gráfico no soportado: $tipo');
        }
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al obtener datos del gráfico: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${EnvConfig.serverUrl}/api$endpoint');
    try {
      final response = await _client.get(url);
      return response;
    } catch (e) {
      LoggingService.error('Error en GET request: $url', e);
      rethrow;
    }
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('${EnvConfig.serverUrl}/api$endpoint');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      LoggingService.error('Error en PATCH request: $url', e);
      rethrow;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      LoggingService.info('Iniciando subida de imagen: ${imageFile.path}');

      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));

      // Agregar el archivo a la solicitud
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile('image', stream, length,
          filename: imageFile.path.split('/').last);

      request.files.add(multipartFile);

      LoggingService.info('Enviando solicitud de subida...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggingService.info('Imagen subida exitosamente: ${data['imageUrl']}');
        return data['imageUrl'];
      } else {
        LoggingService.error('Error al subir imagen',
            'Código de estado: ${response.statusCode}');
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error en uploadImage', e);
      throw Exception('Error en la subida: $e');
    }
  }
}
