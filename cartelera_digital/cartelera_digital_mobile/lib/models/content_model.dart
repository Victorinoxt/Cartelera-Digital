class ContentModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final String fileType;
  final DateTime startDate;
  final DateTime endDate;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.fileType,
    DateTime? startDate,
    DateTime? endDate,
  }) : 
    this.startDate = startDate ?? DateTime.now(),
    this.endDate = endDate ?? DateTime.now().add(const Duration(days: 7));

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['fileName'] ?? 'Sin título',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['url'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      fileType: json['fileType'] ?? 'unknown',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'fileType': fileType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}