import 'package:flutter/material.dart';
import 'home_repository.dart';
import 'models/dashboard.dart';

class HomeState extends ChangeNotifier {
  final HomeRepository _repository;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DashboardResponse? _dashboardData;
  bool _isLoading = false;
  String? _error;

  HomeState({HomeRepository? repository}) : _repository = repository ?? HomeRepository();

  DateTime get currentMonth => _currentMonth;
  DashboardResponse? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get canGoToNextMonth {
    final now = DateTime.now();
    final realCurrentMonth = DateTime(now.year, now.month, 1);
    return _currentMonth.isBefore(realCurrentMonth);
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _repository.getDashboard(
        month: _currentMonth.month,
        year: _currentMonth.year,
      );
    } catch (e) {
      _error = e.toString();
      _dashboardData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextMonth() {
    if (!canGoToNextMonth) return;
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    loadDashboard();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    loadDashboard();
  }
}
