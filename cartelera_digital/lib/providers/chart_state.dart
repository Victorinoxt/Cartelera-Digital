final chartStateProvider = StateNotifierProvider<ChartStateNotifier, ChartState>((ref) {
  return ChartStateNotifier();
});

class ChartState {
  final List<ChartData> charts;
  final Map<String, bool> chartVisibility;
  final String? selectedChartId;
  final ChartTheme chartTheme;

  ChartState({
    this.charts = const [],
    this.chartVisibility = const {},
    this.selectedChartId,
    this.chartTheme = const ChartTheme(),
  });

  ChartState copyWith({
    List<ChartData>? charts,
    Map<String, bool>? chartVisibility,
    String? selectedChartId,
    ChartTheme? chartTheme,
  }) {
    return ChartState(
      charts: charts ?? this.charts,
      chartVisibility: chartVisibility ?? this.chartVisibility,
      selectedChartId: selectedChartId ?? this.selectedChartId,
      chartTheme: chartTheme ?? this.chartTheme,
    );
  }
}

class ChartStateNotifier extends StateNotifier<ChartState> {
  ChartStateNotifier() : super(ChartState());

  void updateChart(ChartData chart) {
    final updatedCharts = state.charts.map((c) => 
      c.id == chart.id ? chart : c
    ).toList();
    
    state = state.copyWith(charts: updatedCharts);
  }

  void toggleChartVisibility(String chartId) {
    final visibility = {...state.chartVisibility};
    visibility[chartId] = !(visibility[chartId] ?? true);
    state = state.copyWith(chartVisibility: visibility);
  }

  void selectChart(String? chartId) {
    state = state.copyWith(selectedChartId: chartId);
  }
}
