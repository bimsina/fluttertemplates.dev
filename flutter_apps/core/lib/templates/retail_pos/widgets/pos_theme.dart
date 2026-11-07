import 'package:flutter/material.dart';

/// Layers the template's component styling over the host app's theme. Every
/// colour still comes from the host's [ColorScheme], so swapping the seed colour
/// or switching to dark mode restyles the whole register.
abstract final class PosTheme {
  static const double tileRadius = 14;
  static const double panelRadius = 18;

  /// The workspace behind panels.
  static Color ground(ColorScheme scheme) => scheme.surfaceContainerLow;

  /// Till tape and receipt stock.
  static Color paper(ColorScheme scheme) =>
      scheme.brightness == Brightness.light
      ? scheme.surfaceContainerLowest
      : scheme.surfaceContainerHigh;

  /// A container and foreground pair for a category. The tone follows the
  /// category, so a product keeps its colour under any filter.
  static (Color, Color) categoryTone(ColorScheme scheme, int index) =>
      switch (index % 6) {
        0 => (scheme.primaryContainer, scheme.onPrimaryContainer),
        1 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
        2 => (scheme.secondaryFixedDim, scheme.onSecondaryFixed),
        3 => (scheme.primaryFixedDim, scheme.onPrimaryFixed),
        4 => (scheme.tertiaryFixedDim, scheme.onTertiaryFixed),
        _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      };

  /// Brand color the register's color scheme is generated from.
  static const seedColor = Color(0xFFB45309);

  static ThemeData resolve(ThemeData host) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: host.brightness,
    );
    final base = host.copyWith(colorScheme: scheme);
    final text = base.textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return base.copyWith(
      scaffoldBackgroundColor: ground(scheme),
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: ground(scheme),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: scheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: const Size(0, 48),
          textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(shape),
          visualDensity: VisualDensity.standard,
        ),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dividerTheme: base.dividerTheme.copyWith(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: base.navigationRailTheme.copyWith(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
        minWidth: 84,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        height: 68,
      ),
    );
  }
}

extension TabularFigures on TextStyle {
  /// Fixed-width digits, so columns of money line up.
  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
