import 'dart:convert';
import '../../core/api/api_client.dart';
import 'models/dashboard.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<DashboardResponse> getDashboard({required int month, required int year}) async {
    final response = await _apiClient.get('/api/dashboard/?month=$month&year=$year');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }
}
