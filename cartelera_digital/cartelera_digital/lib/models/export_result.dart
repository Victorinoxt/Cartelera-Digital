import 'export_settings.dart';

class ExportResult {
  final ExportSettings settings;
  final void Function(double)? onProgress;

  const ExportResult({
    required this.settings,
    this.onProgress,
  });
}
