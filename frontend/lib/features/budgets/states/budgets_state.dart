import 'package:flutter/material.dart';
import '../repositories/budgets_repository.dart';
import '../models/budget.dart';
import '../../transactions/repositories/categories_repository.dart';
import '../../transactions/models/category.dart';
import '../../home/home_repository.dart';
import '../../home/models/dashboard.dart';

class BudgetsState extends ChangeNotifier {
  final BudgetsRepository _repository;
  final CategoriesRepository _categoriesRepository;
  final HomeRepository _homeRepository;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Budget> _budgets = [];
  List<Category> _categories = [];
  DashboardResponse? _dashboardData;

  bool _isLoading = false;
  String? _error;

  BudgetsState({
    BudgetsRepository? repository,
    CategoriesRepository? categoriesRepository,
    HomeRepository? homeRepository,
  })  : _repository = repository ?? BudgetsRepository(),
        _categoriesRepository = categoriesRepository ?? CategoriesRepository(),
        _homeRepository = homeRepository ?? HomeRepository();

  DateTime get currentMonth => _currentMonth;
  List<Budget> get budgets => _budgets;
  List<Category> get categories => _categories;
  DashboardResponse? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Budget> get currentMonthBudgets {
    return _budgets.where((b) => b.month == _currentMonth.month && b.year == _currentMonth.year).toList();
  }

  bool get canGoToNextMonth {
    final now = DateTime.now();
    final realCurrentMonth = DateTime(now.year, now.month, 1);
    return _currentMonth.isBefore(realCurrentMonth);
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all data concurrently
      final futures = await Future.wait([
        _repository.getBudgets(),
        _categoriesRepository.getCategories(),
        _homeRepository.getDashboard(month: _currentMonth.month, year: _currentMonth.year),
      ]);

      _budgets = futures[0] as List<Budget>;
      _categories = futures[1] as List<Category>;
      _dashboardData = futures[2] as DashboardResponse;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    try {
      _dashboardData = await _homeRepository.getDashboard(month: _currentMonth.month, year: _currentMonth.year);
    } catch (e) {
      // Keep existing data if dashboard fails independently
    }
  }

  void nextMonth() {
    if (!canGoToNextMonth) return;
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    // Since budgets and categories are global lists we only need to reload dashboard for the new month summary
    _isLoading = true;
    notifyListeners();
    loadDashboard().then((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    _isLoading = true;
    notifyListeners();
    loadDashboard().then((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> addBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    try {
      final newBudget = await _repository.createBudget(
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
      );
      _budgets.add(newBudget);
      if (month == _currentMonth.month && year == _currentMonth.year) {
        await loadDashboard(); // refresh dashboard summary
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> editBudget(
    int id, {
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    try {
      final updatedBudget = await _repository.updateBudget(
        id,
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
      );
      final index = _budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
      }
      if (month == _currentMonth.month && year == _currentMonth.year) {
        await loadDashboard();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      await loadDashboard();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
