import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chart_data.dart';
import '../models/export_settings.dart';
import '../models/export_type.dart';
import '../utils/file_utils.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<String> exportContent({
    required String content,
    required ExportSettings settings,
    Function(double, String)? onProgress,
  }) async {
    switch (settings.type) {
      case ExportType.pdf:
        return await _exportToPdf(content, settings, onProgress);
      case ExportType.image:
        return await _exportToImage(content, settings, onProgress);
      case ExportType.csv:
        return await _exportToCsv(content, settings, onProgress);
      case ExportType.excel:
        return await _exportToExcel(content, settings, onProgress);
      default:
        throw UnimplementedError('Tipo de exportación no soportado: ${settings.type}');
    }
  }

  Future<String> _exportToPdf(
    String content,
    ExportSettings settings,
    Function(double, String)? onProgress,
  ) async {
    onProgress?.call(0.0, 'Iniciando exportación a PDF...');
    // Implementar exportación a PDF
    throw UnimplementedError('Exportación a PDF no implementada');
  }

  Future<String> _exportToImage(
    String content,
    ExportSettings settings,
    Function(double, String)? onProgress,
  ) async {
    onProgress?.call(0.0, 'Iniciando exportación a imagen...');
    // Implementar exportación a imagen
    throw UnimplementedError('Exportación a imagen no implementada');
  }

  Future<String> _exportToCsv(
    String content,
    ExportSettings settings,
    Function(double, String)? onProgress,
  ) async {
    onProgress?.call(0.0, 'Iniciando exportación a CSV...');
    // Implementar exportación a CSV
    throw UnimplementedError('Exportación a CSV no implementada');
  }

  Future<String> _exportToExcel(
    String content,
    ExportSettings settings,
    Function(double, String)? onProgress,
  ) async {
    onProgress?.call(0.0, 'Iniciando exportación a Excel...');
    // Implementar exportación a Excel
    throw UnimplementedError('Exportación a Excel no implementada');
  }

  Future<void> exportChart({
    required BuildContext context,
    required Widget chart,
    required ExportSettings settings,
    Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Preparando exportación...');

      // Crear un widget contenedor con todas las configuraciones
      final exportWidget = RepaintBoundary(
        child: Container(
          width: settings.width,
          height: settings.height,
          padding: settings.padding,
          decoration: BoxDecoration(
            color: settings.backgroundColor,
            border: settings.includeBorder ? Border.all(
              color: settings.borderColor,
              width: settings.borderWidth,
            ) : null,
          ),
          child: Stack(
            children: [
              // Gráfico principal
              chart,
              
              // Título personalizado si está habilitado
              if (settings.showCustomTitle && settings.customTitle != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Text(
                    settings.customTitle!,
                    style: TextStyle(
                      fontSize: settings.titleFontSize,
                      color: settings.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              // Marca de agua si está habilitada
              if (settings.showWatermark && settings.watermarkText != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Opacity(
                    opacity: settings.watermarkOpacity,
                    child: Text(
                      settings.watermarkText!,
                      style: TextStyle(
                        fontSize: settings.watermarkFontSize,
                        color: settings.watermarkColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

      onProgress?.call(0.3, 'Procesando gráfico...');

      // Capturar el gráfico como imagen
      final boundary = exportWidget.createRenderObject(context) as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: settings.quality);
      final byteData = await image.toByteData(
        format: settings.format == 'PNG' ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba
      );

      if (byteData == null) throw Exception('Error al procesar la imagen');

      onProgress?.call(0.6, 'Guardando archivo...');

      // Crear directorio si no existe
      final directory = await getApplicationDocumentsDirectory();
      final exportPath = settings.exportPath ?? '${directory.path}/exports';
      await Directory(exportPath).create(recursive: true);

      // Guardar archivo
      final fileName = 'chart_${DateTime.now().millisecondsSinceEpoch}.${settings.format.toLowerCase()}';
      final file = File('$exportPath/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      onProgress?.call(1.0, '¡Exportación completada!');
    } catch (e) {
      throw Exception('Error al exportar el gráfico: $e');
    }
  }
}