import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/auth/auth_state.dart';
import 'package:etracker/features/auth/auth_repository.dart';
import 'package:etracker/features/auth/models/user.dart';

class MockAuthRepository extends AuthRepository {
  bool hasTokenVal = false;
  bool shouldThrowOnUser = false;
  bool loginSuccess = true;

  @override
  Future<bool> hasToken() async => hasTokenVal;

  @override
  Future<User> getCurrentUser() async {
    if (shouldThrowOnUser) throw AuthException('Error');
    return User(id: 1, username: 'testuser', email: 'test@example.com');
  }

  @override
  Future<void> login(String username, String password) async {
    if (!loginSuccess) throw AuthException('Invalid login');
  }

  @override
  Future<User> register(String username, String email, String password) async {
    return User(id: 1, username: username, email: email);
  }

  @override
  Future<void> logout() async {
    hasTokenVal = false;
  }
}

void main() {
  group('AuthState', () {
    late AuthState authState;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authState = AuthState(authRepository: mockRepository);
    });

    test('initial status is AuthStatus.initial', () {
      expect(authState.status, AuthStatus.initial);
    });

    test('checkAuthentication without token sets unauthenticated', () async {
      mockRepository.hasTokenVal = false;
      await authState.checkAuthentication();
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, isNull);
    });

    test('checkAuthentication with token sets authenticated', () async {
      mockRepository.hasTokenVal = true;
      await authState.checkAuthentication();
      expect(authState.status, AuthStatus.authenticated);
      expect(authState.user, isNotNull);
      expect(authState.user!.username, 'testuser');
    });

    test('login success sets authenticated', () async {
      mockRepository.loginSuccess = true;
      final result = await authState.login('test', 'password');
      expect(result, isTrue);
      expect(authState.status, AuthStatus.authenticated);
    });

    test('login failure sets unauthenticated and sets error', () async {
      mockRepository.loginSuccess = false;
      final result = await authState.login('test', 'wrong');
      expect(result, isFalse);
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.errorMessage, 'Invalid login');
    });

    test('logout sets unauthenticated', () async {
      mockRepository.hasTokenVal = true;
      await authState.checkAuthentication(); // become authenticated

      await authState.logout();
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, isNull);
    });
  });
}
