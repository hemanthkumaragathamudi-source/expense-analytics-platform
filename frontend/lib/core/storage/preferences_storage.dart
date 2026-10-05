import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesStorage {
  final FlutterSecureStorage _storage;

  static const String _themeModeKey = 'theme_mode';

  PreferencesStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: _themeModeKey, value: themeMode);
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: _themeModeKey);
  }
}
