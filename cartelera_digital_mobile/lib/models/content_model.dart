import '../config/server_config.dart';
import '../services/logging_service.dart';

enum ContentType { image, video }

class ContentModel {
  final String id;
  final String? title;
  final String imageUrl;
  final String type;
  final String status;
  final DateTime? assignedAt;
  final bool isActive;

  ContentModel({
    required this.id,
    this.title,
    required this.imageUrl,
    this.type = 'image',
    this.status = 'active',
    this.assignedAt,
    this.isActive = true,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    try {
      return ContentModel(
        id: json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title']?.toString(),
        imageUrl: json['imageUrl']?.toString() ?? json['url']?.toString() ?? '',
        type: json['type']?.toString() ?? 'image',
        status: json['status']?.toString() ?? 'active',
        assignedAt: json['assignedAt'] != null
            ? DateTime.parse(json['assignedAt'].toString())
            : null,
        isActive: json['status']?.toString()?.toLowerCase() == 'active',
      );
    } catch (e) {
      LoggingService.error('Error al parsear ContentModel: $e\nDatos: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'type': type,
      'status': status,
      'assignedAt': assignedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'ContentModel(id: $id, title: $title, imageUrl: $imageUrl, type: $type, status: $status, assignedAt: $assignedAt, isActive: $isActive)';
  }

  // Método para crear una copia del modelo con cambios
  ContentModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? type,
    String? status,
    DateTime? assignedAt,
    bool? isActive,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
