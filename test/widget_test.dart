import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golf_society/services/persistence_service.dart';
import 'package:golf_society/main.dart';

void main() {
  testWidgets('Golf Society app smoke test', (WidgetTester tester) async {
    // Setup mocks
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistenceService = PersistenceService(prefs);

    // Build nuestra app y disparar un frame.
    // We must wrap in ProviderScope and override the persistence provider
    await tester.pumpWidget(ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(persistenceService),
      ],
      child: const GolfSocietyApp(),
    ));

    // Wait for app initialization and navigation
    await tester.pumpAndSettle();

    // Verify that our custom navigation bar exists
    expect(find.byType(BoxyArtBottomNavBar), findsOneWidget);
    
    // Verify that Home tab is showing (label in the nav bar)
    expect(find.text('Home'), findsOneWidget);
  });
}
