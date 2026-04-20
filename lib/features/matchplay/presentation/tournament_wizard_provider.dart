import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/match_play_tournament.dart';
import '../logic/match_play_draw_service.dart';
import '../domain/match_definition.dart';
import 'package:uuid/uuid.dart';

class TournamentWizardState {
  final TournamentType type;
  final SeedingType seedingType;
  final List<MatchPlayEntrant> entrants;
  final int step;
  final String name;
  final bool isPairs;

  TournamentWizardState({
    this.type = TournamentType.knockout,
    this.seedingType = SeedingType.random,
    this.entrants = const [],
    this.step = 0,
    this.name = '',
    this.isPairs = false,
  });

  TournamentWizardState copyWith({
    TournamentType? type,
    SeedingType? seedingType,
    List<MatchPlayEntrant>? entrants,
    int? step,
    String? name,
    bool? isPairs,
  }) {
    return TournamentWizardState(
      type: type ?? this.type,
      seedingType: seedingType ?? this.seedingType,
      entrants: entrants ?? this.entrants,
      step: step ?? this.step,
      name: name ?? this.name,
      isPairs: isPairs ?? this.isPairs,
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

  MatchPlayTournament finalize() {
    const uuid = Uuid();
    List<MatchDefinition> generatedMatches = [];
    Map<String, List<String>> divisions = {};

    if (state.type == TournamentType.divisionsPlusKnockout) {
      divisions = MatchPlayDrawService.generateDivisions(
        entrants: state.entrants,
        entrantsPerDivision: 4, // Default to 4
        seedingType: state.seedingType,
      );
      // For groups/divisions, matches are generated later inside the groups
    } else {
      generatedMatches = MatchPlayDrawService.generateKnockoutDraw(
        entrants: state.entrants,
        seedingType: state.seedingType,
        startRound: MatchRoundType.roundOf16, // Default fallback
      );
    }

    return MatchPlayTournament(
      id: uuid.v4(),
      name: state.name,
      type: state.type,
      seedingType: state.seedingType,
      entrants: state.entrants,
      divisions: divisions,
      matches: generatedMatches,
      createdAt: DateTime.now(),
    );
  }
}

final tournamentWizardProvider = NotifierProvider<TournamentWizardNotifier, TournamentWizardState>(() {
  return TournamentWizardNotifier();
});
