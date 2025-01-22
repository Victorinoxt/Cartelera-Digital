import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/chart_data.dart';

class ChartPreview extends StatelessWidget {
  final List<ChartData> data;
  final String type;
  final Color color;

  const ChartPreview({
    super.key,
    required this.data,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'line':
        return _buildLineChart();
      case 'bar':
        return _buildBarChart();
      case 'pie':
        return _buildPieChart();
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          color: color,
        )
      ],
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries>[
        BarSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          color: color,
        )
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => color,
        )
      ],
    );
  }
}
