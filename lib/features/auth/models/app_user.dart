/// The signed-in user, as the app needs them.
///
/// Deliberately smaller than Supabase's `User`: the screens only need these
/// three fields, and keeping it separate means the auth source can change
/// without touching them.
class AppUser {
  const AppUser({required this.id, required this.email, this.displayName});

  final String id;
  final String email;
  final String? displayName;

  /// Name to greet the user with; falls back to the part before the `@`.
  String get greetingName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final local = email.split('@').first;
    if (local.isEmpty) return 'Yatırımcı';
    return local[0].toUpperCase() + local.substring(1);
  }

  AppUser copyWith({String? displayName}) => AppUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
  );
}
