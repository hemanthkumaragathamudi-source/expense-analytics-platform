import 'package:flutter/material.dart';
import 'theme_state.dart';

class ThemeProvider extends InheritedNotifier<ThemeState> {
  const ThemeProvider({
    super.key,
    required ThemeState themeState,
    required super.child,
  }) : super(notifier: themeState);

  static ThemeState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    if (provider == null) {
      throw Exception('ThemeProvider not found in context');
    }
    return provider.notifier!;
  }
}
