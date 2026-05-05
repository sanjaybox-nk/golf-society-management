import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/utils/firestore_normalizer.dart';

void main() {
  group('FirestoreNormalizer.resolveMemberId', () {
    test('returns memberId when present', () {
      expect(
        FirestoreNormalizer.resolveMemberId({'memberId': 'abc', 'userId': 'xyz'}),
        'abc',
      );
    });

    test('falls back to userId when memberId absent', () {
      expect(
        FirestoreNormalizer.resolveMemberId({'userId': 'xyz', 'playerId': 'ppp'}),
        'xyz',
      );
    });

    test('falls back to playerId when memberId and userId absent', () {
      expect(
        FirestoreNormalizer.resolveMemberId({'playerId': 'ppp'}),
        'ppp',
      );
    });

    test('returns unknown when no ID field present', () {
      expect(
        FirestoreNormalizer.resolveMemberId({}),
        'unknown',
      );
    });

    test('returns unknown when all ID fields are null', () {
      expect(
        FirestoreNormalizer.resolveMemberId({'memberId': null, 'userId': null, 'playerId': null}),
        'unknown',
      );
    });

    test('converts non-String values to String', () {
      expect(
        FirestoreNormalizer.resolveMemberId({'memberId': 12345}),
        '12345',
      );
    });

    test('memberId takes priority over userId and playerId', () {
      expect(
        FirestoreNormalizer.resolveMemberId({
          'memberId': 'member',
          'userId': 'user',
          'playerId': 'player',
        }),
        'member',
      );
    });

    test('handles extra irrelevant fields without error', () {
      expect(
        FirestoreNormalizer.resolveMemberId({
          'name': 'Alice',
          'score': 72,
          'memberId': 'alice123',
        }),
        'alice123',
      );
    });
  });
}
