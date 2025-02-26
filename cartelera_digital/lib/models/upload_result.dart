class UploadResult {
  final bool success;
  final String? imageUrl;
  final String? uploadId;
  final String? fileName;
  final String? fileType;
  final String? state;
  final double? progress;
  final String? error;
  final String? timestamp;

  UploadResult({
    required this.success,
    this.imageUrl,
    this.uploadId,
    this.fileName,
    this.fileType,
    this.state,
    this.progress,
    this.error,
    this.timestamp,
  });

  factory UploadResult.success({
    required String imageUrl,
    required String fileName,
    String? fileType,
  }) {
    return UploadResult(
      success: true,
      imageUrl: imageUrl,
      fileName: fileName,
      fileType: fileType,
      state: 'completed',
      progress: 100,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory UploadResult.error(String error) {
    return UploadResult(
      success: false,
      error: error,
      state: 'failed',
      progress: 0,
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
