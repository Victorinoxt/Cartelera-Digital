import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/server_config.dart';
import '../services/media_cache_service.dart';
import '../widgets/media_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({super.key});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _mediaList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadCachedMedia(); // Primero cargar del cache
    await _initWebSocket(); // Luego inicializar el WebSocket
    await _loadImagesFromServer(); // Finalmente cargar del servidor
  }

  Future<void> _initWebSocket() async {
    try {
      final wsUrl = Uri.parse('${ServerConfig.wsUrl}/ws');
      print('Conectando a WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(wsUrl);

      // Generar un ID único para el dispositivo si no existe
      final deviceId = await _getDeviceId();

      _channel!.stream.listen(
        (message) {
          print('Mensaje WebSocket recibido: $message');
          final data = json.decode(message);
          
          if (data['event'] == 'device_config') {
            print('Configuración recibida del servidor: ${data['payload']}');
            // Guardar la configuración recibida
            _saveDeviceConfig(data['payload']);
          } else if (data['event'] == 'media-update') {
            _updateMediaList(data['payload']);
            MediaCacheService.cacheMedia(data['payload']);
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          setState(() => _error = error.toString());
        },
        onDone: () {
          print('Conexión WebSocket cerrada');
          _reconnectWebSocket();
        },
      );

      // Registrarse como dispositivo móvil con ID consistente
      _channel!.sink.add(json.encode({
        'event': 'mobile_connect',
        'payload': {
          'type': 'mobile',
          'id': deviceId,
        }
      }));

    } catch (e) {
      print('Error al inicializar WebSocket: $e');
      setState(() => _error = e.toString());
      _reconnectWebSocket();
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> _saveDeviceConfig(Map<String, dynamic> config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_config', json.encode(config));
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _initWebSocket();
      }
    });
  }

  Future<void> _loadImagesFromServer() async {
    try {
      setState(() => _isLoading = true);
      
      final response = await http.get(
        Uri.parse('${ServerConfig.baseUrl}/api/mobile/images'),
        headers: ServerConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Imágenes cargadas del servidor: ${data.length}');
        _updateMediaList(data);
        await MediaCacheService.cacheMedia(data);
      } else {
        print('Error al cargar imágenes: ${response.statusCode}');
        throw Exception('Error al cargar imágenes del servidor');
      }
    } catch (e) {
      print('Error al cargar imágenes: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMediaList(dynamic data) {
    if (data is List) {
      setState(() {
        _mediaList = List<Map<String, dynamic>>.from(data);
        _error = null;
      });
    }
  }

  Future<void> _loadCachedMedia() async {
    final cached = await MediaCacheService.getCachedMedia();
    if (cached.isNotEmpty) {
      setState(() => _mediaList = cached);
    }
  }

  Future<void> _refreshContent() async {
    await _loadImagesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _mediaList.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _mediaList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshContent,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: _mediaList.isEmpty
          ? const Center(child: Text('No hay contenido disponible'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 16/9,
              ),
              itemCount: _mediaList.length,
              itemBuilder: (context, index) {
                final media = _mediaList[index];
                return MediaItemWidget(media: media);
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
} 