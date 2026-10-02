import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/budgets/repositories/budgets_repository.dart';

class MockApiClient extends ApiClient {
  final Future<http.Response> Function(String) onGet;
  final Future<http.Response> Function(String, {Map<String, dynamic>? body}) onPost;
  final Future<http.Response> Function(String, {Map<String, dynamic>? body}) onPut;
  final Future<http.Response> Function(String) onDelete;

  MockApiClient({
    required this.onGet,
    required this.onPost,
    required this.onPut,
    required this.onDelete,
  });

  @override
  Future<http.Response> get(String endpoint) => onGet(endpoint);

  @override
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) => onPost(endpoint, body: body);

  @override
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) => onPut(endpoint, body: body);

  @override
  Future<http.Response> delete(String endpoint) => onDelete(endpoint);
}

void main() {
  group('BudgetsRepository', () {
    test('getBudgets returns list of budgets on 200', () async {
      final mockClient = MockApiClient(
        onGet: (endpoint) async {
          expect(endpoint, '/api/budgets/');
          return http.Response('[{"id": 1, "user_id": 2, "category_id": 3, "amount": 500.0, "month": 1, "year": 2024}]', 200);
        },
        onPost: (_, {body}) async => http.Response('', 500),
        onPut: (_, {body}) async => http.Response('', 500),
        onDelete: (_) async => http.Response('', 500),
      );

      final repository = BudgetsRepository(apiClient: mockClient);
      final budgets = await repository.getBudgets();

      expect(budgets.length, 1);
      expect(budgets[0].id, 1);
      expect(budgets[0].amount, 500.0);
    });

    test('createBudget returns new budget on 201', () async {
      final mockClient = MockApiClient(
        onGet: (_) async => http.Response('', 500),
        onPost: (endpoint, {body}) async {
          expect(endpoint, '/api/budgets/');
          expect(body!['amount'], 500.0);
          return http.Response('{"id": 1, "user_id": 2, "category_id": 3, "amount": 500.0, "month": 1, "year": 2024}', 201);
        },
        onPut: (_, {body}) async => http.Response('', 500),
        onDelete: (_) async => http.Response('', 500),
      );

      final repository = BudgetsRepository(apiClient: mockClient);
      final budget = await repository.createBudget(categoryId: 3, amount: 500.0, month: 1, year: 2024);

      expect(budget.id, 1);
      expect(budget.amount, 500.0);
    });
  });
}
