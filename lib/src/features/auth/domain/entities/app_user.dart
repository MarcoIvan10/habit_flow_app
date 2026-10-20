/// Entidad de dominio pura que representa al usuario autenticado.
///
/// Desacopla la capa de dominio y presentación del tipo `User` de `supabase_flutter`.
final class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.createdAt,
    this.isDemo = false,
  });

  final String id;
  final String email;
  final DateTime? createdAt;
  final bool isDemo;

  /// Nombre corto derivado del correo para mostrar en encabezados.
  String get displayName {
    final parts = email.split('@');
    return parts.first.isNotEmpty ? parts.first : 'Usuario';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          isDemo == other.isDemo;

  @override
  int get hashCode => Object.hash(id, email, isDemo);
}

