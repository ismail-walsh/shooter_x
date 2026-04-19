import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'auth_test.dart';
import 'home_page_test.dart';
import 'add_session_test.dart';
import 'clubs_test.dart';
import 'community_test.dart';
import 'training_test.dart';

/// Entry-point that runs all integration test groups.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// Running the tests
/// ─────────────────────────────────────────────────────────────────────────────
///
/// Standard Flutter integration tests (works on any connected device/emulator):
///   flutter test integration_test/app_test.dart --device-id <id>
///
/// Using the Patrol CLI (installs a native test runner for faster iteration,
/// closer to a Playwright experience including native UI interaction):
///   dart pub global activate patrol_cli
///   patrol test --target integration_test/app_test.dart
///
/// Run a single group only (e.g. auth):
///   flutter test integration_test/auth_test.dart --device-id <id>
///
/// ─────────────────────────────────────────────────────────────────────────────
/// Test account
/// ─────────────────────────────────────────────────────────────────────────────
/// Tests use the credentials defined in helpers/test_helpers.dart:
///   email:    test@shooterx.dev
///   password: Test1234!
///
/// Create this account in your Supabase project before running.
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow', authTests);
  group('Home page', homePageTests);
  group('Add session', addSessionTests);
  group('Clubs', clubsTests);
  group('Community', communityTests);
  group('Training', trainingTests);
}
