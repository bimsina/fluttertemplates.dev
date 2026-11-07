import 'package:flutter/material.dart';

/// The default brand color. Everything else is generated from it.
const Color defaultAuthSeed = Color(0xFF7A3E6B);

/// The bold brand surface behind headers and the session pass. Full primary
/// glares on a dark background, so dark mode uses the quieter container.
extension BrandSurface on ColorScheme {
  Color get brand => brightness == Brightness.dark ? primaryContainer : primary;
  Color get onBrand =>
      brightness == Brightness.dark ? onPrimaryContainer : onPrimary;
}

/// The app's theme. Widgets only read colors from `colorScheme`, so changing
/// the seed recolors the whole flow in both brightnesses.
ThemeData buildAuthTheme({
  required Color seedColor,
  required Brightness brightness,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = base.textTheme;
  final fieldShape = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: scheme.outline),
  );
  const buttonShape = StadiumBorder();
  const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      displaySmall: text.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.08,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.12,
      ),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      errorMaxLines: 3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: fieldShape,
      enabledBorder: fieldShape,
      focusedBorder: fieldShape.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: fieldShape.copyWith(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: fieldShape.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 44),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 44),
        textStyle: buttonText,
      ),
    ),
  );
}
