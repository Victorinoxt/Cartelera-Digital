import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/chart_data.dart';
import '../models/custom_chart.dart';
import '../services/logging_service.dart';
import '../services/api_service.dart';

class ChartException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ChartException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ChartException: $message (Code: $code)';
}

class ChartState {
  final List<ChartData> salesData;
  final List<ChartData> productionData;
  final List<ChartData> otStatusData;
  final List<ChartData> otRendimientoData;
  final List<CustomChart> customCharts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final DateTime? otStatusDate;
  final DateTime? otRendimientoDate;

  ChartState({
    this.salesData = const [],
    this.productionData = const [],
    this.otStatusData = const [],
    this.otRendimientoData = const [],
    this.customCharts = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.otStatusDate,
    this.otRendimientoDate,
  });

  ChartState copyWith({
    List<ChartData>? salesData,
    List<ChartData>? productionData,
    List<ChartData>? otStatusData,
    List<ChartData>? otRendimientoData,
    List<CustomChart>? customCharts,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    DateTime? otStatusDate,
    DateTime? otRendimientoDate,
  }) {
    return ChartState(
      salesData: salesData ?? this.salesData,
      productionData: productionData ?? this.productionData,
      otStatusData: otStatusData ?? this.otStatusData,
      otRendimientoData: otRendimientoData ?? this.otRendimientoData,
      customCharts: customCharts ?? this.customCharts,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      otStatusDate: otStatusDate ?? this.otStatusDate,
      otRendimientoDate: otRendimientoDate ?? this.otRendimientoDate,
    );
  }
}

final chartControllerProvider = StateNotifierProvider<ChartController, ChartState>((ref) {
  return ChartController();
});

class ChartController extends StateNotifier<ChartState> {
  // Cache para los datos de los gráficos
  final Map<String, List<ChartData>> _cache = {};
  
  // Tiempo de expiración del cache
  static const Duration _cacheExpiration = Duration(minutes: 5);
  DateTime _lastUpdate = DateTime.now();

  final ApiService _apiService = ApiService();

  DateTime? _selectedDate;

  Future<List<ChartData>> _getChartData(String tipo, {DateTime? fecha}) async {
    try {
      final response = await _apiService.getChartData(tipo, fecha);
      return response;
    } catch (e) {
      LoggingService.error('Error al obtener datos del gráfico', e);
      return _getFallbackData(tipo);
    }
  }

  ChartController() : super(ChartState(
    salesData: [],
    productionData: [],
    customCharts: [],
    isLoading: true,
    hasError: false,
  )) {
    initializeData();
  }

  // Método para actualizar un gráfico específico
  Future<void> actualizarGrafico(String tipo) async {
    try {
      state = state.copyWith(isLoading: true);
      final nuevosDatos = await _getChartData(tipo);
      
      switch (tipo) {
        case 'ot_status':
          state = state.copyWith(salesData: nuevosDatos);
          break;
        case 'ot_rendimiento':
          state = state.copyWith(productionData: nuevosDatos);
          break;
      }
      
      state = state.copyWith(isLoading: false);
      LoggingService.info('Gráfico actualizado: $tipo');
    } catch (e) {
      LoggingService.error('Error al actualizar gráfico', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al actualizar gráfico: $e',
      );
    }
  }

  // Método para actualizar los datos de un gráfico
  void updateChartData(String tipo, List<ChartData> newData) {
    switch (tipo) {
      case 'ventas':
        state = state.copyWith(salesData: newData);
        break;
      case 'produccion':
        state = state.copyWith(productionData: newData);
        break;
    }
  }

  // Método para inicializar datos
  void initializeData() {
    try {
      state = state.copyWith(isLoading: true, hasError: false);
      
      actualizarGrafico('ot_status');
      actualizarGrafico('ot_rendimiento');
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al inicializar los datos: $e',
      );
    }
  }

  Future<void> actualizarTodosLosGraficos() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Usamos la fecha actual para ambos gráficos
      final fechaActual = DateTime.now();
      
      // Actualizamos ambos gráficos con la misma fecha
      await actualizarGraficoConFecha('ot_status', fechaActual);
      await actualizarGraficoConFecha('ot_rendimiento', fechaActual);
      
      state = state.copyWith(
        otStatusDate: fechaActual,
        otRendimientoDate: fechaActual,
        isLoading: false,
      );
      
      LoggingService.info('Todos los gráficos actualizados con fecha: ${fechaActual.toIso8601String()}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al actualizar gráficos: $e',
      );
    }
  }

  void logEstadoActual() {
    try {
      LoggingService.info('''
        Estado actual:
        - Ventas: ${state.salesData.length} datos
        - Producción: ${state.productionData.length} datos
        - Gráficos personalizados: ${state.customCharts.length}
        - Estado de carga: ${state.isLoading}
        - Tiene error: ${state.hasError}
        ${state.hasError ? '- Mensaje de error: ${state.errorMessage}' : ''}
      ''');
    } catch (e) {
      LoggingService.error('Error al registrar estado', e);
    }
  }

  // Validación de datos antes de agregar/actualizar
  void _validateChartData(List<ChartData> data) {
    if (data.isEmpty) {
      throw ChartException('Los datos del gráfico no pueden estar vacíos', code: 'EMPTY_DATA');
    }
    
    for (var point in data) {
      if (point.value.isNaN || point.value.isInfinite) {
        throw ChartException('Valor inválido en los datos', code: 'INVALID_VALUE');
      }
      if (point.category.isEmpty) {
        throw ChartException('Categoría vacía en los datos', code: 'EMPTY_CATEGORY');
      }
    }
  }

  // Método mejorado para agregar gráfico personalizado
  Future<void> agregarGraficoPersonalizado(String titulo, String tipo, List<ChartData> datos) async {
    try {
      if (titulo.isEmpty) {
        throw ChartException('El título no puede estar vacío', code: 'EMPTY_TITLE');
      }
      
      _validateChartData(datos);
      
      state = state.copyWith(isLoading: true);
      
      // Verificar si ya existe un gráfico con el mismo título
      if (state.customCharts.any((chart) => chart.title == titulo)) {
        throw ChartException('Ya existe un gráfico con este título', code: 'DUPLICATE_TITLE');
      }

      final nuevoGrafico = CustomChart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titulo,
        type: tipo,
        data: datos,
      );
      
      final nuevosGraficos = [...state.customCharts, nuevoGrafico];
      state = state.copyWith(
        customCharts: nuevosGraficos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is ChartException ? e.message : 'Error al agregar gráfico: $e',
      );
      rethrow;
    }
  }

  void actualizarGraficoPersonalizado(String id, List<ChartData> nuevosDatos) {
    try {
      final nuevosGraficos = state.customCharts.map((grafico) {
        if (grafico.id == id) {
          return CustomChart(
            id: grafico.id,
            title: grafico.title,
            type: grafico.type,
            data: nuevosDatos,
          );
        }
        return grafico;
      }).toList();
      
      state = state.copyWith(
        customCharts: nuevosGraficos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Error al actualizar gráfico: $e',
      );
    }
  }

  Future<List<ChartData>> _fetchNewData(String tipo) async {
    // Simulamos una llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (tipo) {
      case 'ventas':
        return List.generate(5, (index) {
          return ChartData(
            category: ['Ene', 'Feb', 'Mar', 'Abr', 'May'][index],
            value: 20.0 + Random().nextInt(50).toDouble(),
            date: DateTime(2024, index + 1),
            color: Colors.blue.shade500,
          );
        });
        
      case 'produccion':
        return [
          ChartData(
            category: 'Prod A',
            value: (30 + Random().nextInt(40)).toDouble(),
            date: DateTime.now(),
            color: Colors.green.shade500
          ),
          ChartData(
            category: 'Prod B',
            value: (30 + Random().nextInt(40)).toDouble(),
            date: DateTime.now(),
            color: Colors.orange.shade500
          ),
          ChartData(
            category: 'Prod C',
            value: (30 + Random().nextInt(40)).toDouble(),
            date: DateTime.now(),
            color: Colors.purple.shade500
          ),
        ];
        
      default:
        throw ChartException('Tipo de gráfico no soportado: $tipo', code: 'INVALID_TYPE');
    }
  }

  Future<void> actualizarGraficoConFecha(String tipo, DateTime? fecha) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Actualizar la fecha en el estado
      switch (tipo) {
        case 'ot_status':
          state = state.copyWith(
            otStatusDate: fecha,
            isLoading: true,
          );
          break;
        case 'ot_rendimiento':
          state = state.copyWith(
            otRendimientoDate: fecha,
            isLoading: true,
          );
          break;
      }
      
      // Obtener datos con la nueva fecha
      final nuevosDatos = await _apiService.getChartData(tipo, fecha);
      
      // Actualizar datos según el tipo
      switch (tipo) {
        case 'ot_status':
          state = state.copyWith(
            salesData: nuevosDatos,
            otStatusDate: fecha,  // Aseguramos que la fecha se mantiene
            isLoading: false,
          );
          break;
        case 'ot_rendimiento':
          state = state.copyWith(
            productionData: nuevosDatos,
            otRendimientoDate: fecha,  // Aseguramos que la fecha se mantiene
            isLoading: false,
          );
          break;
      }
      
      LoggingService.info('Gráfico actualizado: $tipo con fecha: ${fecha?.toIso8601String()}');
    } catch (e) {
      LoggingService.error('Error al actualizar gráfico', e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al actualizar gráfico con fecha: $e',
      );
    }
  }

  List<ChartData> _getFallbackData(String tipo) {
    switch (tipo) {
      case 'ot_status':
        return [
          ChartData(
            category: 'Pendiente',
            value: 5,
            date: DateTime.now(),
            color: Colors.orange
          ),
          ChartData(
            category: 'En Proceso',
            value: 3,
            date: DateTime.now(),
            color: Colors.blue
          ),
          ChartData(
            category: 'Completado',
            value: 8,
            date: DateTime.now(),
            color: Colors.green
          ),
        ];
      
      case 'ot_rendimiento':
        return [
          ChartData(
            category: 'Sin datos',
            value: 0,
            date: DateTime.now(),
            color: Colors.blue.shade500
          ),
        ];
      
      default:
        return [];
    }
  }
}
