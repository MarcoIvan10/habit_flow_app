/// Sealed hierarchy representing strongly-typed application exceptions.
///
/// Decouples domain and presentation error handling from third-party SDK
/// exception types and prevents raw stack traces from leaking into the UI.
sealed class AppException implements Exception {
  /// Creates an [AppException] with a safe [userMessage] and optional [technicalDetails].
  const AppException({
    required this.userMessage,
    this.technicalDetails,
  });

  /// Human-readable, localized message safe to display in the UI.
  final String userMessage;

  /// Optional internal diagnostic details excluded from end-user display.
  final String? technicalDetails;

  @override
  String toString() => userMessage;
}

/// Represents authentication and session lifecycle failures.
final class AuthAppException extends AppException {
  /// Creates an [AuthAppException].
  const AuthAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}

/// Represents database persistence, constraint, or Row Level Security failures.
final class DatabaseAppException extends AppException {
  /// Creates a [DatabaseAppException].
  const DatabaseAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}

/// Represents domain rule or form input validation failures.
final class ValidationAppException extends AppException {
  /// Creates a [ValidationAppException].
  const ValidationAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}

/// Represents network connectivity or timeout failures.
final class NetworkAppException extends AppException {
  /// Creates a [NetworkAppException].
  const NetworkAppException({
    super.userMessage =
        'Error de conexión. Verifica tu acceso a internet e inténtalo de nuevo.',
    super.technicalDetails,
  });
}

/// Represents unexpected errors that do not match a specific domain category.
final class UnknownAppException extends AppException {
  /// Creates an [UnknownAppException].
  const UnknownAppException({
    required super.userMessage,
    super.technicalDetails,
  });
}
