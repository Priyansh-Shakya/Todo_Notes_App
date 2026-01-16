import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xffb3d7f6); // maybe a brand blue or something
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFFEEEEEE); // very light grey
  static const background = Color(0xffdcdcdc); // your current
  static const surface = Colors.white;
  static const onBackground = Colors.black87;
  static const onSurface = Colors.black87;
  static const error = Color(0xFFB00020);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 1,
  ),
  cardColor: AppColors.surface,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
  ),
  textTheme: TextTheme(
    headlineLarge: const TextStyle(fontSize: 25, color: AppColors.onBackground),
    headlineMedium: const TextStyle(
      fontSize: 20,
      color: AppColors.onBackground,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.onSurface),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
  ),
  // maybe also ListTileTheme, CheckboxTheme etc
);

class AppColorsDark {
  static const primary = Color(0xff030303); // light blueish accent
  static const onPrimary = Colors.black;
  static const background = Color(0xff1b1b1b); // background
  static const surface = Colors.black; // slightly lighter than background
  static const onBackground = Colors.white70;
  static const onSurface = Colors.white70;
  static const error = Color(0xFFCF6679);
}

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    secondary: AppColorsDark.primary.withOpacity(0.75),
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.onSurface,
    error: AppColorsDark.error,
  ),
  scaffoldBackgroundColor: AppColorsDark.background,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 1,
  ),
  cardColor: AppColorsDark.surface, //should be darker than background
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColorsDark.primary,
    foregroundColor: Colors.black,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorsDark.primary;
      }
      return Colors.grey;
    }),
  ),
  iconTheme: IconThemeData(color: Colors.white70),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 24, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 20, color: Colors.white),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xffd2d2d2)),
    labelSmall: TextStyle(fontSize: 12, color: Colors.white54),
  ),
);
