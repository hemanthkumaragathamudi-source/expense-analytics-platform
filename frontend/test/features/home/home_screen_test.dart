import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/home/widgets/financial_summary_card.dart';
import 'package:etracker/features/home/models/dashboard.dart';
import 'package:etracker/core/theme/app_theme.dart';

void main() {
  group('FinancialSummaryCard Widget Test', () {
    testWidgets('displays correct summary values', (WidgetTester tester) async {
      final summary = DashboardSummary(
        income: 5000.0,
        expenses: 2000.0,
        balance: 3000.0,
        transactionCount: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FinancialSummaryCard(summary: summary),
          ),
        ),
      );

      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('\$3000.00'), findsOneWidget);

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('\$5000.00'), findsOneWidget);

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('\$2000.00'), findsOneWidget);

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });
  });
}
