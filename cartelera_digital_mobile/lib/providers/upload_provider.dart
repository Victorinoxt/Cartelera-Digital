import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/upload_service.dart';
import 'cache_provider.dart';
import '../config/server_config.dart';
import 'shared_preferences_provider.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(
    baseUrl: ServerConfig.baseUrl, // Usar la configuración centralizada
    prefs: ref
        .read(sharedPreferencesProvider), // Asumiendo que existe este provider
  );
});
