import '../constants/app_constants.dart';

/// Provides input validation and text sanitization rules to protect domain integrity.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _alphanumericPasswordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).+$',
  );

  /// Validates an email address format and returns a localized error message if invalid.
  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  /// Validates password length and complexity requirements.
  static String? validatePassword(String? value, {bool isSignUp = false}) {
    final raw = value ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (raw.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres.';
    }
    if (isSignUp && !_alphanumericPasswordRegExp.hasMatch(raw)) {
      return 'Incluye al menos una letra y un número.';
    }
    return null;
  }

  /// Validates a habit name after sanitizing whitespace and control characters.
  static String? validateHabitName(String? value) {
    final sanitized = sanitizeText(value ?? '');
    if (sanitized.isEmpty) {
      return 'El nombre del hábito no puede estar vacío.';
    }
    if (sanitized.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    if (sanitized.length > AppConstants.maxHabitNameLength) {
      return 'Máximo ${AppConstants.maxHabitNameLength} caracteres permitidos.';
    }
    return null;
  }

  /// Normalizes consecutive whitespace into a single space and removes ASCII control characters.
  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .trim();
  }
}
