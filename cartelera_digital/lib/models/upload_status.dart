import 'package:flutter/material.dart';

enum UploadState {
  pending,
  inProgress,
  completed,
  failed
}

class UploadStatus {
  final String id;
  final String fileName;
  final String fileType;
  final double progress;
  final UploadState state;
  final String? error;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? uploadedBy;
  final int fileSize;

  const UploadStatus({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.progress,
    required this.state,
    this.error,
    required this.createdAt,
    this.updatedAt,
    this.uploadedBy,
    required this.fileSize,
  });

  UploadStatus copyWith({
    String? fileName,
    double? progress,
    UploadState? state,
    String? error,
    DateTime? updatedAt,
  }) {
    return UploadStatus(
      id: id,
      fileName: fileName ?? this.fileName,
      fileType: fileType,
      progress: progress ?? this.progress,
      state: state ?? this.state,
      error: error ?? this.error,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploadedBy: uploadedBy,
      fileSize: fileSize,
    );
  }
}