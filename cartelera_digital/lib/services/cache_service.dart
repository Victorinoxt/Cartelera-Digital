import 'package:shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String CACHE_KEY_PREFIX = 'chart_cache_';
  static const Duration DEFAULT_EXPIRATION = Duration(minutes: 30);

  CacheService(this._prefs);

  Future<void> saveData(String key, dynamic data, {Duration? expiration}) async {
    final expirationTime = DateTime.now().add(expiration ?? DEFAULT_EXPIRATION);
    await _prefs.setString('${CACHE_KEY_PREFIX}$key', jsonEncode({
      'data': data,
      'expiration': expirationTime.toIso8601String(),
    }));
  }

  Future<T?> getData<T>(String key) async {
    final data = _prefs.getString('${CACHE_KEY_PREFIX}$key');
    if (data == null) return null;

    final cached = jsonDecode(data);
    final expiration = DateTime.parse(cached['expiration']);
    
    if (DateTime.now().isAfter(expiration)) {
      await _prefs.remove('${CACHE_KEY_PREFIX}$key');
      return null;
    }

    return cached['data'] as T;
  }
}