import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/budgets/budgets_screen.dart';

void main() {
  testWidgets('BudgetsScreen has Budgets title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BudgetsScreen()));

    expect(find.text('Budgets'), findsOneWidget);
    // Since the initial state sets isLoading to true, it should show a loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
