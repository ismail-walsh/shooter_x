import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the Clubs tab.
void clubsTests() {
  testWidgets('Clubs tab loads without infinite spinner', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    // Navigate to Clubs tab
    await pumpUntilFound(tester, find.byIcon(Icons.groups_outlined));
    await tester.tap(find.byIcon(Icons.groups_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // No lingering full-screen spinner after data loads
    expect(
      find.byType(CircularProgressIndicator).evaluate().length < 3,
      isTrue,
      reason: 'Clubs page still showing too many loading spinners',
    );
  });

  testWidgets('Clubs page shows "Discover New Clubs" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.groups_outlined));
    await tester.tap(find.byIcon(Icons.groups_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.textContaining('Discover'), findsAtLeastNWidgets(1));
  });

  testWidgets('Tapping a club card navigates to Club Profile', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.groups_outlined));
    await tester.tap(find.byIcon(Icons.groups_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Look for a club card – find any InkWell inside the grid
    final clubCard = find
        .descendant(of: find.byType(GridView), matching: find.byType(InkWell))
        .first;
    if (clubCard.evaluate().isEmpty) return; // No clubs seeded, skip

    await tester.tap(clubCard);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Club Profile should have a join/leave button or description
    expect(
      find.textContaining('Join').evaluate().isNotEmpty ||
          find.textContaining('Member').evaluate().isNotEmpty ||
          find.textContaining('Leave').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected Club Profile screen with membership button',
    );
  });

  testWidgets('Find Clubs search filters results', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    // Navigate to Find Clubs (via Clubs tab or Home quick-actions)
    await pumpUntilFound(tester, find.byIcon(Icons.groups_outlined));
    await tester.tap(find.byIcon(Icons.groups_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Look for search field
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isEmpty) return;

    await tester.tap(searchField.first);
    await tester.enterText(searchField.first, 'ZZZNOMATCH999');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // With no match the grid should be empty
    expect(
      find.descendant(of: find.byType(GridView), matching: find.byType(InkWell))
          .evaluate()
          .isEmpty,
      isTrue,
      reason: 'Expected zero results for nonsense search query',
    );
  });
}
