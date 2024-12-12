class ContentModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
} 