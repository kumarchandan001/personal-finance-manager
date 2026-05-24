/// ============================================
/// FINTELIA — BuildContext Extensions
/// Convenient accessors for theme, media, nav
/// ============================================
library;

import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext] to reduce boilerplate
/// when accessing theme data, media queries, and navigation.
extension ContextExtensions on BuildContext {
  // ---- Theme ----

  /// Access the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Access the current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access the current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Whether the current theme is dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ---- Media Query ----

  /// Access the current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width in logical pixels.
  double get screenWidth => mediaQuery.size.width;

  /// Screen height in logical pixels.
  double get screenHeight => mediaQuery.size.height;

  /// Top padding (status bar height).
  double get topPadding => mediaQuery.padding.top;

  /// Bottom padding (navigation bar / safe area).
  double get bottomPadding => mediaQuery.padding.bottom;

  /// Whether the device is in landscape orientation.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Whether the screen is considered "wide" (tablet-like).
  bool get isWideScreen => screenWidth >= 600;

  // ---- Navigation ----

  /// Push a named route.
  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Pop the current route.
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Whether the navigator can pop the current route.
  bool get canPop => Navigator.of(this).canPop();

  // ---- Snackbar ----

  /// Show a snackbar with the given [message].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show an error snackbar.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
