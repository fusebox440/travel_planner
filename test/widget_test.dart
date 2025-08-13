import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/main.dart';

void main() {
  // A basic test to ensure the app starts.
  testWidgets('App starts and shows welcome text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap with ProviderScope for Riverpod.
    await tester.pumpWidget(const ProviderScope(
      child: MyApp(initialLocation: '/'), // Start at the home page for the test
    ));

    // Since the initial screen might be loading, we look for the AppBar title.
    expect(find.text('My Trips'), findsOneWidget);
  });
}