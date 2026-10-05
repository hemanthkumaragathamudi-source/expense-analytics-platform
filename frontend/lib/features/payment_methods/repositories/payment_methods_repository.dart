import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/payment_method.dart';

class PaymentMethodsRepository {
  final ApiClient _apiClient;

  PaymentMethodsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _apiClient.get('/api/payment-methods/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<PaymentMethod> getPaymentMethod(int id) async {
    final response = await _apiClient.get('/api/payment-methods/$id');
    if (response.statusCode == 200) {
      return PaymentMethod.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load payment method');
    }
  }

  Future<PaymentMethod> createPaymentMethod(String name) async {
    final response = await _apiClient.post(
      '/api/payment-methods/',
      body: {'name': name},
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PaymentMethod.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to create payment method';
      try {
        final body = jsonDecode(response.body);
        if (body['detail'] != null) {
          errorMessage = body['detail'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<PaymentMethod> updatePaymentMethod(int id, String name) async {
    final response = await _apiClient.put(
      '/api/payment-methods/$id',
      body: {'name': name},
    );
    if (response.statusCode == 200) {
      return PaymentMethod.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to update payment method';
      try {
        final body = jsonDecode(response.body);
        if (body['detail'] != null) {
          errorMessage = body['detail'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<void> deletePaymentMethod(int id) async {
    final response = await _apiClient.delete('/api/payment-methods/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      String errorMessage = 'Failed to delete payment method';
      try {
        final body = jsonDecode(response.body);
        if (body['detail'] != null) {
          errorMessage = body['detail'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
