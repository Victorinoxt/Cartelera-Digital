enum UploadState {
  pending,
  inProgress,
  completed,
  failed,
}

class UploadStatus {
  final String id;
  final String fileName;
  final String fileType;
  final double progress;
  final UploadState state;
  final DateTime timestamp;
  final String? url;
  final String? error;
  final Map<String, dynamic> metadata;

  UploadStatus({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.progress,
    required this.state,
    required this.timestamp,
    this.url,
    this.error,
    required this.metadata,
  });

  factory UploadStatus.fromJson(Map<String, dynamic> json) {
    return UploadStatus(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      state: _parseState(json['state'] as String? ?? ''),
      timestamp: json['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
        : DateTime.now(),
      url: json['url'] as String?,
      error: json['error'] as String?,
      metadata: json['metadata'] ?? {},
    );
  }

  static UploadState _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return UploadState.pending;
      case 'inprogress':
      case 'in_progress':
        return UploadState.inProgress;
      case 'completed':
        return UploadState.completed;
      case 'failed':
        return UploadState.failed;
      default:
        return UploadState.pending;
    }
  }

  UploadStatus copyWith({
    String? id,
    String? fileName,
    String? fileType,
    double? progress,
    UploadState? state,
    DateTime? timestamp,
    String? url,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return UploadStatus(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      progress: progress ?? this.progress,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      url: url ?? this.url,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}
