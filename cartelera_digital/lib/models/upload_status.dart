import 'package:flutter/material.dart';

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
  final String? url;

  UploadStatus({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.progress,
    required this.state,
    this.url,
  });

  UploadStatus copyWith({
    String? id,
    String? fileName,
    String? fileType,
    double? progress,
    UploadState? state,
    String? url,
  }) {
    return UploadStatus(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      progress: progress ?? this.progress,
      state: state ?? this.state,
      url: url ?? this.url,
    );
  }
}