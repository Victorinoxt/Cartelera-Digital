import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/export_settings.dart'; 

class ExportSettingsDialog extends ConsumerWidget {
  final Widget chart;
  final String title;
  final ExportSettings initialSettings;

  const ExportSettingsDialog({
    Key? key,
    required this.chart,
    required this.title,
    required this.initialSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            child: chart,
          ),
          // ... resto de las configuraciones
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (chart != null) {
              Navigator.pop(context, initialSettings);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No hay gráfico para exportar')), 
              );
            }
          },
          child: Text('Exportar'),
        ),
      ],
    );
  }
}