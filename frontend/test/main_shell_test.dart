import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:etracker/features/auth/auth_state.dart';
import 'package:etracker/routing/app_router.dart';
import 'package:etracker/features/auth/auth_repository.dart';
import 'package:etracker/features/auth/models/user.dart';

class ShellMockAuthRepo extends AuthRepository {
  @override
  Future<bool> hasToken() async => true;

  @override
  Future<User> getCurrentUser() async {
    return User(id: 1, username: 'testuser', email: 'test@example.com');
  }
}

void main() {
  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    final authState = AuthState(authRepository: ShellMockAuthRepo());
    await authState.checkAuthentication();
    final appRouter = AppRouter(authState);

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: appRouter.router,
    ));
    await tester.pumpAndSettle();

    // Verify initial tab is Home
    expect(find.text('Home Screen (Placeholder)'), findsOneWidget);

    // Tap Transactions
    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();
    expect(find.text('Transactions Screen (Placeholder)'), findsOneWidget);

    // Tap Budgets
    await tester.tap(find.text('Budgets').last);
    await tester.pumpAndSettle();
    expect(find.text('Budgets Screen (Placeholder)'), findsOneWidget);

    // Tap Analytics
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();
    expect(find.text('Analytics Screen (Placeholder)'), findsOneWidget);

    // Tap Profile
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Profile Screen (Placeholder)'), findsOneWidget);
  });
}
