import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/main.dart';

void main() {
  testWidgets('App loads FoundationShowcase with essential widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ETrackerApp());

    // Verify that the title is present.
    expect(find.text('E-Tracker Foundation'), findsOneWidget);

    // Verify typography texts are present.
    expect(find.text('Typography'), findsOneWidget);
    expect(find.text('Headline Large'), findsOneWidget);
    expect(find.text('Financial Value: \$1,234.56'), findsOneWidget);

    // Verify TextFields exist (by label text)
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify AppButtons exist
    expect(find.text('Primary Action'), findsOneWidget);
    expect(find.text('Disabled Action'), findsOneWidget);
  });
}
