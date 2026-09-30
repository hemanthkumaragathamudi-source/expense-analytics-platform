import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import 'auth_state.dart';

class LoginScreen extends StatefulWidget {
  final AuthState authState;

  const LoginScreen({super.key, required this.authState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    widget.authState.login(
      _usernameController.text,
      _passwordController.text
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authState.status == AuthStatus.loading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                AppSpacing.gapLg,
                if (widget.authState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      widget.authState.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                AppTextField(
                  controller: _usernameController,
                  labelText: 'Username or Email',
                  hintText: 'Enter your username or email',
                ),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                ),
                AppSpacing.gapLg,
                AppButton(
                  text: isLoading ? 'Logging in...' : 'Login',
                  onPressed: isLoading ? null : _onLogin,
                ),
                AppSpacing.gapMd,
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/register'),
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
