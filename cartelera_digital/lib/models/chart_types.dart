import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import '../models/chart_data.dart';

class ChartTypeBuilder {
  static List<CartesianSeries<ChartData, String>> buildLineChart(List<ChartData> data) {
    return <CartesianSeries<ChartData, String>>[
      LineSeries<ChartData, String>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.category,
        yValueMapper: (ChartData data, _) => data.value,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }

  static List<CartesianSeries<ChartData, String>> buildBarChart(List<ChartData> data) {
    return <CartesianSeries<ChartData, String>>[
      ColumnSeries<ChartData, String>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.category,
        yValueMapper: (ChartData data, _) => data.value,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }

  static List<CircularSeries<ChartData, String>> buildPieChart(List<ChartData> data) {
    return <CircularSeries<ChartData, String>>[
      PieSeries<ChartData, String>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.category,
        yValueMapper: (ChartData data, _) => data.value,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }
}