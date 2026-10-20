import '../entities/app_user.dart';

/// Modos del formulario de autenticación.
enum AuthFormMode {
  signIn,
  signUp,
}

/// Estado sellado (Dart 3 Sealed Class) para la sesión global de autenticación.
/// Permite pattern matching exhaustivo en el enrutador raíz sin booleanos sueltos.
sealed class AuthSessionState {
  const AuthSessionState();
}

final class AuthSessionLoading extends AuthSessionState {
  const AuthSessionLoading();
}

final class AuthSessionAuthenticated extends AuthSessionState {
  const AuthSessionAuthenticated(this.user);
  final AppUser user;
}

final class AuthSessionUnauthenticated extends AuthSessionState {
  const AuthSessionUnauthenticated({this.message});
  final String? message;
}

/// Estado sellado (Dart 3 Sealed Class) para la acción de envío del formulario Login/Registro.
sealed class AuthSubmissionState {
  const AuthSubmissionState();
}

final class AuthSubmissionIdle extends AuthSubmissionState {
  const AuthSubmissionIdle();
}

final class AuthSubmissionSubmitting extends AuthSubmissionState {
  const AuthSubmissionSubmitting(this.mode);
  final AuthFormMode mode;
}

final class AuthSubmissionSuccess extends AuthSubmissionState {
  const AuthSubmissionSuccess({this.infoMessage});
  final String? infoMessage;
}

final class AuthSubmissionFailure extends AuthSubmissionState {
  const AuthSubmissionFailure(this.errorMessage);
  final String errorMessage;
}

