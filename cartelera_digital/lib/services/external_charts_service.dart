import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/chart_data.dart';
import 'logging_service.dart';
import '../config/env_config.dart';
import 'package:flutter/material.dart';

class ExternalChartsService {
  final http.Client _client;
  final Duration _cacheDuration;
  final Map<String, _CacheEntry> _cache = {};

  ExternalChartsService({http.Client? client}) 
    : _client = client ?? http.Client(),
      _cacheDuration = Duration(minutes: EnvConfig.cacheDurationMinutes);

  Future<List<ChartData>> getEstadisticasSolicitudes({DateTime? fecha}) async {
    try {
      // Verificar caché
      final cacheKey = _getCacheKey('graph_1', fecha);
      if (_cache.containsKey(cacheKey)) {
        final entry = _cache[cacheKey]!;
        if (!entry.isExpired) {
          LoggingService.info('Usando datos en caché para: $cacheKey');
          return entry.data;
        }
      }

      final queryParams = <String, String>{
        'fecha_final': _formatDate(fecha ?? DateTime.now()),
      };

      final uri = Uri.parse('${EnvConfig.externalApiUrl}${EnvConfig.planificadorEndpoint}')
          .replace(queryParameters: queryParams);

      LoggingService.info('Fetching estadísticas from: $uri');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La solicitud tardó demasiado en completarse');
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final chartData = _processChartData(data);
        
        // Guardar en caché
        _cache[cacheKey] = _CacheEntry(chartData);
        
        return chartData;
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al obtener estadísticas: $e');
      rethrow;
    }
  }

  List<ChartData> _processChartData(List<dynamic> data) {
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
  }

  String _getCacheKey(String tipo, DateTime? fecha) {
    return '${tipo}_${fecha?.toIso8601String() ?? "all"}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _CacheEntry {
  final List<ChartData> data;
  final DateTime timestamp;
  final Duration duration;

  _CacheEntry(this.data, {Duration? duration}) 
    : timestamp = DateTime.now(),
      duration = duration ?? const Duration(minutes: 5);

  bool get isExpired => 
    DateTime.now().difference(timestamp) > duration;
}
