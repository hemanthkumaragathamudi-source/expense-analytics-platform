import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:etracker/features/home/home_repository.dart';
import 'package:etracker/core/api/api_client.dart';
import 'package:etracker/features/home/models/dashboard.dart';
import 'dart:convert';

// Minimal mock approach to avoid adding mockito
class MockApiClient extends ApiClient {
  final Map<String, dynamic> responseJson;
  final int statusCode;

  MockApiClient({required this.responseJson, this.statusCode = 200});

  @override
  Future<http.Response> get(String endpoint) async {
    return http.Response(jsonEncode(responseJson), statusCode);
  }
}

void main() {
  group('HomeRepository', () {
    test('getDashboard returns DashboardResponse on 200 OK', () async {
      final mockData = {
        "month": 10,
        "year": 2023,
        "summary": {
          "income": 5000.0,
          "expenses": 2000.0,
          "balance": 3000.0,
          "transaction_count": 10
        },
        "spending_by_category": [],
        "budget": {
          "total_budget": 3000.0,
          "total_expenses": 2000.0,
          "remaining": 1000.0,
          "percentage_used": 66.6,
          "is_over_budget": false
        },
        "recent_transactions": [],
        "insight": {
          "type": "none",
          "title": null,
          "description": null
        }
      };

      final mockClient = MockApiClient(responseJson: mockData);
      final repo = HomeRepository(apiClient: mockClient);

      final response = await repo.getDashboard(month: 10, year: 2023);

      expect(response, isA<DashboardResponse>());
      expect(response.month, 10);
      expect(response.year, 2023);
      expect(response.summary.income, 5000.0);
    });

    test('getDashboard throws exception on non-200 status', () async {
      final mockClient = MockApiClient(responseJson: {}, statusCode: 500);
      final repo = HomeRepository(apiClient: mockClient);

      expect(
        () => repo.getDashboard(month: 10, year: 2023),
        throwsA(isA<Exception>()),
      );
    });
  });
}
