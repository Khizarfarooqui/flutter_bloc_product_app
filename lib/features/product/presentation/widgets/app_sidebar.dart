import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.dashboard_rounded, color: colorScheme.primary, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Product Hub',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: location == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          _NavItem(
            icon: Icons.inventory_2_rounded,
            label: 'Products',
            isSelected: location.startsWith('/products'),
            onTap: () => context.go('/products'),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isSelected: location == '/settings',
            onTap: () => context.go('/settings'),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'v1.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}
