import 'package:flutter/material.dart';
import '../repositories/analytics_repository.dart';
import '../../home/models/dashboard.dart';

class AnalyticsState extends ChangeNotifier {
  final AnalyticsRepository _repository;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DashboardResponse? _analyticsData;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  AnalyticsState({AnalyticsRepository? repository}) : _repository = repository ?? AnalyticsRepository();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  DateTime get currentMonth => _currentMonth;
  DashboardResponse? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      _analyticsData = await _repository.getAnalyticsData(
        month: _currentMonth.month,
        year: _currentMonth.year,
      );
    } catch (e) {
      _error = e.toString();
      _analyticsData = null;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void nextMonth() {
    if (!canGoToNextMonth) return;
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    loadData();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    loadData();
  }
}
