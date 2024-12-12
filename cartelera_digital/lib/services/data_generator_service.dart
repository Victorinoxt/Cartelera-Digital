import 'package:flutter/material.dart';
import 'dart:math';
import '../models/chart_data.dart';

class DataGeneratorService {
  static final Map<String, List<String>> categories = {
    'ventas': ['Ene', 'Feb', 'Mar', 'Abr', 'May'],
    'produccion': ['Prod A', 'Prod B', 'Prod C'],
    'calidad': ['Excelente', 'Bueno', 'Regular', 'Defectuoso'],
    'eficiencia': ['Línea 1', 'Línea 2', 'Línea 3'],
  };

  static final Map<String, List<Color>> colors = {
    'ventas': [Colors.blue.shade500],
    'produccion': [Colors.green.shade500, Colors.orange.shade500, Colors.purple.shade500],
    'calidad': [Colors.green.shade500, Colors.blue.shade500, Colors.orange.shade500, Colors.red.shade500],
    'eficiencia': [Colors.green.shade500, Colors.blue.shade500, Colors.purple.shade500],
  };

  List<ChartData> generateData(String tipo, {int? count}) {
    final cats = categories[tipo] ?? [];
    final cols = colors[tipo] ?? [];
    
    switch (tipo) {
      case 'ventas':
        return _generateSalesData();
      case 'produccion':
        return _generateProductionData();
      case 'calidad':
        return _generateQualityData();
      case 'eficiencia':
        return _generateEfficiencyData();
      default:
        throw Exception('Tipo no soportado: $tipo');
    }
  }

  List<ChartData> _generateSalesData() {
    return List.generate(categories['ventas']!.length, (index) {
      return ChartData(
        category: categories['ventas']![index],
        value: 20.0 + Random().nextInt(50).toDouble(),
        date: DateTime(2024, index + 1),
        color: colors['ventas']![0],
      );
    });
  }

  List<ChartData> _generateProductionData() {
    return List.generate(5, (index) => ChartData(
      category: 'Prod ${index + 1}',
      value: Random().nextDouble() * 100,
      date: DateTime.now(),
      color: Colors.blue,
    ));
  }

  List<ChartData> _generateQualityData() {
    return List.generate(3, (index) => ChartData(
      category: 'Calidad ${index + 1}',
      value: Random().nextDouble() * 100,
      date: DateTime.now(),
      color: Colors.green,
    ));
  }

  List<ChartData> _generateEfficiencyData() {
    return List.generate(4, (index) => ChartData(
      category: 'Eficiencia ${index + 1}',
      value: Random().nextDouble() * 100,
      date: DateTime.now(),
      color: Colors.orange,
    ));
  }
}