import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/media_item.dart';
import '../models/upload_status.dart';
import '../models/monitoring_state.dart';
import '../services/monitoring_service.dart';
import '../services/media_api_service.dart';
import '../services/logging_service.dart';

final monitoringControllerProvider =
    StateNotifierProvider<MonitoringController, MonitoringState>((ref) {
  final mediaService = ref.read(mediaApiServiceProvider);
  final monitoringService = ref.read(monitoringServiceProvider);
  return MonitoringController(mediaService, monitoringService);
});

class MonitoringController extends StateNotifier<MonitoringState> {
  final MediaApiService _mediaService;
  final MonitoringService _service;

  MonitoringController(this._mediaService, this._service)
      : super(MonitoringState.initial()) {
    initializeMonitoring();
  }

  Future<void> initializeMonitoring() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Obtener imágenes de monitoreo
      final images = await _service.getMonitoringImages();
      
      // Obtener estado de subidas
      final status = await _service.getUploadStatus();
      
      state = state.copyWith(
        uploads: status,
        monitoringImages: images,
        isLoading: false,
        completedUploads:
            status.where((u) => u.state == UploadState.completed).length,
        pendingUploads:
            status.where((u) => u.state == UploadState.pending).length,
        inProgressUploads:
            status.where((u) => u.state == UploadState.inProgress).length,
        failedUploads:
            status.where((u) => u.state == UploadState.failed).length,
      );
    } catch (e) {
      LoggingService.error('Error al inicializar monitoreo', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al inicializar monitoreo: $e',
      );
    }
  }

  Future<void> refreshStatus() async {
    try {
      // Obtener imágenes de monitoreo
      final images = await _service.getMonitoringImages();
      
      // Obtener estado de subidas
      final status = await _service.getUploadStatus();
      
      state = state.copyWith(
        uploads: status,
        monitoringImages: images,
        completedUploads:
            status.where((u) => u.state == UploadState.completed).length,
        pendingUploads:
            status.where((u) => u.state == UploadState.pending).length,
        inProgressUploads:
            status.where((u) => u.state == UploadState.inProgress).length,
        failedUploads:
            status.where((u) => u.state == UploadState.failed).length,
      );
    } catch (e) {
      LoggingService.error('Error al actualizar estado', e);
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Error al actualizar estado: $e',
      );
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      state = state.copyWith(isLoading: true);
      final result = await _mediaService.uploadFile(file);
      if (result != null) {
        await refreshStatus();
      }
    } catch (e) {
      LoggingService.error('Error al subir archivo', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al subir archivo: $e',
      );
    }
  }

  Future<void> updateImageStatus(String id, String newStatus) async {
    try {
      final success = await _service.updateMonitoringStatus(id, newStatus);
      if (success) {
        await refreshStatus();
      }
    } catch (e) {
      LoggingService.error('Error al actualizar estado de imagen', e);
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Error al actualizar estado de imagen: $e',
      );
    }
  }
}
