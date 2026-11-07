import 'package:flutter/material.dart';

enum ThemePreference {
  system('System', Icons.brightness_auto_outlined),
  light('Light', Icons.light_mode_outlined),
  dark('Dark', Icons.dark_mode_outlined);

  const ThemePreference(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The theme choice. It belongs to the device rather than the account, so it
/// survives signing out.
///
/// SWAP POINT: this lives in memory. Save [preference] with shared_preferences
/// or similar if it should survive a restart.
class AppearanceController extends ChangeNotifier {
  ThemePreference _preference = ThemePreference.system;
  ThemePreference get preference => _preference;

  set preference(ThemePreference value) {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
  }

  /// [host] is the surrounding app's brightness, which is what "System" means
  /// for a widget that lives under someone else's `MaterialApp`.
  Brightness resolve(Brightness host) => switch (_preference) {
    ThemePreference.system => host,
    ThemePreference.light => Brightness.light,
    ThemePreference.dark => Brightness.dark,
  };
}
