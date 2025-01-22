import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageCacheService {
  static final Map<String, Uint8List> _memoryCache = {};
  static const int _maxCacheSize = 50;

  static Future<void> cacheImage(String id, Uint8List bytes) async {
    _memoryCache[id] = bytes;
    
    if (_memoryCache.length > _maxCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/cache/charts/$id.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  static Future<Uint8List?> getCachedImage(String id) async {
    if (_memoryCache.containsKey(id)) {
      return _memoryCache[id];
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/cache/charts/$id.png');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _memoryCache[id] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('Error al leer imagen del caché: $e');
    }
    return null;
  }
}
