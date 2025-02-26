import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logging_service.dart';
import 'env_config.dart';

class ServerConfig {
  static void _log(String message) {
    print('ServerConfig: $message');
  }

  // URL base para el servidor
  static String get baseUrl {
    final url =
        'http://${EnvConfig.serverIp}:${EnvConfig.serverPort.toString()}';
    _log('baseUrl: $url');
    return url;
  }

  // URL base para la API
  static String get apiUrl {
    final url = '$baseUrl/api';
    _log('apiUrl: $url');
    return url;
  }

  // URL para WebSocket
  static String get wsUrl {
    final url =
        'ws://${EnvConfig.serverIp}:${EnvConfig.serverPort.toString()}/ws';
    _log('wsUrl: $url');
    return url;
  }

  // URLs específicas
  static String get imagesUrl {
    final url = '$apiUrl/images';
    _log('imagesUrl: $url');
    return url;
  }

  static String get uploadUrl {
    final url = '$apiUrl/upload';
    _log('uploadUrl: $url');
    return url;
  }

  static String get uploadStatusUrl {
    final url = '$apiUrl/upload-status';
    _log('uploadStatusUrl: $url');
    return url;
  }

  static String get uploadsUrl {
    final url = '$baseUrl/uploads';
    _log('uploadsUrl: $url');
    return url;
  }

  // URL para imágenes
  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final url = '$uploadsUrl/$imagePath';
    _log('getImageUrl: $url');
    return url;
  }

  // Verificar conexión con el servidor
  static Future<bool> checkServerConnection() async {
    try {
      final url = '$apiUrl/health';
      _log('checkServerConnection: $url');
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      _log('Error al verificar conexión con el servidor: $e');
      return false;
    }
  }

  // Obtener estado del servidor
  static Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final url = '$apiUrl/status';
      _log('getServerStatus: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw HttpException('Error al obtener estado del servidor');
    } catch (e) {
      _log('Error al obtener estado del servidor: $e');
      rethrow;
    }
  }
}
