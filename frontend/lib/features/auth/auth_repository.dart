import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> login(String username, String password) async {
    final response = await _apiClient.postForm(
      '/login',
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      if (token != null) {
        await _tokenStorage.saveToken(token);
      } else {
        throw AuthException('Invalid response format');
      }
    } else {
      final errorData = _parseError(response.body);
      throw AuthException(errorData ?? 'Login failed');
    }
  }

  Future<User> register(String username, String email, String password) async {
    final response = await _apiClient.post(
      '/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      final errorData = _parseError(response.body);
      throw AuthException(errorData ?? 'Registration failed');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/me');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
       await _tokenStorage.deleteToken();
       throw AuthException('Unauthorized');
    } else {
      throw AuthException('Failed to fetch user');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  Future<bool> hasToken() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  String? _parseError(String body) {
    try {
      final data = jsonDecode(body);
      if (data['detail'] != null) {
        if (data['detail'] is String) {
          return data['detail'];
        }
        // Handle validation errors format
        if (data['detail'] is List && data['detail'].isNotEmpty) {
           return data['detail'][0]['msg']?.toString();
        }
      }
    } catch (_) {}
    return null;
  }
}
