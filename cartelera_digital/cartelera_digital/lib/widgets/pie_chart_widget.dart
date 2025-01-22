import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cartelera_digital/lib/models/chart_data.dart';

class PieChartWidget extends StatelessWidget {
  final List<ChartData> data;

  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        textStyle: TextStyle(
          fontSize: 16, // Aumentamos el tamaño del texto de la leyenda
          fontWeight: FontWeight.w500,
        ),
        iconHeight: 20, // Aumentamos el tamaño del icono
        iconWidth: 20,
      ),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            // Mostrar el porcentaje
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            // Formato del texto que se mostrará
            labelFormatter: (args) {
              return '${args.value.toStringAsFixed(1)}%';
            },
          ),
          // Configuración de espacio entre segmentos
          explode: true,
          explodeOffset: '5%',
        ),
      ],
    );
  }
}
