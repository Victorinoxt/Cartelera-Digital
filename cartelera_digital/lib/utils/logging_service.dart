class LoggingService {
  static void info(String message) {
    print('[INFO] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(String message, [String? details]) {
    print('[ERROR] $message');
    if (details != null) {
      print('[ERROR DETAILS] $details');
    }
  }
}
