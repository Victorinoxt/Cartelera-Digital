class ExportPreset {
  final String id;
  final String name;
  final ExportSettings settings;
  final DateTime createdAt;
  final bool isDefault;

  const ExportPreset({
    required this.id,
    required this.name,
    required this.settings,
    required this.createdAt,
    this.isDefault = false,
  });

  // Convertir a/desde JSON para almacenamiento
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'settings': {
      'width': settings.width,
      'height': settings.height,
      'quality': settings.quality,
      'includeBorder': settings.includeBorder,
      'backgroundColor': settings.backgroundColor.value,
      'borderColor': settings.borderColor.value,
      'borderWidth': settings.borderWidth,
      'format': settings.format,
      'padding': {
        'top': settings.padding.top,
        'right': settings.padding.right,
        'bottom': settings.padding.bottom,
        'left': settings.padding.left,
      },
    },
    'createdAt': createdAt.toIso8601String(),
    'isDefault': isDefault,
  };

  factory ExportPreset.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['settings'] as Map<String, dynamic>;
    final paddingJson = settingsJson['padding'] as Map<String, dynamic>;

    return ExportPreset(
      id: json['id'],
      name: json['name'],
      settings: ExportSettings(
        width: settingsJson['width'],
        height: settingsJson['height'],
        quality: settingsJson['quality'],
        includeBorder: settingsJson['includeBorder'],
        backgroundColor: Color(settingsJson['backgroundColor']),
        borderColor: Color(settingsJson['borderColor']),
        borderWidth: settingsJson['borderWidth'],
        format: settingsJson['format'],
        padding: EdgeInsets.fromLTRB(
          paddingJson['left'],
          paddingJson['top'],
          paddingJson['right'],
          paddingJson['bottom'],
        ),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] ?? false,
    );
  }
}
