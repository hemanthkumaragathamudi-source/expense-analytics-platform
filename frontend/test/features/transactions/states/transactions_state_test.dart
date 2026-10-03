import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:etracker/features/transactions/states/transactions_state.dart';
import 'package:etracker/features/transactions/repositories/transactions_repository.dart';
import 'package:etracker/features/transactions/repositories/categories_repository.dart';
import 'package:etracker/features/transactions/models/transaction.dart';
import 'package:etracker/features/transactions/models/category.dart';

class MockTransactionsRepository extends Mock implements TransactionsRepository {}
class MockCategoriesRepository extends Mock implements CategoriesRepository {}

void main() {
  group('TransactionsState', () {
    late TransactionsState state;
    late MockTransactionsRepository mockTransactionsRepo;
    late MockCategoriesRepository mockCategoriesRepo;

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

    setUp(() {
      mockTransactionsRepo = MockTransactionsRepository();
      mockCategoriesRepo = MockCategoriesRepository();
      state = TransactionsState(
        transactionsRepository: mockTransactionsRepo,
        categoriesRepository: mockCategoriesRepo,
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
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
          )).thenAnswer((_) async => [mockTransaction]);

      await state.loadData();

      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.transactions.length, 1);
      expect(state.getCategoryName(1), 'Food');
    });

    test('loadData failure', () async {
      when(() => mockCategoriesRepo.getCategories())
          .thenAnswer((_) async => [mockCategory]);
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
          )).thenThrow(Exception('Failed'));

      await state.loadData();

      expect(state.isLoading, false);
      expect(state.error, contains('Failed'));
      expect(state.transactions.isEmpty, true);
    });

    test('setFilterType loads data with new type', () async {
      when(() => mockCategoriesRepo.getCategories())
          .thenAnswer((_) async => []);
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
          )).thenAnswer((_) async => []);

      // Needs to await loading data when filter is set
      // setFilterType is synchronous but triggers an async loadData internally
      state.setFilterType(TransactionFilterType.expense);

      // wait a bit for async to complete
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: 'EXPENSE',
          )).called(1);
    });

    test('deleteTransaction success', () async {
      when(() => mockCategoriesRepo.getCategories())
          .thenAnswer((_) async => []);
      when(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
          )).thenAnswer((_) async => []);
      when(() => mockTransactionsRepo.deleteTransaction(1))
          .thenAnswer((_) async => {});

      await state.deleteTransaction(1);

      verify(() => mockTransactionsRepo.deleteTransaction(1)).called(1);
      verify(() => mockTransactionsRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            transactionType: any(named: 'transactionType'),
          )).called(1);
    });
  });
}
