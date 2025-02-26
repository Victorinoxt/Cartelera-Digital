import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/logging_service.dart';

class ServerService {
  static Process? _serverProcess;
  
  static Future<void> startServer() async {
    try {
      final serverPath = path.join(Directory.current.path, 'server');
      LoggingService.info('Iniciando servidor Node.js en: $serverPath');

      // Asegurarse que existan los directorios necesarios
      await Directory(path.join(serverPath, 'data')).create(recursive: true);
      await Directory(path.join(serverPath, 'monitoring')).create(recursive: true);
      await Directory(path.join(serverPath, 'uploads')).create(recursive: true);

      // Crear contents.json si no existe
      final contentsFile = File(path.join(serverPath, 'data', 'contents.json'));
      if (!await contentsFile.exists()) {
        await contentsFile.writeAsString('[]');
      }

      // Primero intentar matar cualquier instancia previa de node
      if (Platform.isWindows) {
        try {
          await Process.run('taskkill', ['/F', '/IM', 'node.exe']);
          // Esperar un momento para asegurar que el proceso se haya cerrado
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          // Ignorar errores si no hay procesos para matar
        }
      }

      // Obtener la ruta del directorio del servidor
      final serverDir = path.join(
        Directory.current.parent.path,
        'server'
      );
      
      LoggingService.info('Iniciando servidor Node.js en: $serverDir');
      
      // Verificar que el directorio del servidor existe
      if (!Directory(serverDir).existsSync()) {
        throw Exception('No se encontró el directorio del servidor en: $serverDir');
      }

      // Verificar que server.js existe
      final serverFile = path.join(serverDir, 'server.js');
      if (!File(serverFile).existsSync()) {
        throw Exception('No se encontró server.js en: $serverFile');
      }
      
      // Iniciar el proceso de Node.js
      _serverProcess = await Process.start(
        'node',
        ['server.js'],
        workingDirectory: serverDir,
      );
      
      // Manejar la salida del servidor
      _serverProcess!.stdout.listen(
        (data) => LoggingService.info('[Server] ${String.fromCharCodes(data)}'),
        onError: (error) => LoggingService.error('[Server Error]', error.toString()),
      );
      
      _serverProcess!.stderr.listen(
        (data) => LoggingService.error('[Server Error]', String.fromCharCodes(data)),
      );
      
      // Esperar un momento para que el servidor inicie
      await Future.delayed(const Duration(seconds: 2));
      
    } catch (e) {
      LoggingService.error('Error al iniciar el servidor', e.toString());
      rethrow;
    }
  }
  
  static Future<void> stopServer() async {
    if (_serverProcess != null) {
      LoggingService.info('Deteniendo servidor Node.js');
      _serverProcess!.kill();
      _serverProcess = null;

      // En Windows, asegurarse de que el proceso node.exe se detenga
      if (Platform.isWindows) {
        try {
          await Process.run('taskkill', ['/F', '/IM', 'node.exe']);
        } catch (e) {
          // Ignorar errores si no hay procesos para matar
        }
      }
    }
  }
}
