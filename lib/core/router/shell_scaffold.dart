import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/product/presentation/widgets/app_sidebar.dart';
import 'drawer_scope.dart';

class ShellScaffold extends StatefulWidget {
  const ShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(child: widget.child),
          ],
        ),
      );
    }
    return DrawerScope(
      scaffoldKey: _drawerKey,
      child: Scaffold(
        key: _drawerKey,
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_rounded),
                  title: const Text('Products'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/products');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/settings');
                  },
                ),
              ],
            ),
          ),
        ),
        body: widget.child,
      ),
    );
  }
}
