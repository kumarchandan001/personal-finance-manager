/// ============================================
/// FINTELIA — Spacing Constants
/// Consistent spacing scale and presets
/// ============================================
library;

import 'package:flutter/material.dart';

/// Spacing scale and layout presets for consistent UI rhythm.
class AppSpacing {
  AppSpacing._();

  // ---- Spacing Scale (4px base) ----
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // ---- Screen Padding ----
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: base, vertical: sm);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: base);

  // ---- Card Padding ----
  static const EdgeInsets cardPadding = EdgeInsets.all(base);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(md);

  // ---- List Item Padding ----
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: base, vertical: md);

  // ---- Section Spacing ----
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalBase = SizedBox(height: base);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalBase = SizedBox(width: base);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);

  // ---- Border Radius ----
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusFull = 999;

  static final BorderRadius borderRadiusSm =
      BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd =
      BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg =
      BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl =
      BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl =
      BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusFull =
      BorderRadius.circular(radiusFull);
}
