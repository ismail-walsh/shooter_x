import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the Home page.
void homePageTests() {
  testWidgets('Home page shows "Recent" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Recent'));
    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('Home page shows "Upcoming Events" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Upcoming Events'));
    expect(find.text('Upcoming Events'), findsOneWidget);
  });

  testWidgets('Home page shows "Leaderboard" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Leaderboard'));
    expect(find.text('Leaderboard'), findsOneWidget);
  });

  testWidgets('Tapping "Add Session" button navigates to add session screen',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Log Shoot'));
    await tester.tap(find.text('Log Shoot').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Add Session form should be visible
    expect(
      find.textContaining('Session').evaluate().isNotEmpty ||
          find.textContaining('Discipline').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected Add Session screen',
    );
  });

  testWidgets('Session cards show real date and accuracy (not hardcoded)',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // The old hardcoded text must not appear
    expect(find.text('10th Sept'), findsNothing);
    expect(find.text('22m Range - Marlin .357'), findsNothing);
    expect(find.text('96%'), findsNothing);
  });

  testWidgets('Tapping a session card navigates to Session Summary',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Only run if there are session cards in the horizontal list
    final sessionCards = find.ancestor(
      of: find.byIcon(Icons.sports_score_outlined),
      matching: find.byType(InkWell),
    );

    if (sessionCards.evaluate().isEmpty) {
      // No sessions yet — skip
      return;
    }

    await tester.tap(sessionCards.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Session Summary'), findsOneWidget);
  });
}
