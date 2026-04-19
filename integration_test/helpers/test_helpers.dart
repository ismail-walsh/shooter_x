import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shooter_x/main.dart' as app;

/// Test credentials — use a dedicated test account in Supabase.
const String kTestEmail = 'test@shooterx.dev';
const String kTestPassword = 'Test1234!';

/// Boot the full app.
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Navigate to login screen and sign in with [kTestEmail] / [kTestPassword].
Future<void> signIn(WidgetTester tester) async {
  // Wait for onboarding / login screen
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // If we're already on the home page skip sign-in
  if (find.text('ShooterX').evaluate().isNotEmpty &&
      find.text('Recent').evaluate().isNotEmpty) {
    return;
  }

  // Tap "Get Started" or "Log In" on onboarding
  final getStarted = find.textContaining('Get Started');
  final logIn = find.textContaining('Log In');
  if (getStarted.evaluate().isNotEmpty) {
    await tester.tap(getStarted.first);
    await tester.pumpAndSettle();
  } else if (logIn.evaluate().isNotEmpty) {
    await tester.tap(logIn.first);
    await tester.pumpAndSettle();
  }

  // Fill email
  final emailField = find.byType(TextFormField).first;
  await tester.tap(emailField);
  await tester.enterText(emailField, kTestEmail);
  await tester.pumpAndSettle();

  // Fill password
  final passwordField = find.byType(TextFormField).last;
  await tester.tap(passwordField);
  await tester.enterText(passwordField, kTestPassword);
  await tester.pumpAndSettle();

  // Submit
  await tester.tap(find.textContaining('Sign In').first);
  await tester.pumpAndSettle(const Duration(seconds: 4));
}

/// Tap a bottom nav tab by its icon.
Future<void> tapNavTab(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Pump until a [Finder] appears or [timeout] elapses.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw Exception('Timed out waiting for: $finder');
}
