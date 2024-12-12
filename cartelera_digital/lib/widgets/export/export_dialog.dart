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
          style: Theme.of(context).textTheme.bodySmall,
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
          child: Text('Cancelar'),
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
      final result = await ref.read(exportServiceProvider).exportContent(
        settings: _settings,
        type: widget.initialType,
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