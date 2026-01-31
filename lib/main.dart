import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjector();
  runApp(const ProductDashboardApp());
}

class ProductDashboardApp extends StatefulWidget {
  const ProductDashboardApp({super.key});

  @override
  State<ProductDashboardApp> createState() => _ProductDashboardAppState();
}

class _ProductDashboardAppState extends State<ProductDashboardApp> {
  final ThemeModeNotifier _themeNotifier = ThemeModeNotifier();

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      notifier: _themeNotifier,
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Product Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeModeScope.of(context).mode,
            routerConfig: createRouter(),
          );
        },
      ),
    );
  }
}
