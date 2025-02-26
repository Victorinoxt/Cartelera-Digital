import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../services/logging_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerConfig {
  static const String _serverUrlKey = 'server_url';

  // URLs por entorno
  static const String _webDevUrl = 'http://192.168.0.3:4000';
  static const String _mobileDevUrl = 'http://192.168.0.3:4000';
  static const String _prodUrl = 'http://192.168.0.3:4000';

  static String get _defaultUrl {
    if (kIsWeb) {
      return _webDevUrl;
    } else if (kDebugMode) {
      return _mobileDevUrl;
    } else {
      return _prodUrl;
    }
  }

  static String _baseUrl = _defaultUrl;

  // Getter para la URL base
  static String get baseUrl => _baseUrl;

  // Getter para la URL de la API
  static String get apiUrl => '$_baseUrl/api';

  // URLs específicas para contenido
  static String get imagesUrl => '$apiUrl/images';
  static String get uploadUrl => '$apiUrl/upload';
  static String get unpublishUrl => '$apiUrl/mobile/unpublish';
  static String get healthUrl => '$apiUrl/health';

  // URL para imágenes móviles
  static String get mobileImagesUrl => '$_baseUrl/mobile/images';

  // URL para uploads
  static String get uploadsUrl => '$baseUrl/uploads';

  // Método para obtener la URL completa de una imagen
  static String getImageUrl(String path) {
    if (path.isEmpty) return '';

    // Si la URL ya es completa, verificar si necesita transformación
    if (path.startsWith('http')) {
      final uri = Uri.parse(path);
      // Reemplazar localhost por 127.0.0.1
      String host = uri.host == 'localhost' ? '127.0.0.1' : uri.host;

      // Si la URL ya está en el formato correcto, solo actualizar el host
      if (uri.path.contains('/mobile/images/')) {
        return uri.replace(host: host).toString();
      }

      // Si no, extraer el nombre del archivo y construir la nueva URL
      final filename = uri.pathSegments.last;
      // Verificar si el nombre del archivo ya incluye la ruta /mobile/images
      if (filename.contains('mobile/images/')) {
        return '$baseUrl/$filename';
      }
      return '$mobileImagesUrl/$filename';
    }

    // Si es una ruta relativa, asegurarse que no empiece con /
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    // Verificar si la ruta ya incluye /mobile/images
    if (cleanPath.startsWith('mobile/images/')) {
      return '$baseUrl/$cleanPath';
    }
    // Codificar el nombre del archivo para manejar espacios y caracteres especiales
    final encodedPath = Uri.encodeComponent(cleanPath);
    return '$mobileImagesUrl/$encodedPath';
  }

  // Inicializar la configuración
  static Future<void> initialize() async {
    try {
      await dotenv.load();
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(_serverUrlKey) ?? _defaultUrl;
      LoggingService.info('Inicializando servidor en: $_baseUrl');

      bool isConnected = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!isConnected && retryCount < maxRetries) {
        try {
          isConnected = await testConnection();
          if (isConnected) {
            LoggingService.info('Conexión exitosa al servidor');
            break;
          }
        } catch (e) {
          LoggingService.warning('Intento ${retryCount + 1} fallido: $e');
        }
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (!isConnected) {
        LoggingService.error('No se pudo conectar al servidor: $_baseUrl');
        throw Exception('No se pudo establecer conexión con el servidor');
      }
    } catch (e) {
      LoggingService.error(
          'Error al inicializar configuración del servidor', e);
      rethrow;
    }
  }

  // Validar conexión con el servidor
  static Future<bool> testConnection() async {
    try {
      final healthUrl = '$apiUrl/health';
      LoggingService.info('Probando conexión con: $healthUrl');

      if (kIsWeb) {
        try {
          final request = html.HttpRequest();
          final completer = Completer<bool>();

          request.open('GET', healthUrl);
          request.setRequestHeader('Accept', 'application/json');
          request.setRequestHeader('Content-Type', 'application/json');

          request.onLoad.listen((event) {
            if (request.status == 200) {
              LoggingService.success('Conexión exitosa con el servidor (Web)');
              completer.complete(true);
            } else {
              LoggingService.error(
                  'Error al conectar con el servidor (Web): ${request.status}');
              completer.complete(false);
            }
          });

          request.onError.listen((event) {
            LoggingService.error('Error al probar conexión (Web)', event);
            completer.complete(false);
          });

          request.send();
          return await completer.future;
        } catch (e) {
          LoggingService.error('Error al probar conexión (Web)', e);
          return false;
        }
      } else {
        final response = await http.get(
          Uri.parse(healthUrl),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () =>
              throw TimeoutException('La conexión tardó demasiado'),
        );

        if (response.statusCode == 200) {
          LoggingService.success('Conexión exitosa con el servidor');
          return true;
        } else {
          LoggingService.error(
              'Error al conectar con el servidor: ${response.statusCode}');
          return false;
        }
      }
    } catch (e) {
      LoggingService.error('Error al probar conexión', e);
      return false;
    }
  }

  // Actualizar la URL del servidor
  static Future<void> updateServerUrl(String newUrl) async {
    try {
      final uri = Uri.parse(newUrl);
      if (!uri.isAbsolute) {
        throw FormatException('La URL debe ser absoluta');
      }

      // Validar que la nueva URL responde
      final response = await http.get(Uri.parse('$newUrl/api/health'));
      if (response.statusCode != 200) {
        throw Exception('El servidor no responde en la nueva URL');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_serverUrlKey, newUrl);
      _baseUrl = newUrl;
      LoggingService.info('URL del servidor actualizada a: $newUrl');
    } catch (e) {
      LoggingService.error('Error al actualizar URL del servidor', e);
      throw Exception('Error al actualizar URL: $e');
    }
  }

  // Restablecer a valores predeterminados
  static Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_serverUrlKey);
      _baseUrl = _defaultUrl;
      LoggingService.info(
          'Configuración restablecida a valores predeterminados: $_defaultUrl');
    } catch (e) {
      LoggingService.error('Error al restablecer configuración', e);
      rethrow;
    }
  }

  static String get monitoringUrl => '$apiUrl/monitoring';
  static String get mobileUrl => '$apiUrl/mobile';

  static const int autoPlayDuration = 10; // segundos
  static const int transitionDuration = 300; // milisegundos

  // WebSocket Configuration
  static String get wsUrl {
    final serverUrl = baseUrl.replaceFirst('http', 'ws');
    return serverUrl;
  }

  static String getWebSocketUrl(String path) {
    return '$wsUrl$path';
  }

  // No usamos /ws porque el servidor usa socket.io
  static String get wsEndpoint => wsUrl;

  // Endpoints
  static String get healthEndpoint => '$apiUrl/health';
  static String get contentsEndpoint => '$apiUrl/mobile/images';
  static String get uploadEndpoint => '$apiUrl/upload';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos

  // Reintentos
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 segundo

  static String get serverAddress => dotenv.env['SERVER_IP'] ?? '192.168.0.3';
  static String get socketUrl => 'http://$serverAddress:4000';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['API_TOKEN'] ?? ''}'
      };
}
