import '../entities/app_user.dart';
import '../models/sign_up_result.dart';

/// Abstract repository contract for authentication and session lifecycle operations.
abstract interface class AuthRepository {
  /// Currently authenticated user, or `null` if no session is active.
  AppUser? get currentUser;

  /// Emits the current [AppUser] whenever the authentication state changes.
  Stream<AppUser?> watchAuthStateChanges();

  /// Authenticates a user using [email] and [password].
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user account using [email] and [password].
  Future<SignUpResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Terminates the active user session.
  Future<void> signOut();
}
