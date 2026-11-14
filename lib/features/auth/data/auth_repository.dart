import '../models/app_user.dart';

/// What happened after a sign-up attempt.
enum SignUpOutcome {
  /// The user is signed in right away (e-mail confirmation is off).
  signedIn,

  /// Supabase sent a confirmation mail and there is no session yet.
  confirmationRequired,
}

/// An error worth showing to the user, already in Turkish.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure($message)';
}

/// Everything the app needs from an authentication source.
abstract interface class AuthRepository {
  /// Who is signed in right now, synchronously. Null when nobody is.
  AppUser? get currentUser;

  /// Emits on every sign-in, sign-out and token refresh.
  Stream<AppUser?> get changes;

  /// False in demo mode and wherever Google sign-in is not configured.
  bool get supportsGoogle;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
