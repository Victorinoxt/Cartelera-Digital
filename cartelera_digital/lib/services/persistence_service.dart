import 'package:shared_preferences.dart';
import '../models/custom_chart.dart';

class PersistenceService {
  final SharedPreferences _prefs;
  static const String CHARTS_KEY = 'custom_charts';

  PersistenceService(this._prefs);

  Future<void> saveCustomCharts(List<CustomChart> charts) async {
    final data = charts.map((c) => c.toJson()).toList();
    await _prefs.setString(CHARTS_KEY, jsonEncode(data));
  }

  Future<List<CustomChart>> loadCustomCharts() async {
    final data = _prefs.getString(CHARTS_KEY);
    if (data == null) return [];
    
    final List<dynamic> jsonData = jsonDecode(data);
    return jsonData.map((j) => CustomChart.fromJson(j)).toList();
  }
}