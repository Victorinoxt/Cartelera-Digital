import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? error;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.error,
  });
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Simulación de base de datos local
  final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'id': '1',
      'username': 'admin',
      'password': 'Admin123!', // En producción, esto estaría hasheado
      'role': 'ADMIN',
      'isActive': true,
    },
    'operador': {
      'id': '2',
      'username': 'operador',
      'password': 'Operador123!', // En producción, esto estaría hasheado
      'role': 'OPERATOR',
      'isActive': true,
    },
  };

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Método para iniciar sesión
  Future<AuthResponse> login(String username, String password) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));

      // Verificar credenciales
      final userData = _mockUsers[username.toLowerCase()];
      if (userData == null || userData['password'] != password) {
        return AuthResponse(
          success: false,
          error: 'Usuario o contraseña incorrectos',
        );
      }

      if (!userData['isActive']) {
        return AuthResponse(
          success: false,
          error: 'Usuario inactivo',
        );
      }

      // Generar token (en producción, esto vendría del servidor)
      final token = base64Encode(utf8.encode('${username}_${DateTime.now().millisecondsSinceEpoch}'));
      
      // Crear usuario
      final user = User(
        id: userData['id'],
        username: userData['username'],
        role: userData['role'],
        lastLogin: DateTime.now(),
        isActive: userData['isActive'],
      );

      // Guardar datos en SharedPreferences
      await _saveAuthData(token, user);

      return AuthResponse(
        success: true,
        token: token,
        user: user,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  // Método para verificar si hay una sesión activa
  Future<AuthResponse> checkAuth() async {
    try {
      final token = _prefs.getString(_tokenKey);
      final userJson = _prefs.getString(_userKey);

      if (token == null || userJson == null) {
        return AuthResponse(success: false);
      }

      final user = User.fromJson(jsonDecode(userJson));
      
      // Verificar si el token es válido (en producción, esto se haría con el servidor)
      return AuthResponse(
        success: true,
        token: token,
        user: user,
      );
    } catch (e) {
      return AuthResponse(success: false, error: 'Error al verificar autenticación');
    }
  }

  // Método para guardar datos de autenticación
  Future<void> _saveAuthData(String token, User user) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Método para obtener el token actual
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // Método para obtener el usuario actual
  User? getCurrentUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }
}
