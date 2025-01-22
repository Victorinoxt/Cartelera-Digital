import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static String serverIP = '192.168.100.13';
  static const int serverPort = 3000;
  
  // URLs base para las APIs
  static String get baseUrl => 'http://$serverIP:$serverPort';
  static String get apiUrl => '$baseUrl/api';
  static String get uploadsUrl => '$baseUrl/uploads';
  static String get socketUrl => baseUrl;

  // Métodos para persistencia
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIP = prefs.getString('server_ip');
    if (savedIP != null && savedIP.isNotEmpty) {
      serverIP = savedIP;
    }
  }
  
  static Future<void> updateServerIP(String newIP) async {
    serverIP = newIP;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', newIP);
  }
}
