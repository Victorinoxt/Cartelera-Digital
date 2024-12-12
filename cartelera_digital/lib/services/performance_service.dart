class PerformanceService {
  static final Map<String, List<Duration>> _metrics = {};

  static void startMetric(String name) {
    if (!_metrics.containsKey(name)) {
      _metrics[name] = [];
    }
    _metrics[name]!.add(Duration.zero);
  }

  static void endMetric(String name) {
    if (_metrics.containsKey(name)) {
      final start = _metrics[name]!.last;
      final duration = DateTime.now().difference(DateTime.now().subtract(start));
      _metrics[name]![_metrics[name]!.length - 1] = duration;
    }
  }

  static Map<String, Duration> getAverageMetrics() {
    return Map.fromEntries(
      _metrics.entries.map((entry) {
        final avg = entry.value.reduce((a, b) => a + b) ~/ entry.value.length;
        return MapEntry(entry.value, avg);
      }),
    );
  }
}