final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppState {
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;
  final List<ChartData> charts;
  final Map<String, dynamic> configurations;

  AppState({
    this.isLoading = false,
    this.error,
    this.themeMode = ThemeMode.light,
    this.charts = const [],
    this.configurations = const {},
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
    List<ChartData>? charts,
    Map<String, dynamic>? configurations,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      themeMode: themeMode ?? this.themeMode,
      charts: charts ?? this.charts,
      configurations: configurations ?? this.configurations,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, error: null);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void updateCharts(List<ChartData> charts) {
    state = state.copyWith(charts: charts);
  }

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light,
    );
  }
}
