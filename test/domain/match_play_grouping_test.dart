import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

GolfEvent _event({int interval = 10}) => GolfEvent(
  id: 'evt-1',
  title: 'Test Event',
  seasonId: 'season-1',
  date: DateTime(2026, 6, 1),
  teeOffTime: DateTime(2026, 6, 1, 8, 0),
  teeOffInterval: interval,
);

RegistrationItem _player(String id, {bool isGuest = false}) {
  final reg = EventRegistration(
    memberId: id,
    memberName: 'Player $id',
    attendingGolf: true,
    isConfirmed: true,
    hasPaid: true,
  );
  return RegistrationItem(
    registration: reg,
    originalRegistration: reg,
    isGuest: isGuest,
    registeredAt: DateTime(2026, 5, 1),
    hasPaid: true,
    isConfirmed: true,
    name: 'Player $id',
    needsBuggy: false,
  );
}

MatchDefinition _match(String a, String b) => MatchDefinition(
  id: 'match-$a-$b',
  type: MatchType.singles,
  team1Ids: [a],
  team2Ids: [b],
);

MatchDefinition _bye(String playerId) => MatchDefinition(
  id: 'bye-$playerId',
  type: MatchType.singles,
  team1Ids: [playerId],
  team2Ids: [],
  isBye: true,
);

Map<String, double> _hc(List<RegistrationItem> players) =>
    {for (final p in players) p.registration.memberId: 12.0};

List<TeeGroup> _generate({
  required List<MatchDefinition> matches,
  required List<RegistrationItem> players,
  GolfEvent? event,
}) =>
    GroupingService.generateMatchPlayGrouping(
      event: event ?? _event(),
      matches: matches,
      participants: players,
      previousEventsInSeason: [],
      memberHandicaps: _hc(players),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GroupingService.generateMatchPlayGrouping', () {
    test('returns empty when no participants', () {
      final result = _generate(matches: [_match('a', 'b')], players: []);
      expect(result, isEmpty);
    });

    test('single match → 2-ball group', () {
      final result = _generate(
        matches: [_match('a', 'b')],
        players: [_player('a'), _player('b')],
      );
      expect(result.length, 1);
      expect(result[0].players.length, 2);
    });

    test('two matches → 1 × 4-ball', () {
      final players = ['a', 'b', 'c', 'd'].map(_player).toList();
      final result = _generate(
        matches: [_match('a', 'b'), _match('c', 'd')],
        players: players,
      );
      expect(result.length, 1);
      expect(result[0].players.length, 4);
    });

    test('four matches → 2 × 4-ball', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map(_player).toList();
      final matches = [_match('a', 'b'), _match('c', 'd'), _match('e', 'f'), _match('g', 'h')];
      final result = _generate(matches: matches, players: players);
      expect(result.length, 2);
      expect(result.every((g) => g.players.length == 4), isTrue);
    });

    test('paired players are always in the same group', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map(_player).toList();
      final matches = [_match('a', 'b'), _match('c', 'd'), _match('e', 'f'), _match('g', 'h')];
      final result = _generate(matches: matches, players: players);

      for (final match in matches) {
        final groupOfA = result.firstWhere(
          (g) => g.players.any((p) => p.registrationMemberId == match.playerAId),
        );
        expect(
          groupOfA.players.any((p) => p.registrationMemberId == match.playerBId),
          isTrue,
          reason: '${match.playerAId} and ${match.playerBId} must share a group',
        );
      }
    });

    test('three matches with no extras → 4-ball + 2-ball', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f'].map(_player).toList();
      final result = _generate(
        matches: [_match('a', 'b'), _match('c', 'd'), _match('e', 'f')],
        players: players,
      );
      final sizes = result.map((g) => g.players.length).toList()..sort();
      expect(sizes, [2, 4]);
    });

    test('odd pair + bye registrant → 4-ball + 3-ball', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'bye1'].map(_player).toList();
      final matches = [_match('a', 'b'), _match('c', 'd'), _match('e', 'f'), _bye('bye1')];
      final result = _generate(matches: matches, players: players);

      final sizes = result.map((g) => g.players.length).toList()..sort();
      expect(sizes, [3, 4]);
      expect(result.any((g) => g.players.any((p) => p.registrationMemberId == 'bye1')), isTrue);
    });

    test('odd pair + unpaired registrant → 4-ball + 3-ball', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'extra'].map(_player).toList();
      final result = _generate(
        matches: [_match('a', 'b'), _match('c', 'd'), _match('e', 'f')],
        players: players,
      );
      final sizes = result.map((g) => g.players.length).toList()..sort();
      expect(sizes, [3, 4]);
      expect(result.any((g) => g.players.any((p) => p.registrationMemberId == 'extra')), isTrue);
    });

    test('unregistered player in draw → match skipped, registered player treated as unpaired', () {
      // 'b' is in the draw but never registered → match a-b skipped
      final players = [_player('a'), _player('c'), _player('d')];
      final result = _generate(
        matches: [_match('a', 'b'), _match('c', 'd')],
        players: players,
      );
      // c-d → pair; a → unpaired filler → 3-ball [c, d, a]
      expect(result.length, 1);
      expect(result[0].players.length, 3);
      final ids = result[0].players.map((p) => p.registrationMemberId).toSet();
      expect(ids, containsAll(['a', 'c', 'd']));
      expect(ids, isNot(contains('b')));
    });

    test('guests are excluded even if in participants', () {
      final players = [_player('a'), _player('b'), _player('guest1', isGuest: true)];
      final result = _generate(
        matches: [_match('a', 'b')],
        players: players,
      );
      final allIds = result.expand((g) => g.players.map((p) => p.registrationMemberId));
      expect(allIds, isNot(contains('guest1')));
    });

    test('no player appears in more than one group', () {
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'x', 'y'].map(_player).toList();
      final matches = [_match('a', 'b'), _match('c', 'd'), _match('e', 'f'), _match('g', 'h')];
      final result = _generate(matches: matches, players: players);

      final allIds = result.expand((g) => g.players.map((p) => p.registrationMemberId)).toList();
      expect(allIds.length, equals(allIds.toSet().length));
    });

    test('extra registrants beyond the draw fill additional groups', () {
      // 2 pairs → 4-ball; 4 extras → 1 × 4-ball
      final players = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map(_player).toList();
      final matches = [_match('a', 'b'), _match('c', 'd')];
      final result = _generate(matches: matches, players: players);

      expect(result.length, 2);
      expect(result.every((g) => g.players.length == 4), isTrue);
    });

    test('tee times increment by teeOffInterval per group', () {
      final teeOff = DateTime(2026, 6, 1, 8, 0);
      final event = GolfEvent(
        id: 'e', title: 'T', seasonId: 's', date: DateTime(2026, 6, 1),
        teeOffTime: teeOff,
        teeOffInterval: 10,
      );
      final players = ['a', 'b', 'c', 'd'].map(_player).toList();
      final result = GroupingService.generateMatchPlayGrouping(
        event: event,
        matches: [_match('a', 'b'), _match('c', 'd')],
        participants: players,
        previousEventsInSeason: [],
        memberHandicaps: _hc(players),
      );
      // 2 pairs → 1 group → first group starts at teeOff
      expect(result[0].teeTime, teeOff);
    });

    test('each group has exactly one captain assigned', () {
      final players = ['a', 'b', 'c', 'd'].map(_player).toList();
      final result = _generate(
        matches: [_match('a', 'b'), _match('c', 'd')],
        players: players,
      );
      for (final group in result) {
        final captains = group.players.where((p) => p.isCaptain).length;
        expect(captains, 1);
      }
    });
  });
}
