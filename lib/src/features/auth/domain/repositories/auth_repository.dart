import '../entities/app_user.dart';

/// Resultado de registro usando un Record de Dart 3:
/// - `user`: Usuario autenticado o creado.
/// - `requiresEmailConfirmation`: `true` si Supabase requiere verificar el correo antes de iniciar sesión.
typedef SignUpResult = ({
  AppUser? user,
  bool requiresEmailConfirmation,
});

/// Contrato de repositorio de autenticación (Principio de Inversión de Dependencias - SOLID).
///
/// La capa de presentación y dominio solo conocen esta interfaz, nunca `SupabaseClient`.
abstract interface class AuthRepository {
  /// Usuario actualmente autenticado, o `null` si no existe sesión activa.
  AppUser? get currentUser;

  /// Flujo reactivo de cambios en la sesión del usuario.
  Stream<AppUser?> watchAuthStateChanges();

  /// Inicia sesión con correo electrónico y contraseña.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registra una nueva cuenta con correo electrónico y contraseña.
  Future<SignUpResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Cierra la sesión activa de forma segura.
  Future<void> signOut();
}

