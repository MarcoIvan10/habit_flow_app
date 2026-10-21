import '../entities/app_user.dart';

/// Sealed hierarchy representing the global authentication session state.
sealed class AuthSessionState {
  /// Creates an [AuthSessionState].
  const AuthSessionState();
}

/// Indicates that the initial authentication session is still being resolved.
final class AuthSessionLoading extends AuthSessionState {
  /// Creates an [AuthSessionLoading] state.
  const AuthSessionLoading();
}

/// Indicates an active authenticated session for [user].
final class AuthSessionAuthenticated extends AuthSessionState {
  /// Creates an [AuthSessionAuthenticated] state.
  const AuthSessionAuthenticated(this.user);

  /// The authenticated user entity.
  final AppUser user;
}

/// Indicates that no authenticated session is active.
final class AuthSessionUnauthenticated extends AuthSessionState {
  /// Creates an [AuthSessionUnauthenticated] state with an optional feedback [message].
  const AuthSessionUnauthenticated({this.message});

  /// Optional informational or error message explaining why the session ended.
  final String? message;
}

