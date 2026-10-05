import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/payment_methods/models/payment_method.dart';
import 'package:etracker/features/payment_methods/repositories/payment_methods_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late PaymentMethodsRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = PaymentMethodsRepository(apiClient: mockApiClient);
  });

  group('PaymentMethodsRepository', () {
    const paymentMethodJson = {
      'id': 1,
      'name': 'Cash',
    };

    final paymentMethod = PaymentMethod.fromJson(paymentMethodJson);

    test('getPaymentMethods should return list of payment methods on success', () async {
      when(() => mockApiClient.get('/api/payment-methods/'))
          .thenAnswer((_) async => http.Response(jsonEncode([paymentMethodJson]), 200));

      final result = await repository.getPaymentMethods();

      expect(result.length, 1);
      expect(result.first, equals(paymentMethod));
      verify(() => mockApiClient.get('/api/payment-methods/')).called(1);
    });

    test('getPaymentMethods should throw exception on failure', () async {
      when(() => mockApiClient.get('/api/payment-methods/'))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => repository.getPaymentMethods(), throwsException);
    });

    test('getPaymentMethod should return a payment method on success', () async {
      when(() => mockApiClient.get('/api/payment-methods/1'))
          .thenAnswer((_) async => http.Response(jsonEncode(paymentMethodJson), 200));

      final result = await repository.getPaymentMethod(1);

      expect(result, equals(paymentMethod));
      verify(() => mockApiClient.get('/api/payment-methods/1')).called(1);
    });

    test('createPaymentMethod should return newly created payment method on success', () async {
      when(() => mockApiClient.post('/api/payment-methods/', body: {'name': 'Cash'}))
          .thenAnswer((_) async => http.Response(jsonEncode(paymentMethodJson), 201));

      final result = await repository.createPaymentMethod('Cash');

      expect(result, equals(paymentMethod));
    });

    test('updatePaymentMethod should return updated payment method on success', () async {
      when(() => mockApiClient.put('/api/payment-methods/1', body: {'name': 'Bank'}))
          .thenAnswer((_) async => http.Response(jsonEncode({'id': 1, 'name': 'Bank'}), 200));

      final result = await repository.updatePaymentMethod(1, 'Bank');

      expect(result.name, 'Bank');
    });

    test('deletePaymentMethod should complete normally on success', () async {
      when(() => mockApiClient.delete('/api/payment-methods/1'))
          .thenAnswer((_) async => http.Response('', 204));

      await expectLater(repository.deletePaymentMethod(1), completes);
    });

    test('deletePaymentMethod should extract backend error on failure', () async {
      when(() => mockApiClient.delete('/api/payment-methods/1'))
          .thenAnswer((_) async => http.Response(jsonEncode({'detail': 'Cannot delete used payment method'}), 400));

      expect(
        () => repository.deletePaymentMethod(1),
        throwsA(predicate((e) => e.toString().contains('Cannot delete used payment method'))),
      );
    });
  });
}
