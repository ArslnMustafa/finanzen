import '../../../core/format/money.dart';

/// A row of the `profiles` table.
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.baseCurrency,
  });

  factory Profile.fromRow(Map<String, dynamic> row) => Profile(
    id: row['id'] as String,
    displayName: row['display_name'] as String?,
    baseCurrency: Currency.fromCode((row['base_currency'] as String?) ?? 'TRY'),
  );

  final String id;
  final String? displayName;

  /// Currency every total is shown in.
  final Currency baseCurrency;
}
