import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/export_settings.dart';
import '../models/export_type.dart';
import '../widgets/chart_builder.dart';
import '../widgets/export_settings_dialog.dart';
import '../providers/chart_providers.dart';

class SafeChartBuilder extends ConsumerWidget {
  final List<ChartData> data;
  final String type;
  final String title;

  const SafeChartBuilder({
    super.key,
    required this.data,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ChartBuilder(
          data: data,
          type: type,
          title: title,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _handleExport(context, ref),
            tooltip: 'Exportar gráfico',
          ),
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref) async {
    try {
      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar $title',
          chart: ChartBuilder(
            data: data, 
            type: type, 
            title: title
          ),
          initialSettings: const ExportSettings(
            type: ExportType.image,
            width: 1920,
            height: 1080,
            quality: 3.0,
            format: 'PNG',
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(16),
            customTitle: null,
          ),
        ),
      );

      if (settings != null) {
        final exportService = ref.read(chartExportServiceProvider);
        final result = await exportService.exportChartAsImage(
          context,
          ChartBuilder(
            data: data, 
            type: type, 
            title: title
          ),
          title,
          settings,
        );

        if (result != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gráfico "$title" exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar "$title": $e')),
        );
      }
    }
  }
}