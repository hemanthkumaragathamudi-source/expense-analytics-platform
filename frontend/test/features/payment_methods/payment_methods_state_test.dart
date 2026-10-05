import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:etracker/features/payment_methods/models/payment_method.dart';
import 'package:etracker/features/payment_methods/repositories/payment_methods_repository.dart';
import 'package:etracker/features/payment_methods/payment_methods_state.dart';

class MockPaymentMethodsRepository extends Mock implements PaymentMethodsRepository {}

void main() {
  late PaymentMethodsState state;
  late MockPaymentMethodsRepository mockRepository;

  setUp(() {
    mockRepository = MockPaymentMethodsRepository();
    state = PaymentMethodsState(repository: mockRepository);
  });

  group('PaymentMethodsState', () {
    const paymentMethod = PaymentMethod(id: 1, name: 'Cash');

    test('initial state is correct', () {
      expect(state.paymentMethods, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('loadPaymentMethods populates list on success', () async {
      when(() => mockRepository.getPaymentMethods())
          .thenAnswer((_) async => [paymentMethod]);

      await state.loadPaymentMethods();

      expect(state.paymentMethods, equals([paymentMethod]));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('loadPaymentMethods sets error on failure', () async {
      when(() => mockRepository.getPaymentMethods())
          .thenThrow(Exception('Failed to load'));

      await state.loadPaymentMethods();

      expect(state.paymentMethods, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Failed to load');
    });

    test('createPaymentMethod adds to list on success', () async {
      when(() => mockRepository.createPaymentMethod('Bank'))
          .thenAnswer((_) async => const PaymentMethod(id: 2, name: 'Bank'));

      final success = await state.createPaymentMethod('Bank');

      expect(success, isTrue);
      expect(state.paymentMethods.length, 1);
      expect(state.paymentMethods.first.name, 'Bank');
    });

    test('createPaymentMethod sets error on failure', () async {
      when(() => mockRepository.createPaymentMethod('Bank'))
          .thenThrow(Exception('Failed to create'));

      final success = await state.createPaymentMethod('Bank');

      expect(success, isFalse);
      expect(state.paymentMethods, isEmpty);
      expect(state.error, 'Failed to create');
    });

    test('updatePaymentMethod updates item in list on success', () async {
      // Setup initial state
      when(() => mockRepository.getPaymentMethods())
          .thenAnswer((_) async => [paymentMethod]);
      await state.loadPaymentMethods();

      when(() => mockRepository.updatePaymentMethod(1, 'Card'))
          .thenAnswer((_) async => const PaymentMethod(id: 1, name: 'Card'));

      final success = await state.updatePaymentMethod(1, 'Card');

      expect(success, isTrue);
      expect(state.paymentMethods.first.name, 'Card');
    });

    test('deletePaymentMethod removes item from list on success', () async {
      // Setup initial state
      when(() => mockRepository.getPaymentMethods())
          .thenAnswer((_) async => [paymentMethod]);
      await state.loadPaymentMethods();

      when(() => mockRepository.deletePaymentMethod(1))
          .thenAnswer((_) async => {});

      final success = await state.deletePaymentMethod(1);

      expect(success, isTrue);
      expect(state.paymentMethods, isEmpty);
    });

    test('deletePaymentMethod handles backend error properly', () async {
      // Setup initial state
      when(() => mockRepository.getPaymentMethods())
          .thenAnswer((_) async => [paymentMethod]);
      await state.loadPaymentMethods();

      when(() => mockRepository.deletePaymentMethod(1))
          .thenThrow(Exception('Cannot delete in use'));

      final success = await state.deletePaymentMethod(1);

      expect(success, isFalse);
      expect(state.paymentMethods.length, 1); // Not removed
      expect(state.error, 'Cannot delete in use');
    });

    test('clearError resets error state', () async {
      when(() => mockRepository.getPaymentMethods())
          .thenThrow(Exception('Failed to load'));
      await state.loadPaymentMethods();
      expect(state.error, isNotNull);

      state.clearError();

      expect(state.error, isNull);
    });
  });
}
