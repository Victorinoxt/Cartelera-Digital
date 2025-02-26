import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/media_api_service.dart';
import 'services/server_service.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'config/env_config.dart';
import 'providers/auth_provider.dart';

void main() async {
  // Asegurarse de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await EnvConfig.init();
  
  // Inicializar la localización
  await initializeDateFormatting('es');
  
  // Iniciar el servidor Node.js
  await ServerService.startServer();

  // Asegurarse de que el servidor se detenga cuando la aplicación se cierre
  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      detachedCallBack: () async {
        await ServerService.stopServer();
      },
    ),
  );
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

// Manejador del ciclo de vida de la aplicación
class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? detachedCallBack;

  LifecycleEventHandler({
    this.detachedCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        if (detachedCallBack != null) {
          await detachedCallBack!();
        }
        break;
      default:
        break;
    }
  }
}

Future<void> checkApiConnection(WidgetRef ref) async {
  try {
    final mediaApiService = ref.read(mediaApiServiceProvider);
    bool isConnected = await mediaApiService.checkConnection();
    if (isConnected) {
      debugPrint('Conexión exitosa con la API de monitoreo.');
    } else {
      debugPrint('Error al conectar con la API de monitoreo.');
    }
  } catch (e) {
    debugPrint('Error al verificar la conexión: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Verificar la conexión con la API al iniciar
    checkApiConnection(ref);
    
    return MaterialApp(
      title: 'Cartelera Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5733),
        ),
        useMaterial3: true,
      ),
      home: authState.isAuthenticated
          ? const SplashScreen()
          : const LoginScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
      ],
    );
  }
}
