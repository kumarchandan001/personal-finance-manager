/// ============================================
/// FINTELIA — Form Validators
/// Reusable validation functions
/// ============================================
library;

import 'package:fintelia/core/constants/app_constants.dart';

/// Form field validation functions.
///
/// Each returns `null` on valid input, or an error message string.
class Validators {
  Validators._();

  /// Validate a required field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Validate a password with minimum length.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate that a confirmation password matches.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  /// Validate a transaction amount.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than zero';
    if (parsed > 999999999999) return 'Amount is too large';
    return null;
  }

  /// Validate a name field.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.length > AppConstants.maxNameLength) return 'Name is too long';
    return null;
  }

  /// Validate a description field (optional but length-limited).
  static String? description(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be ${AppConstants.maxDescriptionLength} characters or less';
    }
    return null;
  }
}
