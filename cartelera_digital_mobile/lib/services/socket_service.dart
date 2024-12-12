import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';

final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

class SocketService {
  late IO.Socket socket;
  
  void initializeSocket() {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .enableForceNew()
        .setExtraHeaders({'Access-Control-Allow-Origin': '*'})
        .build()
    );

    socket.connect();

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
      print('📦 Datos recibidos: $data');
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

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
} 