/// ============================================
/// FINTELIA — String Extensions
/// ============================================
library;

/// String utility extensions for formatting and validation.
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize each word.
  String get titleCase =>
      split(' ').map((w) => w.capitalize).join(' ');

  /// Remove all whitespace.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if the string is a valid email.
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  /// Check if the string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Truncate with ellipsis at [maxLength].
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Convert to initials (e.g., "John Doe" -> "JD").
  String get initials => split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns true if null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the string or a default value.
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}
