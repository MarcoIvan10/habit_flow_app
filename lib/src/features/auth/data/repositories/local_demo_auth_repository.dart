import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación en memoria de [AuthRepository] (Principio de Sustitución de Liskov).
///
/// Permite utilizar y probar el flujo completo de autenticación cuando aún no se han
/// inyectado las credenciales de Supabase en `.env` o `--dart-define`.
final class LocalDemoAuthRepository implements AuthRepository {
  LocalDemoAuthRepository();

  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> watchAuthStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final user = AppUser(
      id: 'demo-user-001',
      email: email.trim().toLowerCase(),
      createdAt: DateTime.now(),
      isDemo: true,
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<SignUpResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return (
      user: user,
      requiresEmailConfirmation: false,
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _controller.add(null);
  }
}

