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
    await tester.pump();
    await tester.pump();

    // Verify initial tab is Home
    expect(find.text('Hello, there'), findsWidgets);

    // Tap Transactions
    await tester.tap(find.text('Transactions').last);
    await tester.pump();
    await tester.pump();
    expect(find.widgetWithText(AppBar, 'Transactions'), findsOneWidget);

    // Tap Budgets
    await tester.tap(find.text('Budgets').last);
    await tester.pump();
    await tester.pump();
    expect(find.widgetWithText(AppBar, 'Budgets'), findsOneWidget);

    // Tap Analytics
    await tester.tap(find.text('Analytics').last);
    await tester.pump();
    await tester.pump();
    expect(find.widgetWithText(AppBar, 'Analytics'), findsOneWidget);

    // Tap Profile
    await tester.tap(find.text('Profile').last);
    await tester.pump();
    await tester.pump();
    expect(find.text('Settings').first, findsOneWidget); // Found in the new ProfileScreen
  });
}
