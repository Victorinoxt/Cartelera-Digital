import 'env_config.dart';

// Planificador API endpoints
class PlanificadorEndpoints {
  static String get baseUrl => '${ApiConfig.apiUrl}/planificador';
  static String get solicitudes => '$baseUrl/solicitudes';
  static String get rendimiento => '$baseUrl/rendimiento';
  
  static String getSolicitudById(String id) => '$solicitudes/$id';
  static String getRendimientoByFecha(DateTime fecha) => 
      '$rendimiento?fecha=${fecha.toIso8601String()}';
}

// Monitoreo API endpoints
class MonitoreoEndpoints {
  static String get baseUrl => '${ApiConfig.apiUrl}/monitoring';
  static String get images => '$baseUrl/images';
  static String get status => '$baseUrl/status';
  static String get upload => '$baseUrl/upload';
  
  static String getImageById(String id) => '$images/$id';
  static String getStatusById(String id) => '$status/$id';
}

// Media API endpoints
class MediaEndpoints {
  static String get baseUrl => '${ApiConfig.apiUrl}/media';
  static String get images => '$baseUrl/images';
  static String get upload => '$baseUrl/upload';
  static String get status => '$baseUrl/status';
  
  static String getImageById(String id) => '$images/$id';
  static String getImagesByType(String type) => '$images?type=$type';
}

// Auth API endpoints
class AuthEndpoints {
  static String get baseUrl => '${ApiConfig.apiUrl}/auth';
  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get refresh => '$baseUrl/refresh';
  static String get verify => '$baseUrl/verify';
}

// Main API configuration
class ApiConfig {
  // Base URLs
  static String get baseUrl => EnvConfig.serverUrl;
  static String get apiUrl => '$baseUrl/api';
  static String get wsUrl => 'ws://${EnvConfig.serverIp}:${EnvConfig.serverPort}/ws';

  // Health Check
  static String get health => '$apiUrl/health';

  // API Endpoints
  static final planificador = PlanificadorEndpoints();
  // Para obtener imágenes de monitoreo
  static final monitoreo = MonitoreoEndpoints();
  // Para obtener una imagen específica
  static final media = MediaEndpoints();
  // Autenticación
  static final auth = AuthEndpoints();
}
