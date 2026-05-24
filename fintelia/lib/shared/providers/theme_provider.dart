/// ============================================
/// FINTELIA — Theme Provider
/// Dark/Light/System theme mode management
/// ============================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode state notifier.
///
/// Manages the app's theme mode (light, dark, system) and
/// persists the selection via local storage.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Set to light mode.
  void setLightMode() => state = ThemeMode.light;

  /// Set to dark mode.
  void setDarkMode() => state = ThemeMode.dark;

  /// Set to system default.
  void setSystemMode() => state = ThemeMode.system;

  /// Toggle between light and dark mode.
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Set mode from a string value (for persistence).
  void setFromString(String mode) {
    switch (mode) {
      case 'light':
        state = ThemeMode.light;
      case 'dark':
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  /// Get the current mode as a string (for persistence).
  String get modeString {
    switch (state) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Global theme mode provider.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
