import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/alerts/alerts_screen.dart';
import '../features/asset_detail/asset_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/markets/markets_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Routes. Each main screen keeps its own navigation stack so switching tabs
/// does not throw away where the user was, and the web URLs stay readable.
final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
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
  ],
);
