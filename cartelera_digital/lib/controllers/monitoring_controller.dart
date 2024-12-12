import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_status.dart';
import '../models/monitoring_state.dart';
import '../services/monitoring_service.dart';

final monitoringControllerProvider =
    StateNotifierProvider<MonitoringController, MonitoringState>((ref) {
  return MonitoringController(ref.watch(monitoringServiceProvider));
});

class MonitoringController extends StateNotifier<MonitoringState> {
  final MonitoringService _service;

  MonitoringController(this._service) : super(MonitoringState.initial()) {
    initializeMonitoring();
  }

  Future<void> initializeMonitoring() async {
    try {
      state = state.copyWith(isLoading: true);
      final status = await _service.getUploadStatus();
      state = state.copyWith(
        uploads: status,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al inicializar monitoreo: $e',
      );
    }
  }

  Future<void> refreshStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      final status = await _service.getUploadStatus();
      state = state.copyWith(
        uploads: status,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al actualizar estado: $e',
      );
    }
  }
}
