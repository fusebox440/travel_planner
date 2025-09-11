import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/itinerary/models/itinerary.dart';
import 'package:travel_planner/features/itinerary/widgets/add_item_dialog.dart';

void main() {
  group('AddItemDialog', () {
    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddItemDialog(),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to submit without title
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Should show error
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('creates ItineraryItem with valid input',
        (WidgetTester tester) async {
      ItineraryItem? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<ItineraryItem>(
                  context: context,
                  builder: (context) => const AddItemDialog(),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Activity');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, equals('Test Activity'));
      expect(result!.type, equals(ItineraryItemType.custom));
      expect(result!.id, isNotEmpty); // Check for generated UUID
    });

    testWidgets('handles optional fields correctly',
        (WidgetTester tester) async {
      ItineraryItem? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<ItineraryItem>(
                  context: context,
                  builder: (context) => const AddItemDialog(),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Fill in all fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Activity');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test Location');
      await tester.enterText(find.byType(TextFormField).last, 'Test Notes');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, equals('Test Activity'));
      expect(result!.location, equals('Test Location'));
      expect(result!.notes, equals('Test Notes'));
    });

    testWidgets('can be cancelled', (WidgetTester tester) async {
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await showDialog<ItineraryItem>(
                  context: context,
                  builder: (context) => const AddItemDialog(),
                );
                dialogClosed = result == null;
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Click cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(dialogClosed, isTrue);
    });
  });
}
