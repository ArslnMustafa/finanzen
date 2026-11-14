import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/app_user.dart';
import 'auth_repository.dart';

/// Authentication against Supabase.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final sb.GoTrueClient _auth;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> get changes =>
      _auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));

  @override
  bool get supportsGoogle => true;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(email: email.trim(), password: password);
    } on sb.AuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    } catch (_) {
      throw const AuthFailure(_networkMessage);
    }
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        // The 0003 trigger reads this when it creates the profile row.
        data: {'display_name': displayName.trim()},
      );
      return response.session == null
          ? SignUpOutcome.confirmationRequired
          : SignUpOutcome.signedIn;
    } on sb.AuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    } catch (_) {
      throw const AuthFailure(_networkMessage);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(sb.OAuthProvider.google);
    } on sb.AuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    } catch (_) {
      throw const AuthFailure(_networkMessage);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on sb.AuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    } catch (_) {
      throw const AuthFailure(_networkMessage);
    }
  }

  AppUser? _toAppUser(sb.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final name = (metadata['display_name'] ?? metadata['full_name']) as String?;
    return AppUser(id: user.id, email: user.email ?? '', displayName: name);
  }

  static const _networkMessage =
      'Bağlantı kurulamadı. İnternetini kontrol edip tekrar dener misin?';

  /// Supabase answers in English; the user reads Turkish.
  static String _messageFor(sb.AuthException error) {
    return switch (error.code) {
      'invalid_credentials' => 'E-posta veya şifre hatalı.',
      'email_not_confirmed' =>
        'E-posta adresin henüz doğrulanmamış. Gelen kutunu kontrol et.',
      'user_already_exists' || 'email_exists' =>
        'Bu e-posta ile bir hesap zaten var. Giriş yapmayı dene.',
      'weak_password' => 'Şifre çok zayıf; en az 6 karakter olmalı.',
      'over_email_send_rate_limit' || 'over_request_rate_limit' =>
        'Çok fazla deneme yapıldı. Birkaç dakika sonra tekrar dene.',
      'validation_failed' => 'E-posta adresi geçerli görünmüyor.',
      'signup_disabled' => 'Yeni kayıt şu anda kapalı.',
      _ => 'Giriş yapılamadı: ${error.message}',
    };
  }
}
