import 'upload_status.dart';

class MonitoringState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<UploadStatus> uploads;
  final int pendingUploads;
  final int inProgressUploads;
  final int completedUploads;
  final int failedUploads;

  MonitoringState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.uploads,
    required this.pendingUploads,
    required this.inProgressUploads,
    required this.completedUploads,
    required this.failedUploads,
  });

  factory MonitoringState.initial() {
    return MonitoringState(
      isLoading: false,
      hasError: false,
      uploads: [],
      pendingUploads: 0,
      inProgressUploads: 0,
      completedUploads: 0,
      failedUploads: 0,
    );
  }

  MonitoringState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<UploadStatus>? uploads,
    int? pendingUploads,
    int? inProgressUploads,
    int? completedUploads,
    int? failedUploads,
  }) {
    return MonitoringState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      uploads: uploads ?? this.uploads,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      inProgressUploads: inProgressUploads ?? this.inProgressUploads,
      completedUploads: completedUploads ?? this.completedUploads,
      failedUploads: failedUploads ?? this.failedUploads,
    );
  }
}