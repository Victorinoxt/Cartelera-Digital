import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/chart_data.dart';
import '../../models/export_settings.dart';
import '../../widgets/chart_widgets/chart_dialog.dart';
import '../../services/media_service.dart';
import '../../services/chart_export_service.dart';
import '../../widgets/export_settings_dialog.dart';
import '../../controllers/chart_controller.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/lazy_loading_grid.dart';
import '../../services/logging_service.dart';
import 'package:intl/intl.dart';
import '../../models/chart_types.dart';
import '../../utils/chart_builders.dart';
import '../../widgets/chart_builder.dart';
import '../../widgets/safe_chart_builder.dart';

// Definir los providers
final mediaServiceProvider = Provider((ref) => MediaService());
final chartExportServiceProvider = Provider((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  return ChartExportService(mediaService);
});

final exportProgressProvider = StateProvider<double>((ref) => 0.0);

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

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  ChartSeriesController? _chartController;
  bool _isExporting = false;
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartControllerProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: chartState.isLoading
                  ? const LoadingView(message: 'Cargando gráficos...')
                  : chartState.hasError
                      ? ErrorView(
                          message: chartState.errorMessage ??
                              'Error al cargar los gráficos',
                          onRetry: () => ref.refresh(chartControllerProvider),
                        )
                      : _buildChartGrid(chartState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(chartControllerProvider.notifier)
              .actualizarTodosLosGraficos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Actualizando todos los gráficos...'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        tooltip: 'Actualizar Todo',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Gráficos',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _mostrarFiltros,
                icon: const Icon(Icons.filter_list),
                label: const Text('Filtros'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportarTodosLosGraficos,
                icon: const Icon(Icons.file_download),
                label: const Text('Exportar Todo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartGrid(ChartState state) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _buildChartWithFilter(
<<<<<<< HEAD
            type: 'bar',
            data: state.salesData,
            title: 'OT Completadas por Técnico',
            tipo: 'ot_status'),
        _buildChartWithFilter(
            type: 'bar',
            data: state.productionData,
            title: 'Rendimiento del mes OT Completadas',
            tipo: 'ot_rendimiento'),
=======
          type: 'bar',
          data: state.salesData,
          title: 'OT Completadas por Técnico',
          tipo: 'ot_status'
        ),
        _buildChartWithFilter(
          type: 'bar',
          data: state.productionData,
          title: 'Rendimiento del mes OT Completadas',
          tipo: 'ot_rendimiento'
        ),
>>>>>>> origin/main
      ],
    );
  }

  Widget _buildChartWithFilter({
    required String type,
    required List<ChartData> data,
    required String title,
    required String tipo,
  }) {
    final chartState = ref.watch(chartControllerProvider);
<<<<<<< HEAD
    final selectedDate = tipo == 'ot_status'
        ? chartState.otStatusDate
=======
    final selectedDate = tipo == 'ot_status' 
        ? chartState.otStatusDate 
>>>>>>> origin/main
        : chartState.otRendimientoDate;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: () => _exportChart(
                        title,
<<<<<<< HEAD
                        type == 'pie'
                            ? _buildPieChart(data)
                            : _buildBarChart(data),
=======
                        type == 'pie' ? _buildPieChart(data) : _buildBarChart(data),
>>>>>>> origin/main
                      ),
                      tooltip: 'Exportar gráfico',
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _showDatePicker(context, ref, tipo),
<<<<<<< HEAD
                      tooltip: selectedDate != null
=======
                      tooltip: selectedDate != null 
>>>>>>> origin/main
                          ? DateFormat('dd/MM/yyyy', 'es').format(selectedDate)
                          : 'Seleccionar fecha',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
<<<<<<< HEAD
            child: type == 'pie' ? _buildPieChart(data) : _buildBarChart(data),
=======
            child: type == 'pie' 
                ? _buildPieChart(data)
                : _buildBarChart(data),
>>>>>>> origin/main
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String type, List<ChartData> data) {
    return ChartBuilder(
      data: data,
      type: type,
<<<<<<< HEAD
      title: type == 'pie'
          ? 'OT Abiertas/Completadas'
          : 'Rendimiento del mes OT Completadas',
=======
      title: type == 'pie' ? 'OT Abiertas/Completadas' : 'Rendimiento del mes OT Completadas',
>>>>>>> origin/main
    );
  }

  Future<void> _exportChart(String title, Widget chart) async {
    try {
      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar $title',
          chart: chart,
          initialSettings: const ExportSettings(
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
          chart,
          title,
          settings,
        );

        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gráfico "$title" exportado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar "$title": $e')),
        );
      }
    }
  }

  void _editCustomChart(String title) {
    final customChart = ref
        .read(chartControllerProvider)
        .customCharts
        .firstWhere((chart) => chart.title == title);

    showDialog(
      context: context,
      builder: (context) => ChartDialog(
        title: 'Editar $title',
        initialData: {
          'type': customChart.type,
          'colors': customChart.data.map((d) => d.color as Color).toList(),
          'dataPoints': customChart.data
              .map((d) => {
                    'category': d.category,
                    'value': d.value,
                    'color': d.color,
                  })
              .toList(),
        },
      ),
    ).then((result) {
      if (result != null) {
        final newData = result['data'] as List<ChartData>;
        ref
            .read(chartControllerProvider.notifier)
            .actualizarGraficoPersonalizado(customChart.id, newData);
      }
    });
  }

  void _showAddChartDialog() {
    showDialog(
      context: context,
      builder: (context) => ChartDialog(
        title: 'Nuevo Grfico',
        initialData: {
          'type': 'line',
          'colors': [Colors.blue.shade500],
          'dataPoints': [],
        },
      ),
    ).then((result) {
      if (result != null) {
        ref.read(chartControllerProvider.notifier).agregarGraficoPersonalizado(
              result['title'],
              result['type'],
              result['data'],
            );
      }
    });
  }

  Widget _buildChartByType(String type, List<ChartData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    try {
      return _buildChart(type, data);
    } catch (e) {
      LoggingService.error('Error al construir gráfico', e);
      return Center(child: Text('Error al mostrar el gráfico: $e'));
    }
  }

  Widget _buildPieChart(List<ChartData> data) {
    return SafeChartBuilder(
      data: data,
      type: 'pie',
      title: 'OT Abiertas/Completadas',
    );
  }

  Widget _buildBarChart(List<ChartData> data) {
    if (data.isEmpty) return const SizedBox();
<<<<<<< HEAD

    // Calculamos el total para los porcentajes
    final total = data.fold(0.0, (sum, item) => sum + item.value);

=======
    
    // Calculamos el total para los porcentajes
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    
>>>>>>> origin/main
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 12),
        labelRotation: 0,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Cantidad de OTs'),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.y OTs Cerradas',
        header: '',
      ),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelMapper: (ChartData data, _) {
            final percentage = (data.value / total * 100).toStringAsFixed(1);
            return '${percentage}%';
          },
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportarTodosLosGraficos() async {
    try {
      final chartState = ref.read(chartControllerProvider);
<<<<<<< HEAD

=======
      
>>>>>>> origin/main
      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar Todos los Gráficos',
          chart: _buildPieChart(chartState.salesData),
          initialSettings: const ExportSettings(
            width: 1920,
            height: 1080,
            quality: 3.0,
            format: 'PNG',
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(16),
          ),
        ),
      );

      if (settings != null) {
        final exportService = ref.read(chartExportServiceProvider);
<<<<<<< HEAD

=======
        
>>>>>>> origin/main
        // Lista de gráficos a exportar
        final graficos = [
          {
            'chart': _buildPieChart(chartState.salesData),
            'title': 'OT Abiertas/Completadas'
          },
          {
            'chart': _buildBarChart(chartState.productionData),
            'title': 'Rendimiento del mes OT Completadas'
          },
        ];

        for (var i = 0; i < graficos.length; i++) {
          final grafico = graficos[i];
          final result = await exportService.exportChartAsImage(
            context,
            grafico['chart'] as Widget,
            grafico['title'] as String,
            settings,
          );

          if (result == null) {
<<<<<<< HEAD
            throw Exception(
                'Error al exportar el gráfico: ${grafico['title']}');
=======
            throw Exception('Error al exportar el gráfico: ${grafico['title']}');
>>>>>>> origin/main
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
            const SnackBar(
                content: Text('Todos los gráficos exportados exitosamente')),
=======
            const SnackBar(content: Text('Todos los gráficos exportados exitosamente')),
>>>>>>> origin/main
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar gráficos: $e')),
        );
      }
    }
  }

  void _mostrarFiltros() {
    final chartState = ref.read(chartControllerProvider);
<<<<<<< HEAD

=======
    
>>>>>>> origin/main
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros de Gráficos'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro para OT Status
              _buildFilterCard(
                title: 'OT Status',
                subtitle: 'Filtrar por fecha',
                icon: Icons.pie_chart,
                date: chartState.otStatusDate,
                onTap: () => _showDatePicker(context, ref, 'ot_status'),
<<<<<<< HEAD
                onClear: () => ref
                    .read(chartControllerProvider.notifier)
=======
                onClear: () => ref.read(chartControllerProvider.notifier)
>>>>>>> origin/main
                    .actualizarGraficoConFecha('ot_status', null),
              ),
              const SizedBox(height: 8),
              // Filtro para Rendimiento
              _buildFilterCard(
                title: 'Rendimiento OT',
                subtitle: 'Filtrar por mes',
                icon: Icons.bar_chart,
                date: chartState.otRendimientoDate,
                onTap: () => _showDatePicker(context, ref, 'ot_rendimiento'),
<<<<<<< HEAD
                onClear: () => ref
                    .read(chartControllerProvider.notifier)
=======
                onClear: () => ref.read(chartControllerProvider.notifier)
>>>>>>> origin/main
                    .actualizarGraficoConFecha('ot_rendimiento', null),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
<<<<<<< HEAD
              ref
                  .read(chartControllerProvider.notifier)
                  .actualizarTodosLosGraficos();
=======
              ref.read(chartControllerProvider.notifier).actualizarTodosLosGraficos();
>>>>>>> origin/main
              Navigator.of(context).pop();
            },
            child: const Text('Actualizar Todo'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
<<<<<<< HEAD
          date != null 
=======
          date != null
>>>>>>> origin/main
              ? DateFormat('dd/MM/yyyy', 'es').format(date)
              : subtitle
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: onTap,
              tooltip: 'Seleccionar fecha',
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
                tooltip: 'Limpiar filtro',
              ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _showDatePicker(
      BuildContext context, WidgetRef ref, String tipo) async {
    final chartState = ref.read(chartControllerProvider);
    final currentDate = tipo == 'ot_status'
        ? chartState.otStatusDate
        : chartState.otRendimientoDate;

=======
  Future<void> _showDatePicker(BuildContext context, WidgetRef ref, String tipo) async {
    final chartState = ref.read(chartControllerProvider);
    final currentDate = tipo == 'ot_status' 
        ? chartState.otStatusDate 
        : chartState.otRendimientoDate;
        
>>>>>>> origin/main
    final fecha = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
<<<<<<< HEAD
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (fecha != null && mounted) {
      await ref
          .read(chartControllerProvider.notifier)
=======
    );
    
    if (fecha != null) {
      await ref.read(chartControllerProvider.notifier)
>>>>>>> origin/main
          .actualizarGraficoConFecha(tipo, fecha);
    }
  }

  // Exportar un gráfico individual
  Future<void> _exportSingleChart(Widget chart, String title) async {
    try {
      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar $title',
          chart: chart,
          initialSettings: const ExportSettings(
            width: 1920,
            height: 1080,
            quality: 3.0,
            format: 'PNG',
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(16),
          ),
        ),
      );

      if (settings != null) {
        setState(() => _isExporting = true);
        _showProgressDialog();
<<<<<<< HEAD

=======
        
>>>>>>> origin/main
        final exportService = ref.read(chartExportServiceProvider);
        final result = await exportService.exportChartAsImage(
          context,
          chart,
          title,
          settings,
        );

        if (result != null) {
          ref.read(exportProgressProvider.notifier).state = 1.0;
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gráfico exportado exitosamente')),
            );
          }
        }
        setState(() => _isExporting = false);
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  // Exportar todos los gráficos
  Future<void> _exportAllCharts() async {
    try {
      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar Todos los Gráficos',
<<<<<<< HEAD
          chart: _buildChart(
              'pie', ref.read(chartControllerProvider).otStatusData),
=======
          chart: _buildChart('pie', ref.read(chartControllerProvider).otStatusData),
>>>>>>> origin/main
          initialSettings: const ExportSettings(
            width: 1920,
            height: 1080,
            quality: 3.0,
            format: 'PNG',
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(16),
          ),
        ),
      );

      if (settings != null) {
        setState(() => _isExporting = true);
        _showProgressDialog();

        final charts = [
          _buildChart('pie', ref.read(chartControllerProvider).otStatusData),
<<<<<<< HEAD
          _buildChart(
              'bar', ref.read(chartControllerProvider).otRendimientoData),
        ];

        final exportService = ref.read(chartExportServiceProvider);

        for (var i = 0; i < charts.length; i++) {
          final progress = (i + 1) / charts.length;
          ref.read(exportProgressProvider.notifier).state = progress;

=======
          _buildChart('bar', ref.read(chartControllerProvider).otRendimientoData),
        ];

        final exportService = ref.read(chartExportServiceProvider);
        
        for (var i = 0; i < charts.length; i++) {
          final progress = (i + 1) / charts.length;
          ref.read(exportProgressProvider.notifier).state = progress;
          
>>>>>>> origin/main
          final result = await exportService.exportChartAsImage(
            context,
            charts[i],
            'Gráfico_${i + 1}',
            settings,
          );

          if (result == null) {
            throw Exception('Error al exportar el gráfico ${i + 1}');
          }
        }

        setState(() => _isExporting = false);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
            const SnackBar(
                content: Text('Todos los gráficos exportados exitosamente')),
=======
            const SnackBar(content: Text('Todos los gráficos exportados exitosamente')),
>>>>>>> origin/main
          );
        }
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar gráficos: $e')),
        );
      }
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final progress = ref.watch(exportProgressProvider);
          return AlertDialog(
            title: const Text('Exportando gráfico(s)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          );
        },
      ),
    );
  }
}
