import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/theme.dart';
<<<<<<< HEAD
import 'screens/splash_screen.dart';
=======
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
>>>>>>> origin/main
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('es').then((_) {
    runApp(
<<<<<<< HEAD
      ProviderScope(
=======
      const ProviderScope(
>>>>>>> origin/main
        child: MyApp(),
      ),
    );
  });
}

<<<<<<< HEAD
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartelera Digital',
      theme: AppTheme.customTheme,
      home: SplashScreen(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
=======
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Cartelera Digital',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
>>>>>>> origin/main
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
