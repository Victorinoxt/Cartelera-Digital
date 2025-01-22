import 'package:mysql1/mysql1.dart';
import '../config/database_config.dart';

class MySqlService {
  static final MySqlService _instance = MySqlService._internal();
  factory MySqlService() => _instance;
  MySqlService._internal();

  Future<MySqlConnection> _getConnection() async {
    final settings = ConnectionSettings(
      host: DatabaseConfig.host,
      port: DatabaseConfig.port,
      user: DatabaseConfig.username,
      password: DatabaseConfig.password,
      db: DatabaseConfig.database,
    );
    return await MySqlConnection.connect(settings);
  }

  // Por ahora, usaremos datos ficticios
  Future<List<Map<String, dynamic>>> obtenerDatosGraficos() async {
    try {
      // Simulamos una consulta a la base de datos
      return [
        {'mes': 'Enero', 'valor': 35},
        {'mes': 'Febrero', 'valor': 28},
        {'mes': 'Marzo', 'valor': 42},
        {'mes': 'Abril', 'valor': 30},
        {'mes': 'Mayo', 'valor': 25},
      ];
      
      // Cuando tengas la base de datos real, usarías algo así:
      /*
      final conn = await _getConnection();
      var results = await conn.query('SELECT mes, valor FROM datos_graficos');
      await conn.close();
      return results.map((r) => {
        'mes': r['mes'],
        'valor': r['valor'],
      }).toList();
      */
    } catch (e) {
      print('Error al obtener datos: $e');
      return [];
    }
  }
}
