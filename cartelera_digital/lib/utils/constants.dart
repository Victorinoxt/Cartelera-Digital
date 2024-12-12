import 'package:flutter/material.dart';
import 'package:cartelera_digital/constants/app_colors.dart';

class AppConstants {
  static const String appName = 'Cartelera Digital';
  static const String version = '1.0.0';

  // Rutas de navegación
  static const String dashboardRoute = '/';
  static const String chartsRoute = '/charts';
  static const String mediaRoute = '/media';

  // Configuración
  static const int defaultDuration = 10;
  static const int maxMediaItems = 50;
}

const String kAppName = 'Cartelera Digital';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  // ... otras configuraciones de tema
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  // ... otras configuraciones de tema
);
