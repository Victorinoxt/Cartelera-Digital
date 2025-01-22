import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import '../models/export_settings.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../services/logging_service.dart';

class ChartExportService {
  final MediaService _mediaService;

  ChartExportService(this._mediaService);

  Future<MediaItem?> exportChartAsImage(
    BuildContext context,
    Widget chart,
    String title,
    ExportSettings settings,
  ) async {
    try {
      if (settings.exportPath != null) {
        final normalizedPath = settings.exportPath!.replaceAll('/', Platform.pathSeparator);
        final directory = Directory(normalizedPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        throw Exception('Ruta de exportación no especificada');
      }

      final boundaryKey = GlobalKey();
      final exportWidget = RepaintBoundary(
        key: boundaryKey,
        child: Material(
          color: settings.backgroundColor,
          child: Container(
            width: settings.width,
            height: settings.height,
            padding: settings.padding,
            decoration: BoxDecoration(
              border: settings.includeBorder
                  ? Border.all(
                      color: settings.borderColor,
                      width: settings.borderWidth,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: math.max(settings.width, 300),
                  height: math.max(settings.height, 200),
                  child: chart,
                ),
                if (settings.showCustomTitle && settings.customTitle != null)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        settings.customTitle!,
                        style: TextStyle(
                          fontSize: settings.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: settings.titleColor,
                        ),
                      ),
                    ),
                  ),
                if (settings.showWatermark && settings.watermarkText != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Opacity(
                      opacity: settings.watermarkOpacity,
                      child: Transform.rotate(
                        angle: -math.pi / 6,
                        child: Text(
                          settings.watermarkText!,
                          style: TextStyle(
                            fontSize: settings.watermarkFontSize,
                            color: settings.watermarkColor,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      final overlayState = Overlay.of(context);
      final entry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          child: SizedBox(
            width: settings.width,
            height: settings.height,
            child: exportWidget,
          ),
        ),
      );

      overlayState.insert(entry);

      try {
        await Future.delayed(const Duration(milliseconds: 1800));

        final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: settings.quality);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData == null) throw Exception('Error al generar la imagen');

        final bytes = byteData.buffer.asUint8List();
        final sanitizedFileName = '${settings.customTitle ?? title}_${DateTime.now().millisecondsSinceEpoch}.${settings.format.toLowerCase()}'
            .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        
        final normalizedPath = settings.exportPath!.replaceAll('/', Platform.pathSeparator);
        final filePath = path.join(normalizedPath, sanitizedFileName);
        
        LoggingService.info('Intentando guardar en: $filePath');
        
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        LoggingService.info('Archivo guardado exitosamente en: ${file.path}');

        final mediaItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: sanitizedFileName,
          type: MediaType.image,
          path: file.path,
          duration: 0,
        );

        await _mediaService.addItem(mediaItem);
        return mediaItem;
      } finally {
        entry.remove();
      }
    } catch (e) {
      LoggingService.error('Error al exportar gráfico', e);
      rethrow;
    }
  }

  String _getMimeType(String format) {
    switch (format.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
      default:
        return 'image/png';
    }
  }

  Future<void> exportChart({
    required BuildContext context,
    required Widget chart,
    required ExportSettings settings,
    Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Preparando exportación...');
      
      final result = await exportChartAsImage(
        context,
        chart,
        settings.customTitle ?? 'Gráfico',
        settings,
      );

      if (result != null) {
        onProgress?.call(1.0, '¡Exportación completada!');
      } else {
        throw Exception('Error al exportar el gráfico');
      }
    } catch (e) {
      debugPrint('Error en la exportación del gráfico: $e');
      rethrow;
    }
  }
}
