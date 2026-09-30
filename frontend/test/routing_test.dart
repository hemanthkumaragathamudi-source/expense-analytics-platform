import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:etracker/features/auth/auth_state.dart';
import 'package:etracker/routing/app_router.dart';
import 'package:etracker/features/auth/auth_repository.dart';
import 'package:etracker/features/auth/models/user.dart';

class TestMockAuthRepo extends AuthRepository {
  bool _hasToken = false;

  void setToken(bool val) => _hasToken = val;

  @override
  Future<bool> hasToken() async => _hasToken;

  @override
  Future<User> getCurrentUser() async {
    return User(id: 1, username: 'testuser', email: 'test@example.com');
  }

  @override
  Future<void> logout() async {
    _hasToken = false;
  }
}

void main() {
  testWidgets('Unauthenticated user routes to login', (WidgetTester tester) async {
    final repo = TestMockAuthRepo();
    repo.setToken(false);
    final authState = AuthState(authRepository: repo);
    await authState.checkAuthentication();

    final appRouter = AppRouter(authState);

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: appRouter.router,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Username or Email'), findsOneWidget);
  });

  testWidgets('Authenticated user routes to shell (Home)', (WidgetTester tester) async {
    final repo = TestMockAuthRepo();
    repo.setToken(true);
    final authState = AuthState(authRepository: repo);
    await authState.checkAuthentication();

    final appRouter = AppRouter(authState);

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: appRouter.router,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen (Placeholder)'), findsOneWidget);
    // Bottom nav bar items
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
