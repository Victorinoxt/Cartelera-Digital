class ContentItem {
  final String id;
  final String title;
  final String path;
  final String type;
  final Map<String, dynamic> metadata;
  final DateTime uploadedAt;

  ContentItem({
    required this.id,
    required this.title,
    required this.path,
    required this.type,
    required this.metadata,
    required this.uploadedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? 'image',
      metadata: json['metadata'] ?? {},
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'type': type,
      'metadata': metadata,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
} 