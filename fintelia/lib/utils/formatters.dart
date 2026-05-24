/// ============================================
/// FINTELIA — Formatters
/// Currency, date, and number formatting
/// ============================================
library;

import 'package:intl/intl.dart';

/// Centralized formatting utilities for financial data display.
class Formatters {
  Formatters._();

  // ---- Currency ----

  /// Format amount as currency (e.g., $1,234.56).
  static String currency(
    double amount, {
    String symbol = '₹',
    int decimalDigits = 2,
  }) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Format as compact currency (e.g., $1.2K, $3.4M).
  static String compactCurrency(double amount, {String symbol = '₹'}) {
    return NumberFormat.compactCurrency(symbol: symbol).format(amount);
  }

  // ---- Date / Time ----

  /// Format as full date (e.g., "May 21, 2025").
  static String fullDate(DateTime date) =>
      DateFormat.yMMMMd().format(date);

  /// Format as short date (e.g., "May 21").
  static String shortDate(DateTime date) =>
      DateFormat.MMMd().format(date);

  /// Format as numeric date (e.g., "05/21/2025").
  static String numericDate(DateTime date) =>
      DateFormat('MM/dd/yyyy').format(date);

  /// Format as time (e.g., "2:30 PM").
  static String time(DateTime date) =>
      DateFormat.jm().format(date);

  /// Format as date and time (e.g., "May 21, 2025 at 2:30 PM").
  static String dateTime(DateTime date) =>
      DateFormat.yMMMMd().add_jm().format(date);

  /// Relative time string (e.g., "2 hours ago", "Yesterday").
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return shortDate(date);
  }

  // ---- Numbers ----

  /// Format with comma separators (e.g., 1,234,567).
  static String number(num value, {int decimalDigits = 0}) {
    return NumberFormat('#,##0${'.' * (decimalDigits > 0 ? 1 : 0)}${'0' * decimalDigits}')
        .format(value);
  }

  /// Format as percentage (e.g., "75.5%").
  static String percentage(double value, {int decimalDigits = 1}) =>
      '${value.toStringAsFixed(decimalDigits)}%';
}
