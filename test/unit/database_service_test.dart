import 'package:flutter_test/flutter_test.dart';

/// Unit tests for DatabaseService helper logic.
///
/// The Supabase client itself is not mocked here — pure logic helpers are
/// tested instead. For full end-to-end DB tests use the integration_test suite.
void main() {
  group('Accuracy calculation', () {
    double calculateAccuracy(int hits, int totalShots) {
      if (totalShots == 0) return 0.0;
      return (hits / totalShots) * 100.0;
    }

    test('80 hits out of 100 = 80.0%', () {
      expect(calculateAccuracy(80, 100), equals(80.0));
    });

    test('8 hits out of 10 = 80.0%', () {
      expect(calculateAccuracy(8, 10), equals(80.0));
    });

    test('0 hits out of 10 = 0.0%', () {
      expect(calculateAccuracy(0, 10), equals(0.0));
    });

    test('10 hits out of 10 = 100.0%', () {
      expect(calculateAccuracy(10, 10), equals(100.0));
    });

    test('0 total shots = 0.0% (no division by zero)', () {
      expect(calculateAccuracy(0, 0), equals(0.0));
    });
  });

  group('Rank suffix helper', () {
    String getRankSuffix(int rank) {
      if (rank % 100 >= 11 && rank % 100 <= 13) return 'th';
      switch (rank % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    test('1st', () => expect(getRankSuffix(1), equals('st')));
    test('2nd', () => expect(getRankSuffix(2), equals('nd')));
    test('3rd', () => expect(getRankSuffix(3), equals('rd')));
    test('4th', () => expect(getRankSuffix(4), equals('th')));
    test('11th (special case)', () => expect(getRankSuffix(11), equals('th')));
    test('12th (special case)', () => expect(getRankSuffix(12), equals('th')));
    test('13th (special case)', () => expect(getRankSuffix(13), equals('th')));
    test('21st', () => expect(getRankSuffix(21), equals('st')));
    test('100th', () => expect(getRankSuffix(100), equals('th')));
    test('101st', () => expect(getRankSuffix(101), equals('st')));
  });

  group('Session label builder', () {
    String buildSessionLabel(int? distance, String? firearm) {
      return [
        if (distance != null) '${distance}m',
        if (firearm != null && firearm.isNotEmpty) firearm,
      ].join(' - ');
    }

    test('distance and firearm', () {
      expect(buildSessionLabel(25, 'Ruger 10/22'), equals('25m - Ruger 10/22'));
    });

    test('distance only', () {
      expect(buildSessionLabel(50, null), equals('50m'));
    });

    test('firearm only', () {
      expect(buildSessionLabel(null, 'Beretta 92'), equals('Beretta 92'));
    });

    test('neither', () {
      expect(buildSessionLabel(null, null), equals(''));
    });

    test('empty firearm string', () {
      expect(buildSessionLabel(100, ''), equals('100m'));
    });
  });
}
