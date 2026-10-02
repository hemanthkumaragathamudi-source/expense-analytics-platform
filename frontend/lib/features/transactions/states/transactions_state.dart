import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/categories_repository.dart';
import '../models/category.dart';

enum TransactionFilterType { all, expense, income }

class TransactionsState extends ChangeNotifier {
  final TransactionsRepository _transactionsRepository;
  final CategoriesRepository _categoriesRepository;

  List<Transaction> _transactions = [];
  Map<int, Category> _categoriesMap = {};
  bool _isLoading = false;
  String? _error;

  DateTime _currentMonth = DateTime.now();
  TransactionFilterType _filterType = TransactionFilterType.all;

  TransactionsState({
    TransactionsRepository? transactionsRepository,
    CategoriesRepository? categoriesRepository,
  })  : _transactionsRepository = transactionsRepository ?? TransactionsRepository(),
        _categoriesRepository = categoriesRepository ?? CategoriesRepository();

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get currentMonth => _currentMonth;
  TransactionFilterType get filterType => _filterType;

  // Make category name lookup available to UI
  String getCategoryName(int id) {
    return _categoriesMap[id]?.name ?? 'Unknown';
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load categories once to build the lookup map
      if (_categoriesMap.isEmpty) {
        final categories = await _categoriesRepository.getCategories();
        _categoriesMap = {for (var c in categories) c.id: c};
      }

      final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

      String? typeParam;
      if (_filterType == TransactionFilterType.expense) typeParam = 'EXPENSE';
      if (_filterType == TransactionFilterType.income) typeParam = 'INCOME';

      _transactions = await _transactionsRepository.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
        transactionType: typeParam,
      );

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterType(TransactionFilterType type) {
    if (_filterType != type) {
      _filterType = type;
      loadData();
    }
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    loadData();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    loadData();
  }

  bool get canGoToNextMonth {
    final now = DateTime.now();
    return _currentMonth.year < now.year || (_currentMonth.year == now.year && _currentMonth.month < now.month);
  }

  Future<void> deleteTransaction(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _transactionsRepository.deleteTransaction(id);
      await loadData();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
