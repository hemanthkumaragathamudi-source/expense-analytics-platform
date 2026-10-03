import 'package:flutter/foundation.dart' hide Category;
import 'models/category.dart';
import 'repositories/categories_repository.dart';

class CategoriesState extends ChangeNotifier {
  final CategoriesRepository _repository;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  CategoriesState({CategoriesRepository? repository})
      : _repository = repository ?? CategoriesRepository() {
    loadCategories();
  }

  List<Category> get categories => _categories;
  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'INCOME').toList();
  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'EXPENSE').toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notifySafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    _notifySafe();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifySafe();
    }
  }

  Future<void> addCategory(String name, String type) async {
    _isLoading = true;
    _error = null;
    _notifySafe();

    try {
      final newCategory = await _repository.createCategory(name, type);
      _categories.add(newCategory);
      // Sort alphabetically by name
      _categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      _notifySafe();
    }
  }

  Future<void> updateCategory(int id, String name, String type) async {
    _isLoading = true;
    _error = null;
    _notifySafe();

    try {
      final updatedCategory = await _repository.updateCategory(id, name, type);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        _categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      _notifySafe();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    _notifySafe();

    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      _notifySafe();
    }
  }
}
