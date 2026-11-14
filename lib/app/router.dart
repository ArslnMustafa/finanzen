import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/alerts/alerts_screen.dart';
import '../features/asset_detail/asset_detail_screen.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/models/app_user.dart';
import '../features/home/home_screen.dart';
import '../features/markets/markets_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import '../features/settings/settings_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Where anyone without a session ends up.
const _loginPath = '/giris';

/// Routes. Each main screen keeps its own navigation stack so switching tabs
/// does not throw away where the user was, and the web URLs stay readable.
///
/// Anyone without a session is sent to `/giris`; signing in or out rebuilds
/// the routes through [refreshListenable].
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<AppUser?>(ref.read(authProvider));
  ref.listen<AppUser?>(authProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(authProvider) != null;
      final atLogin = state.matchedLocation == _loginPath;
      if (!signedIn) return atLogin ? null : _loginPath;
      if (atLogin) return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/markets',
                name: 'markets',
                builder: (context, state) => MarketsScreen(
                  focusSearch: state.uri.queryParameters['ara'] == '1',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portfolio',
                name: 'portfolio',
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                name: 'alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/asset/:symbol',
        name: 'asset',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            AssetDetailScreen(symbol: state.pathParameters['symbol']!),
      ),
      GoRoute(
        path: _loginPath,
        name: 'login',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/ayarlar',
        name: 'settings',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
