enum MediaType { image, video, chart }

class MediaItem {
  final String id;
  final String title;
  final MediaType type;
  final String path;
  final int duration;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.path,
    this.duration = 10,
    this.metadata = const {},
    this.tags = const [],
  });

  MediaItem copyWith({
    String? title,
    int? duration,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return MediaItem(
      id: id,
      title: title ?? this.title,
      type: type,
      path: path,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }
} 