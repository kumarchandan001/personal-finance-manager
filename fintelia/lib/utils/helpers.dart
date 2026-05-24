/// ============================================
/// FINTELIA — Helper Utilities
/// General-purpose helper functions
/// ============================================
library;

import 'package:flutter/material.dart';

/// General-purpose helper functions used across the app.
class Helpers {
  Helpers._();

  /// Get a category icon based on category name.
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
      case 'utilities':
        return Icons.receipt_long_rounded;
      case 'health':
      case 'medical':
        return Icons.medical_services_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'salary':
      case 'income':
        return Icons.account_balance_wallet_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'rent':
      case 'housing':
        return Icons.home_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      case 'subscription':
        return Icons.subscriptions_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get a color for a transaction category.
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
      case 'dining':
        return const Color(0xFFFF6B6B);
      case 'transport':
      case 'transportation':
        return const Color(0xFF4ECDC4);
      case 'shopping':
        return const Color(0xFFFFE66D);
      case 'bills':
      case 'utilities':
        return const Color(0xFFA8E6CF);
      case 'health':
      case 'medical':
        return const Color(0xFFFF8A80);
      case 'entertainment':
        return const Color(0xFFB388FF);
      case 'education':
        return const Color(0xFF82B1FF);
      case 'salary':
      case 'income':
        return const Color(0xFF69F0AE);
      case 'investment':
        return const Color(0xFF00E5FF);
      case 'rent':
      case 'housing':
        return const Color(0xFFFFAB91);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  /// Get a greeting based on time of day.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Generate a unique transaction reference.
  static String generateReference() {
    final now = DateTime.now();
    return 'TXN${now.millisecondsSinceEpoch}';
  }
}
