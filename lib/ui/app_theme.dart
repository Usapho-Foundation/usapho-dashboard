import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF1F6A5A);

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans',
    fontFamilyFallback: const [
      'Segoe UI Emoji',
      'Apple Color Emoji',
      'Noto Color Emoji',
      'Roboto',
    ],
    textTheme: _zeroLetterSpacing(ThemeData.light().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F7F4),
    ),
    scaffoldBackgroundColor: const Color(0xFFF3F2EE),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6D3D1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6D3D1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: seed, width: 1.4),
      ),
    ),
  );
}

TextTheme _zeroLetterSpacing(TextTheme base) {
  TextStyle z(TextStyle? s) =>
      (s ?? const TextStyle()).copyWith(letterSpacing: 0);
  return base.copyWith(
    displayLarge: z(base.displayLarge),
    displayMedium: z(base.displayMedium),
    displaySmall: z(base.displaySmall),
    headlineLarge: z(base.headlineLarge),
    headlineMedium: z(base.headlineMedium),
    headlineSmall: z(base.headlineSmall),
    titleLarge: z(base.titleLarge),
    titleMedium: z(base.titleMedium),
    titleSmall: z(base.titleSmall),
    bodyLarge: z(base.bodyLarge),
    bodyMedium: z(base.bodyMedium),
    bodySmall: z(base.bodySmall),
    labelLarge: z(base.labelLarge),
    labelMedium: z(base.labelMedium),
    labelSmall: z(base.labelSmall),
  );
}
