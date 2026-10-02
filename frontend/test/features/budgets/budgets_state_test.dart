import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/budgets/states/budgets_state.dart';
import 'package:etracker/features/budgets/repositories/budgets_repository.dart';
import 'package:etracker/features/transactions/repositories/categories_repository.dart';
import 'package:etracker/features/home/home_repository.dart';
import 'package:etracker/features/budgets/models/budget.dart';
import 'package:etracker/features/home/models/dashboard.dart';
import 'package:etracker/features/transactions/models/category.dart';

class MockBudgetsRepository extends BudgetsRepository {
  bool getBudgetsCalled = false;

  @override
  Future<List<Budget>> getBudgets() async {
    getBudgetsCalled = true;
    return [];
  }
}

class MockCategoriesRepository extends CategoriesRepository {
  bool getCategoriesCalled = false;

  @override
  Future<List<Category>> getCategories() async {
    getCategoriesCalled = true;
    return [];
  }
}

class MockHomeRepository extends HomeRepository {
  bool getDashboardCalled = false;

  @override
  Future<DashboardResponse> getDashboard({required int month, required int year}) async {
    getDashboardCalled = true;
    return DashboardResponse(
      month: month,
      year: year,
      summary: DashboardSummary(income: 0, expenses: 0, balance: 0, transactionCount: 0),
      spendingByCategory: [],
      budget: DashboardBudget(totalBudget: 0, totalExpenses: 0, remaining: 0, percentageUsed: 0, isOverBudget: false),
      recentTransactions: [],
      insight: DashboardInsight(type: 'none', title: null, description: null),
    );
  }
}

void main() {
  group('BudgetsState', () {
    late BudgetsState state;
    late MockBudgetsRepository mockBudgetsRepo;
    late MockCategoriesRepository mockCategoriesRepo;
    late MockHomeRepository mockHomeRepo;

    setUp(() {
      mockBudgetsRepo = MockBudgetsRepository();
      mockCategoriesRepo = MockCategoriesRepository();
      mockHomeRepo = MockHomeRepository();

      state = BudgetsState(
        repository: mockBudgetsRepo,
        categoriesRepository: mockCategoriesRepo,
        homeRepository: mockHomeRepo,
      );
    });

    test('initial values are correct', () {
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.budgets.isEmpty, true);
    });

    test('loadData fetches budgets, categories, and dashboard', () async {
      await state.loadData();

      expect(state.isLoading, false);
      expect(state.error, null);
      expect(mockBudgetsRepo.getBudgetsCalled, true);
      expect(mockCategoriesRepo.getCategoriesCalled, true);
      expect(mockHomeRepo.getDashboardCalled, true);
    });

    test('nextMonth and previousMonth work correctly', () async {
      final initialMonth = state.currentMonth;

      // Go back one month
      state.previousMonth();
      expect(state.currentMonth.month, initialMonth.month == 1 ? 12 : initialMonth.month - 1);

      // Go forward one month
      state.nextMonth();
      expect(state.currentMonth.month, initialMonth.month);

      // Cannot go to future month
      state.nextMonth();
      expect(state.currentMonth.month, initialMonth.month);
    });
  });
}
