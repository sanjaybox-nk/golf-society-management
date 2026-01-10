import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golf_society/main.dart';

void main() {
  testWidgets('Golf Society app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: GolfSocietyApp()));

    // Wait for app initialization
    await tester.pumpAndSettle();

    // Verify that navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify that Home tab is showing
    expect(find.text('Home'), findsOneWidget);
  });
}
