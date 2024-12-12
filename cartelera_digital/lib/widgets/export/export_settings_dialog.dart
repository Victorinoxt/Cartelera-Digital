class ExportSettingsDialog extends ConsumerWidget {
  final Widget chart;
  final String title;
  final ExportSettings initialSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previsualización del gráfico actual
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
            // Validar que el gráfico esté disponible antes de exportar
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