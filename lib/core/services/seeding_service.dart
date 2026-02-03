import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/models/competition.dart';
import 'package:golf_society/models/season.dart';

class SeedingService {
  final Ref ref;

  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await seedTemplates();
    await seedCurrentSeason();
  }

  Future<void> seedTemplates() async {
    final repo = ref.read(competitionsRepositoryProvider);
    
    final templates = [
      _createTemplate(
        name: 'Stableford Open',
        format: CompetitionFormat.stableford,
        allowance: 0.95,
      ),
      _createTemplate(
        name: 'Texas Scramble',
        format: CompetitionFormat.scramble,
        subtype: CompetitionSubtype.texas,
        allowance: 0.1, // 10% combined HC
      ),
      _createTemplate(
        name: 'Match Play Singles',
        format: CompetitionFormat.matchPlay,
        mode: CompetitionMode.singles,
        allowance: 1.0,
      ),
    ];

    for (var t in templates) {
      await repo.addCompetition(t);
    }
  }

  Future<void> seedCurrentSeason() async {
    final repo = ref.read(seasonsRepositoryProvider);
    final seasons = await repo.getSeasons();
    
    if (seasons.isEmpty) {
      final now = DateTime.now();
      final season = Season(
        id: '',
        name: '${now.year} Society Tour',
        year: now.year,
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
        status: SeasonStatus.active,
        isCurrent: true,
        pointsMode: PointsMode.position,
        bestN: 8,
        tiePolicy: TiePolicy.countback,
      );
      await repo.addSeason(season);
    }
  }

  Competition _createTemplate({
    required String name,
    required CompetitionFormat format,
    CompetitionSubtype subtype = CompetitionSubtype.none,
    CompetitionMode mode = CompetitionMode.singles,
    double allowance = 0.95,
  }) {
    return Competition(
      id: '',
      type: CompetitionType.game,
      rules: CompetitionRules(
        format: format,
        subtype: subtype,
        mode: mode,
        handicapAllowance: allowance,
      ),
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      status: CompetitionStatus.open,
    );
  }
}

final seedingServiceProvider = Provider((ref) => SeedingService(ref));
