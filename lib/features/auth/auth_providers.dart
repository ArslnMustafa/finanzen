import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/config/env.dart';
import '../../core/format/money.dart';
import 'data/auth_repository.dart';
import 'data/demo_auth_repository.dart';
import 'data/supabase_auth_repository.dart';
import 'models/app_user.dart';
import 'models/profile.dart';

/// Supabase when the app was built with credentials, the demo stand-in
/// otherwise. Tests override this.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!Env.hasSupabase) return DemoAuthRepository();
  return SupabaseAuthRepository(sb.Supabase.instance.client.auth);
});

/// Who is signed in. Starts with the restored session, so there is no
/// loading flash between launch and the first frame.
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.changes.listen((user) => state = user);
    ref.onDispose(subscription.cancel);
    return repository.currentUser;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider) != null,
);

/// The signed-in user's `profiles` row.
///
/// Falls back to what the session already knows, so the greeting is right
/// even before the row arrives (or in demo mode, where there is no table).
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  final fallback = Profile(
    id: user.id,
    displayName: user.greetingName,
    baseCurrency: Currency.tryLira,
  );
  if (!Env.hasSupabase) return fallback;

  final row = await sb.Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
  if (row == null) return fallback;
  return Profile.fromRow(row);
});

/// Name shown in the greeting on the home screen.
final userNameProvider = Provider<String>((ref) {
  final profileName = ref.watch(profileProvider).value?.displayName;
  if (profileName != null && profileName.trim().isNotEmpty) {
    return profileName.trim();
  }
  return ref.watch(authProvider)?.greetingName ?? 'Yatırımcı';
});

/// Currency every total is converted into.
final baseCurrencyProvider = Provider<Currency>(
  (ref) => ref.watch(profileProvider).value?.baseCurrency ?? Currency.tryLira,
);
