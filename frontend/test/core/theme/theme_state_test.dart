import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/core/theme/theme_state.dart';
import 'package:etracker/core/storage/preferences_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferencesStorage extends Mock implements PreferencesStorage {}

void main() {
  late MockPreferencesStorage mockStorage;

  setUp(() {
    mockStorage = MockPreferencesStorage();
  });

  test('initial state defaults to System mode', () {
    final themeState = ThemeState(storage: mockStorage);
    expect(themeState.themeMode, equals(ThemeMode.system));
  });

  test('init loads saved light mode preference', () async {
    when(() => mockStorage.getThemeMode()).thenAnswer((_) async => ThemeMode.light.toString());

    final themeState = ThemeState(storage: mockStorage);
    await themeState.init();

    expect(themeState.themeMode, equals(ThemeMode.light));
  });

  test('init loads saved dark mode preference', () async {
    when(() => mockStorage.getThemeMode()).thenAnswer((_) async => ThemeMode.dark.toString());

    final themeState = ThemeState(storage: mockStorage);
    await themeState.init();

    expect(themeState.themeMode, equals(ThemeMode.dark));
  });

  test('init retains system mode when no preference saved', () async {
    when(() => mockStorage.getThemeMode()).thenAnswer((_) async => null);

    final themeState = ThemeState(storage: mockStorage);
    await themeState.init();

    expect(themeState.themeMode, equals(ThemeMode.system));
  });

  test('setThemeMode updates mode and persists to storage', () async {
    when(() => mockStorage.saveThemeMode(any())).thenAnswer((_) async {});

    final themeState = ThemeState(storage: mockStorage);

    await themeState.setThemeMode(ThemeMode.dark);

    expect(themeState.themeMode, equals(ThemeMode.dark));
    verify(() => mockStorage.saveThemeMode(ThemeMode.dark.toString())).called(1);
  });
}
