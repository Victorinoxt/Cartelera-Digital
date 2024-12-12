import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:cartelera_digital/constants/app_colors.dart';

class AppTheme {
  static PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }

  static ThemeData get customTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      pageTransitionsTheme: _pageTransitionsTheme,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textColor,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textColor,
          height: 1.5,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        tertiary: AppColors.highlightColor,
        background: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textColor,
        onSurface: AppColors.textColor,
      ),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return AppColors.secondaryColor;
              }
              return AppColors.primaryColor;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return 2;
              }
              return 4;
            },
          ),
          shadowColor: MaterialStateProperty.all(
            Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return AppColors.secondaryColor;
              }
              return AppColors.primaryColor;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return 2;
              }
              return 4;
            },
          ),
          shadowColor: MaterialStateProperty.all(
            Colors.black.withOpacity(0.3),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: const IconThemeData(
          color: AppColors.highlightColor,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.highlightColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        useIndicator: true,
        indicatorColor: AppColors.highlightColor.withOpacity(0.2),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
=======
import 'package:logger/logger.dart';

class AppTheme {
  // Colores personalizados
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFF2F4F6);
  static const Color lightCardColor = Colors.white;
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFF64B5F6);

  // Colores modo oscuro
  static const Color darkBackground = Color(0xFF1E1E2C);
  static const Color darkSurface = Color(0xFF2D2D3F);
  static const Color darkCardColor = Color(0xFF323244);
  static const Color darkAccent = Color(0xFF424255);

  // Tema Claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: lightSurface,
      background: lightBackground,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
    ),
    // Estilo de las tarjetas
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
    // Estilo del AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    // Estilos de texto
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.black87),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
    ),
    // Estilo de los botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Estilo de los íconos
    iconTheme: const IconThemeData(
      color: primaryBlue,
      size: 24,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: lightSurface,
      selectedIconTheme: const IconThemeData(
        color: primaryBlue,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.black87.withOpacity(0.6),
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: primaryBlue,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.black87.withOpacity(0.6),
        fontSize: 14,
      ),
      useIndicator: true,
      indicatorColor: primaryBlue.withOpacity(0.12),
    ),
  );

  // Tema Oscuro mejorado
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: darkSurface,
      background: darkBackground,
      onBackground: Colors.white,
      onSurface: Colors.white,
      tertiary: darkAccent,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkCardColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: darkSurface,
      selectedIconTheme: const IconThemeData(
        color: accentBlue,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.7),
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: accentBlue,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
      ),
      useIndicator: true,
      indicatorColor: accentBlue.withOpacity(0.15),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Colors.white.withOpacity(0.9),
      ),
      bodyLarge: TextStyle(
        color: Colors.white.withOpacity(0.9),
      ),
      bodyMedium: TextStyle(
        color: Colors.white.withOpacity(0.7),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentBlue;
        }
        return Colors.white.withOpacity(0.7);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentBlue.withOpacity(0.5);
        }
        return Colors.white.withOpacity(0.2);
      }),
    ),
  );
}

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void info(String message) {
    _logger.i(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void debug(String message) {
    _logger.d(message);
  }

  static void warning(String message) {
    _logger.w(message);
>>>>>>> origin/main
  }
}
