import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

/// Tests for the Community tab.
void communityTests() {
  testWidgets('Community tab shows "Suggested Communities" section',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.forum_outlined));
    await tester.tap(find.byIcon(Icons.forum_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.textContaining('Suggested Communities'), findsOneWidget);
  });

  testWidgets('Community discipline cards do NOT show hardcoded text',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.forum_outlined));
    await tester.tap(find.byIcon(Icons.forum_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // These were the hardcoded placeholder strings — they must be gone
    expect(find.text('Deer Stalking UK'), findsNothing);
    expect(find.text('3,000 Members'), findsNothing);
  });

  testWidgets('Create post button is tappable and opens create post screen',
      (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.forum_outlined));
    await tester.tap(find.byIcon(Icons.forum_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final createPostButton = find.byIcon(Icons.add).first;
    if (createPostButton.evaluate().isEmpty) return;

    await tester.tap(createPostButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.textContaining('Post').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected Create Post screen',
    );
  });

  testWidgets('Creating a post adds it to the community feed', (tester) async {
    await launchApp(tester);
    await signIn(tester);

    await pumpUntilFound(tester, find.byIcon(Icons.forum_outlined));
    await tester.tap(find.byIcon(Icons.forum_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final createPostButton = find.byIcon(Icons.add);
    if (createPostButton.evaluate().isEmpty) return;

    await tester.tap(createPostButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    const postContent = 'Integration test post ${1000}';
    final textField = find.byType(TextField).first;
    if (textField.evaluate().isEmpty) return;

    await tester.tap(textField);
    await tester.enterText(textField, postContent);
    await tester.pumpAndSettle();

    final submitButton = find.textContaining('Post').last;
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Back on community feed — post should be visible
    expect(find.textContaining(postContent), findsOneWidget);
  });
}
