enum ContentType { image, video }

class ContentModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final ContentType type;
  final Duration? duration;
  final int displayOrder;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? metadata;
  
  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.type,
    this.duration,
    required this.displayOrder,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.metadata,
  });
} 