import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<double> getFreeDiskSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      return stat.size / 1024 / 1024; // Convertir a MB
    } catch (e) {
      print('Error al obtener espacio en disco: $e');
      return 0.0;
    }
  }

  static Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    
    return exportDir.path;
  }

  static Future<bool> ensureDirectoryExists(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return true;
    } catch (e) {
      print('Error al crear directorio: $e');
      return false;
    }
  }

  static String sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}