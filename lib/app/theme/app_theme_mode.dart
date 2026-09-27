import 'package:flutter/material.dart';

/// App-wide theme mode options including system default.
enum AppThemeMode {
  /// Light mode
  light('light'),

  /// Dark mode
  dark('dark'),

  /// Follow device system theme
  system('system');

  final String key;
  const AppThemeMode(this.key);

  /// Resolves ThemeMode enum for MaterialApp.
  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Parses from stored string.
  static AppThemeMode fromKey(String? key) {
    switch (key) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}
