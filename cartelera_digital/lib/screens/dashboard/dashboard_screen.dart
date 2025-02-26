import 'package:flutter/material.dart';
import '../charts/charts_screen.dart';
import '../media/media_screen.dart';
import 'widgets/dashboard_summary.dart';
import 'widgets/quick_actions.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../services/chart_export_service.dart';
import '../../services/media_service.dart';
import '../../widgets/chart_widgets/chart_dialog.dart';
import '../../widgets/export_settings_dialog.dart';
import '../../models/export_settings.dart';
import '../../models/export_type.dart';
import 'widgets/logo_widget.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/chart_data.dart';
import '../../widgets/navigation/navigation_rail_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/theme_toggle_button.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/navigation/drawer_widget.dart';
import '../../utils/chart_builders.dart';
import '../../widgets/chart_widget.dart';
import '../../services/export_service.dart';
import '../../exceptions/export_exception.dart';
import '../monitoring/monitoring_screen.dart';

final mediaServiceProvider = Provider((ref) => MediaService());
final chartExportServiceProvider = Provider((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  return ChartExportService(mediaService);
});
final exportProgressProvider = StateProvider<double>((ref) => 0.0);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _mediaService = MediaService();
  int _selectedIndex = 0;
  List<String> _animations = [
    'assets/animations/animation1.json',
    'assets/animations/animation2.json',
    'assets/animations/animation3.json',
  ];
  int _currentAnimationIndex = 0;
  bool _isExporting = false;
  // Lista de gráficos
  final List<Widget> _charts = [];

  @override
  void initState() {
    super.initState();
    KeyboardShortcutsService.registerShortcuts(
      onExport: _handleExport,
      onNewChart: _showAddChartDialog,
      onSave: _handleSave,
      onUploadMedia: _handleUploadMedia,
      onPreview: _handlePreview,
      onSettings: _handleSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRailWidget(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            logoSize: 60,
            railWidth: 72,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: DashboardContent(
            onNewChart: _showAddChartDialog,
            onUploadMedia: _handleUploadMedia,
            onPreview: _handlePreview,
          ),
        );
      case 1:
        return const ChartsScreen();
      case 2:
        return const MediaScreen();
      case 3:
        return const MonitoringScreen();
      default:
        return const Center(child: Text('Sección no encontrada'));
    }
  }

  void _handleExport() async {
    try {
      final currentChart = _getCurrentChart();
      if (currentChart == null) {
        throw Exception('No hay gráfico seleccionado para exportar');
      }

      final settings = await showDialog<ExportSettings>(
        context: context,
        builder: (context) => ExportSettingsDialog(
          title: 'Exportar Gráfico',
          chart: currentChart,
          initialSettings: ExportSettings(
            type: ExportType.image,
            width: 1920,
            height: 1080,
            quality: 3.0,
            format: 'PNG',
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            customTitle: null,
            includeBorder: false,
            borderColor: Colors.transparent,
            borderWidth: 0,
            exportPath: null,
            showCustomTitle: false,
            titleFontSize: 16,
            titleColor: Colors.black,
          ),
        ),
      );

      if (settings != null) {
        setState(() => _isExporting = true);
        _showProgressDialog();
        
        final exportService = ref.read(chartExportServiceProvider);
        final result = await exportService.exportChartAsImage(
          context,
          currentChart,
          'Gráfico',
          settings,
        );

        if (result != null) {
          ref.read(exportProgressProvider.notifier).state = 1.0;
        }

        setState(() => _isExporting = false);

        if (mounted) {
          Navigator.of(context).pop(); // Cerrar diálogo de progreso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gráfico exportado exitosamente')),
          );
        }
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

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final progress = ref.watch(exportProgressProvider);
          return AlertDialog(
            title: const Text('Exportando gráfico'),
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

  void _showAddChartDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChartDialog(title: 'Nuevo Gráfico'),
    );
  }

  void _handleSave() {
    // Guardar el estado actual según la pantalla seleccionada
    switch (_selectedIndex) {
      case 1:
        // Guardar gráficos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gráficos guardados')),
        );
        break;
      case 2:
        // Guardar media
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media guardada')),
        );
        break;
    }
  }

  void _handleUploadMedia() async {
    if (_selectedIndex != 2) {
      setState(() => _selectedIndex = 2); // Navegar a la pantalla de media
    }
    // Referencia a las líneas 61-73 de media_screen.dart para la implementación
    await _uploadFile();
  }

  void _handlePreview() {
    switch (_selectedIndex) {
      case 1:
        // Preview de gráficos
        break;
      case 2:
        // Preview de media
        // Referencia a las líneas 82-87 de media_screen.dart
        break;
    }
  }

  void _handleSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferencias'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Implementar configuraciones
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final item = await _mediaService.uploadFile();
        
        if (mounted && item != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Archivo subido: ${item.title}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir el archivo: $e')),
          );
        }
      }
    }
  }

  Widget? _getCurrentChart() {
    if (_selectedIndex == 1 && _charts.isNotEmpty) {
      return _charts.first;
    }
    return null;
  }

  Widget _buildDashboardChart(List<ChartData> data, bool isBar) {
    return ChartWidget(
      type: isBar ? 'bar' : 'line',
      data: data,
    );
  }
}

class DashboardContent extends StatelessWidget {
  final VoidCallback onNewChart;
  final VoidCallback onUploadMedia;
  final VoidCallback onPreview;

  const DashboardContent({
    required this.onNewChart,
    required this.onUploadMedia,
    required this.onPreview,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const LogoWidget(size: 80),
            ],
          ),
          const SizedBox(height: 20),
          const DashboardSummary(),
          const SizedBox(height: 20),
          QuickActions(
            onNewChart: onNewChart,
            onUploadMedia: onUploadMedia,
            onPreview: onPreview,
          ),
        ],
      ),
    );
  }
}

class DesktopMenu extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onNewChart;
  final VoidCallback onSettings;
  final VoidCallback onUploadMedia;
  final VoidCallback onPreview;
  final VoidCallback onSave;

  const DesktopMenu({
    required this.onExport,
    required this.onNewChart,
    required this.onSettings,
    required this.onUploadMedia,
    required this.onPreview,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: onNewChart,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyN, control: true),
              leadingIcon: const Icon(Icons.add_chart),
              child: const Text('Nuevo Gráfico'),
            ),
            MenuItemButton(
              onPressed: onSave,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyS, control: true),
              leadingIcon: const Icon(Icons.save),
              child: const Text('Guardar'),
            ),
            MenuItemButton(
              onPressed: onUploadMedia,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyU, control: true),
              leadingIcon: const Icon(Icons.upload_file),
              child: const Text('Subir Media'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: onExport,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyE, control: true),
              leadingIcon: const Icon(Icons.file_download),
              child: const Text('Exportar'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: () => exit(0),
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
              leadingIcon: const Icon(Icons.exit_to_app),
              child: const Text('Salir'),
            ),
          ],
          child: const Text('Archivo'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: onSettings,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyP, control: true),
              child: const Text('Preferencias'),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: onPreview,
              shortcut:
                  const SingleActivator(LogicalKeyboardKey.keyV, control: true),
              child: const Text('Ver Preview'),
            ),
          ],
          child: const Text('Ver'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'Cartelera Digital',
                applicationVersion: '1.0.0',
                applicationIcon: const LogoWidget(size: 50),
              ),
              child: const Text('Acerca de'),
            ),
          ],
          child: const Text('Ayuda'),
        ),
      ],
    );
  }
}
