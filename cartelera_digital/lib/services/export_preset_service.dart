import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/export_settings.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'settings': settings.toJson(),
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
        customTitle: settingsJson['customTitle'],
        watermarkText: settingsJson['watermarkText'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class ExportPresetService {
  static const String _presetKey = 'export_presets';
  final SharedPreferences _prefs;

  ExportPresetService(this._prefs);

  Future<List<ExportPreset>> getPresets() async {
    final presetStrings = _prefs.getStringList(_presetKey) ?? [];
    return presetStrings
        .map((str) => ExportPreset.fromJson(jsonDecode(str)))
        .toList();
  }

  Future<void> savePreset(ExportPreset preset) async {
    final presets = await getPresets();
    presets.add(preset);
    final presetStrings = presets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_presetKey, presetStrings);
  }

  Future<void> deletePreset(String id) async {
    final presets = await getPresets();
    presets.removeWhere((preset) => preset.id == id);
    await _savePresets(presets);
  }

  Future<void> _savePresets(List<ExportPreset> presets) async {
    final presetStrings = presets
        .map((preset) => jsonEncode(preset.toJson()))
        .toList();
    await _prefs.setStringList(_presetKey, presetStrings);
  }

  List<ExportPreset> getDefaultPresets() {
    return [
      ExportPreset(
        id: 'hd',
        name: 'HD',
        settings: const ExportSettings(width: 1280, height: 720),
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      ExportPreset(
        id: 'fullhd',
        name: 'Full HD',
        settings: const ExportSettings(width: 1920, height: 1080),
        createdAt: DateTime.now(),
        isDefault: true,
      ),
      ExportPreset(
        id: '4k',
        name: '4K',
        settings: const ExportSettings(width: 3840, height: 2160),
        createdAt: DateTime.now(),
        isDefault: true,
      ),
    ];
  }
}
