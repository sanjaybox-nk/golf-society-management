import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/utils/guest_id_helper.dart';

void main() {
  group('GuestIdHelper.resolveEffectiveId', () {
    test('returns plain id for non-guest player', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'id': 'p1', 'isGuest': false}),
        'p1',
      );
    });

    test('appends _guest suffix for player with isGuest=true', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'id': 'p1', 'isGuest': true}),
        'p1_guest',
      );
    });

    test('does not double-append _guest suffix', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'id': 'p1_guest', 'isGuest': true}),
        'p1_guest',
      );
    });

    test('detects guest via existing _guest suffix even without isGuest flag', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'id': 'p1_guest'}),
        'p1_guest',
      );
    });

    test('resolves id from registrationMemberId field', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'registrationMemberId': 'p2', 'isGuest': true}),
        'p2_guest',
      );
    });

    test('resolves id from memberId field', () {
      expect(
        GuestIdHelper.resolveEffectiveId({'memberId': 'p3', 'isGuest': false}),
        'p3',
      );
    });

    test('id field takes priority over registrationMemberId', () {
      expect(
        GuestIdHelper.resolveEffectiveId({
          'id': 'direct',
          'registrationMemberId': 'reg',
          'isGuest': false,
        }),
        'direct',
      );
    });

    test('returns empty string when no id field present and not a guest', () {
      expect(GuestIdHelper.resolveEffectiveId({}), '');
    });
  });

  group('GuestIdHelper.isGuest', () {
    test('returns true when isGuest flag is true', () {
      expect(GuestIdHelper.isGuest({'id': 'p1', 'isGuest': true}), isTrue);
    });

    test('returns false when isGuest flag is false', () {
      expect(GuestIdHelper.isGuest({'id': 'p1', 'isGuest': false}), isFalse);
    });

    test('returns true when id ends with _guest suffix', () {
      expect(GuestIdHelper.isGuest({'id': 'p1_guest'}), isTrue);
    });

    test('returns false when neither flag nor suffix', () {
      expect(GuestIdHelper.isGuest({'id': 'p1'}), isFalse);
    });

    test('checks registrationMemberId for suffix when id absent', () {
      expect(GuestIdHelper.isGuest({'registrationMemberId': 'p1_guest'}), isTrue);
    });
  });

  group('GuestIdHelper.stripGuestSuffix', () {
    test('strips _guest from end of id', () {
      expect(GuestIdHelper.stripGuestSuffix('p1_guest'), 'p1');
    });

    test('returns original string when no suffix', () {
      expect(GuestIdHelper.stripGuestSuffix('p1'), 'p1');
    });

    test('does not strip _guest from middle of id', () {
      expect(GuestIdHelper.stripGuestSuffix('p1_guest_extra'), 'p1_guest_extra');
    });

    test('handles empty string', () {
      expect(GuestIdHelper.stripGuestSuffix(''), '');
    });
  });
}
