import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return DefaultCacheManager();
}); 