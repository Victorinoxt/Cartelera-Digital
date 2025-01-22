import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static String host = dotenv.env['DB_HOST'] ?? 'localhost';
  static int port = int.parse(dotenv.env['DB_PORT'] ?? '3306');
  static String database = dotenv.env['DB_NAME'] ?? 'cartelera_digital';
  static String username = dotenv.env['DB_USERNAME'] ?? 'admin';
  static String password = dotenv.env['DB_PASSWORD'] ?? 'admin';
}
