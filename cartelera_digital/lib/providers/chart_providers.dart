import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chart_data.dart';
import '../services/chart_service.dart';
import '../services/data_generator_service.dart';
import '../services/storage_service.dart';
import '../services/chart_export_service.dart';
import '../services/media_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/external_charts_service.dart';
import '../services/api_service.dart';
import '../controllers/chart_controller.dart';

// Provider para SharedPreferences
final sharedPreferencesProvider = FutureProvider((ref) async {
  return await SharedPreferences.getInstance();
});

// Providers principales
final chartServiceProvider = Provider((ref) => ChartService(DataGeneratorService()));

final storageServiceProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw Exception('SharedPreferences no inicializado');
  return StorageService(prefs);
});

final mediaServiceProvider = Provider((ref) => MediaService());

final chartExportServiceProvider = Provider((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  return ChartExportService(mediaService);
});

final exportProgressProvider = StateProvider<double>((ref) => 0.0);

// Provider principal de gráficos
final chartsProvider = StateNotifierProvider<ChartNotifier, AsyncValue<List<ChartData>>>((ref) {
  final chartService = ref.watch(chartServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ChartNotifier(chartService, storageService);
});

class ChartNotifier extends StateNotifier<AsyncValue<List<ChartData>>> {
  final ChartService _chartService;
  final StorageService _storageService;

  ChartNotifier(this._chartService, this._storageService) 
      : super(const AsyncValue.loading()) {
    loadCharts();
  }

  Future<void> loadCharts() async {
    try {
      state = const AsyncValue.loading();
      final charts = _storageService.getCharts();
      state = AsyncValue.data(charts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addChart(ChartData chart) async {
    try {
      final currentCharts = state.value ?? [];
      final updatedCharts = [...currentCharts, chart];
      await _storageService.saveCharts(updatedCharts);
      state = AsyncValue.data(updatedCharts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider para el servicio de API externa
final externalChartsServiceProvider = Provider((ref) => ExternalChartsService());

// Provider para el servicio de API local
final apiServiceProvider = Provider((ref) => ApiService());

// Provider para el controlador de gráficos
final chartControllerProvider = StateNotifierProvider<ChartController, ChartState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final externalChartsService = ref.watch(externalChartsServiceProvider);
  
  return ChartController(
    apiService: apiService,
    externalChartsService: externalChartsService,
  );
});

// Provider para datos de solicitudes
final solicitudesDataProvider = FutureProvider.family<List<ChartData>, DateTime?>((ref, fecha) {
  final externalService = ref.watch(externalChartsServiceProvider);
  return externalService.getEstadisticasSolicitudes(fecha: fecha);
});
