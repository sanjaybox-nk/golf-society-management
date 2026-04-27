import '../../domain/match_standings_calculator.dart';
import '../../../../domain/models/scorecard.dart';
import '../../domain/match_definition.dart';
import '../../../../design_system/design_system.dart';

class MatchPlayStandingsView extends StatelessWidget {
  final String divisionName;
  final List<MatchDefinition> matches;
  final List<Scorecard> scorecards;
  final dynamic event;

  const MatchPlayStandingsView({
    super.key,
    required this.divisionName,
    required this.matches,
    required this.scorecards,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final standings = MatchStandingsCalculator.calculateStandings(
      matches: matches,
      scorecards: scorecards,
      courseConfig: event.courseConfig,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dark900.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppShapes.rMd),
          border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.08)),
          boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.dark800,
                border: Border(bottom: BorderSide(color: AppColors.pureWhite.withValues(alpha: 0.08))),
              ),
              child: Text(
                'DIVISION $divisionName',
                style: const TextStyle(
                  fontSize: AppTypography.sizeLabel,
                  fontWeight: AppTypography.weightBlack,
                  letterSpacing: 1.5,
                  color: AppColors.lime500,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.pureWhite.withValues(alpha: 0.05),
                ),
                child: DataTable(
                  columnSpacing: AppSpacing.x2l,
                  horizontalMargin: AppSpacing.xl,
                  headingRowHeight: 48,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 52,
                  headingRowColor: WidgetStateProperty.all(AppColors.dark900.withValues(alpha: 0.4)),
                  columns: const [
                    DataColumn(label: Text('PLAYER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary))),
                    DataColumn(label: Text('P', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)), numeric: true),
                    DataColumn(label: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)), numeric: true),
                    DataColumn(label: Text('L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)), numeric: true),
                    DataColumn(label: Text('H', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)), numeric: true),
                    DataColumn(label: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.lime500)), numeric: true),
                    DataColumn(label: Text('+/-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)), numeric: true),
                  ],
                  rows: standings.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.playerName, style: const TextStyle(fontWeight: AppTypography.weightBold, color: AppColors.pureWhite))),
                      DataCell(Text('${entry.played}', style: const TextStyle(color: AppColors.pureWhite))),
                      DataCell(Text('${entry.won}', style: const TextStyle(color: AppColors.teamA))),
                      DataCell(Text('${entry.lost}', style: const TextStyle(color: AppColors.teamB))),
                      DataCell(Text('${entry.halved}', style: const TextStyle(color: AppColors.amber500))),
                      DataCell(Text('${entry.points}', style: const TextStyle(color: AppColors.lime500, fontWeight: AppTypography.weightBlack, fontSize: 16))),
                      DataCell(Text(
                        '${entry.holeDiff > 0 ? '+' : ''}${entry.holeDiff}',
                        style: TextStyle(
                          color: entry.holeDiff > 0 ? AppColors.teamA : (entry.holeDiff < 0 ? AppColors.teamB : AppColors.textSecondary),
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
