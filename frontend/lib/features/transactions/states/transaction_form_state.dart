import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/categories_repository.dart';
import '../repositories/payment_methods_repository.dart';

class TransactionFormState extends ChangeNotifier {
  final TransactionsRepository _transactionsRepository;
  final CategoriesRepository _categoriesRepository;
  final PaymentMethodsRepository _paymentMethodsRepository;

  final int userId;
  final Transaction? initialTransaction;

  bool _isLoadingData = false;
  bool _isSaving = false;
  String? _error;

  List<Category> _allCategories = [];
  List<PaymentMethod> _paymentMethods = [];

  // Form Fields
  String _transactionType = 'EXPENSE';
  double? _amount;
  int? _categoryId;
  int? _paymentMethodId;
  DateTime _date = DateTime.now();
  String _description = '';
  String _notes = '';

  TransactionFormState({
    required this.userId,
    this.initialTransaction,
    TransactionsRepository? transactionsRepository,
    CategoriesRepository? categoriesRepository,
    PaymentMethodsRepository? paymentMethodsRepository,
  })  : _transactionsRepository = transactionsRepository ?? TransactionsRepository(),
        _categoriesRepository = categoriesRepository ?? CategoriesRepository(),
        _paymentMethodsRepository = paymentMethodsRepository ?? PaymentMethodsRepository() {

    if (initialTransaction != null) {
      _transactionType = initialTransaction!.transactionType;
      _amount = initialTransaction!.amount;
      _categoryId = initialTransaction!.categoryId;
      _paymentMethodId = initialTransaction!.paymentMethodId;
      _date = initialTransaction!.date;
      _description = initialTransaction!.description ?? '';
      _notes = initialTransaction!.notes ?? '';
    }
  }

  bool get isLoadingData => _isLoadingData;
  bool get isSaving => _isSaving;
  String? get error => _error;

  List<Category> get categories {
    return _allCategories.where((c) => c.type == _transactionType).toList();
  }

  List<PaymentMethod> get paymentMethods => _paymentMethods;

  String get transactionType => _transactionType;
  double? get amount => _amount;
  int? get categoryId => _categoryId;
  int? get paymentMethodId => _paymentMethodId;
  DateTime get date => _date;
  String get description => _description;
  String get notes => _notes;

  Future<void> loadData() async {
    _isLoadingData = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _categoriesRepository.getCategories(),
        _paymentMethodsRepository.getPaymentMethods(),
      ]);

      _allCategories = results[0] as List<Category>;
      _paymentMethods = results[1] as List<PaymentMethod>;

      // Validate initial category matching type
      if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
        _categoryId = null; // Reset if category type doesn't match
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  void setTransactionType(String type) {
    if (_transactionType != type) {
      _transactionType = type;
      _categoryId = null; // Reset category when type changes
      notifyListeners();
    }
  }

  void setAmount(double val) {
    _amount = val;
    notifyListeners();
  }

  void setCategoryId(int? id) {
    _categoryId = id;
    notifyListeners();
  }

  void setPaymentMethodId(int? id) {
    _paymentMethodId = id;
    notifyListeners();
  }

  void setDate(DateTime d) {
    _date = d;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
  }

  void setNotes(String n) {
    _notes = n;
  }

  bool get isValid {
    return _amount != null && _amount! > 0 && _categoryId != null;
  }

  Future<bool> save() async {
    if (!isValid) {
      _error = 'Please fill all required fields correctly.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (initialTransaction == null) {
        await _transactionsRepository.createTransaction(
          userId: userId,
          date: _date,
          categoryId: _categoryId!,
          amount: _amount!,
          transactionType: _transactionType,
          description: _description.isEmpty ? null : _description,
          paymentMethodId: _paymentMethodId,
          notes: _notes.isEmpty ? null : _notes,
        );
      } else {
        await _transactionsRepository.updateTransaction(
          initialTransaction!.id,
          date: _date,
          categoryId: _categoryId!,
          amount: _amount!,
          transactionType: _transactionType,
          description: _description.isEmpty ? null : _description,
          paymentMethodId: _paymentMethodId,
          notes: _notes.isEmpty ? null : _notes,
        );
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
