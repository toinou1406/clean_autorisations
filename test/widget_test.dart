// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastclean/main.dart';

void main() {
  testWidgets('Initial UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We provide the home route as the initial route for this test.
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.home, locale: Locale('en')));

    // Let the app settle.
    await tester.pumpAndSettle();

    // Verify that the main title is present.
    expect(find.byKey(const Key('homeScreenTitle')), findsOneWidget);

    // Verify that the initial "Analyze Photos" button is present.
    expect(find.byKey(const Key('analyzePhotosButton')), findsOneWidget);

    // Verify that the "Delete" button is not present initially.
    expect(find.textContaining('Delete'), findsNothing);
  });
}
