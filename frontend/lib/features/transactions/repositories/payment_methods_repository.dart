import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/payment_method.dart';

class PaymentMethodsRepository {
  final ApiClient _apiClient;

  PaymentMethodsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _apiClient.get('/api/payment-methods/');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => PaymentMethod.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment methods: ${response.statusCode}');
    }
  }
}
