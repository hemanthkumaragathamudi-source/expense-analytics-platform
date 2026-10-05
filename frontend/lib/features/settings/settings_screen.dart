import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = ThemeProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Appearance Section
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.gapSm,
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeName(themeState.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeModal(context),
              ),
            ),
            AppSpacing.gapLg,

            // Management Section
            Text(
              'Management',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.gapSm,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payment_outlined),
                    title: const Text('Payment Methods'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/profile/payment-methods');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Categories'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/profile/categories');
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // About Section
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.gapSm,
            AppCard(
              padding: EdgeInsets.zero,
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('E TRACKER'),
                    subtitle: Text('Version 1.0.0+1'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        final themeState = ThemeProvider.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: AppSpacing.paddingMd,
                child: Text(
                  'Select Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_system_daydream_outlined),
                title: const Text('System'),
                trailing: themeState.themeMode == ThemeMode.system
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeState.setThemeMode(ThemeMode.system);
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text('Light'),
                trailing: themeState.themeMode == ThemeMode.light
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeState.setThemeMode(ThemeMode.light);
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark'),
                trailing: themeState.themeMode == ThemeMode.dark
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeState.setThemeMode(ThemeMode.dark);
                  Navigator.pop(bottomSheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
