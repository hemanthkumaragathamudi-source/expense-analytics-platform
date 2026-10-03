import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/transactions/repositories/payment_methods_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('PaymentMethodsRepository', () {
    late PaymentMethodsRepository repository;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = PaymentMethodsRepository(apiClient: mockApiClient);
    });

    test('getPaymentMethods returns list of payment methods on 200', () async {
      when(() => mockApiClient.get('/api/payment-methods/')).thenAnswer(
        (_) async => http.Response('[{"id": 1, "name": "Cash"}, {"id": 2, "name": "Credit Card"}]', 200),
      );

      final methods = await repository.getPaymentMethods();

      expect(methods.length, 2);
      expect(methods[0].id, 1);
      expect(methods[0].name, 'Cash');
      expect(methods[1].id, 2);
      expect(methods[1].name, 'Credit Card');
    });

    test('getPaymentMethods throws Exception on non-200', () async {
      when(() => mockApiClient.get('/api/payment-methods/')).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(() => repository.getPaymentMethods(), throwsException);
    });
  });
}
