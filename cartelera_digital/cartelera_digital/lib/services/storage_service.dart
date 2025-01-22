import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../models/media_item.dart';
import '../services/logging_service.dart';

class StorageService {
  static const String _chartsKey = 'charts';
  static const String _mediaKey = 'media';
  static const String _settingsKey = 'settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Métodos para Gráficos
  Future<void> saveCharts(List<ChartData> charts) async {
    try {
      final List<Map<String, dynamic>> data = charts.map((chart) => {
        'category': chart.category,
        'value': chart.value,
        'date': chart.date?.toIso8601String(),
        'color': chart.color?.value,
        'title': chart.title,
        'type': chart.type,
        'dataPoints': chart.dataPoints?.map((point) => point.toJson()).toList(),
      }).toList();
      
      await _prefs.setString(_chartsKey, jsonEncode(data));
      LoggingService.info('Gráficos guardados exitosamente: ${charts.length}');
    } catch (e) {
      LoggingService.error('Error al guardar gráficos', e);
      rethrow;
    }
  }

  List<ChartData> getCharts() {
    try {
      final String? data = _prefs.getString(_chartsKey);
      if (data == null) return [];
      
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.map((item) => ChartData(
        category: item['category'] as String,
        value: (item['value'] as num).toDouble(),
        date: item['date'] != null ? DateTime.parse(item['date']) : null,
        color: item['color'] != null ? Color(item['color'] as int) : null,
        title: item['title'] as String?,
        type: item['type'] as String?,
        dataPoints: item['dataPoints'] as List<dynamic>?,
      )).toList();
    } catch (e) {
      LoggingService.error('Error al obtener gráficos', e);
      return [];
    }
  }

  // Métodos para Media
  Future<void> saveMediaItems(List<MediaItem> items) async {
    try {
      final List<Map<String, dynamic>> data = items.map((item) => {
        'id': item.id,
        'title': item.title,
        'type': item.type.toString(),
        'path': item.path,
        'duration': item.duration,
      }).toList();
      
      await _prefs.setString(_mediaKey, jsonEncode(data));
      LoggingService.info('Items de media guardados: ${items.length}');
    } catch (e) {
      LoggingService.error('Error al guardar items de media', e);
      rethrow;
    }
  }

  List<MediaItem> getMediaItems() {
    try {
      final String? data = _prefs.getString(_mediaKey);
      if (data == null) return [];
      
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.map((item) => MediaItem(
        id: item['id'] as String,
        title: item['title'] as String,
        type: _parseMediaType(item['type'] as String),
        path: item['path'] as String,
        duration: (item['duration'] as int?) ?? 10,
      )).toList();
    } catch (e) {
      LoggingService.error('Error al obtener items de media', e);
      return [];
    }
  }

  MediaType _parseMediaType(String typeStr) {
    try {
      return MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == typeStr,
        orElse: () => MediaType.image,
      );
    } catch (e) {
      LoggingService.error('Error al parsear tipo de media: $typeStr', e);
      return MediaType.image;
    }
  }
}
