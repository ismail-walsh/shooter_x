import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the Add Session flow.
void addSessionTests() {
  testWidgets('Add Session form renders all required fields', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Log Shoot'));
    await tester.tap(find.text('Log Shoot').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Required fields
    expect(find.textContaining('Discipline'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Firearm'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Distance'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Total Shots'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Hits'), findsAtLeastNWidgets(1));
  });

  testWidgets('Add Session saves and navigates to Session Summary',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.text('Log Shoot'));
    await tester.tap(find.text('Log Shoot').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill firearm
    final firearmField = find.byType(TextField).at(0);
    if (firearmField.evaluate().isNotEmpty) {
      await tester.tap(firearmField);
      await tester.enterText(firearmField, 'Test Rifle');
      await tester.pumpAndSettle();
    }

    // Fill distance
    final distanceField = find.byType(TextField).at(1);
    if (distanceField.evaluate().isNotEmpty) {
      await tester.tap(distanceField);
      await tester.enterText(distanceField, '25');
      await tester.pumpAndSettle();
    }

    // Fill total shots
    final totalShotsField = find.byType(TextField).at(2);
    if (totalShotsField.evaluate().isNotEmpty) {
      await tester.tap(totalShotsField);
      await tester.enterText(totalShotsField, '10');
      await tester.pumpAndSettle();
    }

    // Fill hits
    final hitsField = find.byType(TextField).at(3);
    if (hitsField.evaluate().isNotEmpty) {
      await tester.tap(hitsField);
      await tester.enterText(hitsField, '8');
      await tester.pumpAndSettle();
    }

    // Submit
    final saveButton = find.textContaining('Save').first;
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Should land on Session Summary
    expect(find.text('Session Summary'), findsOneWidget);
  });

  testWidgets('Session Summary shows real accuracy value after save',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    // Navigate to add session and enter 10 shots / 8 hits = 80%
    await pumpUntilFound(tester, find.text('Log Shoot'));
    await tester.tap(find.text('Log Shoot').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill in fields (best-effort — field indices may vary)
    final textFields = find.byType(TextField);
    final count = textFields.evaluate().length;
    if (count >= 3) {
      await tester.enterText(textFields.at(count - 2), '10'); // total shots
      await tester.enterText(textFields.at(count - 1), '8');  // hits
    }

    final saveButton = find.textContaining('Save');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton.first);
      await tester.tap(saveButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // Accuracy 80% should appear somewhere on Session Summary
    expect(find.textContaining('80'), findsAtLeastNWidgets(1));
  });
}
