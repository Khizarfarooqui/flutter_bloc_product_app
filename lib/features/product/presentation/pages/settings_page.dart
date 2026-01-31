import 'package:flutter/material.dart';

import '../../../../core/theme/theme_mode_scope.dart';
import '../widgets/app_bar_with_search.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        title: 'Settings',
        showSearch: false,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _SettingsContent(),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        const _ThemeSwitchTile(),
      ],
    );
  }
}

class _ThemeSwitchTile extends StatelessWidget {
  const _ThemeSwitchTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeModeScope.of(context).isDark;

    return Card(
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: theme.colorScheme.primary,
        ),
        title: const Text('Theme'),
        subtitle: Text(isDark ? 'Dark mode' : 'Light mode'),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            ThemeModeScope.of(context).toggle();
          },
        ),
      ),
    );
  }
}

