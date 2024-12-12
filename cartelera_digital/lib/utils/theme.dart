import 'package:flutter/material.dart';
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
  }
}
