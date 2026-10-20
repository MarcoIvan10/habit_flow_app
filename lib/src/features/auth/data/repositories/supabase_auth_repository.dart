import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación concreta de [AuthRepository] respaldada por Supabase GoTrue Auth.
final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? _mapSupabaseUser(user) : null;
  }

  @override
  Stream<AppUser?> watchAuthStateChanges() {
    return _client.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      return user != null ? _mapSupabaseUser(user) : null;
    });
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthAppException(
          userMessage: 'No se pudo iniciar sesión. Verifica tus credenciales.',
        );
      }

      return _mapSupabaseUser(user);
    } catch (error) {
      throw AppException.fromError(error);
    }
  }

  @override
  Future<SignUpResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = response.user;
      final session = response.session;

      return (
        user: user != null ? _mapSupabaseUser(user) : null,
        requiresEmailConfirmation: user != null && session == null,
      );
    } catch (error) {
      throw AppException.fromError(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw AppException.fromError(error);
    }
  }

  AppUser _mapSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}

