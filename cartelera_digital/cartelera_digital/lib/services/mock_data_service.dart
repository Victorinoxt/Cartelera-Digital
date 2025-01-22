class MockDataService {
  Future<List<Map<String, dynamic>>> getChartData() async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {'category': 'Ventas', 'value': 1500, 'date': DateTime.now()},
      {'category': 'Producción', 'value': 2200, 'date': DateTime.now()},
      {'category': 'Calidad', 'value': 1800, 'date': DateTime.now()},
    ];
  }
} 