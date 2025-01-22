import '../models/chart_data.dart';

class AnalyticsService {
  Map<String, dynamic> analyzeData(List<ChartData> data) {
    if (data.isEmpty) return {};

    final values = data.map((d) => d.value).toList();
    final dates = data.map((d) => d.date).toList();

    return {
      'min': values.reduce((a, b) => a < b ? a : b),
      'max': values.reduce((a, b) => a > b ? a : b),
      'average': values.reduce((a, b) => a + b) / values.length,
      'dateRange': {
        'start': dates.reduce((a, b) => a.isBefore(b) ? a : b),
        'end': dates.reduce((a, b) => a.isAfter(b) ? a : b),
      },
      'trend': _calculateTrend(values),
    };
  }

  String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'neutral';
    
    double sum = 0;
    for (int i = 1; i < values.length; i++) {
      sum += values[i] - values[i - 1];
    }
    
    final avgChange = sum / (values.length - 1);
    if (avgChange > 0.05) return 'up';
    if (avgChange < -0.05) return 'down';
    return 'neutral';
  }
}