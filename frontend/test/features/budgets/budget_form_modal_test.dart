import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/budgets/widgets/budget_form_modal.dart';
import 'package:etracker/features/transactions/models/category.dart';

void main() {
  testWidgets('BudgetFormModal validation works', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: 'Food', type: 'EXPENSE', createdAt: DateTime.now()),
    ];

    bool onSaveCalled = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BudgetFormModal(
          categories: categories,
          currentMonth: DateTime(2024, 1),
          onSave: (categoryId, amount, month, year) async {
            onSaveCalled = true;
            return true;
          },
        ),
      ),
    ));

    // Tap save without filling anything
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Check for validation errors
    expect(find.text('Please select a category'), findsOneWidget); // SnackBar
    expect(find.text('Please enter an amount'), findsOneWidget); // FormField
    expect(onSaveCalled, false);

    // Close SnackBar
    ScaffoldMessenger.of(tester.element(find.byType(BudgetFormModal))).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // Select Category
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    // Enter invalid amount
    await tester.enterText(find.byType(TextFormField).first, '-100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Amount must be greater than or equal to 0'), findsOneWidget);
    expect(onSaveCalled, false);

    // Enter valid amount
    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(onSaveCalled, true);
  });
}
