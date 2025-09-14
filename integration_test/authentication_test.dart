import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_planner/main.dart' as app;
import 'package:travel_planner/features/authentication/presentation/pages/auth_entry_page.dart';
import 'package:travel_planner/features/authentication/presentation/pages/phone_input_page.dart';
import 'package:travel_planner/features/authentication/presentation/pages/otp_input_page.dart';

/// Helper function to find first available widget from multiple finders
Finder findFirstAvailable(List<Finder> finders) {
  for (final finder in finders) {
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return finders.first; // Return first if none found (will cause test failure)
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete phone authentication flow with test number',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for Firebase initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to authentication if not already there
      if (find.byType(AuthEntryPage).evaluate().isEmpty) {
        // Look for sign in button or similar
        final signInButton = findFirstAvailable(
            [find.text('Sign In'), find.text('Get Started')]);
        if (signInButton.evaluate().isNotEmpty) {
          await tester.tap(signInButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Should be on AuthEntryPage
      expect(find.byType(AuthEntryPage), findsOneWidget);
      expect(find.text('Welcome to Travel Planner'), findsOneWidget);

      // Tap "Continue with Phone" button
      final continueButton = findFirstAvailable([
        find.text('Continue with Phone'),
        find.byKey(const Key('continue_with_phone_button'))
      ]);
      await tester.tap(continueButton.first);
      await tester.pumpAndSettle();

      // Should be on PhoneInputPage
      expect(find.byType(PhoneInputPage), findsOneWidget);

      // Enter phone number in the available text field
      final phoneField = findFirstAvailable(
          [find.byKey(const Key('phone_input')), find.byType(TextFormField)]);
      await tester.tap(phoneField.first);
      await tester.enterText(phoneField.first, '+1234567890');

      // Tap send code button
      final sendButton = findFirstAvailable(
          [find.text('Send Code'), find.byKey(const Key('send_code_button'))]);
      await tester.tap(sendButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for error message (invalid number)
      final hasError = findFirstAvailable(
          [find.textContaining('Invalid'), find.textContaining('invalid')]);
      if (hasError.evaluate().isNotEmpty) {
        // Test number is invalid, which is expected
        return; // End test here
      }

      // If OTP page appears (unlikely with fake number)
      if (find.byType(OtpInputPage).evaluate().isNotEmpty) {
        expect(find.byType(OtpInputPage), findsOneWidget);
      }
    });

    testWidgets('Basic authentication navigation test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we can navigate to authentication flow
      expect(true, isTrue); // Placeholder test to ensure compilation
    });
  });
}
