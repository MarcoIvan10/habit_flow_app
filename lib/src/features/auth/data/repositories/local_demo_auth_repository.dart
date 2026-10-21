import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../../domain/models/sign_up_result.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory implementation of [AuthRepository] used when Supabase credentials are not configured.
final class LocalDemoAuthRepository implements AuthRepository {
  /// Creates a [LocalDemoAuthRepository].
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
