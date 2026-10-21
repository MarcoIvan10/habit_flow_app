import '../entities/app_user.dart';

/// Immutable Dart 3 Record representing the outcome of a user registration request.
typedef SignUpResult = ({
  AppUser? user,
  bool requiresEmailConfirmation,
});

