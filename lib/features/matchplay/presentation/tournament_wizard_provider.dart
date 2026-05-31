import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/match_play_tournament.dart';
import '../logic/match_play_draw_service.dart';
import '../domain/match_definition.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:uuid/uuid.dart';

class TournamentWizardState {
  final TournamentType type;
  final SeedingType seedingType;
  final List<MatchPlayEntrant> entrants;
  final int step;
  final String name;
  final bool isPairs;
  final MatchPlayProgression progressionMode;
  final Map<MatchRoundType, DateTime> roundCutoffs;
  final bool isPublished;
  final String? notes;
  final List<MatchDefinition> draftMatches;
  final Map<String, String> teamAssignments;
  final Map<String, List<String>> divisions;
  final int entrantsPerDivision;

  TournamentWizardState({
    this.type = TournamentType.knockout,
    this.seedingType = SeedingType.random,
    this.entrants = const [],
    this.step = 0,
    this.name = '',
    this.isPairs = false,
    this.progressionMode = MatchPlayProgression.bracketed,
    this.roundCutoffs = const {},
    this.isPublished = false,
    this.notes,
    this.draftMatches = const [],
    this.teamAssignments = const <String, String>{},
    this.divisions = const <String, List<String>>{},
    this.entrantsPerDivision = 4,
  });

  TournamentWizardState copyWith({
    TournamentType? type,
    SeedingType? seedingType,
    List<MatchPlayEntrant>? entrants,
    int? step,
    String? name,
    bool? isPairs,
    MatchPlayProgression? progressionMode,
    Map<MatchRoundType, DateTime>? roundCutoffs,
    bool? isPublished,
    String? notes,
    List<MatchDefinition>? draftMatches,
    Map<String, String>? teamAssignments,
    Map<String, List<String>>? divisions,
    int? entrantsPerDivision,
  }) {
    return TournamentWizardState(
      type: type ?? this.type,
      seedingType: seedingType ?? this.seedingType,
      entrants: entrants ?? this.entrants,
      step: step ?? this.step,
      name: name ?? this.name,
      isPairs: isPairs ?? this.isPairs,
      progressionMode: progressionMode ?? this.progressionMode,
      roundCutoffs: roundCutoffs ?? this.roundCutoffs,
      isPublished: isPublished ?? this.isPublished,
      notes: notes ?? this.notes,
      draftMatches: draftMatches ?? this.draftMatches,
      teamAssignments: teamAssignments ?? this.teamAssignments,
      divisions: divisions ?? this.divisions,
      entrantsPerDivision: entrantsPerDivision ?? this.entrantsPerDivision,
    );
  }
}

class TournamentWizardNotifier extends Notifier<TournamentWizardState> {
  @override
  TournamentWizardState build() => TournamentWizardState();

  void setType(TournamentType type) => state = state.copyWith(type: type);
  void setSeeding(SeedingType seeding) => state = state.copyWith(seedingType: seeding);
  void setMode(bool isPairs) => state = state.copyWith(isPairs: isPairs);
  void setName(String name) => state = state.copyWith(name: name);
  void setProgression(MatchPlayProgression mode) => state = state.copyWith(progressionMode: mode);
  void setPublished(bool isPublished) => state = state.copyWith(isPublished: isPublished);
  void setNotes(String? notes) => state = state.copyWith(notes: notes);
  void setTeamAssignments(Map<String, String> assignments) =>
      state = state.copyWith(teamAssignments: Map<String, String>.from(assignments));

  /// Batch-initializes all tournament configuration in a SINGLE state update.
  /// Use this instead of calling individual setters to prevent multiple rebuild cycles.
  void initializeFromEvent({
    required String name,
    required bool isPairs,
    required TournamentType type,
    required SeedingType seedingType,
    required MatchPlayProgression progressionMode,
    required List<MatchPlayEntrant> entrants,
    bool isPublished = false,
    String? notes,
    Map<MatchRoundType, DateTime> roundCutoffs = const <MatchRoundType, DateTime>{},
    List<MatchDefinition> matches = const <MatchDefinition>[],
    Map<String, String> teamAssignments = const <String, String>{},
    Map<String, List<String>> divisions = const <String, List<String>>{},
  }) {
    state = TournamentWizardState(
      name: name,
      isPairs: isPairs,
      type: type,
      seedingType: seedingType,
      progressionMode: progressionMode,
      entrants: entrants,
      isPublished: isPublished,
      notes: notes,
      draftMatches: matches,
      step: state.step,
      roundCutoffs: roundCutoffs,
      teamAssignments: teamAssignments,
      divisions: divisions,
    );
  }

  void setRoundCutoff(MatchRoundType round, DateTime date) {
    final cutoffs = Map<MatchRoundType, DateTime>.from(state.roundCutoffs);
    cutoffs[round] = date;
    state = state.copyWith(roundCutoffs: cutoffs);
  }

  void nextStep() => state = state.copyWith(step: state.step + 1);
  void prevStep() => state = state.copyWith(step: state.step - 1);

  void addEntrant(MatchPlayEntrant entrant) {
    state = state.copyWith(entrants: [...state.entrants, entrant]);
  }

  void addEntrants(List<MatchPlayEntrant> newEntrants) {
    state = state.copyWith(entrants: [...state.entrants, ...newEntrants]);
  }

  void removeEntrant(String id) {
    state = state.copyWith(entrants: state.entrants.where((e) => e.id != id).toList());
  }

  void updateEntrant(MatchPlayEntrant entrant) {
    state = state.copyWith(
      entrants: state.entrants.map((e) => e.id == entrant.id ? entrant : e).toList(),
    );
  }

  void swapPlayers(String entrantAId, String playerAId, String entrantBId, String playerBId) {
    final entrants = List<MatchPlayEntrant>.from(state.entrants);
    final indexA = entrants.indexWhere((e) => e.id == entrantAId);
    final indexB = entrants.indexWhere((e) => e.id == entrantBId);

    if (indexA != -1 && indexB != -1) {
      final entrantA = entrants[indexA];
      final entrantB = entrants[indexB];

      final newPlayersA = entrantA.playerIds.map((p) => p == playerAId ? playerBId : p).toList();
      final newPlayersB = entrantB.playerIds.map((p) => p == playerBId ? playerAId : p).toList();

      entrants[indexA] = entrantA.copyWith(playerIds: newPlayersA);
      entrants[indexB] = entrantB.copyWith(playerIds: newPlayersB);

      state = state.copyWith(entrants: entrants);
    }
  }

  void swapDraftEntrants({
    required String matchId1,
    required int teamIndex1,
    required String matchId2,
    required int teamIndex2,
  }) {
    final matches = List<MatchDefinition>.from(state.draftMatches);
    final idx1 = matches.indexWhere((m) => m.id == matchId1);
    final idx2 = matches.indexWhere((m) => m.id == matchId2);

    if (idx1 != -1 && idx2 != -1) {
      final m1 = matches[idx1];
      final m2 = matches[idx2];

      final ids1 = teamIndex1 == 1 ? m1.team1Ids : m1.team2Ids;
      final name1 = teamIndex1 == 1 ? m1.team1Name : m1.team2Name;

      final ids2 = teamIndex2 == 1 ? m2.team1Ids : m2.team2Ids;
      final name2 = teamIndex2 == 1 ? m2.team1Name : m2.team2Name;

      matches[idx1] = teamIndex1 == 1
          ? m1.copyWith(team1Ids: ids2, team1Name: name2)
          : m1.copyWith(team2Ids: ids2, team2Name: name2);

      matches[idx2] = teamIndex2 == 1
          ? m2.copyWith(team1Ids: ids1, team1Name: name1)
          : m2.copyWith(team2Ids: ids1, team2Name: name1);

      state = state.copyWith(draftMatches: matches);
    }
  }

  void updateMatchResult(String matchId, MatchResult? result) {
    final matches = state.draftMatches.map((m) {
      if (m.id == matchId) {
        return m.copyWith(manualResult: result);
      }
      return m;
    }).toList();
    state = state.copyWith(draftMatches: matches);
  }

  void generateDraft() {
    if (state.type == TournamentType.divisionsPlusKnockout) {
      final divisions = MatchPlayDrawService.generateDivisions(
        entrants: state.entrants,
        entrantsPerDivision: state.entrantsPerDivision,
        seedingType: state.seedingType,
      );
      final matches = MatchPlayDrawService.generateGroupStageMatches(
        divisions: divisions,
        entrants: state.entrants,
      );
      state = state.copyWith(draftMatches: matches, divisions: divisions);
    } else {
      final matches = MatchPlayDrawService.generateKnockoutDraw(
        entrants: state.entrants,
        seedingType: state.seedingType,
        startRound: _getStartRound(state.entrants.length),
        teamAssignments: state.teamAssignments,
      );
      state = state.copyWith(draftMatches: matches);
    }
  }

  void propagateWinners(List<MatchDefinition> currentMatches) {
    final nextRoundMatches = MatchPlayDrawService.propagateWinners(currentMatches);
    state = state.copyWith(draftMatches: nextRoundMatches);
  }

  MatchRoundType _getStartRound(int count) {
    if (count <= 2) return MatchRoundType.finalRound;
    if (count <= 4) return MatchRoundType.semiFinal;
    if (count <= 8) return MatchRoundType.quarterFinal;
    if (count <= 16) return MatchRoundType.roundOf16;
    return MatchRoundType.roundOf32;
  }

  MatchPlayTournament finalize({String? tournamentId}) {
    const uuid = Uuid();
    List<MatchDefinition> matches = state.draftMatches;
    Map<String, List<String>> divisions = state.divisions;

    // Fallback: generate on the fly if no draft (e.g. first-time save without hitting Generate Draw)
    if (matches.isEmpty) {
      generateDraft();
      matches = state.draftMatches;
      divisions = state.divisions;
    }

    return MatchPlayTournament(
      id: tournamentId ?? uuid.v4(),
      name: state.name,
      type: state.type,
      seedingType: state.seedingType,
      entrants: state.entrants,
      divisions: divisions,
      matches: matches,
      roundCutoffs: state.roundCutoffs,
      isPublished: state.isPublished,
      notes: state.notes,
      createdAt: DateTime.now(),
    );
  }
}

final tournamentWizardProvider = NotifierProvider<TournamentWizardNotifier, TournamentWizardState>(() {
  return TournamentWizardNotifier();
});
