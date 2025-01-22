import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/chart_controller.dart';
import '../models/chart_data.dart';
import '../utils/chart_builders.dart';

class ChartWidget extends ConsumerWidget {
  final String type;
  final List<ChartData> data;
  
  const ChartWidget({
    Key? key, 
    required this.type,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartControllerProvider);

    if (chartState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chartState.hasError) {
      return Center(child: Text(chartState.errorMessage ?? 'Error desconocido'));
    }

    switch (type) {
      case 'bar':
        return ChartBuilders.buildCartesianChart(data, isBar: true);
      case 'line':
        return ChartBuilders.buildCartesianChart(data, isBar: false);
      case 'pie':
        return ChartBuilders.buildCircularChart(data);
      default:
        return const Center(child: Text('Tipo de gráfico no soportado'));
    }
  }
}
