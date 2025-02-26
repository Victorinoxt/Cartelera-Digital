import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../models/content_model.dart';
import '../config/server_config.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'logging_service.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class ContentService {
  static const String _cacheKey = 'cached_contents';
  static const String _metricsKey = 'content_metrics';
  static const String _cacheDir = 'content_cache';

  final Duration _cacheExpiration;
  final Duration _syncInterval;
  final Duration _cleanupInterval;
  final int _maxRetries;
  final int _maxCacheSize;

  Timer? _syncTimer;
  Timer? _cleanupTimer;
  bool _isSyncing = false;
  bool _isDisposed = false;

  final String baseUrl;
  final Duration timeout;

  ContentService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  })  : _cacheExpiration = const Duration(hours: 1),
        _syncInterval = const Duration(minutes: 5),
        _cleanupInterval = const Duration(hours: 24),
        _maxRetries = 3,
        _maxCacheSize = 100 * 1024 * 1024 {
    _startPeriodicSync();
    _startPeriodicCleanup();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    if (!_isDisposed) {
      _syncTimer = Timer.periodic(_syncInterval, (_) {
        if (!_isDisposed) {
          _syncContents();
        }
      });
    }
  }

  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    if (!_isDisposed) {
      _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
        if (!_isDisposed) {
          _cleanupCache();
        }
      });
    }
  }

  Future<void> _syncContents() async {
    if (_isSyncing || _isDisposed) return;
    _isSyncing = true;

    try {
      final contents = await getContents();
      if (!_isDisposed) {
        await _preloadContent(contents);
      }
    } catch (e) {
      print('Error en sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<ContentModel>> getContents() async {
    try {
      LoggingService.info(
          'Solicitando contenidos a: $baseUrl/api/mobile/images');
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/images'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        LoggingService.info('Datos recibidos del servidor: $data');

        final contents = data.map((item) {
          LoggingService.info('Procesando item: $item');
          try {
            return ContentModel.fromJson(item);
          } catch (e) {
            LoggingService.error('Error al procesar item: $e');
            rethrow;
          }
        }).toList();

        LoggingService.info('Contenidos cargados: ${contents.length}');
        return contents.where((content) => content.status == 'active').toList();
      } else {
        LoggingService.error('Error HTTP: ${response.statusCode}');
        LoggingService.error('Respuesta: ${response.body}');
        throw Exception('Error al obtener contenidos: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al cargar imágenes: $e');
      rethrow;
    }
  }

  Future<void> updateContentStatus(String id, String status) async {
    try {
      LoggingService.info('Actualizando estado del contenido $id a $status');
      final response = await http.patch(
        Uri.parse('${ServerConfig.apiUrl}/contents/$id'),
        body: json.encode({'status': status}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
      LoggingService.info('Estado actualizado exitosamente');
    } catch (e) {
      LoggingService.error('Error en updateContentStatus', e);
      throw Exception('Error al actualizar estado: $e');
    }
  }

  Future<void> _preloadContent(List<ContentModel> contents) async {
    for (var content in contents) {
      try {
        if (content.type == ContentType.image) {
          await CachedNetworkImage.evictFromCache(content.imageUrl);

          await DefaultCacheManager().downloadFile(
            content.imageUrl,
            key: content.id,
          );
        } else if (content.type == ContentType.video) {
          final controller = VideoPlayerController.network(content.imageUrl);
          await controller.initialize();
          await controller.dispose();
        }
      } catch (e) {
        print('Error en precarga de ${content.id}: $e');
      }
    }
  }

  Future<void> logContentView(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString(_metricsKey) ?? '{}';
      final metrics = json.decode(metricsJson) as Map<String, dynamic>;

      if (!metrics.containsKey(contentId)) {
        metrics[contentId] = {
          'views': 0,
          'totalDuration': 0,
          'lastViewed': null,
        };
      }

      final contentMetrics = metrics[contentId] as Map<String, dynamic>;
      contentMetrics['views'] = (contentMetrics['views'] as int) + 1;
      contentMetrics['lastViewed'] = DateTime.now().toIso8601String();

      await prefs.setString(_metricsKey, json.encode(metrics));

      try {
        await http.post(
          Uri.parse('${ServerConfig.apiUrl}/metrics'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'contentId': contentId,
            'timestamp': DateTime.now().toIso8601String(),
            'metrics': contentMetrics,
          }),
        );
      } catch (e) {
        print('Error al enviar métricas: $e');
      }
    } catch (e) {
      print('Error al guardar métricas: $e');
    }
  }

  Future<Map<String, dynamic>> getContentMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString(_metricsKey) ?? '{}';
      return json.decode(metricsJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error al obtener métricas: $e');
      return {};
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_metricsKey);
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print('Error al limpiar datos: $e');
    }
  }

  void dispose() {
    _isDisposed = true;
    _syncTimer?.cancel();
    _cleanupTimer?.cancel();
    _syncTimer = null;
    _cleanupTimer = null;
  }

  Future<void> _cacheContents(List<ContentModel> contents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = {
        'timestamp': DateTime.now().toIso8601String(),
        'contents': contents.map((c) => c.toJson()).toList(),
      };

      final jsonString = json.encode(cache);
      final List<int> jsonBytes = utf8.encode(jsonString);
      final List<int> compressed = gzip.encode(jsonBytes);

      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/contents.gz');
      await file.writeAsBytes(compressed);

      await prefs.setString(_cacheKey, file.path);
      await _updateCacheSize(compressed.length);
    } catch (e) {
      print('Error al guardar caché: $e');
    }
  }

  Future<List<ContentModel>> _getCachedContents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachePath = prefs.getString(_cacheKey);

      if (cachePath != null) {
        final file = File(cachePath);
        if (await file.exists()) {
          final compressed = await file.readAsBytes();
          final decompressed = gzip.decode(compressed);
          final jsonString = utf8.decode(decompressed);
          final cache = json.decode(jsonString);

          final cacheTimestamp = DateTime.parse(cache['timestamp']);
          if (DateTime.now().difference(cacheTimestamp) < _cacheExpiration) {
            final List<dynamic> contents = cache['contents'];
            return contents
                .map((json) => ContentModel.fromJson(json))
                .where((content) => content.isActive)
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error al recuperar caché: $e');
      return [];
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> _updateCacheSize(int newBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final currentSize = prefs.getInt('cache_size') ?? 0;
    await prefs.setInt('cache_size', currentSize + newBytes);
  }

  Future<void> _cleanupCache() async {
    if (_isDisposed) return;
    try {
      final dir = await _getCacheDirectory();
      final prefs = await SharedPreferences.getInstance();

      if (_isDisposed) return;

      final files = dir.listSync(recursive: false, followLinks: false);

      files.sort((a, b) {
        final aTime = (a as File).lastModifiedSync();
        final bTime = (b as File).lastModifiedSync();
        return aTime.compareTo(bTime);
      });

      int totalSize = prefs.getInt('cache_size') ?? 0;

      for (var entity in files) {
        if (_isDisposed) return;
        if (entity is File) {
          try {
            final stat = entity.statSync();
            final age = DateTime.now().difference(stat.modified);
            final size = stat.size;

            if (age > _cacheExpiration || totalSize > _maxCacheSize) {
              await entity.delete();
              totalSize -= size;
            }
          } catch (e) {
            print('Error al procesar archivo: $e');
            continue;
          }
        }
      }

      if (!_isDisposed) {
        await prefs.setInt('cache_size', totalSize);
        await DefaultCacheManager().emptyCache();
      }
    } catch (e) {
      print('Error en limpieza de caché: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      LoggingService.info('Probando conexión con el servidor...');
      final response = await http.get(
        Uri.parse('${ServerConfig.apiUrl}/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('La conexión tardó demasiado');
        },
      );

      final isConnected = response.statusCode == 200;
      if (isConnected) {
        LoggingService.success('Conexión exitosa con el servidor');
      } else {
        LoggingService.error(
            'Error al conectar con el servidor: ${response.statusCode}');
      }
      return isConnected;
    } catch (e) {
      LoggingService.error('Error al probar conexión', e);
      return false;
    }
  }

  Future<void> unpublishContent(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/images/$id/unpublish'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception(
            'Error al despublicar contenido: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al despublicar contenido: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContentStatus() async {
    try {
      LoggingService.info('Obteniendo estado del contenido');

      final response = await http.get(
        Uri.parse('${ServerConfig.apiUrl}/mobile/status'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggingService.success('Estado del contenido obtenido exitosamente');
        return data;
      } else {
        throw Exception('Error al obtener estado: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error al obtener estado del contenido', e);
      throw Exception('Error al obtener estado del contenido: $e');
    }
  }
}
