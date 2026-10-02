import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/budget.dart';

class BudgetsRepository {
  final ApiClient _apiClient;

  BudgetsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Budget>> getBudgets() async {
    final response = await _apiClient.get('/api/budgets/');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load budgets: ${response.statusCode}');
    }
  }

  Future<Budget> createBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.post('/api/budgets/', body: {
      'category_id': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    });

    if (response.statusCode == 201) {
      return Budget.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create budget: ${response.statusCode}');
    }
  }

  Future<Budget> updateBudget(
    int id, {
    int? categoryId,
    double? amount,
    int? month,
    int? year,
  }) async {
    final body = <String, dynamic>{};
    if (categoryId != null) body['category_id'] = categoryId;
    if (amount != null) body['amount'] = amount;
    if (month != null) body['month'] = month;
    if (year != null) body['year'] = year;

    final response = await _apiClient.put('/api/budgets/$id', body: body);

    if (response.statusCode == 200) {
      return Budget.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update budget: ${response.statusCode}');
    }
  }

  Future<void> deleteBudget(int id) async {
    final response = await _apiClient.delete('/api/budgets/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete budget: ${response.statusCode}');
    }
  }
}
