import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';

class ChartBuilder extends StatelessWidget {
  final List<ChartData> data;
  final String type;
  final String title;

  const ChartBuilder({
    Key? key,
    required this.data,
    required this.type,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'bar':
        return _buildBarChart();
      case 'pie':
        return _buildPieChart();
      case 'line':
        return _buildLineChart();
      default:
        return const Center(child: Text('Tipo de gráfico no soportado'));
    }
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      title: ChartTitle(text: title),
      series: <CircularSeries<ChartData, String>>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
      legend: Legend(isVisible: true, position: LegendPosition.right),
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}