import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/export_settings.dart';
import '../../models/export_type.dart';
import '../../providers/export_providers.dart';

// Definición de los providers necesarios
final exportProgressProvider = StateProvider<double>((ref) => 0.0);

class ExportDialog extends ConsumerStatefulWidget {
  final ExportType initialType;
  final String content;

  const ExportDialog({
    super.key,
    required this.initialType,
    required this.content,
  });

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  late ExportSettings _settings;
  String _statusMessage = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _settings = ExportSettings(type: widget.initialType);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTypeSelector(),
                      _buildSettingsForm(),
                      _buildPreview(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusSection(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Exportar Contenido',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButton<ExportType>(
      value: _settings.type,
      onChanged: (ExportType? newValue) {
        if (newValue != null) {
          setState(() {
            _settings = _settings.copyWith(type: newValue);
          });
        }
      },
      items: ExportType.values.map<DropdownMenuItem<ExportType>>((ExportType value) {
        return DropdownMenuItem<ExportType>(
          value: value,
          child: Text(value.toString().split('.').last.toUpperCase()),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsForm() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // Aquí puedes agregar más campos de configuración según el tipo de exportación
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // Aquí puedes implementar la vista previa según el tipo de exportación
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        if (_isExporting) ...[
          Consumer(
            builder: (context, ref, _) {
              final progress = ref.watch(exportProgressProvider);
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        Text(
          _statusMessage,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          child: Text(_isExporting ? 'Exportando...' : 'Exportar'),
        ),
      ],
    );
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Iniciando exportación...';
    });

    try {
      final exportService = ref.read(exportServiceProvider);
      final result = await exportService.exportContent(
        settings: _settings,
        content: widget.content,
        onProgress: (progress, message) {
          setState(() => _statusMessage = message);
          ref.read(exportProgressProvider.notifier).state = progress;
        },
      );

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _statusMessage = 'Error: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }
}