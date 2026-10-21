import '../enums/auth_form_mode.dart';

/// Sealed hierarchy representing the submission lifecycle of the authentication form.
sealed class AuthSubmissionState {
  /// Creates an [AuthSubmissionState].
  const AuthSubmissionState();
}

/// Idle state prior to any form submission.
final class AuthSubmissionIdle extends AuthSubmissionState {
  /// Creates an [AuthSubmissionIdle] state.
  const AuthSubmissionIdle();
}

/// Active state while an authentication request for [mode] is in flight.
final class AuthSubmissionSubmitting extends AuthSubmissionState {
  /// Creates an [AuthSubmissionSubmitting] state.
  const AuthSubmissionSubmitting(this.mode);

  /// The form mode being submitted.
  final AuthFormMode mode;
}

/// State indicating that the authentication request succeeded.
final class AuthSubmissionSuccess extends AuthSubmissionState {
  /// Creates an [AuthSubmissionSuccess] state with an optional [infoMessage].
  const AuthSubmissionSuccess({this.infoMessage});

  /// Optional message displayed to the user after successful submission.
  final String? infoMessage;
}

/// State indicating that the authentication request failed with [errorMessage].
final class AuthSubmissionFailure extends AuthSubmissionState {
  /// Creates an [AuthSubmissionFailure] state.
  const AuthSubmissionFailure(this.errorMessage);

  /// Sanitized user-facing error message.
  final String errorMessage;
}

