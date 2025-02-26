import '../models/media_item.dart';
import '../models/upload_status.dart';

class MonitoringState {
  final List<MediaItem> monitoringImages;
  final List<UploadStatus> uploads;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final int completedUploads;
  final int pendingUploads;
  final int inProgressUploads;
  final int failedUploads;

  MonitoringState({
    required this.monitoringImages,
    required this.uploads,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.completedUploads,
    required this.pendingUploads,
    required this.inProgressUploads,
    required this.failedUploads,
  });

  factory MonitoringState.initial() {
    return MonitoringState(
      monitoringImages: [],
      uploads: [],
      isLoading: false,
      hasError: false,
      errorMessage: null,
      completedUploads: 0,
      pendingUploads: 0,
      inProgressUploads: 0,
      failedUploads: 0,
    );
  }

  MonitoringState copyWith({
    List<MediaItem>? monitoringImages,
    List<UploadStatus>? uploads,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? completedUploads,
    int? pendingUploads,
    int? inProgressUploads,
    int? failedUploads,
  }) {
    return MonitoringState(
      monitoringImages: monitoringImages ?? this.monitoringImages,
      uploads: uploads ?? this.uploads,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      completedUploads: completedUploads ?? this.completedUploads,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      inProgressUploads: inProgressUploads ?? this.inProgressUploads,
      failedUploads: failedUploads ?? this.failedUploads,
    );
  }
}