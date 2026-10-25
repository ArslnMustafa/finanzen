/// Why a request did not produce data.
enum FailureKind {
  /// No connection, DNS failure, timeout.
  network,

  /// Source answered with an error or rate-limited us.
  source,

  /// Logged-out or expired session.
  auth,

  /// Anything we did not foresee.
  unknown,
}

/// An error the user may end up reading, so it carries Turkish text.
class AppFailure implements Exception {
  const AppFailure(this.kind, {this.detail});

  const AppFailure.network({String? detail})
    : this(FailureKind.network, detail: detail);

  const AppFailure.source({String? detail})
    : this(FailureKind.source, detail: detail);

  final FailureKind kind;

  /// Technical detail; logged, never shown as-is.
  final String? detail;

  /// Short sentence suitable for the interface.
  String get message => switch (kind) {
    FailureKind.network =>
      'Bağlantı kurulamadı. Son bilinen fiyatları gösteriyoruz.',
    FailureKind.source =>
      'Fiyat kaynağı şu anda yanıt vermiyor. Birazdan tekrar denenecek.',
    FailureKind.auth => 'Oturumun sona ermiş. Tekrar giriş yapman gerekiyor.',
    FailureKind.unknown => 'Beklenmedik bir hata oldu. Tekrar dener misin?',
  };

  @override
  String toString() => 'AppFailure(${kind.name}, $detail)';
}

/// Turns any thrown object into a message the user can read.
String messageFor(Object error) => error is AppFailure
    ? error.message
    : const AppFailure(FailureKind.unknown).message;
