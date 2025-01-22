import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

class EnvConfig {
  // Server Configuration
  static String get serverIp => dotenv.env['SERVER_IP'] ?? 'localhost';
  static int get serverPort => int.parse(dotenv.env['SERVER_PORT'] ?? '3000');
  static String get serverUrl => dotenv.env['SERVER_URL'] ?? 'http://$serverIp:$serverPort';

  // API URLs
  static String get localApiUrl => dotenv.env['LOCAL_API_URL'] ?? 'http://localhost:3000/api';
  static String get externalApiUrl => dotenv.env['EXTERNAL_API_URL'] ?? 'http://192.168.0.3:3003/api';
  static String get monitoringApiUrl => dotenv.env['MONITORING_API_URL'] ?? 'http://192.168.0.4:3000/api';
  
  // External API Endpoints
  static String get planificadorEndpoint => '/planificador/graph_1';
  static String get rendimientoEndpoint => '/planificador/rendimiento';
  
  // WebSocket Configuration
  static bool get wsEnabled => dotenv.env['WS_ENABLED']?.toLowerCase() == 'true';
  static String get wsPath => dotenv.env['WS_PATH'] ?? '/ws';
  static int get wsReconnectInterval => int.parse(dotenv.env['WS_RECONNECT_INTERVAL'] ?? '5000');
  
  // URLs completas
  static String get planificadorUrl => '$externalApiUrl$planificadorEndpoint';
  static String get rendimientoUrl => '$externalApiUrl$rendimientoEndpoint';
  static String get wsUrl => 'ws://$serverIp:$serverPort$wsPath';
  
  // Cache y Debug
  static int get cacheDurationMinutes => int.parse(dotenv.env['CACHE_DURATION_MINUTES'] ?? '5');
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get enableImageCache => dotenv.env['ENABLE_IMAGE_CACHE']?.toLowerCase() == 'true';
  static int get imageCacheSize => int.parse(dotenv.env['IMAGE_CACHE_SIZE'] ?? '100');
  
  // Security Configuration
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'default-secret-key';
  static String get jwtExpiration => dotenv.env['JWT_EXPIRATION'] ?? '24h';
  static List<String> get corsOrigins => 
      (dotenv.env['CORS_ORIGINS'] ?? 'http://localhost:3000').split(',');
  
  // Inicialización
  static Future<void> init() async {
    try {
      // Primero intentar cargar desde el sistema de archivos
      if (await File('.env').exists()) {
        await dotenv.load(fileName: '.env');
        print('Archivo .env cargado desde el sistema de archivos');
        return;
      }

      // Si no existe en el sistema de archivos, intentar cargar desde los assets
      try {
        final envString = await rootBundle.loadString('.env');
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp.env');
        await tempFile.writeAsString(envString);
        await dotenv.load(fileName: tempFile.path);
        await tempFile.delete(); // Limpiamos el archivo temporal
        print('Archivo .env cargado desde los assets');
      } catch (assetError) {
        print('WARNING: No se pudo cargar el archivo .env desde los assets: $assetError');
        print('Usando valores por defecto');
      }
    } catch (e) {
      print('WARNING: Error al cargar el archivo .env: $e');
      print('Usando valores por defecto');
    }
  }
}
