import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logging_service.dart';
import '../config/env_config.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  final Duration _reconnectInterval;

  SocketService()
      : _reconnectInterval =
            Duration(milliseconds: EnvConfig.wsReconnectInterval);

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
  Future<void> connect() async {
    if (!EnvConfig.wsEnabled) {
      LoggingService.info('WebSocket está deshabilitado');
      return;
    }

    if (_socket != null) {
      _socket!.disconnect();
    }

    try {
      _socket = IO.io(EnvConfig.wsUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionDelay(EnvConfig.wsReconnectInterval)
          .setReconnectionAttempts(5)
          .build());

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        LoggingService.info('Conectado al servidor de WebSocket: ${EnvConfig.wsUrl}');
        
        // Guardar el ID del socket cuando se conecte
        if (_socket?.id != null) {
          saveSocketId(_socket!.id!);
        }
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        LoggingService.info('Desconectado del servidor de WebSocket');
      });

      _socket!.onError((error) {
        _isConnected = false;
        LoggingService.error('Error de WebSocket: $error');
      });

      _socket!.onReconnect((_) {
        LoggingService.info('Intentando reconectar al WebSocket...');
      });

    } catch (e) {
      LoggingService.error('Error al conectar WebSocket', e);
      _isConnected = false;
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
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    clearSocketId();
  }

  bool get isConnected => _isConnected;
}
