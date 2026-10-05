import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/profile/profile_screen.dart';
import 'package:etracker/features/auth/auth_state.dart';
import 'package:etracker/features/auth/auth_repository.dart';
import 'package:etracker/features/auth/models/user.dart';

class MockAuthRepository extends AuthRepository {
  bool hasTokenVal = true;
  bool logoutCalled = false;
  User? mockUser;

  @override
  Future<bool> hasToken() async => hasTokenVal;

  @override
  Future<User> getCurrentUser() async {
    if (!hasTokenVal) throw Exception('No token');
    return mockUser ?? User(id: 1, username: 'testuser', email: 'test@example.com');
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    hasTokenVal = false;
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;

  Widget createWidgetUnderTest(AuthState authState) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileScreen(authState: authState),
      ),
    );
  }

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  testWidgets('renders ProfileScreen with authenticated user information', (WidgetTester tester) async {
    mockAuthRepository.mockUser = User(id: 42, username: 'johndoe', email: 'john.doe@example.com');
    final authState = AuthState(authRepository: mockAuthRepository);
    await authState.checkAuthentication();

    await tester.pumpWidget(createWidgetUnderTest(authState));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('johndoe'), findsNWidgets(2));
    expect(find.text('john.doe@example.com'), findsNWidgets(2));
    expect(find.text('J'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('handles missing optional user information gracefully', (WidgetTester tester) async {
    mockAuthRepository.mockUser = User(id: 99, username: '', email: '');
    final authState = AuthState(authRepository: mockAuthRepository);
    await authState.checkAuthentication();

    await tester.pumpWidget(createWidgetUnderTest(authState));
    await tester.pumpAndSettle();

    expect(find.text('Unknown User'), findsOneWidget);
    expect(find.text('No email provided'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.text('Not set'), findsNWidgets(2));
  });

  testWidgets('handles null user gracefully', (WidgetTester tester) async {
    mockAuthRepository.hasTokenVal = false;
    final authState = AuthState(authRepository: mockAuthRepository);
    await authState.checkAuthentication();

    await tester.pumpWidget(createWidgetUnderTest(authState));
    await tester.pumpAndSettle();

    expect(find.text('Unknown User'), findsOneWidget);
    expect(find.text('No email provided'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.text('Not set'), findsNWidgets(3));
  });

  testWidgets('renders Settings navigation tile', (WidgetTester tester) async {
    mockAuthRepository.mockUser = User(id: 42, username: 'johndoe', email: 'john.doe@example.com');
    final authState = AuthState(authRepository: mockAuthRepository);
    await authState.checkAuthentication();

    await tester.pumpWidget(createWidgetUnderTest(authState));
    await tester.pumpAndSettle();

    final settingsTile = find.widgetWithText(ListTile, 'Settings');
    expect(settingsTile, findsOneWidget);
  });

  testWidgets('Logout interaction and expected logout behavior', (WidgetTester tester) async {
    mockAuthRepository.mockUser = User(id: 1, username: 'test', email: 'test@test.com');
    final authState = AuthState(authRepository: mockAuthRepository);
    await authState.checkAuthentication();

    await tester.pumpWidget(createWidgetUnderTest(authState));
    await tester.pumpAndSettle();

    final logoutButton = find.widgetWithText(ElevatedButton, 'Logout');
    expect(logoutButton, findsOneWidget);

    // Scroll to the logout button to make sure it is tappable
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();

    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(mockAuthRepository.logoutCalled, isTrue);
  });
}
