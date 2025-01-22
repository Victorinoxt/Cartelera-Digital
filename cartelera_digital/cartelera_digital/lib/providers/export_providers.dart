import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/export_service.dart';
import '../models/export_settings.dart';

// Provider para el servicio de exportación
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

// Provider para el progreso de la exportación
final exportProgressProvider = StateProvider<double>((ref) => 0.0);

// Provider para el estado de la exportación
final exportStateProvider = StateProvider<ExportState>((ref) => ExportState.idle);

// Provider para las configuraciones de exportación
final exportSettingsProvider = StateProvider<ExportSettings?>((ref) => null);

// Enumeración para el estado de la exportación
enum ExportState {
  idle,
  exporting,
  completed,
  error,
}
