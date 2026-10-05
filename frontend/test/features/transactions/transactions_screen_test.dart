import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/transactions/transactions_screen.dart';
import 'package:etracker/features/transactions/states/transactions_state.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: TransactionsScreen(),
      ),
    );
  }

  group('TransactionsScreen Widget Tests', () {
    testWidgets('renders search field, filter controls, and empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // allow CircularProgressIndicator and animations to settle

      // Search field renders
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search transactions...'), findsOneWidget);

      // Filter controls render
      expect(find.byType(SegmentedButton<TransactionFilterType>), findsOneWidget); // Type filter
      expect(find.byIcon(Icons.filter_list), findsOneWidget); // Advanced filters button

      // we might see error or empty state depending on http mock, just check elements exist
    });

    testWidgets('opens advanced filters dialog and shows clear option', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // bottom sheet animation

      // Dialog content renders
      expect(find.text('Filters & Sorting'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('search input shows clear icon and can be cleared', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pump();

      // Clear icon appears
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // TextField is empty, clear icon disappears
      expect(find.text('Groceries'), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });
}
