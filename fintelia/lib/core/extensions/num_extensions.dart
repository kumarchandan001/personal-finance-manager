/// ============================================
/// FINTELIA — Numeric Extensions
/// ============================================
library;

import 'package:intl/intl.dart';

/// Numeric formatting extensions for financial display.
extension NumExtensions on num {
  /// Format as currency string (e.g., $1,234.56).
  String toCurrency({String symbol = '₹', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// Format as compact currency (e.g., $1.2K).
  String toCompactCurrency({String symbol = '₹'}) {
    final formatter = NumberFormat.compactCurrency(symbol: symbol);
    return formatter.format(this);
  }

  /// Format as percentage (e.g., 75.5%).
  String toPercentage({int decimalDigits = 1}) =>
      '${toStringAsFixed(decimalDigits)}%';

  /// Format with comma separators (e.g., 1,234,567).
  String toFormatted({int decimalDigits = 0}) {
    final formatter = NumberFormat('#,##0${'.' * (decimalDigits > 0 ? 1 : 0)}${'0' * decimalDigits}');
    return formatter.format(this);
  }

  /// Whether this number is positive.
  bool get isPositive => this > 0;

  /// Whether this number is negative.
  bool get isNegative => this < 0;

  /// Return a sign prefix string (+ or -).
  String get signPrefix => isNegative ? '' : '+';

  /// Format as signed currency (e.g., +$500 or -$200).
  String toSignedCurrency({String symbol = '₹'}) =>
      '$signPrefix${toCurrency(symbol: symbol)}';
}
