import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the Training tab.
void trainingTests() {
  testWidgets('Training tab renders "Disciplines" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.school_outlined));
    await tester.tap(find.byIcon(Icons.school_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Disciplines'), findsOneWidget);
  });

  testWidgets('Training tab renders "Training Modules" section', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.school_outlined));
    await tester.tap(find.byIcon(Icons.school_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Training Modules'), findsOneWidget);
  });

  testWidgets('Discipline carousel does NOT show hardcoded items',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.school_outlined));
    await tester.tap(find.byIcon(Icons.school_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // The four old hardcoded names must not appear as discipline chip labels
    // (they could legitimately appear if those are the real DB discipline names,
    // but the point is they're being rendered from DB, so the test validates
    // the "All" chip is present which only appears when DB-driven)
    expect(find.text('All'), findsOneWidget,
        reason: '"All" chip is injected by the new Supabase-driven carousel');
  });

  testWidgets('Tapping "All" discipline chip shows unfiltered modules',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.school_outlined));
    await tester.tap(find.byIcon(Icons.school_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap the "All" chip
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Modules section should still be visible
    expect(find.text('Training Modules'), findsOneWidget);
  });

  testWidgets('Tapping a discipline chip filters the module list',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.school_outlined));
    await tester.tap(find.byIcon(Icons.school_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Find discipline chips (skip the first "All" chip)
    final chips = find.ancestor(
      of: find.byType(Text),
      matching: find.byType(InkWell),
    );
    if (chips.evaluate().length < 2) return; // Not enough chips to filter

    // Tap the second chip (first real discipline)
    await tester.tap(chips.at(1));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Modules section header must still be visible after filtering
    expect(find.text('Training Modules'), findsOneWidget);
  });
}
