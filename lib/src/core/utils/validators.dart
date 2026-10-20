import '../constants/app_constants.dart';

/// Validadores y sanitizadores de entrada para proteger la integridad de los formularios.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Valida formato de correo electrónico.
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

  /// Valida longitud y seguridad básica de contraseña.
  static String? validatePassword(String? value, {bool isSignUp = false}) {
    final raw = value ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (raw.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres.';
    }
    if (isSignUp && !RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(raw)) {
      return 'Incluye al menos una letra y un número.';
    }
    return null;
  }

  /// Valida y sanitiza el nombre de un hábito.
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

  /// Normaliza espacios (incluyendo saltos de línea y tabulaciones) y limpia caracteres de control.
  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .trim();
  }
}
