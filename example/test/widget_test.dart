// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dynamic_popup_example/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Dynamic Popup Example'), findsOneWidget);
    
    // Verify that buttons are displayed
    expect(find.text('Open Test Page'), findsOneWidget);
    expect(find.text('Show Non-blocking Popup'), findsOneWidget);
    expect(find.text('Show Blocking Popup'), findsOneWidget);
    expect(find.text('Show Complex Popup'), findsOneWidget);
    expect(find.text('Reset All Popup States'), findsOneWidget);
  });
}