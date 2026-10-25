import '../mock/mock_catalog.dart';
import '../models/alert_rule.dart';
import '../models/holding.dart';

/// Watchlist, holdings and alerts.
///
/// Phase 4 replaces the in-memory implementation with Supabase tables behind
/// row level security; the screens only ever see this interface.
abstract interface class UserDataRepository {
  List<String> watchlist();
  List<Holding> holdings();
  List<AlertRule> alerts();

  void setWatchlist(List<String> assetIds);
  void setHoldings(List<Holding> holdings);
  void setAlerts(List<AlertRule> alerts);
}

/// Keeps user data in memory for the mock phase.
class MemoryUserDataRepository implements UserDataRepository {
  MemoryUserDataRepository()
    : _watchlist = [...MockCatalog.watchlist],
      _holdings = [...MockCatalog.holdings],
      _alerts = [...MockCatalog.alerts];

  List<String> _watchlist;
  List<Holding> _holdings;
  List<AlertRule> _alerts;

  @override
  List<String> watchlist() => List.unmodifiable(_watchlist);

  @override
  List<Holding> holdings() => List.unmodifiable(_holdings);

  @override
  List<AlertRule> alerts() => List.unmodifiable(_alerts);

  @override
  void setWatchlist(List<String> assetIds) => _watchlist = [...assetIds];

  @override
  void setHoldings(List<Holding> holdings) => _holdings = [...holdings];

  @override
  void setAlerts(List<AlertRule> alerts) => _alerts = [...alerts];
}
