import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionsRepository {
  final ApiClient _apiClient;

  TransactionsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Transaction>> getTransactions({
    int? categoryId,
    String? transactionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (transactionType != null) queryParams['transaction_type'] = transactionType;
    if (startDate != null) queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
    if (endDate != null) queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);

    final uri = Uri(path: '/api/transactions/', queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await _apiClient.get(uri.toString());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _apiClient.get('/api/transactions/$id');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Transaction.fromJson(json);
    } else {
      throw Exception('Failed to load transaction: ${response.statusCode}');
    }
  }

  Future<Transaction> createTransaction({
    required int userId,
    required DateTime date,
    required int categoryId,
    String? description,
    required double amount,
    required String transactionType,
    int? paymentMethodId,
    String? notes,
  }) async {
    final body = {
      'user_id': userId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category_id': categoryId,
      'amount': amount,
      'transaction_type': transactionType,
    };

    if (description != null && description.isNotEmpty) body['description'] = description;
    if (paymentMethodId != null) body['payment_method_id'] = paymentMethodId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final response = await _apiClient.post('/api/transactions/', body: body);

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Transaction.fromJson(json);
    } else {
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  Future<Transaction> updateTransaction(int id, {
    DateTime? date,
    int? categoryId,
    String? description,
    double? amount,
    String? transactionType,
    int? paymentMethodId,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (date != null) body['date'] = DateFormat('yyyy-MM-dd').format(date);
    if (categoryId != null) body['category_id'] = categoryId;
    if (description != null) body['description'] = description;
    if (amount != null) body['amount'] = amount;
    if (transactionType != null) body['transaction_type'] = transactionType;
    if (paymentMethodId != null) body['payment_method_id'] = paymentMethodId;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.put('/api/transactions/$id', body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Transaction.fromJson(json);
    } else {
      throw Exception('Failed to update transaction: ${response.body}');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await _apiClient.delete('/api/transactions/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${response.body}');
    }
  }
}
