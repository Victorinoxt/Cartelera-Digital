import 'upload_status.dart';

class MonitoringState {
  final List<UploadStatus> uploads;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const MonitoringState({
    required this.uploads,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
  });

  int get pendingUploads => uploads.where((u) => u.state == UploadState.pending).length;
  int get inProgressUploads => uploads.where((u) => u.state == UploadState.inProgress).length;
  int get completedUploads => uploads.where((u) => u.state == UploadState.completed).length;
  int get failedUploads => uploads.where((u) => u.state == UploadState.failed).length;

  factory MonitoringState.initial() {
    return const MonitoringState(
      uploads: [],
      isLoading: false,
      hasError: false,
    );
  }

  MonitoringState copyWith({
    List<UploadStatus>? uploads,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return MonitoringState(
      uploads: uploads ?? this.uploads,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}