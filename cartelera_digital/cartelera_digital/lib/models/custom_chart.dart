import 'package:flutter/material.dart';
import 'chart_data.dart';

class CustomChart {
  final String id;
  final String title;
  final String type;
  final List<ChartData> data;
  final bool editable;

  CustomChart({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
    this.editable = true,
  });
}