
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/golf_event_match_extensions.dart';
import '../../../../features/events/presentation/events_provider.dart';
import '../../../../features/members/presentation/profile_provider.dart';
import '../../../../features/competitions/presentation/competitions_provider.dart';
import '../../../../features/members/presentation/members_provider.dart';
import '../../../../models/competition.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/member.dart';

part 'match_play_providers.g.dart';

class MatchData {
  final MatchDefinition match;
  final MatchResult result;
  MatchData({required this.match, required this.result});
}

@riverpod
class CurrentMatchController extends _$CurrentMatchController {
  @override
  FutureOr<MatchData?> build(String eventId) async {
    final eventAsync = ref.watch(eventProvider(eventId));
    final user = ref.watch(effectiveUserProvider);
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    final allMembersAsync = ref.watch(allMembersProvider);
    
    return eventAsync.when(
      data: (event) {
        final comp = compAsync.asData?.value;
        final membersList = allMembersAsync.asData?.value ?? [];

        // 1. Find Match for Current User
        var matches = event.matches;

        // [NEW] Dynamic Derivation if matches are empty but competition is Match Play
        if (matches.isEmpty && comp?.rules.format == CompetitionFormat.matchPlay) {
          final groups = event.grouping['groups'] as List?;
          if (groups != null) {
            // Find user's group
            final myGroup = groups.firstWhereOrNull((g) {
              final players = g['players'] as List?;
              return players?.any((p) {
                final pid = p['registrationMemberId'] ?? p['id'];
                final id = p['isGuest'] == true ? '${pid}_guest' : pid;
                return id == user.id;
              }) ?? false;
            });

            if (myGroup != null) {
              final players = myGroup['players'] as List?;
              if (players != null && players.length >= 2) {
                final subtype = comp?.rules.subtype ?? CompetitionSubtype.none;
                
                if (subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes) {
                   // Split 1+2 vs 3+4
                   final pIds = players.map((p) {
                      final pid = p['registrationMemberId'] ?? p['id'];
                      return p['isGuest'] == true ? '${pid}_guest' : pid as String;
                   }).toList();

                    final Map<String, double> indices = {};
                    final Map<String, Map<String, dynamic>> configs = {};

                    for (var pid in pIds) {
                      final baseId = pid.replaceFirst('_guest', '');
                      final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
                      final member = membersList.firstWhereOrNull((m) => m.id == baseId);
                      
                      double index = 18.0;
                      if (pid.contains('_guest')) {
                        index = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
                      } else {
                        index = member?.handicap ?? 18.0;
                      }
                      indices[pid] = index;
                      configs[pid] = _resolvePlayerCourseConfig(pid, event, membersList);
                    }

                    final Map<String, int> strokes = MatchPlayCalculator.calculateRelativeStrokes(
                      playerIds: pIds, 
                      playerIndices: indices, 
                      courseConfigs: configs, 
                      rules: comp?.rules ?? const CompetitionRules(),
                      baseRating: (event.courseConfig['rating'] as num?)?.toDouble() ?? 72.0,
                    );

                   final t1 = pIds.take(2).toList();
                   final t2 = pIds.skip(2).take(2).toList();
                   
                   if (t1.isNotEmpty && t2.isNotEmpty) {
                      matches = [
                        MatchDefinition(
                          id: 'dynamic_${event.id}_${myGroup['id'] ?? 'g'}',
                          type: subtype == CompetitionSubtype.fourball ? MatchType.fourball : MatchType.foursomes,
                          team1Ids: t1,
                          team2Ids: t2,
                          strokesReceived: strokes,
                        )
                      ];
                   }
                } else {
                   // Singles Match Play: 1 vs 2, 3 vs 4
                   final pIds = players.map((p) {
                      final pid = p['registrationMemberId'] ?? p['id'];
                      return p['isGuest'] == true ? '${pid}_guest' : pid as String;
                   }).toList();

                   final Map<String, double> indices = {};
                   final Map<String, Map<String, dynamic>> configs = {};

                   for (var pid in pIds) {
                      final baseId = pid.replaceFirst('_guest', '');
                      final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
                      final member = membersList.firstWhereOrNull((m) => m.id == baseId);
                      
                      double index = 18.0;
                      if (pid.contains('_guest')) {
                        index = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
                      } else {
                        index = member?.handicap ?? 18.0;
                      }
                      indices[pid] = index;
                      configs[pid] = _resolvePlayerCourseConfig(pid, event, membersList);
                   }

                   final Map<String, int> strokes = MatchPlayCalculator.calculateRelativeStrokes(
                      playerIds: pIds, 
                      playerIndices: indices, 
                      courseConfigs: configs, 
                      rules: comp?.rules ?? const CompetitionRules(),
                      baseRating: (event.courseConfig['rating'] as num?)?.toDouble() ?? 72.0,
                   );

                   final userIndex = pIds.indexOf(user.id);
                   if (userIndex != -1) {
                      final pairIndex = userIndex.isEven ? userIndex + 1 : userIndex - 1;
                      if (pairIndex < pIds.length) {
                        final opponentId = pIds[pairIndex];
                        final uStrokes = strokes[user.id] ?? 0;
                        final oStrokes = strokes[opponentId] ?? 0;

                        matches = [
                          MatchDefinition(
                            id: 'dynamic_singles_${event.id}_${user.id}',
                            type: MatchType.singles,
                            team1Ids: userIndex.isEven ? [user.id] : [opponentId],
                            team2Ids: userIndex.isEven ? [opponentId] : [user.id],
                            strokesReceived: {
                               user.id: uStrokes,
                               opponentId: oStrokes,
                            },
                          )
                        ];
                      }
                   }
                }
              }
            }
          }
        }

        if (matches.isEmpty) return null;

        final userMatch = matches.where((m) => m.team1Ids.contains(user.id) || m.team2Ids.contains(user.id)).firstOrNull;
        if (userMatch == null) return null;
        

        // 2. Verified Data Source: Use the stream of scorecards for this event
        final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
        
        // Return null while loading or error, or calculate if data available
        return scorecardsAsync.when(
          data: (scorecards) {
             final result = MatchPlayCalculator.calculate(
              match: userMatch, 
              scorecards: scorecards, 
              courseConfig: event.courseConfig, 
              holesToPlay: event.courseConfig['holes']?.length ?? 18
            );
            return MatchData(match: userMatch, result: result);
          },
          loading: () => null,
          error: (_, s) => null,
        );

      },
      loading: () => null,
      error: (_, s) => null,
    );
  }

  Map<String, dynamic> _resolvePlayerCourseConfig(String memberId, GolfEvent event, List<Member> membersList) {
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.courseConfig;

    final member = membersList.firstWhereOrNull((m) => m.id == memberId.replaceFirst('_guest', ''));
    final gender = member?.gender?.toLowerCase() ?? 'male';
    
    Map<String, dynamic>? selectedTee;
    if (gender == 'female') {
       if (event.selectedFemaleTeeName != null) {
         selectedTee = (tees.firstWhereOrNull((t) => 
           (t['name'] ?? '').toString().toLowerCase() == event.selectedFemaleTeeName!.toLowerCase()
         ) as Map<String, dynamic>?);
       }
       selectedTee ??= (tees.firstWhereOrNull((t) => 
         (t['name'] ?? '').toString().toLowerCase().contains('red') || 
         (t['name'] ?? '').toString().toLowerCase().contains('lady') ||
         (t['name'] ?? '').toString().toLowerCase().contains('female')
       ) as Map<String, dynamic>?);
    }
    
    selectedTee ??= (tees.firstWhereOrNull((t) => 
       (t['name'] ?? '').toString().toLowerCase() == (event.selectedTeeName ?? 'white').toLowerCase()
    ) as Map<String, dynamic>?);

    selectedTee ??= (tees.first as Map<String, dynamic>);

    return {
       ...event.courseConfig,
       'par': selectedTee['par'] ?? (selectedTee['holes'] as List?)?.fold<int>(0, (a, b) => a + ((b as Map)['par'] as int? ?? 0)) ?? 72,
       'rating': selectedTee['rating'] ?? 72,
       'slope': selectedTee['slope'] ?? 113,
       'holes': selectedTee['holes'] ?? event.courseConfig['holes'],
    };
  }
}
