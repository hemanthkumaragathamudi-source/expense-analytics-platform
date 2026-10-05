import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/categories_repository.dart';
import '../repositories/payment_methods_repository.dart';
import '../models/category.dart';
import '../models/payment_method.dart';

enum TransactionFilterType { all, expense, income }
enum TransactionSortOption { newest, oldest, amountHighest, amountLowest }

class TransactionsState extends ChangeNotifier {
  final TransactionsRepository _transactionsRepository;
  final CategoriesRepository _categoriesRepository;
  final PaymentMethodsRepository _paymentMethodsRepository;

  List<Transaction> _transactions = [];
  Map<int, Category> _categoriesMap = {};
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  DateTime _currentMonth = DateTime.now();
  TransactionFilterType _filterType = TransactionFilterType.all;

  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedPaymentMethodId;
  TransactionSortOption _sortOption = TransactionSortOption.newest;

  bool _isDisposed = false;

  TransactionsState({
    TransactionsRepository? transactionsRepository,
    CategoriesRepository? categoriesRepository,
    PaymentMethodsRepository? paymentMethodsRepository,
  })  : _transactionsRepository = transactionsRepository ?? TransactionsRepository(),
        _categoriesRepository = categoriesRepository ?? CategoriesRepository(),
        _paymentMethodsRepository = paymentMethodsRepository ?? PaymentMethodsRepository();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get currentMonth => _currentMonth;
  TransactionFilterType get filterType => _filterType;

  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedPaymentMethodId => _selectedPaymentMethodId;
  TransactionSortOption get sortOption => _sortOption;

  List<Category> get categories => _categoriesMap.values.toList();
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  // Make category name lookup available to UI
  String getCategoryName(int id) {
    return _categoriesMap[id]?.name ?? 'Unknown';
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load categories and payment methods once
      if (_categoriesMap.isEmpty) {
        final categories = await _categoriesRepository.getCategories();
        _categoriesMap = {for (var c in categories) c.id: c};
      }
      if (_paymentMethods.isEmpty) {
        try {
          _paymentMethods = await _paymentMethodsRepository.getPaymentMethods();
        } catch (e) {
          // It's ok if payment methods fail to load, we can just show empty list
        }
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
        categoryId: _selectedCategoryId,
      );

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  List<Transaction> get displayedTransactions {
    List<Transaction> filtered = List.from(_transactions);

    // Apply client-side search filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((t) {
        final descMatch = t.description?.toLowerCase().contains(query) ?? false;
        final notesMatch = t.notes?.toLowerCase().contains(query) ?? false;
        return descMatch || notesMatch;
      }).toList();
    }

    // Apply client-side payment method filter
    if (_selectedPaymentMethodId != null) {
      filtered = filtered.where((t) => t.paymentMethodId == _selectedPaymentMethodId).toList();
    }

    // Apply client-side sorting
    filtered.sort((a, b) {
      switch (_sortOption) {
        case TransactionSortOption.newest:
          return b.date.compareTo(a.date);
        case TransactionSortOption.oldest:
          return a.date.compareTo(b.date);
        case TransactionSortOption.amountHighest:
          return b.amount.compareTo(a.amount);
        case TransactionSortOption.amountLowest:
          return a.amount.compareTo(b.amount);
      }
    });

    return filtered;
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setCategoryId(int? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      loadData(); // Requires server-side reload
    }
  }

  void setPaymentMethodId(int? paymentMethodId) {
    if (_selectedPaymentMethodId != paymentMethodId) {
      _selectedPaymentMethodId = paymentMethodId;
      notifyListeners(); // Client-side filtering only
    }
  }

  void setSortOption(TransactionSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners(); // Client-side sorting only
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedPaymentMethodId = null;
    _filterType = TransactionFilterType.all;
    _sortOption = TransactionSortOption.newest;

    // Changing category or filterType requires reloading server data
    loadData();
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
