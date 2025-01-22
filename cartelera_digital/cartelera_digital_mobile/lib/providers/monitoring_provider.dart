import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/api_service.dart';

class MonitoringNotifier extends StateNotifier<AsyncValue<List<ContentModel>>> {
  final ApiService _apiService;

  MonitoringNotifier(this._apiService) : super(const AsyncValue.loading()) {
    refreshMonitoringData();
  }

  Future<void> refreshMonitoringData() async {
    try {
      state = const AsyncValue.loading();
      final monitoringImages = await _apiService.getMonitoringImages();
      state = AsyncValue.data(monitoringImages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final monitoringProvider =
    StateNotifierProvider<MonitoringNotifier, AsyncValue<List<ContentModel>>>(
  (ref) => MonitoringNotifier(
    ref.watch(apiServiceProvider),
  ),
);
