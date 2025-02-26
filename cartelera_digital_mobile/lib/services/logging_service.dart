import 'package:flutter/foundation.dart';

class LoggingService {
  static void info(String message) {
    print('📘 INFO: $message');
  }

  static void warning(String message) {
    print('⚠️ WARNING: $message');
  }

  static void error(String message, [dynamic error]) {
    print('❌ ERROR: $message');
    if (error != null) {
      print('Stack trace:\n$error');
    }
  }

  static void success(String message) {
    print('✅ SUCCESS: $message');
  }
}
