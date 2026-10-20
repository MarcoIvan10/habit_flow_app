import 'package:supabase_flutter/supabase_flutter.dart';

/// Jerarquía sellada (Dart 3) para el manejo tipado y exhaustivo de errores
/// en todas las capas de la aplicación sin exponer trazas internas al usuario.
sealed class AppException implements Exception {
  const AppException({
    required this.userMessage,
    this.technicalDetails,
  });

  /// Mensaje seguro y amigable listo para mostrarse en la interfaz de usuario.
  final String userMessage;

  /// Detalle técnico opcional para diagnóstico interno (no expuesto en UI).
  final String? technicalDetails;

  @override
  String toString() => userMessage;

  /// Transforma cualquier excepción de infraestructura en un [AppException] tipado.
  factory AppException.fromError(Object error) {
    if (error is AppException) return error;

    if (error is AuthException) {
      return AuthAppException.fromSupabaseAuth(error);
    }

    if (error is PostgrestException) {
      return DatabaseAppException.fromPostgrest(error);
    }

    return UnknownAppException(
      userMessage:
          'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
      technicalDetails: error.toString(),
    );
  }
}

/// Errores relacionados con autenticación y gestión de sesiones.
final class AuthAppException extends AppException {
  const AuthAppException({
    required super.userMessage,
    super.technicalDetails,
  });

  factory AuthAppException.fromSupabaseAuth(AuthException error) {
    final msg = error.message.toLowerCase();
    final friendlyMessage = switch (msg) {
      _ when msg.contains('invalid login credentials') =>
        'Correo electrónico o contraseña incorrectos.',
      _ when msg.contains('email not confirmed') =>
        'Debes confirmar tu correo electrónico antes de iniciar sesión.',
      _ when msg.contains('user already registered') =>
        'Este correo electrónico ya está registrado.',
      _ when msg.contains('password should be at least') =>
        'La contraseña no cumple con la longitud mínima requerida.',
      _ when msg.contains('rate limit') || msg.contains('too many requests') =>
        'Demasiados intentos. Espera unos minutos antes de volver a intentar.',
      _ when msg.contains('network') || msg.contains('socket') =>
        'Sin conexión a internet. Verifica tu red e inténtalo de nuevo.',
      _ => 'No se pudo completar la autenticación. Verifica tus datos.',
    };

    return AuthAppException(
      userMessage: friendlyMessage,
      technicalDetails: '${error.statusCode}: ${error.message}',
    );
  }
}

/// Errores de persistencia o políticas RLS en PostgreSQL (Supabase).
final class DatabaseAppException extends AppException {
  const DatabaseAppException({
    required super.userMessage,
    super.technicalDetails,
  });

  factory DatabaseAppException.fromPostgrest(PostgrestException error) {
    final code = error.code ?? '';
    final friendlyMessage = switch (code) {
      '23505' => 'Este registro ya existe para la fecha seleccionada.',
      '42501' => 'No tienes permisos para realizar esta operación (RLS).',
      '23503' => 'El recurso relacionado ya no existe.',
      _ => 'No se pudieron sincronizar los datos con el servidor.',
    };

    return DatabaseAppException(
      userMessage: friendlyMessage,
      technicalDetails: '[${error.code}] ${error.message}',
    );
  }
}

/// Errores de validación de reglas de negocio o formularios.
final class ValidationAppException extends AppException {
  const ValidationAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}

/// Errores de conectividad de red.
final class NetworkAppException extends AppException {
  const NetworkAppException({
    super.userMessage =
        'Error de conexión. Verifica tu acceso a internet e inténtalo de nuevo.',
    super.technicalDetails,
  });
}

/// Errores no categorizados.
final class UnknownAppException extends AppException {
  const UnknownAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}

