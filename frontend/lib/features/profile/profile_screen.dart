import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  final AuthState authState;

  const ProfileScreen({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text(
                      user?.username.isNotEmpty == true
                          ? user!.username.substring(0, 1).toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    (user?.username == null || user!.username.isEmpty)
                        ? 'Unknown User'
                        : user.username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    (user?.email == null || user!.email.isEmpty)
                        ? 'No email provided'
                        : user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,

            // Account Section
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.gapSm,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Username'),
                    subtitle: Text((user?.username == null || user!.username.isEmpty)
                        ? 'Not set'
                        : user.username),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text((user?.email == null || user!.email.isEmpty)
                        ? 'Not set'
                        : user.email),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('User ID'),
                    subtitle: Text(user?.id.toString() ?? 'Not set'),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Settings Section
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.gapSm,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // To be implemented in future
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,

            // Logout Section
            AppButton(
              text: 'Logout',
              onPressed: () {
                authState.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
