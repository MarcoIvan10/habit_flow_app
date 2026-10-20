import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/local_demo_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/models/auth_ui_state.dart';
import '../../domain/repositories/auth_repository.dart';

/// Inyección de dependencias para [AuthRepository].
///
/// Si las credenciales de Supabase están configuradas en `.env` o `--dart-define`,
/// provee [SupabaseAuthRepository]; de lo contrario, provee [LocalDemoAuthRepository]
/// para permitir pruebas locales sin bloqueos.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final isConfigured = ref.watch(isSupabaseInitializedProvider);
  if (isConfigured) {
    final client = ref.watch(supabaseClientProvider);
    return SupabaseAuthRepository(client);
  }
  return LocalDemoAuthRepository();
});

/// Notifier global que gestiona el estado sellado [AuthSessionState] de la sesión activa.
class AuthSessionNotifier extends Notifier<AuthSessionState> {
  StreamSubscription<dynamic>? _authSubscription;

  @override
  AuthSessionState build() {
    final repository = ref.watch(authRepositoryProvider);

    _authSubscription?.cancel();
    _authSubscription = repository.watchAuthStateChanges().listen(
      (user) {
        if (user != null) {
          state = AuthSessionAuthenticated(user);
        } else {
          state = const AuthSessionUnauthenticated();
        }
      },
      onError: (Object error) {
        final appError = AppException.fromError(error);
        state = AuthSessionUnauthenticated(message: appError.userMessage);
      },
    );

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final initialUser = repository.currentUser;
    if (initialUser != null) {
      return AuthSessionAuthenticated(initialUser);
    }
    return const AuthSessionUnauthenticated();
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AuthSessionUnauthenticated();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);

/// Notifier para gestionar el envío del formulario de Login / Registro
/// mediante la clase sellada [AuthSubmissionState].
class AuthSubmissionController extends Notifier<AuthSubmissionState> {
  @override
  AuthSubmissionState build() => const AuthSubmissionIdle();

  void resetState() {
    state = const AuthSubmissionIdle();
  }

  Future<void> submit({
    required AuthFormMode mode,
    required String email,
    required String password,
  }) async {
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
          if (result.requiresEmailConfirmation) {
            state = const AuthSubmissionSuccess(
              infoMessage:
                  'Cuenta creada. Revisa tu bandeja de entrada para confirmar tu correo antes de iniciar sesión.',
            );
          } else {
            state = const AuthSubmissionSuccess(
              infoMessage: '¡Bienvenido a HabitFlow! Tu cuenta ha sido creada.',
            );
          }
      }
    } catch (error) {
      final appError = AppException.fromError(error);
      state = AuthSubmissionFailure(appError.userMessage);
    }
  }
}

final authSubmissionProvider =
    NotifierProvider<AuthSubmissionController, AuthSubmissionState>(
  AuthSubmissionController.new,
);

