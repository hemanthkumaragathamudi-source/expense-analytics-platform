import 'package:flutter/foundation.dart';
import 'models/payment_method.dart';
import 'repositories/payment_methods_repository.dart';

class PaymentMethodsState extends ChangeNotifier {
  final PaymentMethodsRepository _repository;

  PaymentMethodsState({PaymentMethodsRepository? repository})
      : _repository = repository ?? PaymentMethodsRepository();

  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isDisposed = false;

  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentMethods = await _repository.getPaymentMethods();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> createPaymentMethod(String name) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMethod = await _repository.createPaymentMethod(name);
      _paymentMethods.add(newMethod);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updatePaymentMethod(int id, String name) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMethod = await _repository.updatePaymentMethod(id, name);
      final index = _paymentMethods.indexWhere((m) => m.id == id);
      if (index != -1) {
        _paymentMethods[index] = updatedMethod;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deletePaymentMethod(int id) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deletePaymentMethod(id);
      _paymentMethods.removeWhere((m) => m.id == id);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
