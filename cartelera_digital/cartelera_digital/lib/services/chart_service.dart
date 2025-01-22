import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../services/data_generator_service.dart';
import '../services/logging_service.dart';
import '../controllers/chart_controller.dart';

class ChartService {
  final DataGeneratorService _dataGenerator;
  
  ChartService(this._dataGenerator);

  Future<List<ChartData>> obtenerDatos(String tipo) async {
    try {
      LoggingService.info('Obteniendo datos para: $tipo');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!DataGeneratorService.categories.containsKey(tipo)) {
        throw ChartException(
          'Tipo de gráfico no soportado',
          code: 'INVALID_CHART_TYPE'
        );
      }
      
      final datos = _dataGenerator.generateData(tipo);
      LoggingService.debug('Datos generados exitosamente para: $tipo');
      
      return datos;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error al obtener datos para: $tipo',
        e,
        stackTrace
      );
      if (e is ChartException) {
        rethrow;
      }
      throw ChartException(
        'Error al obtener datos',
        code: 'DATA_ERROR',
        originalError: e
      );
    }
  }

  Future<List<ChartData>> obtenerDatosHistoricos(String tipo, DateTime? desde, DateTime? hasta) async {
    try {
      LoggingService.info('Obteniendo datos históricos para: $tipo');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final datos = _dataGenerator.generateData(tipo, count: 30);
      return datos.where((d) => 
        d.date != null && 
        desde != null && 
        hasta != null &&
        d.date!.isAfter(desde) && 
        d.date!.isBefore(hasta)
      ).toList();
    } catch (e) {
      LoggingService.error('Error al obtener datos históricos', e);
      throw ChartException(
        'Error al obtener datos históricos',
        code: 'HISTORICAL_DATA_ERROR'
      );
    }
  }
}
