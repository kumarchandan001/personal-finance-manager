/// ============================================
/// FINTELIA — Shadow System
/// Elevation and glassmorphism shadows
/// ============================================
library;

import 'package:flutter/material.dart';

/// Shadow presets for cards, modals, bottom sheets, and glassmorphism.
class AppShadows {
  AppShadows._();

  // ---- Light Mode Shadows ----

  /// Subtle shadow for cards at rest.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Elevated shadow for floating elements.
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Strong shadow for modals and dialogs.
  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Bottom navigation bar shadow.
  static List<BoxShadow> get bottomNavShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ];

  // ---- Dark Mode Shadows ----

  /// Dark mode card shadow (glow effect).
  static List<BoxShadow> get darkCardShadow => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ---- Glassmorphism ----

  /// Glassmorphism shadow for frosted glass effect.
  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ---- Colored Shadows ----

  /// Primary colored shadow for branded buttons.
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Success colored shadow.
  static List<BoxShadow> get successShadow => [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
