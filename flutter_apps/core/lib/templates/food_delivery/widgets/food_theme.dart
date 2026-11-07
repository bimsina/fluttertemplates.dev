import 'package:flutter/material.dart';

/// App-wide seed, used outside of any restaurant.
const brandSeed = Color(0xFF17795E);

final _cache = <(int, Brightness, DynamicSchemeVariant), ThemeData>{};

/// Builds (and caches) the full theme for a seed color.
ThemeData foodThemeData(
  Color seed,
  Brightness brightness,
  DynamicSchemeVariant variant,
) {
  return _cache.putIfAbsent(
    (seed.toARGB32(), brightness, variant),
    () => _build(
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: variant,
      ),
    ),
  );
}

ThemeData _build(ColorScheme scheme) {
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
  final buttonText = text.labelLarge?.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      // Sizes must be explicit here: the text theme of a raw ThemeData only
      // gets its font sizes when Theme.of() localizes it.
      titleTextStyle: text.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: buttonShape,
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        textStyle: buttonText?.copyWith(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      labelType: NavigationRailLabelType.all,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}

/// Re-themes its subtree from [seed], keeping the ambient brightness. This is
/// what gives each restaurant its own palette.
class FoodTheme extends StatelessWidget {
  const FoodTheme({
    super.key,
    required this.seed,
    this.variant = DynamicSchemeVariant.vibrant,
    required this.child,
  });

  final Color seed;

  /// Restaurants use the saturated default. The app root uses a calmer one so
  /// the restaurant colors stand out against it.
  final DynamicSchemeVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: foodThemeData(seed, Theme.of(context).brightness, variant),
      child: child,
    );
  }
}
