import 'dart:async';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// Stand-in used when the app is built without Supabase credentials.
///
/// It keeps phase 1 behaviour: somebody is always signed in, so the screens
/// can be opened and the mock data browsed without a backend.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository();

  static const _demoUser = AppUser(
    id: 'demo-user',
    email: 'demo@finanstakip.app',
    displayName: 'Mustafa',
  );

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user = _demoUser;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get changes => _controller.stream;

  @override
  bool get supportsGoogle => false;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _user = AppUser(id: 'demo-user', email: email);
    _controller.add(_user);
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _user = AppUser(id: 'demo-user', email: email, displayName: displayName);
    _controller.add(_user);
    return SignUpOutcome.signedIn;
  }

  @override
  Future<void> signInWithGoogle() async {
    throw const AuthFailure('Demo modunda Google ile giriş yok.');
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}
