import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_planner/features/itinerary/models/itinerary.dart';
import 'package:travel_planner/features/itinerary/screens/itinerary_screen.dart';
import 'package:travel_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Itinerary Feature Test', () {
    testWidgets('Add new itinerary item flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Itinerary Screen (assuming navigation logic)
      // This will need to be adjusted based on your actual navigation
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      // Find and tap add item button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'Visit Museum');
      await tester.enterText(find.byType(TextFormField).at(1), 'City Museum');
      await tester.enterText(
          find.byType(TextFormField).last, 'Check special exhibits');

      // Submit the form
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify the item appears in the list
      expect(find.text('Visit Museum'), findsOneWidget);
      expect(find.text('City Museum'), findsOneWidget);
    });

    testWidgets('Edit existing itinerary item flow',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Itinerary Screen
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      // Find and tap edit button on existing item
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Verify edit dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Modify the item
      await tester.enterText(
          find.byType(TextFormField).first, 'Updated Activity');

      // Save changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the changes appear
      expect(find.text('Updated Activity'), findsOneWidget);
    });

    testWidgets('Delete itinerary item flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Itinerary Screen
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      // Remember the title of the first item
      final String itemTitle =
          (tester.widget(find.byType(Text).first) as Text).data!;

      // Find and tap delete button
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the item is gone
      expect(find.text(itemTitle), findsNothing);
    });
  });
}
