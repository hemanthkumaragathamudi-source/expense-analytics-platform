import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  final AuthState authState;

  const ProfileScreen({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile Screen (Placeholder)'),
              AppSpacing.gapLg,
              if (authState.user != null)
                Text('Logged in as: ${authState.user!.username}'),
              AppSpacing.gapLg,
              AppButton(
                text: 'Logout',
                onPressed: () {
                  authState.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
