import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/logging_service.dart';

class ServerManager {
  static Process? _serverProcess;
  static bool _isStarted = false;
  
  static Future<bool> startServer() async {
    if (_isStarted) {
      LoggingService.info('El servidor ya está en ejecución');
      return true;
    }

    try {
      // Obtener la ruta del directorio del servidor
      final currentDir = Directory.current.path;
      final serverDir = currentDir.endsWith('cartelera_digital')
          ? path.join(currentDir, 'server')
          : path.join(path.dirname(currentDir), 'cartelera_digital', 'server');
      
      LoggingService.info('Iniciando servidor Node.js en: $serverDir');
      
      // Iniciar el proceso de Node.js
      _serverProcess = await Process.start(
        'node',
        ['server.js'],
        workingDirectory: serverDir,
      );
      
      // Manejar la salida del servidor
      _serverProcess!.stdout.listen(
        (data) => LoggingService.info('[Server] ${String.fromCharCodes(data)}'),
        onError: (error) => LoggingService.error('[Server Error] $error'),
      );
      
      _serverProcess!.stderr.listen(
        (data) => LoggingService.error('[Server Error] ${String.fromCharCodes(data)}'),
      );
      
      // Esperar un momento para que el servidor inicie
      await Future.delayed(const Duration(seconds: 2));
      
      _isStarted = true;
      return true;
    } catch (e) {
      LoggingService.error('Error al iniciar el servidor: $e');
      _isStarted = false;
      return false;
    }
  }
  
  static void stopServer() {
    if (_serverProcess != null) {
      LoggingService.info('Deteniendo servidor Node.js');
      _serverProcess!.kill();
      _serverProcess = null;
      _isStarted = false;
    }
  }
}
