import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../models/content_model.dart';
import '../services/logging_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  service.initialize();
  SocketService.instance = service;
  return service;
});

class SocketService {
  static late SocketService instance;

  IO.Socket? _socket;
  final _imagesController = StreamController<List<ContentModel>>.broadcast();
  final _cartelerasController = StreamController<List<dynamic>>.broadcast();
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<List<ContentModel>> get onImagesUpdated => _imagesController.stream;
  Stream<List<dynamic>> get onCartelerasUpdated => _cartelerasController.stream;
  Stream<dynamic> get onMessages => _messageController.stream;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket no inicializado. Llama a initialize() primero.');
    }
    return _socket!;
  }

  void initialize() {
    if (_socket != null) return; // Ya inicializado

    _socket = IO.io(
      ServerConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _setupSocketListeners();
    connect();
  }

  void _setupSocketListeners() {
    socket.on('connect', (_) {
      print('Conectado al servidor de sockets');
      requestImages();
    });

    socket.on('connect_error', (data) {
      print('Error al conectar: $data');
    });

    socket.on('reconnect_attempt', (data) {
      print('Intentando reconectar: $data');
    });

    socket.on('reconnect_failed', (_) {
      print('No se pudo reconectar');
    });

    socket.on('images_updated', (data) {
      print('Actualización de imágenes recibida: ${data.length}');
      if (data is List) {
        final images = data.map((item) => ContentModel.fromJson(item)).toList();
        _imagesController.add(images);
      }
    });

    socket.on('carteleras_updated', (data) {
      print('Recibida actualización de carteleras');
      if (data is List) {
        _cartelerasController.add(data);
      }
    });

    socket.on('error', (error) {
      print('Error en el socket: $error');
    });

    socket.on('new_content', (data) {
      print('Nuevo contenido recibido: $data');
    });

    socket.on('message', _handleWebSocketMessage);
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      LoggingService.info('Mensaje WebSocket recibido: $message');

      switch (data['event']) {
        case 'content_removed':
          _handleContentRemoved(data['payload']);
          break;
        case 'content_updated':
          _handleContentUpdated(data['payload']);
          break;
        case 'device_config':
          _handleDeviceConfig(data['payload']);
          break;
        default:
          _messageController.add(data);
      }
    } catch (e) {
      LoggingService.error('Error al procesar mensaje: $e');
    }
  }

  void _handleContentRemoved(Map<String, dynamic> payload) {
    try {
      LoggingService.info('Contenido eliminado recibido: $payload');
      if (payload['remainingContent'] != null) {
        final List<dynamic> remainingContent = payload['remainingContent'];
        _messageController.add({
          'event': 'content_updated',
          'payload': remainingContent
        });
      }
    } catch (e) {
      LoggingService.error('Error al manejar eliminación de contenido: $e');
    }
  }

  void _handleContentUpdated(dynamic payload) {
    try {
      LoggingService.info('Actualización de contenido recibida: $payload');
      _messageController.add({
        'event': 'content_updated',
        'payload': payload
      });
    } catch (e) {
      LoggingService.error('Error al manejar actualización de contenido: $e');
    }
  }

  void _handleDeviceConfig(Map<String, dynamic> payload) {
    try {
      LoggingService.info('Configuración de dispositivo recibida: $payload');
      _messageController.add({
        'event': 'device_config',
        'payload': payload});
    } catch (e) {
      LoggingService.error('Error al manejar configuración de dispositivo: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    final completer = Completer<bool>();

    socket.emitWithAck('login', {
      'username': username,
      'password': password,
    }, ack: (data) {
      if (data != null && data['success'] == true) {
        requestImages();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void requestImages() {
    print('Solicitando imágenes al servidor...');
    socket.emit('request_images');
  }

  void addCartelera(Map<String, dynamic> cartelera) {
    socket.emit('add_cartelera', cartelera);
  }

  void deleteImage(String id) {
    socket.emit('delete_image', {'id': id});
  }

  Future<void> deleteImageHttp(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ServerConfig.baseUrl}/images/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la imagen');
      }

      // No necesitamos hacer nada más aquí ya que el servidor emitirá un evento 'imagesUpdated'
    } catch (e) {
      print('Error al eliminar imagen: $e');
      rethrow;
    }
  }

  Future<void> deleteAllImages() async {
    try {
      final response = await http.delete(
        Uri.parse('${ServerConfig.baseUrl}/images'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar todas las imágenes');
      }

      // No necesitamos hacer nada más aquí ya que el servidor emitirá un evento 'imagesUpdated'
    } catch (e) {
      print('Error al eliminar todas las imágenes: $e');
      rethrow;
    }
  }

  void listenToCarteleras(Function(List<dynamic>) callback) {
    socket.on('carteleras_updated', (data) {
      if (data is List) {
        callback(data);
      }
    });
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
      print('Intentando conectar al servidor: ${ServerConfig.baseUrl}');
    }
  }

  void disconnect() {
    socket.disconnect();
  }

  void dispose() {
    disconnect();
    _imagesController.close();
    _cartelerasController.close();
    _messageController.close();
  }
}
