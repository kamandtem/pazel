import 'package:flutter/material.dart';
abstract final class DesignTokens {
  static const violet = Color(0xFF7152D9);
  static const apricot = Color(0xFFFF8857);
  static const mint = Color(0xFF23846B);
  static const paper = Color(0xFFF8F7FC);
  static const ink = Color(0xFF292638);
  static const muted = Color(0xFF696477);
  static const line = Color(0xFFE7E2F0);
  static const gap = 16.0;
  static const cardRadius = 24.0;
}
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: DesignTokens.violet,
    brightness: brightness,
    surface: dark ? const Color(0xFF252130) : const Color(0xFFFDFCFD));
  final base = ThemeData(useMaterial3: true, brightness: brightness,
    colorScheme: scheme, fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: dark ? const Color(0xFF191622) : DesignTokens.paper);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontSize: 28,
        fontWeight: FontWeight.w700, height: 1.5),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 20,
        fontWeight: FontWeight.w700, height: 1.5),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.7),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.7)),
    appBarTheme: AppBarTheme(backgroundColor: base.scaffoldBackgroundColor,
      scrolledUnderElevation: 0, centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: scheme.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      minimumSize: const Size(48, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16,
        fontWeight: FontWeight.w700))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 32));
}
