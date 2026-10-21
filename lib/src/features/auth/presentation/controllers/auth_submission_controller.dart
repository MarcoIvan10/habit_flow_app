import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/supabase_error_mapper.dart';
import '../../domain/enums/auth_form_mode.dart';
import '../../domain/states/auth_submission_state.dart';
import '../providers/auth_providers.dart';

/// Controls authentication form submission state and enforces request throttling
/// against rapid duplicate submissions (OWASP A04 mitigation).
class AuthSubmissionController extends Notifier<AuthSubmissionState> {
  DateTime? _lastFailureAt;
  static const Duration _failureCooldown = Duration(seconds: 2);

  @override
  AuthSubmissionState build() => const AuthSubmissionIdle();

  /// Resets the form submission state back to [AuthSubmissionIdle].
  void resetState() {
    state = const AuthSubmissionIdle();
  }

  /// Submits login or registration credentials according to [mode].
  Future<void> submit({
    required AuthFormMode mode,
    required String email,
    required String password,
  }) async {
    if (state is AuthSubmissionSubmitting) {
      return;
    }
    if (_isInFailureCooldown()) {
      state = const AuthSubmissionFailure(
        'Por favor espera un momento antes de volver a intentar.',
      );
      return;
    }

    state = AuthSubmissionSubmitting(mode);
    final repository = ref.read(authRepositoryProvider);

    try {
      switch (mode) {
        case AuthFormMode.signIn:
          await repository.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          state = const AuthSubmissionSuccess();
        case AuthFormMode.signUp:
          final result = await repository.signUpWithEmailAndPassword(
            email: email,
            password: password,
          );
          state = AuthSubmissionSuccess(
            infoMessage: result.requiresEmailConfirmation
                ? 'Cuenta creada. Revisa tu bandeja de entrada para confirmar tu correo antes de iniciar sesión.'
                : '¡Bienvenido a HabitFlow! Tu cuenta ha sido creada.',
          );
      }
    } catch (error) {
      _lastFailureAt = DateTime.now();
      final appError = SupabaseErrorMapper.map(error);
      state = AuthSubmissionFailure(appError.userMessage);
    }
  }

  bool _isInFailureCooldown() {
    final lastFailure = _lastFailureAt;
    if (lastFailure == null) {
      return false;
    }
    return DateTime.now().difference(lastFailure) < _failureCooldown;
  }
}

