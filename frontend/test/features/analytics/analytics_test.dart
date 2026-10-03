import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/analytics/states/analytics_state.dart';
import 'package:etracker/features/analytics/repositories/analytics_repository.dart';
import 'package:etracker/features/home/models/dashboard.dart';
import 'package:etracker/core/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:etracker/features/analytics/widgets/analytics_spending_breakdown.dart';

class MockApiClient extends ApiClient {
  final http.Response response;
  MockApiClient(this.response);

  @override
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    return response;
  }
}

class MockAnalyticsRepository extends AnalyticsRepository {
  final DashboardResponse? mockResponse;
  final Exception? mockException;

  MockAnalyticsRepository({this.mockResponse, this.mockException});

  @override
  Future<DashboardResponse> getAnalyticsData({required int month, required int year}) async {
    if (mockException != null) throw mockException!;
    if (mockResponse != null) return mockResponse!;
    throw Exception('Mock data not provided');
  }
}

void main() {
  group('AnalyticsRepository', () {
    test('getAnalyticsData parses success response', () async {
      final jsonResponse = '''
      {
        "month": 10,
        "year": 2026,
        "summary": {"income": 100, "expenses": 50, "balance": 50, "transaction_count": 1},
        "spending_by_category": [],
        "budget": {"total_budget": 100, "total_expenses": 50, "remaining": 50, "percentage_used": 50.0, "is_over_budget": false},
        "recent_transactions": [],
        "insight": {"type": "none", "title": null, "description": null}
      }
      ''';
      final repository = AnalyticsRepository(apiClient: MockApiClient(http.Response(jsonResponse, 200)));
      final data = await repository.getAnalyticsData(month: 10, year: 2026);
      expect(data.month, 10);
      expect(data.summary.income, 100);
    });

    test('getAnalyticsData throws error on failure', () async {
      final repository = AnalyticsRepository(apiClient: MockApiClient(http.Response('Error', 500)));
      expect(() => repository.getAnalyticsData(month: 10, year: 2026), throwsException);
    });
  });

  group('AnalyticsState', () {
    test('initial state is correct', () {
      final state = AnalyticsState(repository: MockAnalyticsRepository());
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.analyticsData, isNull);
      expect(state.canGoToNextMonth, isFalse);
    });

    test('previousMonth updates currentMonth and calls loadData', () {
      final state = AnalyticsState(repository: MockAnalyticsRepository(
        mockException: Exception('error'),
      ));
      final initialMonth = state.currentMonth;
      state.previousMonth();

      expect(state.currentMonth.month, initialMonth.month == 1 ? 12 : initialMonth.month - 1);
    });

    test('nextMonth updates currentMonth if canGoToNextMonth is true', () {
      final state = AnalyticsState(repository: MockAnalyticsRepository(
        mockException: Exception('error'),
      ));

      state.previousMonth();
      expect(state.canGoToNextMonth, isTrue);

      final previousMonth = state.currentMonth;
      state.nextMonth();

      expect(state.currentMonth.isAfter(previousMonth), isTrue);
      expect(state.canGoToNextMonth, isFalse);
    });
  });

  group('Analytics Widgets', () {
    testWidgets('AnalyticsSpendingBreakdown empty state', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnalyticsSpendingBreakdown(spending: []),
        ),
      ));

      expect(find.text('No spending data for this month.'), findsOneWidget);
    });
  });
}
