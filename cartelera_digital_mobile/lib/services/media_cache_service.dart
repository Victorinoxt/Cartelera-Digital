import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MediaCacheService {
  static const String _cacheKey = 'media_cache';
  static const String _lastUpdateKey = 'last_update';

  // Guardar medios en cache
  static Future<void> cacheMedia(List<dynamic> mediaList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mediaJson = json.encode(mediaList);
      await prefs.setString(_cacheKey, mediaJson);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error al guardar en cache: $e');
    }
  }

  // Obtener medios del cache
  static Future<List<Map<String, dynamic>>> getCachedMedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mediaJson = prefs.getString(_cacheKey);
      if (mediaJson != null) {
        final List<dynamic> decoded = json.decode(mediaJson);
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      print('Error al leer cache: $e');
    }
    return [];
  }

  // Limpiar cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
      
      // Limpiar archivos cacheados
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error al limpiar cache: $e');
    }
  }

  // Verificar si el cache está actualizado
  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString(_lastUpdateKey);
      if (lastUpdate == null) return false;

      final lastUpdateTime = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      // Cache válido por 1 hora
      return now.difference(lastUpdateTime).inHours < 1;
    } catch (e) {
      print('Error al verificar cache: $e');
      return false;
    }
  }
} 