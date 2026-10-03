import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/categories/repositories/categories_repository.dart';
import 'package:etracker/features/categories/models/category.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late CategoriesRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = CategoriesRepository(apiClient: mockApiClient);
  });

  group('CategoriesRepository', () {
    test('getCategories returns list of Categories on success', () async {
      when(() => mockApiClient.get('/categories/')).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'name': 'Groceries',
              'type': 'EXPENSE',
              'user_id': 2,
              'created_at': '2023-01-01T10:00:00.000Z',
            }
          ]),
          200,
        ),
      );

      final categories = await repository.getCategories();

      expect(categories.length, 1);
      expect(categories.first.name, 'Groceries');
      verify(() => mockApiClient.get('/categories/')).called(1);
    });

    test('getCategories throws exception on failure', () async {
      when(() => mockApiClient.get('/categories/')).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      expect(() => repository.getCategories(), throwsException);
    });

    test('createCategory returns a new Category on success', () async {
      when(() => mockApiClient.post('/categories/', body: {'name': 'New Cat', 'type': 'EXPENSE'}))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 2,
            'name': 'New Cat',
            'type': 'EXPENSE',
            'user_id': 2,
            'created_at': '2023-01-01T10:00:00.000Z',
          }),
          201,
        ),
      );

      final category = await repository.createCategory('New Cat', 'EXPENSE');

      expect(category.id, 2);
      expect(category.name, 'New Cat');
      verify(() => mockApiClient.post('/categories/', body: {'name': 'New Cat', 'type': 'EXPENSE'})).called(1);
    });

    test('updateCategory returns updated Category on success', () async {
      when(() => mockApiClient.put('/categories/1', body: {'name': 'Updated Cat', 'type': 'INCOME'}))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 1,
            'name': 'Updated Cat',
            'type': 'INCOME',
            'user_id': 2,
            'created_at': '2023-01-01T10:00:00.000Z',
          }),
          200,
        ),
      );

      final category = await repository.updateCategory(1, 'Updated Cat', 'INCOME');

      expect(category.name, 'Updated Cat');
      expect(category.type, 'INCOME');
      verify(() => mockApiClient.put('/categories/1', body: {'name': 'Updated Cat', 'type': 'INCOME'})).called(1);
    });

    test('deleteCategory completes successfully on success', () async {
      when(() => mockApiClient.delete('/categories/1')).thenAnswer(
        (_) async => http.Response('', 204),
      );

      await repository.deleteCategory(1);

      verify(() => mockApiClient.delete('/categories/1')).called(1);
    });
  });
}
