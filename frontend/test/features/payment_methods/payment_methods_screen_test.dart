import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/payment_methods/payment_methods_screen.dart';

// Since the screen creates the state internally, we will test the widget visually.
// And skip actual mocking of network calls by doing basic widget assertions.
// We will test if the screen mounts and displays its structure correctly.

void main() {
  testWidgets('PaymentMethodsScreen mounts and shows title', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PaymentMethodsScreen(),
    ));

    // Initially loading state
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
