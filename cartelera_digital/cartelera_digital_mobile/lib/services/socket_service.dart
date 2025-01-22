import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../models/content_model.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  service.initialize();
  return service;
});

class SocketService {
  IO.Socket? _socket;
  final _imagesController = StreamController<List<ContentModel>>.broadcast();
  final _cartelerasController = StreamController<List<dynamic>>.broadcast();

  Stream<List<ContentModel>> get onImagesUpdated => _imagesController.stream;
  Stream<List<dynamic>> get onCartelerasUpdated => _cartelerasController.stream;

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

    socket.on('disconnect', (_) {
      print('Desconectado del servidor de sockets');
    });

    socket.on('images_updated', (data) {
      print('Recibida actualización de imágenes: ${data.length} imágenes');
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
  }
}