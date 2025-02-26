import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/media_item.dart';
import '../models/upload_status.dart';
import '../models/monitoring_state.dart';
import '../services/monitoring_service.dart';
import '../services/media_api_service.dart';
import '../services/logging_service.dart';
import '../services/socket_service.dart';

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
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    SocketService.instance.socket?.on('monitoring_updated', (data) async {
      LoggingService.info('Recibida actualización de monitoreo');
      await refreshStatus();
    });
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
      LoggingService.error('Error al actualizar estado', e);
      state = state.copyWith(
        isLoading: false,
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

  Future<void> syncSelectedImages(List<String> imageIds) async {
    try {
      state = state.copyWith(isLoading: true);

      // Actualizar el estado de las imágenes seleccionadas a "pending"
      for (final id in imageIds) {
        final image = state.monitoringImages.firstWhere(
          (img) => img.id == id,
          orElse: () => throw Exception('Imagen no encontrada'),
        );

        // Actualizar el estado en el servidor
        await _service.updateMonitoringStatus(id, 'pending');

        // Actualizar el estado localmente
        final updatedImages = state.monitoringImages.map((img) {
          if (img.id == id) {
            return img.copyWith(
              metadata: {...img.metadata, 'status': 'pending'},
            );
          }
          return img;
        }).toList();

        state = state.copyWith(monitoringImages: updatedImages);
      }

      // Refrescar el estado completo
      await refreshStatus();
    } catch (e) {
      LoggingService.error('Error al sincronizar imágenes', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al sincronizar imágenes: $e',
      );
    }
  }

  Future<void> uploadToMobile(List<String> imageIds) async {
    try {
      state = state.copyWith(isLoading: true);

      for (final id in imageIds) {
        try {
          final image = state.monitoringImages.firstWhere(
            (img) => img.id == id,
            orElse: () => throw Exception('Imagen no encontrada: $id'),
          );

          LoggingService.info('Procesando imagen: ${image.id}');

          // Actualizar estado a "procesando"
          await _service.updateMonitoringStatus(id, 'processing');

          // Subir la imagen
          await _service.uploadToMobile(image);

          // Actualizar estado a "completado"
          await _service.updateMonitoringStatus(id, 'completed');

          // Emitir progreso
          SocketService.instance.emitUploadProgress(id, 1.0);

          LoggingService.info('Imagen procesada exitosamente: ${image.id}');
        } catch (e) {
          LoggingService.error('Error procesando imagen $id', e);
          await _service.updateMonitoringStatus(id, 'failed');
          SocketService.instance.emitUploadProgress(id, 0.0);
        }
      }

      await refreshStatus();
    } catch (e) {
      LoggingService.error('Error general al subir a móvil', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al subir a móvil: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Método para eliminar una imagen
  Future<void> deleteImage(String id) async {
    try {
      state = state.copyWith(isLoading: true);

      final success = await _service.deleteMonitoringImage(id);
      if (success) {
        // Actualizar la lista de imágenes localmente
        final updatedImages =
            state.monitoringImages.where((img) => img.id != id).toList();
        state = state.copyWith(
          monitoringImages: updatedImages,
          isLoading: false,
        );
      } else {
        throw Exception('No se pudo eliminar la imagen');
      }
    } catch (e) {
      LoggingService.error('Error al eliminar imagen', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al eliminar imagen: $e',
      );
    }
  }

  // Método para eliminar múltiples imágenes
  Future<void> deleteMultipleImages(List<String> ids) async {
    try {
      state = state.copyWith(isLoading: true);

      final success = await _service.deleteMultipleImages(ids);
      if (success) {
        // Actualizar la lista de imágenes localmente
        final updatedImages = state.monitoringImages
            .where((img) => !ids.contains(img.id))
            .toList();
        state = state.copyWith(
          monitoringImages: updatedImages,
          isLoading: false,
        );
      } else {
        throw Exception('No se pudieron eliminar las imágenes');
      }
    } catch (e) {
      LoggingService.error('Error al eliminar imágenes', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al eliminar imágenes: $e',
      );
    }
  }

  // Actualizar los getters para usar el nuevo campo status
  int get activeCount =>
      state.monitoringImages.where((img) => img.status == 'active').length;

  int get pendingCount =>
      state.monitoringImages.where((img) => img.status == 'pending').length;

  int get completedCount =>
      state.monitoringImages.where((img) => img.status == 'completed').length;

  int get failedCount =>
      state.monitoringImages.where((img) => img.status == 'failed').length;
}
