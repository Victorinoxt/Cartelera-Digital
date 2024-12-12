import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chart_data.dart';
import 'logging_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  static const String _baseUrl = 'http://192.168.0.4:3003/api';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ChartData>> getChartData(String tipo, DateTime? fecha) async {
    try {
      switch (tipo) {
        case 'ot_status':
          final queryParams = <String, String>{};
          if (fecha != null) {
            queryParams['fecha_aviso'] = _formatDate(fecha);
          }
          
          // Hacer tres llamadas para obtener los diferentes estados
          final completadasUri = Uri.parse('$_baseUrl/planificador/solicitudes')
              .replace(queryParameters: {...queryParams, 'status': 'Completado'});
          final pendientesUri = Uri.parse('$_baseUrl/planificador/solicitudes')
              .replace(queryParameters: {...queryParams, 'status': 'Pendiente'});
          final enProcesoUri = Uri.parse('$_baseUrl/planificador/solicitudes')
              .replace(queryParameters: {...queryParams, 'status': 'En Proceso'});
          
          final responses = await Future.wait([
            _client.get(completadasUri),
            _client.get(pendientesUri),
            _client.get(enProcesoUri),
          ]);
          
          if (responses.every((response) => response.statusCode == 200)) {
            final completadas = jsonDecode(responses[0].body) as List<dynamic>;
            final pendientes = jsonDecode(responses[1].body) as List<dynamic>;
            final enProceso = jsonDecode(responses[2].body) as List<dynamic>;
            
            final total = completadas.length + pendientes.length + enProceso.length;
            
            return [
              ChartData(
                category: 'Completado\n(${(completadas.length / total * 100).toStringAsFixed(1)}%)',
                value: completadas.length.toDouble(),
                date: fecha ?? DateTime.now(),
                color: Colors.green.shade500
              ),
              ChartData(
                category: 'Pendiente\n(${(pendientes.length / total * 100).toStringAsFixed(1)}%)',
                value: pendientes.length.toDouble(),
                date: fecha ?? DateTime.now(),
                color: Colors.orange.shade500
              ),
              ChartData(
                category: 'En Proceso\n(${(enProceso.length / total * 100).toStringAsFixed(1)}%)',
                value: enProceso.length.toDouble(),
                date: fecha ?? DateTime.now(),
                color: Colors.blue.shade500
              ),
            ];
          }
          throw Exception('Error al obtener datos de estado');
          
        case 'ot_rendimiento':
          final queryParams = <String, String>{
            'status': 'Completado'
          };
          
          if (fecha != null) {
            queryParams['fecha_aviso'] = _formatDate(fecha);
          }
          
          final uri = Uri.parse('$_baseUrl/planificador/solicitudes')
              .replace(queryParameters: queryParams);
              
          final response = await _client.get(uri);
          
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return _mapOTRendimientoData(data, fecha);
          }
          throw Exception('Error al obtener datos de rendimiento: ${response.statusCode}');
          
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

  Future<dynamic> patch(String endpoint, {required Map<String, dynamic> data}) async {
    // Implementar lógica de PATCH
  }
}
