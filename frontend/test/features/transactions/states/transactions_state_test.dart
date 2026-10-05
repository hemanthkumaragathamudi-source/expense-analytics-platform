import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:etracker/features/transactions/states/transactions_state.dart';
import 'package:etracker/features/transactions/repositories/transactions_repository.dart';
import 'package:etracker/features/transactions/repositories/categories_repository.dart';
import 'package:etracker/features/transactions/repositories/payment_methods_repository.dart';
import 'package:etracker/features/transactions/models/transaction.dart';
import 'package:etracker/features/transactions/models/category.dart';
import 'package:etracker/features/transactions/models/payment_method.dart';

class MockTransactionsRepository extends Mock implements TransactionsRepository {}
class MockCategoriesRepository extends Mock implements CategoriesRepository {}
class MockPaymentMethodsRepository extends Mock implements PaymentMethodsRepository {}

void main() {
  group('TransactionsState', () {
    late TransactionsState state;
    late MockTransactionsRepository mockTransactionsRepo;
    late MockCategoriesRepository mockCategoriesRepo;
    late MockPaymentMethodsRepository mockPaymentMethodsRepo;

    final mockTransaction = Transaction(
      id: 1,
      userId: 1,
      date: DateTime.now(),
      categoryId: 1,
      amount: 10.0,
      transactionType: 'EXPENSE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockCategory = Category(
      id: 1,
      name: 'Food',
      type: 'EXPENSE',
      createdAt: DateTime.now(),
    );

    final mockPaymentMethod = PaymentMethod(
      id: 1,
      name: 'Credit Card',
    );

    setUp(() {
      mockTransactionsRepo = MockTransactionsRepository();
      mockCategoriesRepo = MockCategoriesRepository();
      mockPaymentMethodsRepo = MockPaymentMethodsRepository();

      when(() => mockCategoriesRepo.getCategories()).thenAnswer((_) async => []);
      when(() => mockPaymentMethodsRepo.getPaymentMethods()).thenAnswer((_) async => []);

      state = TransactionsState(
        transactionsRepository: mockTransactionsRepo,
        categoriesRepository: mockCategoriesRepo,
        paymentMethodsRepository: mockPaymentMethodsRepo,
      );
    });

    test('initial state', () {
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.transactions.isEmpty, true);
      expect(state.filterType, TransactionFilterType.all);
    });

    test('loadData success', () async {
      when(() => mockCategoriesRepo.getCategories())
          .thenAnswer((_) async => [mockCategory]);
      when(() => mockPaymentMethodsRepo.getPaymentMethods())
          .thenAnswer((_) async => [mockPaymentMethod]);
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
            categoryId: any(named: 'categoryId'),
          )).thenAnswer((_) async => [mockTransaction]);

      await state.loadData();

      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.transactions.length, 1);
      expect(state.getCategoryName(1), 'Food');
    });

    test('loadData failure', () async {
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
            categoryId: any(named: 'categoryId'),
          )).thenThrow(Exception('Failed'));

      await state.loadData();

      expect(state.isLoading, false);
      expect(state.error, contains('Failed'));
      expect(state.transactions.isEmpty, true);
    });

    test('setFilterType loads data with new type', () async {
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
            categoryId: any(named: 'categoryId'),
          )).thenAnswer((_) async => []);

      state.setFilterType(TransactionFilterType.expense);
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: 'EXPENSE',
            categoryId: any(named: 'categoryId'),
          )).called(1);
    });

    test('deleteTransaction success', () async {
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
            categoryId: any(named: 'categoryId'),
          )).thenAnswer((_) async => []);
      when(() => mockTransactionsRepo.deleteTransaction(1))
          .thenAnswer((_) async => {});

      await state.deleteTransaction(1);

      verify(() => mockTransactionsRepo.deleteTransaction(1)).called(1);
    });

    group('Client-side Filtering & Sorting', () {
      final tx1 = Transaction(
        id: 1, userId: 1, date: DateTime(2023, 10, 1), categoryId: 1,
        amount: 100, transactionType: 'EXPENSE', paymentMethodId: 1,
        description: 'Apple', notes: 'Lunch', createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final tx2 = Transaction(
        id: 2, userId: 1, date: DateTime(2023, 10, 5), categoryId: 2,
        amount: 50, transactionType: 'EXPENSE', paymentMethodId: null,
        description: 'Banana', notes: 'Snack', createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final tx3 = Transaction(
        id: 3, userId: 1, date: DateTime(2023, 10, 10), categoryId: 1,
        amount: 200, transactionType: 'INCOME', paymentMethodId: 2,
        description: 'Salary Apple', notes: null, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );

      setUp(() async {
        when(() => mockTransactionsRepo.getTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              transactionType: any(named: 'transactionType'),
              categoryId: any(named: 'categoryId'),
            )).thenAnswer((_) async => [tx1, tx2, tx3]);

        await state.loadData();
      });

      test('search filter works case-insensitive on description and notes', () {
        state.setSearchQuery('apple');
        expect(state.displayedTransactions.length, 2);
        expect(state.displayedTransactions.map((t) => t.id).toList(), [tx3.id, tx1.id]); // tx3 is newer

        state.setSearchQuery('lunch');
        expect(state.displayedTransactions.length, 1);
        expect(state.displayedTransactions.first.id, tx1.id);

        state.setSearchQuery('nothing');
        expect(state.displayedTransactions.isEmpty, true);

        state.setSearchQuery('   ');
        expect(state.displayedTransactions.length, 3);
      });

      test('payment method filter', () {
        state.setPaymentMethodId(1);
        expect(state.displayedTransactions.length, 1);
        expect(state.displayedTransactions.first.id, tx1.id);

        state.setPaymentMethodId(null);
        expect(state.displayedTransactions.length, 3);
      });

      test('sorting options', () {
        // Newest (Default)
        expect(state.displayedTransactions.map((t) => t.id).toList(), [tx3.id, tx2.id, tx1.id]);

        // Oldest
        state.setSortOption(TransactionSortOption.oldest);
        expect(state.displayedTransactions.map((t) => t.id).toList(), [tx1.id, tx2.id, tx3.id]);

        // Highest Amount
        state.setSortOption(TransactionSortOption.amountHighest);
        expect(state.displayedTransactions.map((t) => t.id).toList(), [tx3.id, tx1.id, tx2.id]);

        // Lowest Amount
        state.setSortOption(TransactionSortOption.amountLowest);
        expect(state.displayedTransactions.map((t) => t.id).toList(), [tx2.id, tx1.id, tx3.id]);
      });

      test('clearFilters resets all client-side and server-side states', () async {
        state.setSearchQuery('apple');
        state.setPaymentMethodId(1);
        state.setSortOption(TransactionSortOption.amountHighest);

        state.clearFilters();

        expect(state.searchQuery, '');
        expect(state.selectedPaymentMethodId, null);
        expect(state.sortOption, TransactionSortOption.newest);
        expect(state.filterType, TransactionFilterType.all);
        expect(state.selectedCategoryId, null);
      });

      test('setCategoryId triggers server reload', () async {
        state.setCategoryId(1);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockTransactionsRepo.getTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              transactionType: any(named: 'transactionType'),
              categoryId: 1,
            )).called(1);
      });
    });
  });
}
