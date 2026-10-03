import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/category.dart';

class CategoriesRepository {
  final ApiClient _apiClient;

  CategoriesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> createCategory(String name, String type) async {
    final response = await _apiClient.post(
      '/categories/',
      body: {'name': name, 'type': type},
    );
    if (response.statusCode == 201) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<Category> updateCategory(int id, String name, String type) async {
    final response = await _apiClient.put(
      '/categories/$id',
      body: {'name': name, 'type': type},
    );
    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await _apiClient.delete('/categories/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
}
