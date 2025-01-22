class UploadStatus {
  final String id;
  final String? url;
  final String? fileName;
  final String? fileType;
  final String state;
  final double progress;

  UploadStatus({
    required this.id,
    this.url,
    this.fileName,
    this.fileType,
    required this.state,
    required this.progress,
  });

  factory UploadStatus.fromJson(Map<String, dynamic> json) {
    return UploadStatus(
      id: json['id'] ?? '',
      url: json['url'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      state: json['state'] ?? 'unknown',
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'fileType': fileType,
      'state': state,
      'progress': progress,
    };
  }
}
