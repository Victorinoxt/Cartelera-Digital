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
      return [];
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
    }
  }

  List<UploadStatus> _parseUploadStatus(dynamic response) {
    if (response == null) return [];
    if (response is! List) return [];
    
    return response.map((item) {
      try {
        return UploadStatus(
          id: item['id'] ?? '',
          fileName: item['fileName'] ?? '',
          fileType: item['fileType'] ?? '',
          progress: (item['progress'] ?? 0.0).toDouble(),
          state: _parseUploadState(item['state']),
          url: item['url'],
        );
      } catch (e) {
        LoggingService.error('Error al parsear upload status', e);
        return UploadStatus(
          id: '',
          fileName: '',
          fileType: '',
          progress: 0.0,
          state: UploadState.failed,
        );
      }
    }).toList();
  }

  UploadState _parseUploadState(String? state) {
    switch (state?.toLowerCase()) {
      case 'pending':
        return UploadState.pending;
      case 'inprogress':
        return UploadState.inProgress;
      case 'completed':
        return UploadState.completed;
      case 'failed':
        return UploadState.failed;
      default:
        return UploadState.pending;
    }
  }
}