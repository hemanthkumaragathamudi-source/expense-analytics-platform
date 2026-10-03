import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/home/home_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transactions/transaction_form_screen.dart';
import '../features/transactions/models/transaction.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/categories/categories_screen.dart';

class AppRouter {
  final AuthState authState;

  AppRouter(this.authState);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authState,
    redirect: (context, state) {
      final status = authState.status;

      // Still loading authentication state, stay where we are (or show splash)
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isUnauthenticated = status == AuthStatus.unauthenticated;

      if (isUnauthenticated) {
        // If unauthenticated and going to register, allow it.
        // Otherwise, redirect to login.
        return isGoingToRegister ? null : '/login';
      }

      // If authenticated but trying to go to login/register, redirect to home.
      if (isGoingToLogin || isGoingToRegister) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(authState: authState),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(authState: authState),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Wrap the loading state in the shell or check at the root level?
          // If status is loading and we got here, it's safe to just show the shell
          // or a loading indicator. The redirect guard handles the real protection.
          if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => TransactionFormScreen(authState: authState),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final transaction = state.extra as Transaction?;
                      return TransactionFormScreen(
                        authState: authState,
                        transaction: transaction,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/budgets',
                builder: (context, state) => const BudgetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => ProfileScreen(authState: authState),
                routes: [
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
