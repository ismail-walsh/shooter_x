import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the authentication flow.
void authTests() {
  testWidgets('App shows onboarding on cold start when signed out',
      (tester) async {
    await launchApp(tester);

    // Should see onboarding or login screen – not the home nav bar
    expect(
      find.textContaining('ShooterX').evaluate().isNotEmpty ||
          find.textContaining('Log In').evaluate().isNotEmpty ||
          find.textContaining('Get Started').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected onboarding / auth screen on launch',
    );
  });

  testWidgets('Sign in with valid credentials reaches Home page',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    // After sign-in the bottom nav and "Recent" heading should be visible
    await pumpUntilFound(tester, find.text('Recent'));
    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('Sign in with wrong password shows error', (tester) async {
    await launchApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to login if on onboarding
    final logIn = find.textContaining('Log In');
    if (logIn.evaluate().isNotEmpty) {
      await tester.tap(logIn.first);
      await tester.pumpAndSettle();
    }

    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'test@shooterx.dev');
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(passwordField, 'WRONG_PASSWORD');
    await tester.tap(find.textContaining('Sign In').first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Expect an error snackbar or inline message
    expect(
      find.byType(SnackBar).evaluate().isNotEmpty ||
          find.textContaining('Invalid').evaluate().isNotEmpty ||
          find.textContaining('error').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected error feedback for wrong password',
    );
  });

  testWidgets('Logout returns user to onboarding / login', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    // Go to profile
    await pumpUntilFound(tester, find.byIcon(Icons.account_circle));
    await tester.tap(find.byIcon(Icons.account_circle).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap logout
    await pumpUntilFound(tester, find.textContaining('Logout'));
    await tester.tap(find.textContaining('Logout').first);
    await tester.pumpAndSettle();

    // Confirm dialog
    final confirmButton = find.textContaining('Logout').last;
    if (confirmButton.evaluate().isNotEmpty) {
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // Should be back at onboarding / login
    expect(
      find.textContaining('Log In').evaluate().isNotEmpty ||
          find.textContaining('Get Started').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected auth screen after logout',
    );
  });
}
