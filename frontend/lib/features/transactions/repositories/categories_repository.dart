import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/category.dart';

class CategoriesRepository {
  final ApiClient _apiClient;

  CategoriesRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/api/categories/');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }
}
