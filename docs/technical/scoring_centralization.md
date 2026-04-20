# Scoring Centralization Status

## Overview
The scoring logic for all event types and grouping views is now 100% centralized within the `EventScoringProcessor` and `EventScoringController`.

## Centralized Logic Paths
- **Individual Scores**: Calculated in `EventScoringProcessor.process` and stored in `individualScores`.
- **Leaderboard Rankings**: Derived centrally and stored in `leaderboard`.
- **Match Play Results**: Calculated using `MatchPlayCalculator` within the centralized processor and propagated via `matchStatus` fields.
- **Group Rankings (Podium)**: Calculated in `EventScoringProcessor` based on `CompetitionRules.teamBestXCount`.
- **Split Team Scores (Side A vs Side B)**: 
    - **Fourball/Pairs**: Calculated using `ScoringCalculator.calculateBestBall` inside the processor.
    - **Scramble Pairs**: Handled as pair-aggregates centrally.
    - **Display**: Grouping cards now pull these scores from the `ProcessedGroupResult.sideAScore` and `sideBScore` fields.

## Key Files
- `lib/features/events/logic/event_scoring_processor.dart`: The single source of truth for all calculations.
- `lib/features/events/domain/models/processed_event_data.dart`: The unified data model for all views.
- `lib/features/events/presentation/widgets/grouping_widgets.dart`: Lean UI components that only handle presentation.

## Maintenance Notes
- DO NOT add scoring calculation logic to UI components (Stateless or Stateful widgets).
- If a new competition format is added, implement its logic in `ScoringCalculator` and wire it into `EventScoringProcessor`.
- All views should consume data via the `eventScoringControllerProvider`.
