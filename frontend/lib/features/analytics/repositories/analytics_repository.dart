import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../home/models/dashboard.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<DashboardResponse> getAnalyticsData({required int month, required int year}) async {
    final response = await _apiClient.get('/api/dashboard/?month=$month&year=$year');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load analytics data: ${response.statusCode}');
    }
  }
}
