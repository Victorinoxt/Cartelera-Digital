import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

class SocketService {
  late IO.Socket socket;
  String? _token;
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        initializeSocket();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  void initializeSocket() {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $_token'})
        .enableAutoConnect()
        .build()
    );

    socket.onConnect((_) {
      print('✅ Conectado al servidor');
    });

    socket.onConnectError((data) {
      print('❌ Error de conexión: $data');
    });

    socket.onDisconnect((_) {
      print('❌ Desconectado del servidor');
    });

    socket.on('error', (error) {
      print('❌ Error de socket: $error');
    });
  }

  void listenToCarteleras(Function(List<ContentModel>) onCartelerasUpdated) {
    socket.on('carteleras', (data) {
      print('📦 Datos recibidos después de eliminar: $data');
      try {
        final carteleras = (data as List)
            .map((item) => ContentModel.fromJson(item as Map<String, dynamic>))
            .toList();
        print('✅ Carteleras procesadas: ${carteleras.length}');
        onCartelerasUpdated(carteleras);
      } catch (e) {
        print('❌ Error al procesar datos: $e');
      }
    });
  }

  // Método para agregar una nueva cartelera
  void addCartelera(ContentModel nuevaCartelera) {
    socket.emit('nueva_cartelera', nuevaCartelera.toJson());
  }

  // Método para eliminar una cartelera
  void deleteCartelera(String id) {
    print('Emitiendo evento eliminar_cartelera con ID: $id');
    socket.emit('eliminar_cartelera', id);
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
} 