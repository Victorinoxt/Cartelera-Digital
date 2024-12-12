import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_status.dart';
import 'api_service.dart';
import 'logging_service.dart';

final monitoringServiceProvider = Provider((ref) => MonitoringService(ref));

class MonitoringService {
  final Ref _ref;
  
  MonitoringService(this._ref);

  Future<List<UploadStatus>> getUploadStatus() async {
    try {
      final response = await _ref.read(apiServiceProvider).get('/uploads/status');
      return _parseUploadStatus(response);
    } catch (e) {
      LoggingService.error('Error al obtener estado de subidas', e);
      throw Exception('Error al obtener estado de subidas: $e');
    }
  }

  Future<void> updateUploadProgress(String uploadId, double progress) async {
    try {
      await _ref.read(apiServiceProvider).patch(
        '/uploads/$uploadId/progress',
        data: {'progress': progress},
      );
    } catch (e) {
      LoggingService.error('Error al actualizar progreso', e);
      throw Exception('Error al actualizar progreso: $e');
    }
  }

  List<UploadStatus> _parseUploadStatus(dynamic response) {
    if (response is! List) throw Exception('Formato de respuesta inválido');
    
    return response.map((item) => UploadStatus(
      id: item['id'],
      fileName: item['fileName'],
      fileType: item['fileType'],
      progress: item['progress']?.toDouble() ?? 0.0,
      state: _parseUploadState(item['state']),
      error: item['error'],
      createdAt: DateTime.parse(item['createdAt']),
      updatedAt: item['updatedAt'] != null 
          ? DateTime.parse(item['updatedAt'])
          : null,
      uploadedBy: item['uploadedBy'],
      fileSize: item['fileSize'],
    )).toList();
  }

  UploadState _parseUploadState(String? state) {
    switch (state) {
      case 'pending': return UploadState.pending;
      case 'inProgress': return UploadState.inProgress;
      case 'completed': return UploadState.completed;
      case 'failed': return UploadState.failed;
      default: return UploadState.pending;
    }
  }
}