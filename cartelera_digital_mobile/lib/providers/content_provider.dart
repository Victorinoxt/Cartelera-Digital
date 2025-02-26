import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';
import '../config/server_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logging_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

// Proveedor para SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Proveedor para el servicio de contenido
final contentServiceProvider = Provider((ref) {
  return ContentService(
    baseUrl: ServerConfig.baseUrl,
    timeout: Duration(milliseconds: ServerConfig.connectionTimeout),
  );
});

// Proveedor para la lista de contenidos
final contentProvider =
    AsyncNotifierProvider<ContentNotifier, List<ContentModel>>(() {
  return ContentNotifier();
});

// Proveedor para el estado de carga
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Proveedor para errores
final errorProvider = StateProvider<String?>((ref) => null);

final contentsProvider = FutureProvider<List<ContentModel>>((ref) async {
  final contentService = ref.watch(contentServiceProvider);
  return contentService.getContents();
});

class ContentNotifier extends AsyncNotifier<List<ContentModel>> {
  WebSocketChannel? _channel;
  bool _isConnecting = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  Timer? _reconnectTimer;

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }

  void _initializeWebSocket() async {
    if (_isConnecting || _retryCount >= maxRetries) return;

    try {
      _isConnecting = true;
      final wsUrl = ServerConfig.baseUrl.replaceFirst('http', 'ws');
      LoggingService.info('Intentando conectar a WebSocket: $wsUrl/ws');

      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws'));

      _channel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) {
          LoggingService.error('Error en WebSocket', error);
          _handleReconnection();
        },
        onDone: () {
          LoggingService.warning('WebSocket desconectado');
          _handleReconnection();
        },
      );

      LoggingService.success('WebSocket conectado exitosamente');
      _retryCount = 0;
      _refreshContent();
    } catch (e) {
      LoggingService.error('Error al inicializar WebSocket', e);
      _handleReconnection();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      LoggingService.info('Mensaje WebSocket recibido: $data');

      switch (data['event']) {
        case 'content_removed':
          _handleContentRemoved(data['payload']);
          break;
        case 'content_updated':
          _handleContentUpdate(data['payload']);
          break;
      }
    } catch (e) {
      LoggingService.error('Error al procesar mensaje WebSocket', e);
    }
  }

  void _handleContentUpdate(dynamic data) {
    try {
      if (data is List) {
        final updatedContent =
            data.map((item) => ContentModel.fromJson(item)).toList();
        state = AsyncValue.data(updatedContent);
        LoggingService.info(
            'Estado actualizado con ${updatedContent.length} elementos');
        ref.notifyListeners();
      }
    } catch (e) {
      LoggingService.error('Error al procesar actualización de contenido', e);
    }
  }

  void _handleContentRemoved(dynamic data) {
    try {
      if (data is Map<String, dynamic> && data['remainingContent'] != null) {
        final List<dynamic> remainingContent = data['remainingContent'];
        final updatedContent = remainingContent
            .map((item) => ContentModel.fromJson(item))
            .toList();

        state = AsyncValue.data(updatedContent);
        LoggingService.info(
            'Estado actualizado después de eliminación: ${updatedContent.length} elementos');
        ref.notifyListeners();
      }
    } catch (e) {
      LoggingService.error('Error al procesar eliminación de contenido', e);
    }
  }

  void _handleReconnection() {
    if (_retryCount >= maxRetries) {
      LoggingService.warning('Máximo número de intentos alcanzado');
      return;
    }

    _retryCount++;
    _reconnectTimer?.cancel();
    _reconnectTimer =
        Timer(Duration(seconds: ServerConfig.retryDelay ~/ 1000), () {
      if (!_isConnecting) {
        LoggingService.info(
            'Intentando reconectar WebSocket... (Intento $_retryCount)');
        _initializeWebSocket();
      }
    });
  }

  void _refreshContent() async {
    try {
      final contentService = ref.read(contentServiceProvider);
      final contents = await contentService.getContents();
      state = AsyncValue.data(contents);
      LoggingService.info(
          'Contenido actualizado: ${contents.length} elementos');

      // Forzar actualización de la UI
      ref.notifyListeners();
    } catch (e) {
      LoggingService.error('Error al refrescar contenido', e);
    }
  }

  @override
  Future<List<ContentModel>> build() async {
    _initializeWebSocket();
    return loadContents();
  }

  Future<List<ContentModel>> loadContents() async {
    try {
      LoggingService.info('Cargando contenidos...');
      final contentService = ref.read(contentServiceProvider);
      final contents = await contentService.getContents();
      LoggingService.info('${contents.length} contenidos cargados');
      return contents;
    } catch (e) {
      LoggingService.error('Error al cargar contenidos', e);
      throw e;
    }
  }

  Future<void> unpublishContent(String id) async {
    state = const AsyncValue.loading();
    try {
      final contentService = ref.read(contentServiceProvider);
      await contentService.unpublishContent(id);
      // Recargar el contenido después de despublicar
      await loadContents();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
