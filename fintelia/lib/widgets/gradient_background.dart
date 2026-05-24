/// ============================================
/// FINTELIA — Gradient Background
/// Reusable gradient background wrapper
/// ============================================
library;

import 'package:fintelia/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// A reusable gradient background wrapper for screens.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.darkSurfaceVariant,
                      AppColors.darkBackground,
                    ]
                  : [
                      AppColors.lightBackground,
                      Colors.white,
                      AppColors.lightBackground,
                    ],
            ),
      ),
      child: child,
    );
  }
}
