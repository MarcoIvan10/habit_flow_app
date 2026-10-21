import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

/// Maps infrastructure and Supabase SDK exceptions into domain-safe [AppException] subtypes.
abstract final class SupabaseErrorMapper {
  /// Converts any thrown [error] object into a sanitized [AppException].
  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }
    if (error is AuthException) {
      return _mapAuthException(error);
    }
    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }
    return UnknownAppException(
      userMessage:
          'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
      technicalDetails: error.toString(),
    );
  }

  static AuthAppException _mapAuthException(AuthException error) {
    final normalized = error.message.toLowerCase();
    final friendlyMessage = switch (normalized) {
      _ when normalized.contains('invalid login credentials') =>
        'Correo electrónico o contraseña incorrectos.',
      _ when normalized.contains('email not confirmed') =>
        'Debes confirmar tu correo electrónico antes de iniciar sesión.',
      _ when normalized.contains('user already registered') =>
        'Este correo electrónico ya está registrado.',
      _ when normalized.contains('password should be at least') =>
        'La contraseña no cumple con la longitud mínima requerida.',
      _
          when normalized.contains('rate limit') ||
              normalized.contains('too many requests') =>
        'Demasiados intentos. Espera unos minutos antes de volver a intentar.',
      _
          when normalized.contains('network') ||
              normalized.contains('socket') =>
        'Sin conexión a internet. Verifica tu red e inténtalo de nuevo.',
      _ => 'No se pudo completar la autenticación. Verifica tus datos.',
    };

    return AuthAppException(
      userMessage: friendlyMessage,
      technicalDetails: '${error.statusCode}: ${error.message}',
    );
  }

  static DatabaseAppException _mapPostgrestException(PostgrestException error) {
    final code = error.code ?? '';
    final friendlyMessage = switch (code) {
      '23505' => 'Este registro ya existe para la fecha seleccionada.',
      '42501' => 'No tienes permisos para realizar esta operación (RLS).',
      '23503' => 'El recurso relacionado ya no existe.',
      '23514' => 'Los datos enviados no cumplen las reglas de validación.',
      _ => 'No se pudieron sincronizar los datos con el servidor.',
    };

    return DatabaseAppException(
      userMessage: friendlyMessage,
      technicalDetails: '[${error.code}] ${error.message}',
    );
  }
}

