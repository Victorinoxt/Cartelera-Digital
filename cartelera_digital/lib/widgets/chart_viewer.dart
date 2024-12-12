class ChartViewer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartStateProvider);
    final isLoading = ref.watch(appStateProvider).isLoading;

    return Stack(
      children: [
        if (chartState.charts.isEmpty)
          Center(
            child: Text('No hay gráficos disponibles'),
          )
        else
          ListView.builder(
            itemCount: chartState.charts.length,
            itemBuilder: (context, index) {
              final chart = chartState.charts[index];
              final isVisible = chartState.chartVisibility[chart.id] ?? true;

              if (!isVisible) return SizedBox.shrink();

              return ChartCard(
                chart: chart,
                isSelected: chart.id == chartState.selectedChartId,
                onTap: () => ref.read(chartStateProvider.notifier).selectChart(chart.id),
              );
            },
          ),
        if (isLoading)
          Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
