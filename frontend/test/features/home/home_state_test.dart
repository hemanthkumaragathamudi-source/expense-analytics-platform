import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/home/home_state.dart';
import 'package:etracker/features/home/home_repository.dart';
import 'package:etracker/core/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  group('HomeState', () {
    late Map<String, dynamic> mockData;

    setUp(() {
      mockData = {
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
    });

    test('initial state', () {
      final state = HomeState();

      expect(state.isLoading, false);
      expect(state.dashboardData, isNull);
      expect(state.error, isNull);

      final now = DateTime.now();
      expect(state.currentMonth.month, now.month);
      expect(state.currentMonth.year, now.year);
    });

    test('loadDashboard sets loading, data, and clears error on success', () async {
      final repo = HomeRepository(apiClient: MockApiClient(responseJson: mockData));
      final state = HomeState(repository: repo);

      expect(state.isLoading, false);

      final future = state.loadDashboard();

      // Should be loading immediately
      expect(state.isLoading, true);

      await future;

      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.dashboardData, isNotNull);
      expect(state.dashboardData!.summary.income, 5000.0);
    });

    test('loadDashboard sets error and clears data on failure', () async {
      final repo = HomeRepository(apiClient: MockApiClient(responseJson: {}, statusCode: 500));
      final state = HomeState(repository: repo);

      await state.loadDashboard();

      expect(state.isLoading, false);
      expect(state.error, isNotNull);
      expect(state.dashboardData, isNull);
    });

    test('nextMonth increments month and reloads data if not current month', () async {
      final repo = HomeRepository(apiClient: MockApiClient(responseJson: mockData));
      final state = HomeState(repository: repo);

      // force state to previous month to allow nextMonth to run
      state.previousMonth();
      final initialMonth = state.currentMonth;

      state.nextMonth();

      expect(
        state.currentMonth.month,
        initialMonth.month == 12 ? 1 : initialMonth.month + 1
      );
      // It should trigger loadDashboard, we know state will start loading
      expect(state.isLoading, true);
    });

    test('previousMonth decrements month and reloads data', () async {
      final repo = HomeRepository(apiClient: MockApiClient(responseJson: mockData));
      final state = HomeState(repository: repo);

      final initialMonth = state.currentMonth;

      state.previousMonth();

      expect(
        state.currentMonth.month,
        initialMonth.month == 1 ? 12 : initialMonth.month - 1
      );
      expect(state.isLoading, true);
    });

    test('cannot navigate to future month', () {
      final state = HomeState();

      // By default it starts on current month, so canGoToNextMonth is false
      expect(state.canGoToNextMonth, false);

      state.nextMonth();
      // Month shouldn't have changed
      final now = DateTime.now();
      expect(state.currentMonth.month, now.month);
    });
  });
}
