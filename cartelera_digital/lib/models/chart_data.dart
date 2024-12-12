import 'package:flutter/material.dart';

class ChartData {
  final String category;
  final double value;
  final DateTime? date;
  final Color? color;
  final String? title;
  final String? type;
  final List<dynamic>? dataPoints;

  ChartData({
    required this.category,
    required this.value,
    this.date,
    this.color,
    this.title,
    this.type,
    this.dataPoints,
  });

  // Para convertir datos dinámicos a ChartData
  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      category: map['category'] as String,
      value: (map['value'] as num).toDouble(),
      color: map['color'] as Color?,
      date: map['date'] as DateTime?,
      title: map['title'] as String?,
      type: map['type'] as String?,
      dataPoints: map['dataPoints'] as List<dynamic>?,
    );
  }
}

// Ejemplo de uso:
final List<ChartData> pieData = [
  ChartData(
    category: 'Excelente',
    value: 40.0,
    color: Colors.green,
    date: DateTime.now(),
  ),
  ChartData(
    category: 'Bueno',
    value: 30.0,
    color: Colors.blue,
    date: DateTime.now(),
  ),
  ChartData(
    category: 'Regular',
    value: 20.0,
    color: Colors.orange,
    date: DateTime.now(),
  ),
  ChartData(
    category: 'Defectuoso',
    value: 10.0,
    color: Colors.red,
    date: DateTime.now(),
  ),
]; 