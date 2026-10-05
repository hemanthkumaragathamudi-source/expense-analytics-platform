import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:etracker/features/payment_methods/models/payment_method.dart';
import 'package:etracker/features/payment_methods/payment_methods_state.dart';
import 'package:etracker/features/payment_methods/widgets/payment_method_form_dialog.dart';

class MockPaymentMethodsState extends Mock implements PaymentMethodsState {}

void main() {
  late MockPaymentMethodsState mockState;

  setUp(() {
    mockState = MockPaymentMethodsState();
    when(() => mockState.isLoading).thenReturn(false);
    when(() => mockState.error).thenReturn(null);
  });

  Widget buildDialog(PaymentMethod? paymentMethod) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: mockState,
          builder: (context, _) => PaymentMethodFormDialog(
            state: mockState,
            paymentMethod: paymentMethod,
          ),
        ),
      ),
    );
  }

  group('PaymentMethodFormDialog', () {
    testWidgets('shows Add title when adding', (tester) async {
      await tester.pumpWidget(buildDialog(null));
      expect(find.text('Add Payment Method'), findsOneWidget);
    });

    testWidgets('shows Edit title and prefills name when editing', (tester) async {
      await tester.pumpWidget(buildDialog(const PaymentMethod(id: 1, name: 'Cash')));
      expect(find.text('Edit Payment Method'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('shows error when submitting empty name', (tester) async {
      await tester.pumpWidget(buildDialog(null));

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
      verifyNever(() => mockState.createPaymentMethod(any()));
    });

    testWidgets('calls createPaymentMethod when saving a new item', (tester) async {
      when(() => mockState.createPaymentMethod(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildDialog(null));

      await tester.enterText(find.byType(TextFormField), 'Bank');
      await tester.tap(find.text('Save'));
      await tester.pump();

      verify(() => mockState.createPaymentMethod('Bank')).called(1);
    });

    testWidgets('calls updatePaymentMethod when saving an edited item', (tester) async {
      when(() => mockState.updatePaymentMethod(any(), any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildDialog(const PaymentMethod(id: 1, name: 'Cash')));

      await tester.enterText(find.byType(TextFormField), 'Card');
      await tester.tap(find.text('Save'));
      await tester.pump();

      verify(() => mockState.updatePaymentMethod(1, 'Card')).called(1);
    });
  });
}
