import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
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
      final status = await _service.getUploadStatus();
      state = state.copyWith(
        uploads: status,
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
      state = state.copyWith(isLoading: true);
      final status = await _service.getUploadStatus();
      state = state.copyWith(
        uploads: status,
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
      LoggingService.error('Error al actualizar estado', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al actualizar estado: $e',
      );
    }
  }

  Future<void> uploadImage(String filePath) async {
    try {
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();

      final newUpload = UploadStatus(
        id: uploadId,
        fileName: filePath.split('/').last,
        fileType: 'image',
        progress: 0.0,
        state: UploadState.pending,
      );

      state = state.copyWith(
        uploads: [...state.uploads, newUpload],
        pendingUploads: state.pendingUploads + 1,
      );

      _updateUploadState(uploadId, UploadState.inProgress, 0.2);

      final imageUrl = await _mediaService.uploadImage(File(filePath));

      _updateUploadState(
        uploadId,
        UploadState.completed,
        1.0,
        url: imageUrl,
      );

      LoggingService.info('Imagen subida exitosamente: $imageUrl');
    } catch (e) {
      LoggingService.error('Error al subir imagen', e);
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Error al subir imagen: $e',
      );
    }
  }

  void _updateUploadState(String id, UploadState uploadState, double progress,
      {String? url}) {
    final updatedUploads = state.uploads.map((upload) {
      if (upload.id == id) {
        return upload.copyWith(
          state: uploadState,
          progress: progress,
          url: url ?? upload.url,
        );
      }
      return upload;
    }).toList();

    state = state.copyWith(
      uploads: updatedUploads,
      pendingUploads:
          updatedUploads.where((u) => u.state == UploadState.pending).length,
      inProgressUploads:
          updatedUploads.where((u) => u.state == UploadState.inProgress).length,
      completedUploads:
          updatedUploads.where((u) => u.state == UploadState.completed).length,
      failedUploads:
          updatedUploads.where((u) => u.state == UploadState.failed).length,
    );
  }
}
