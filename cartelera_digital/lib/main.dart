import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/media_api_service.dart'; // Importar el servicio de API

void main() {
  initializeDateFormatting('es').then((_) {
    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
    checkApiConnection(); // Llamar al método de verificación de conexión
  });
}

void checkApiConnection() async {
  final mediaApiService = MediaApiService();
  bool isConnected = await mediaApiService.checkConnection();
  if (isConnected) {
    print('Conexión exitosa con la API de monitoreo.');
  } else {
    print('Error al conectar con la API de monitoreo.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartelera Digital',
      theme: AppTheme.customTheme,
      home: SplashScreen(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
    );
  }
}
