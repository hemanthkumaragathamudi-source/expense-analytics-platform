import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/transactions/repositories/transactions_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('TransactionsRepository', () {
    late TransactionsRepository repository;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = TransactionsRepository(apiClient: mockApiClient);
    });

    final txJson = '''
    {
      "id": 1,
      "user_id": 1,
      "date": "2023-10-01",
      "category_id": 2,
      "description": "Coffee",
      "amount": 4.5,
      "transaction_type": "EXPENSE",
      "payment_method_id": 3,
      "notes": "Morning coffee",
      "created_at": "2023-10-01T08:00:00Z",
      "updated_at": "2023-10-01T08:00:00Z"
    }
    ''';

    test('getTransactions returns list of transactions on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response('[$txJson]', 200),
      );

      final transactions = await repository.getTransactions();

      expect(transactions.length, 1);
      expect(transactions[0].id, 1);
      expect(transactions[0].amount, 4.5);
    });

    test('getTransactions applies query parameters correctly', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response('[]', 200),
      );

      await repository.getTransactions(
        categoryId: 2,
        transactionType: 'EXPENSE',
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 31),
      );

      final captured = verify(() => mockApiClient.get(captureAny())).captured;
      final url = captured.first as String;

      expect(url.contains('category_id=2'), isTrue);
      expect(url.contains('transaction_type=EXPENSE'), isTrue);
      expect(url.contains('start_date=2023-10-01'), isTrue);
      expect(url.contains('end_date=2023-10-31'), isTrue);
    });

    test('getTransaction returns transaction on 200', () async {
      when(() => mockApiClient.get('/api/transactions/1')).thenAnswer(
        (_) async => http.Response(txJson, 200),
      );

      final transaction = await repository.getTransaction(1);

      expect(transaction.id, 1);
      expect(transaction.amount, 4.5);
    });

    test('createTransaction returns new transaction on 201', () async {
      when(() => mockApiClient.post('/api/transactions/', body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(txJson, 201),
      );

      final transaction = await repository.createTransaction(
        userId: 1,
        date: DateTime(2023, 10, 1),
        categoryId: 2,
        amount: 4.5,
        transactionType: 'EXPENSE',
      );

      expect(transaction.id, 1);
      expect(transaction.amount, 4.5);
    });

    test('updateTransaction returns updated transaction on 200', () async {
      when(() => mockApiClient.put('/api/transactions/1', body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(txJson, 200),
      );

      final transaction = await repository.updateTransaction(
        1,
        amount: 4.5,
      );

      expect(transaction.id, 1);
      expect(transaction.amount, 4.5);
    });

    test('deleteTransaction returns successfully on 204', () async {
      when(() => mockApiClient.delete('/api/transactions/1')).thenAnswer(
        (_) async => http.Response('', 204),
      );

      await expectLater(repository.deleteTransaction(1), completes);
    });
  });
}
