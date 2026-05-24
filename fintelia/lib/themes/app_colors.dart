/// ============================================
/// FINTELIA — App Colors
/// Premium fintech-inspired color palette
/// ============================================
library;

import 'package:flutter/material.dart';

/// FINTELIA color palette — premium fintech-inspired design tokens.
///
/// Primary: Deep indigo-violet (#6C63FF)
/// Uses a sophisticated palette with gradients, glassmorphism support,
/// and semantic colors for financial data (profit/loss).
class AppColors {
  AppColors._();

  // ---- Primary Brand ----
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);
  static const Color primaryContainer = Color(0xFFE8E6FF);

  // ---- Secondary ----
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);

  // ---- Accent ----
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFF9EC6);
  static const Color accentDark = Color(0xFFD4376E);

  // ---- Financial Semantic ----
  static const Color income = Color(0xFF30D158);
  static const Color incomeLight = Color(0xFFB9F6CA);
  static const Color expense = Color(0xFFFF453A);
  static const Color expenseLight = Color(0xFFFFCDD2);
  static const Color profit = Color(0xFF00E676);
  static const Color loss = Color(0xFFFF1744);

  // ---- Status ----
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);

  // ---- Neutral ----
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ---- Dark Mode Surfaces ----
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF16213E);
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkCard = Color(0xFF1E1E3A);
  static const Color darkElevated = Color(0xFF252547);

  // ---- Light Mode Surfaces ----
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ---- Gradients ----
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A42DB), Color(0xFF3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E1E3A), Color(0xFF252547)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ---- Glassmorphism ----
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassDarkBg = Colors.black.withValues(alpha: 0.3);

  // ---- Chart Colors ----
  static const List<Color> chartPalette = [
    Color(0xFF5E5CE6), // Indigo
    Color(0xFF32ADE6), // Cyan
    Color(0xFFFF9F0A), // Orange
    Color(0xFF30D158), // Green
    Color(0xFFFF453A), // Coral
    Color(0xFFBF5AF2), // Purple
    Color(0xFF64D2FF), // Sky
    Color(0xFFFFD60A), // Yellow
  ];
}
