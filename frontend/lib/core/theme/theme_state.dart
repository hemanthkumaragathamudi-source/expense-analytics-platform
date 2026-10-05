import 'package:flutter/material.dart';
import '../storage/preferences_storage.dart';

class ThemeState extends ChangeNotifier {
  final PreferencesStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDisposed = false;

  ThemeState({PreferencesStorage? storage})
      : _storage = storage ?? PreferencesStorage();

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final savedMode = await _storage.getThemeMode();
    if (savedMode != null) {
      _themeMode = _parseThemeMode(savedMode);
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    if (!_isDisposed) {
      notifyListeners();
    }
    await _storage.saveThemeMode(mode.toString());
  }

  ThemeMode _parseThemeMode(String modeString) {
    if (modeString == ThemeMode.light.toString()) return ThemeMode.light;
    if (modeString == ThemeMode.dark.toString()) return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
