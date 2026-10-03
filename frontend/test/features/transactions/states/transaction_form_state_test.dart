import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:etracker/features/transactions/states/transaction_form_state.dart';
import 'package:etracker/features/transactions/repositories/transactions_repository.dart';
import 'package:etracker/features/transactions/repositories/categories_repository.dart';
import 'package:etracker/features/transactions/repositories/payment_methods_repository.dart';
import 'package:etracker/features/transactions/models/category.dart';
import 'package:etracker/features/transactions/models/payment_method.dart';
import 'package:etracker/features/transactions/models/transaction.dart';

class MockTransactionsRepository extends Mock implements TransactionsRepository {}
class MockCategoriesRepository extends Mock implements CategoriesRepository {}
class MockPaymentMethodsRepository extends Mock implements PaymentMethodsRepository {}

void main() {
  group('TransactionFormState', () {
    late TransactionFormState state;
    late MockTransactionsRepository mockTransactionsRepo;
    late MockCategoriesRepository mockCategoriesRepo;
    late MockPaymentMethodsRepository mockPaymentMethodsRepo;

    final mockCategory = Category(id: 1, name: 'Food', type: 'EXPENSE', createdAt: DateTime.now());
    final mockPaymentMethod = PaymentMethod(id: 1, name: 'Cash');

    setUp(() {
      mockTransactionsRepo = MockTransactionsRepository();
      mockCategoriesRepo = MockCategoriesRepository();
      mockPaymentMethodsRepo = MockPaymentMethodsRepository();

      state = TransactionFormState(
        userId: 1,
        transactionsRepository: mockTransactionsRepo,
        categoriesRepository: mockCategoriesRepo,
        paymentMethodsRepository: mockPaymentMethodsRepo,
      );
    });

    test('initial state', () {
      expect(state.isLoadingData, false);
      expect(state.isSaving, false);
      expect(state.transactionType, 'EXPENSE');
      expect(state.isValid, false);
    });

    test('loadData populates categories and payment methods', () async {
      when(() => mockCategoriesRepo.getCategories()).thenAnswer((_) async => [mockCategory]);
      when(() => mockPaymentMethodsRepo.getPaymentMethods()).thenAnswer((_) async => [mockPaymentMethod]);

      await state.loadData();

      expect(state.categories.length, 1);
      expect(state.paymentMethods.length, 1);
    });

    test('save new transaction success', () async {
      when(() => mockTransactionsRepo.createTransaction(
        userId: any(named: 'userId'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        amount: any(named: 'amount'),
        transactionType: any(named: 'transactionType'),
      )).thenAnswer((_) async => Transaction(
        id: 1, userId: 1, date: DateTime.now(), categoryId: 1, amount: 10.0, transactionType: 'EXPENSE', createdAt: DateTime.now(), updatedAt: DateTime.now()
      ));

      state.setAmount(10.0);
      state.setCategoryId(1);

      final result = await state.save();

      expect(result, true);
      verify(() => mockTransactionsRepo.createTransaction(
        userId: 1,
        date: any(named: 'date'),
        categoryId: 1,
        amount: 10.0,
        transactionType: 'EXPENSE',
      )).called(1);
    });
  });
}
