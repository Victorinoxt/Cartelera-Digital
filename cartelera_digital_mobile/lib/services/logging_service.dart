import 'package:flutter/foundation.dart';

enum LOGLEVEL { INFO, WARNING, ERROR }

class LoggingService {
  static void info(String message) {
    _log(LOGLEVEL.INFO, message);
  }

  static void warning(String message) {
    _log(LOGLEVEL.WARNING, message);
  }

  static void error(String message, [dynamic error]) {
    if (error != null) {
      _log(LOGLEVEL.ERROR, '$message: $error');
    } else {
      _log(LOGLEVEL.ERROR, message);
    }
  }

  static void _log(LOGLEVEL level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$level] $timestamp: $message');
  }
} 