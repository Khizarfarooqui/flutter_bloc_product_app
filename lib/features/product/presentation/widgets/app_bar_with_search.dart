import 'package:flutter/material.dart';

import '../../../../core/router/drawer_scope.dart';

class AppBarWithSearch extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithSearch({
    super.key,
    required this.title,
    this.searchQuery,
    this.onSearchChanged,
    this.actions,
    this.showSearch = true,
  });

  final String title;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? actions;
  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final canOpenDrawer = DrawerScope.of(context) != null;

    return AppBar(
      leading: canOpenDrawer
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => DrawerScope.openDrawer(context),
              tooltip: 'Menu',
            )
          : null,
      title: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showSearch && isWide && onSearchChanged != null) ...[
            const SizedBox(width: 24),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }
}
