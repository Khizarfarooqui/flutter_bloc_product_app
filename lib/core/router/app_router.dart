import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/product/presentation/pages/dashboard_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/settings_page.dart';
import 'shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/products',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) => '/products',
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductListPage(),
            ),
          ),
          GoRoute(
            path: '/products/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaterialPage(
                key: state.pageKey,
                child: ProductDetailsPage(productId: int.tryParse(id) ?? 0),
              );
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
