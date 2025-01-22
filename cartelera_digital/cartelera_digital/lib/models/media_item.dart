enum MediaType { image, video }

class MediaItem {
  final String id;
  final String title;
  final MediaType type;
  final String path;
  final int duration;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? estado;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.path,
    this.duration = 10,
    this.metadata = const {},
    this.tags = const [],
    this.estado,
  });

  MediaItem copyWith({
    String? title,
    int? duration,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? estado,
  }) {
    return MediaItem(
      id: id,
      title: title ?? this.title,
      type: type,
      path: path,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      estado: estado ?? this.estado,
    );
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] == 'video' ? MediaType.video : MediaType.image,
      path: json['path'] as String,
      duration: json['duration'] as int? ?? 10,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      estado: json['estado'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type == MediaType.video ? 'video' : 'image',
      'path': path,
      'duration': duration,
      'metadata': metadata,
      'tags': tags,
      'estado': estado,
    };
  }
}