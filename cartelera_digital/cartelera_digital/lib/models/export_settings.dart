import 'package:flutter/material.dart';
import 'export_type.dart';

class ExportSettings {
  final ExportType type;
  final double width;
  final double height;
  final double quality;
  final String format;
  final Color backgroundColor;
  final EdgeInsets padding;
  final bool includeBorder;
  final Color borderColor;
  final double borderWidth;
  final String? exportPath;
  
  // Configuraciones de título personalizado
  final bool showCustomTitle;
  final String? customTitle;
  final double titleFontSize;
  final Color titleColor;
  
  // Configuraciones de marca de agua
  final bool showWatermark;
  final String? watermarkText;
  final double watermarkFontSize;
  final Color watermarkColor;
  final double watermarkOpacity;

  const ExportSettings({
    required this.type,
    this.width = 1920,
    this.height = 1080,
    this.quality = 3.0,
    this.format = 'PNG',
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.includeBorder = false,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.exportPath,
    this.showCustomTitle = false,
    this.customTitle,
    this.titleFontSize = 24,
    this.titleColor = Colors.black,
    this.showWatermark = false,
    this.watermarkText,
    this.watermarkFontSize = 16,
    this.watermarkColor = Colors.black45,
    this.watermarkOpacity = 0.3,
  });

  ExportSettings copyWith({
    ExportType? type,
    double? width,
    double? height,
    double? quality,
    String? format,
    Color? backgroundColor,
    EdgeInsets? padding,
    bool? includeBorder,
    Color? borderColor,
    double? borderWidth,
    String? exportPath,
    bool? showCustomTitle,
    String? customTitle,
    double? titleFontSize,
    Color? titleColor,
    bool? showWatermark,
    String? watermarkText,
    double? watermarkFontSize,
    Color? watermarkColor,
    double? watermarkOpacity,
  }) {
    return ExportSettings(
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      includeBorder: includeBorder ?? this.includeBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      exportPath: exportPath ?? this.exportPath,
      showCustomTitle: showCustomTitle ?? this.showCustomTitle,
      customTitle: customTitle ?? this.customTitle,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      titleColor: titleColor ?? this.titleColor,
      showWatermark: showWatermark ?? this.showWatermark,
      watermarkText: watermarkText ?? this.watermarkText,
      watermarkFontSize: watermarkFontSize ?? this.watermarkFontSize,
      watermarkColor: watermarkColor ?? this.watermarkColor,
      watermarkOpacity: watermarkOpacity ?? this.watermarkOpacity,
    );
  }
}
