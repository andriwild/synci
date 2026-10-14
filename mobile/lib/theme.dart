import 'package:flutter/material.dart';

abstract final class SynciColors {
  static const primary = Color(0xFF3D5A80);
  static const highlight = Color(0xFFFFEE77);
  static const container = Color(0xFFEBF0F6);
  static const background = Color(0xFFF4F4F4);
}

ThemeData buildTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: SynciColors.primary,
    primary: SynciColors.primary,
    surface: Colors.white,
    surfaceContainer: SynciColors.container,
  );
  final roundedButton = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  return ThemeData(
    colorScheme: colors,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
    cardTheme: CardThemeData(
      color: SynciColors.container,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: roundedButton)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: roundedButton)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: roundedButton)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SynciColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: SynciColors.highlight,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
