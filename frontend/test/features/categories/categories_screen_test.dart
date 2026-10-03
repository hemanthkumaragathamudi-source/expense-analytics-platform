import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/categories/categories_screen.dart';

void main() {
  testWidgets('renders category screen basic structure', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CategoriesScreen(),
    ));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
