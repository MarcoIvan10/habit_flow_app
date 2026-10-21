import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/supabase_error_mapper.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/states/auth_session_state.dart';
import '../providers/auth_providers.dart';

/// Manages the global [AuthSessionState] by subscribing to [AuthRepository] session changes.
class AuthSessionNotifier extends Notifier<AuthSessionState> {
  StreamSubscription<AppUser?>? _authSubscription;

  @override
  AuthSessionState build() {
    final repository = ref.watch(authRepositoryProvider);

    _authSubscription?.cancel();
    _authSubscription = repository.watchAuthStateChanges().listen(
      _onUserChanged,
      onError: _onSessionError,
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

  /// Signs out the current user and transitions to [AuthSessionUnauthenticated].
  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AuthSessionUnauthenticated();
  }

  void _onUserChanged(AppUser? user) {
    if (user != null) {
      state = AuthSessionAuthenticated(user);
    } else {
      state = const AuthSessionUnauthenticated();
    }
  }

  void _onSessionError(Object error) {
    final appError = SupabaseErrorMapper.map(error);
    state = AuthSessionUnauthenticated(message: appError.userMessage);
  }
}

