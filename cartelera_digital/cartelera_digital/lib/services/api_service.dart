import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chart_data.dart';
import 'logging_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../config/env_config.dart';
import 'dart:async';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final String _baseUrl = EnvConfig.externalApiUrl;
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ChartData>> getChartData(String tipo, DateTime? fecha) async {
    try {
      switch (tipo) {
        case 'ot_status':
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
            final data = jsonDecode(response.body);
            
            // Asumiendo que el endpoint devuelve algo como:
            // { "completadas": 10, "pendientes": 5, "en_proceso": 3 }
            final completadas = data['completadas'] ?? 0;
            final pendientes = data['pendientes'] ?? 0;
            final enProceso = data['en_proceso'] ?? 0;
            final total = completadas + pendientes + enProceso;

            return [
              ChartData(
                category: 'Completadas',
                value: completadas.toDouble(),
                color: Colors.green,
                title: '${(completadas / total * 100).round()}%',
              ),
              ChartData(
                category: 'Pendientes',
                value: pendientes.toDouble(),
                color: Colors.orange,
                title: '${(pendientes / total * 100).round()}%',
              ),
              ChartData(
                category: 'En Proceso',
                value: enProceso.toDouble(),
                color: Colors.blue,
                title: '${(enProceso / total * 100).round()}%',
              ),
            ];
          } else {
            throw Exception('Error al obtener datos: ${response.statusCode}');
          }

        case 'ot_rendimiento':
          final queryParams = <String, String>{
            'fecha_final': _formatDate(fecha ?? DateTime.now()),
          };

          final uri = Uri.parse('$_baseUrl${EnvConfig.planificadorEndpoint}')
              .replace(queryParameters: queryParams);

          LoggingService.info('Fetching rendimiento data from: $uri');

          final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('La solicitud tardó demasiado en completarse');
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return _mapOTRendimientoData(data, fecha);
          }
          throw Exception(
              'Error al obtener datos de rendimiento: ${response.statusCode}');

        default:
          throw Exception('Tipo de gráfico no soportado: $tipo');
      }
    } catch (e) {
      LoggingService.error('Error en getChartData', e);
      return _getFallbackData(tipo);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<ChartData> _mapOTRendimientoData(List<dynamic> data, DateTime? fecha) {
    final Map<String, int> rendimientoMap = {};
    int totalOTs = 0;

    // Lista de colores para las barras
    final List<Color> colors = [
      Colors.blue.shade500,
      Colors.purple.shade500,
      Colors.green.shade500,
      Colors.orange.shade500,
      Colors.red.shade500,
    ];

    // Contamos las OTs completadas por cada técnico
    for (var item in data) {
      if (item['status'] == 'Completado') {
        final tecnico = item['asignada_a']?.toString() ?? 'Sin Asignar';
        if (tecnico != 'Sin Asignar') {
          rendimientoMap[tecnico] = (rendimientoMap[tecnico] ?? 0) + 1;
          totalOTs++;
        }
      }
    }

    // Ordenamos por cantidad de OTs completadas (descendente)
    final sortedEntries = rendimientoMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tomamos los top 5 técnicos con mejor rendimiento
    return sortedEntries.take(5).map((entry) {
      final index = sortedEntries.indexOf(entry);
      final porcentaje = (entry.value / totalOTs * 100).toStringAsFixed(1);

      return ChartData(
        category: '${entry.key}\n(${porcentaje}%)',
        value: entry.value.toDouble(),
        date: fecha ?? DateTime.now(),
        color: colors[index % colors.length],
      );
    }).toList();
  }

  List<ChartData> _getFallbackData(String tipo) {
    switch (tipo) {
      case 'ot_status':
        return [
          ChartData(
              category: 'Pendiente',
              value: 5,
              date: DateTime.now(),
              color: Colors.orange),
          ChartData(
              category: 'En Proceso',
              value: 3,
              date: DateTime.now(),
              color: Colors.blue),
          ChartData(
              category: 'Completado',
              value: 8,
              date: DateTime.now(),
              color: Colors.green),
        ];
      case 'ot_rendimiento':
        return [
          ChartData(
              category: 'Juan Pérez',
              value: 4,
              date: DateTime.now(),
              color: Colors.blue.shade500),
          ChartData(
              category: 'María López',
              value: 6,
              date: DateTime.now(),
              color: Colors.green.shade500),
          ChartData(
              category: 'Luis Fernández',
              value: 3,
              date: DateTime.now(),
              color: Colors.purple.shade500),
        ];
      default:
        return [];
    }
  }

  Future<dynamic> get(String endpoint) async {
    // Implementar lógica de GET
  }

  Future<dynamic> patch(String endpoint,
      {required Map<String, dynamic> data}) async {
    // Implementar lógica de PATCH
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
