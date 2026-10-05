import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/settings/settings_screen.dart';
import 'package:etracker/core/theme/theme_provider.dart';
import 'package:etracker/core/theme/theme_state.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeState extends Mock implements ThemeState {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockThemeState mockThemeState;

  setUp(() {
    mockThemeState = MockThemeState();
    when(() => mockThemeState.themeMode).thenReturn(ThemeMode.system);
    // Needed for ListenableBuilder / InheritedNotifier
    when(() => mockThemeState.addListener(any())).thenAnswer((_) {});
    when(() => mockThemeState.removeListener(any())).thenAnswer((_) {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ThemeProvider(
        themeState: mockThemeState,
        child: const SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Check titles
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Management'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // Check tiles
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);

    // Check About section
    expect(find.text('E TRACKER'), findsOneWidget);
    expect(find.text('Version 1.0.0+1'), findsOneWidget);
  });

  testWidgets('Tapping Theme opens bottom sheet with options', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final themeTile = find.widgetWithText(ListTile, 'Theme');
    await tester.tap(themeTile);
    await tester.pumpAndSettle();

    expect(find.text('Select Theme'), findsOneWidget);
    expect(find.text('System'), findsNWidgets(2)); // One in the list tile on screen, one in modal
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}
