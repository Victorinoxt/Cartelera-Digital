import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggingService {
  static final List<LogEntry> _logs = [];
  static LogLevel _minimumLevel = LogLevel.info;

  static void setLogLevel(LogLevel level) {
    _minimumLevel = level;
  }

  static void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (level.index < _minimumLevel.index) return;

    final timestamp = DateTime.now();
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: timestamp,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    
    if (kDebugMode) {
      final prefix = '[${level.toString().toUpperCase()}]';
      print('$prefix ${timestamp.toIso8601String()}: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  static void info(String message) {
    _log(LogLevel.info, message);
  }

  static void warning(String message, [dynamic error]) {
    _log(LogLevel.warning, message, error);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static List<LogEntry> getLogs() => List.unmodifiable(_logs);
  
  static void clearLogs() => _logs.clear();
  
  static List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }
}

class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });
}