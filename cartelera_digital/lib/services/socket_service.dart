import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logging_service.dart';
import '../config/env_config.dart';
import '../config/server_config.dart';
import '../models/media_item.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  try {
    final service = SocketService();
    service.initialize();
    SocketService.instance = service;
    return service;
  } catch (e) {
    LoggingService.error('Error al inicializar SocketService provider', e);
    rethrow;
  }
});

class SocketService {
  static SocketService? _instance;
  
  static SocketService get instance {
    if (_instance == null) {
      throw Exception('SocketService no ha sido inicializado. Asegúrate de llamar a initialize() primero.');
    }
    return _instance!;
  }

  static set instance(SocketService service) {
    _instance = service;
  }

  IO.Socket? _socket;
  bool _isConnected = false;
  final Duration _reconnectInterval;
  
  // Stream controllers para estados de conexión y eventos
  final _connectionStateController = StreamController<bool>.broadcast();
  final _uploadProgressController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters para los streams
  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get uploadProgress => _uploadProgressController.stream;

  SocketService()
      : _reconnectInterval =
            Duration(milliseconds: EnvConfig.wsReconnectInterval);

  void initialize() {
    if (_socket != null) return;

    try {
      _socket = IO.io(
        ServerConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(3000)
            .build(),
      );

      _setupSocketListeners();
      connect();
    } catch (e) {
      LoggingService.error('Error al inicializar SocketService', e);
      rethrow;
    }
  }

  void _setupSocketListeners() {
    socket.on('connect', (_) {
      print('Desktop: Conectado al servidor de sockets');
      _isConnected = true;
      _connectionStateController.add(true);
    });

    socket.on('disconnect', (_) {
      print('Desktop: Desconectado del servidor');
      _isConnected = false;
      _connectionStateController.add(false);
    });

    socket.on('connect_error', (error) {
      print('Desktop: Error de conexión: $error');
      _isConnected = false;
      _connectionStateController.add(false);
    });

    socket.on('reconnect_attempt', (attemptNumber) {
      print('Desktop: Intento de reconexión #$attemptNumber');
    });

    socket.on('reconnect_failed', (_) {
      print('Desktop: Falló la reconexión después de todos los intentos');
    });
  }

  // Método para obtener el ID del socket guardado
  Future<String?> getSavedSocketId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('socketId');
  }

  // Método para guardar el ID del socket
  Future<void> saveSocketId(String socketId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('socketId', socketId);
    LoggingService.info('ID de socket guardado: $socketId');
  }

  // Método para eliminar el ID del socket guardado
  Future<void> clearSocketId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('socketId');
    LoggingService.info('ID de socket eliminado');
  }

  // Método para conectar al socket
  void connect() {
    if (!socket.connected) {
      socket.connect();
      print('Desktop: Intentando conectar al servidor: ${ServerConfig.baseUrl}');
    }
  }

  void emit(String event, dynamic data) {
    if (!_isConnected || _socket == null) {
      LoggingService.warning('Intentando emitir evento sin conexión: $event');
      return;
    }
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    socket.disconnect();
    _isConnected = false;
    _connectionStateController.add(false);
    clearSocketId();
  }

  bool get isConnected => _isConnected;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket no inicializado. Llama a initialize() primero.');
    }
    return _socket!;
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _uploadProgressController.close();
  }

  // Método mejorado para emitir nuevo contenido
  Future<bool> emitNewContent(MediaItem mediaItem) async {
    if (!_isConnected) {
      print('Desktop: No se puede emitir contenido - Sin conexión');
      return false;
    }

    try {
      final completer = Completer<bool>();
      
      socket.emitWithAck('new_content', {
        'id': mediaItem.id,
        'title': mediaItem.title,
        'url': mediaItem.path,
        'type': mediaItem.type == MediaType.video ? 'video' : 'image',
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': mediaItem.metadata,
        'duration': mediaItem.duration,
      }, ack: (data) {
        if (data != null && data['success'] == true) {
          print('Desktop: Contenido emitido exitosamente');
          completer.complete(true);
        } else {
          print('Desktop: Error al emitir contenido');
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      print('Desktop: Error al emitir contenido: $e');
      return false;
    }
  }

  // Método para emitir progreso de carga
  void emitUploadProgress(String id, double progress) {
    if (_isConnected) {
      socket.emit('upload_progress', {
        'id': id,
        'progress': progress,
      });
      _uploadProgressController.add({
        'id': id,
        'progress': progress,
      });
    }
  }
}
