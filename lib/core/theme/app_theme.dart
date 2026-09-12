import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const brand = Color(0xFF007C6C);
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAF9),
      appBarTheme: const AppBarTheme(centerTitle: false),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(64, 48))),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(64, 48))),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
