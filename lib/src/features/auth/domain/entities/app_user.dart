/// Immutable domain entity representing an authenticated application user.
final class AppUser {
  /// Creates an [AppUser] instance.
  const AppUser({
    required this.id,
    required this.email,
    this.createdAt,
    this.isDemo = false,
  });

  /// Unique identifier of the user.
  final String id;

  /// Normalized email address of the user.
  final String email;

  /// Optional account creation timestamp.
  final DateTime? createdAt;

  /// Indicates whether the user is operating in local demo mode.
  final bool isDemo;

  /// Short display name derived from the local part of [email].
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
