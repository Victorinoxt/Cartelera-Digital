enum MediaType { image, video }

class MediaItem {
  final String id;
  final String title;
  final String path;
  final MediaType type;
  final Map<String, dynamic> metadata;
  final int duration;

  MediaItem({
    required this.id,
    required this.title,
    required this.path,
    required this.type,
    this.metadata = const {},
    this.duration = 0,
  });

  MediaItem copyWith({
    String? id,
    String? title,
    String? path,
    MediaType? type,
    Map<String, dynamic>? metadata,
    int? duration,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      duration: duration ?? this.duration,
    );
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      path: json['path'] ?? '',
      type: json['type']?.toString().toLowerCase() == 'video' 
          ? MediaType.video 
          : MediaType.image,
      metadata: json['metadata'] ?? {},
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'type': type == MediaType.video ? 'video' : 'image',
      'metadata': metadata,
      'duration': duration,
    };
  }

  String get status => metadata['status'] ?? 'active';
}