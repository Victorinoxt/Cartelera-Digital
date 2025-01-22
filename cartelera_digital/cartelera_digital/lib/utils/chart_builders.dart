import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';

class ChartBuilders {
  static Widget buildCartesianChart(List<ChartData> data, {bool isBar = false}) {
    CartesianSeries<ChartData, String> series;
    
    if (isBar) {
      series = ColumnSeries<ChartData, String>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.category,
        yValueMapper: (ChartData data, _) => data.value,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelSettings: const DataLabelSettings(isVisible: true)
      );
    } else {
      series = LineSeries<ChartData, String>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.category,
        yValueMapper: (ChartData data, _) => data.value,
        pointColorMapper: (ChartData data, _) => data.color,
        dataLabelSettings: const DataLabelSettings(isVisible: true)
      );
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true),
      series: <CartesianSeries<ChartData, String>>[series]
    );
  }

  static Widget buildCircularChart(List<ChartData> data) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right
      ),
      series: <CircularSeries<ChartData, String>>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true)
        )
      ]
    );
  }
}