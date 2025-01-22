final selectedChartProvider = StateProvider<int>((ref) => 0);

final chartListProvider = StateNotifierProvider<ChartListNotifier, List<Widget>>((ref) {
  return ChartListNotifier();
});

class ChartListNotifier extends StateNotifier<List<Widget>> {
  ChartListNotifier() : super([]);

  void setCharts(List<Widget> charts) {
    state = charts;
  }

  Widget? getChart(int index) {
    if (index >= 0 && index < state.length) {
      return state[index];
    }
    return null;
  }
}