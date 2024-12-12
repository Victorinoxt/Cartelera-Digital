import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColor),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.darkPrimaryColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextColor),
    ),
  );
}
