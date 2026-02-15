import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that manages the App's ThemeMode.
///
/// It uses [ThemeNotifier] to handle logic and persistence.
/// We use `override` in `main.dart` to inject the initial value
/// loaded from SharedPreferences, avoiding async flicker.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  // This value is overridden in main.dart with the saved preference.
  // Defaulting to system if not overridden (though it should be).
  return ThemeNotifier(ThemeMode.system, null);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeNotifier(super.state, this._prefs);

  static const _themeKey = 'theme_mode';

  /// Toggle between Light, Dark, and System modes.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveTheme(mode);
  }

  /// Load the saved theme entry from SharedPreferences.
  /// This is effectively a static helper to be used in main.dart.
  static ThemeMode loadTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    if (_prefs == null) return;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
      value = 'system';
        break;
    }
    await _prefs.setString(_themeKey, value);
  }
}
