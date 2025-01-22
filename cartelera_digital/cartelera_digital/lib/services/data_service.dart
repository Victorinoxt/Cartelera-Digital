import 'package:flutter/material.dart';
import '../models/chart_data.dart';

class DataService {
  static const Map<String, List<String>> defaultCategories = {
    'ot_status': ['Pendiente', 'En proceso', 'Completado'],
    'ot_rendimiento': [],
  };

  static const Map<String, List<Color>> defaultColors = {
    'ot_status': [Colors.orange, Colors.blue, Colors.green],
    'ot_rendimiento': [
      Colors.blue.shade500,
      Colors.green.shade500,
      Colors.purple.shade500,
      Colors.orange.shade500,
    ],
  };

  Future<List<ChartData>> generateData(String tipo) async {
    // Implementar lógica de generación de datos
  }
}