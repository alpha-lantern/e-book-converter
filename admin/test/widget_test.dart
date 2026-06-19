import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin/main.dart';

void main() {
  testWidgets('Admin Login Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the login text is present.
    expect(find.text('Welcome to Codex Admin'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Admin Sign Up Screen toggle and fields validation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify initially we are on Login Screen (2 text fields)
    expect(find.text('Welcome to Codex Admin'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Find the toggle button, ensure it's visible, and tap it
    final toggleButton = find.text("Don't have an account? Sign Up");
    expect(toggleButton, findsOneWidget);
    await tester.ensureVisible(toggleButton);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    // Verify we are now on Create Account mode (5 text fields: email, fullName, orgName, password, confirmPassword)
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('Register'), findsOneWidget);

    // Find the toggle button back to login, ensure it's visible, and tap it
    final toggleBack = find.text("Already have an account? Log In");
    expect(toggleBack, findsOneWidget);
    await tester.ensureVisible(toggleBack);
    await tester.tap(toggleBack);
    await tester.pumpAndSettle();

    // Verify we are back to Login mode
    expect(find.text('Welcome to Codex Admin'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
