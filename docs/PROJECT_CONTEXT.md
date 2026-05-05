# Project Context

> This file is the source of truth for any agent picking up this codebase cold.
> Keep it updated as significant decisions are made or milestones completed.

## What this project is

A Flutter app for managing a golf society — events, scoring, handicaps, match play, membership, and treasury. Multi-tenant (one app instance per society). Backend is Firebase (Firestore, Auth, Storage, Cloud Functions).

## Current state (as of 2026-05-05)

The codebase has just completed a full architectural refactor driven by a May 2026 audit of all 361 source files (~79k LOC). All 6 phases are complete and merged to `main`. The app is feature-complete and heading toward production infrastructure (CI/CD, TestFlight, Play Store).

Full audit report: `docs/CODEBASE_AUDIT_REPORT.md`

## What the refactor did

### Phase 1 — Utilities & hygiene
- Created `ScorecardConstants`, `ScorecardFactory`, `FirestoreNormalizer`, `GuestIdHelper`
- Replaced 72 `debugPrint` calls with `kDebugMode`-gated logging

### Phase 2 — Wired utilities into call sites
- All inline `Scorecard(...)` constructions replaced with `ScorecardFactory`
- All `memberId ?? userId ?? playerId` chains replaced with `FirestoreNormalizer`
- All guest ID patterns replaced with `GuestIdHelper`
- Added `.autoDispose` to 26 screen-scoped providers
- Split `SocietyConfig` into `VisualTokens`, `FinancialConfig`, `MembershipConfig` view-objects

### Phase 3 — God file decomposition
- `grouping_widgets.dart` (1400 LOC) → `grouping_card.dart`, `grouping_player_tile.dart`, `grouping_player_avatar.dart`, `grouping_podium_header.dart`
- `app_router.dart` (850 LOC) → `app_router.dart` (thin) + `routes/member_routes.dart` + `routes/admin_routes.dart`
- `member_home_screen.dart` (700 LOC) → screen + `home_next_match_card.dart`, `home_leaderboard_snippet.dart`, `home_poll_card.dart`, `home_matchplay_card.dart`
- `event_scoring_processor.dart` → extracted `ScoringUtils` and `ScorecardResolver`
- `scorecard_modal.dart` → extracted `ScorecardResolver`

### Phase 4 — Logic out of `build()`
- Match play computation pre-calculated before `showModalBottomSheet()` in `scorecard_modal.dart`
- Introduced `PinnedScoringState` and `pinnedScoringStateProvider` in `event_scores_hub_tab.dart`

### Phase 5 — Architecture upgrades
- **65 unit tests** across `ScorecardFactory`, `FirestoreNormalizer`, `GuestIdHelper`, `ScoringUtils`, `ScorecardResolver`
- **`ScoringStrategy` interface** — `ScoringStrategyRegistry.forRules()` replaces all scattered `isStableford`/`isScramble` flags; three leaderboard sort comparators use `strategy.compareScores()`
- **Design system layering** — `molecules/molecules.dart` and `organisms/organisms.dart` barrel files; `design_system.dart` exports by atomic layer
- **Firestore migration** — `runMigrateMemberIds` HTTP Cloud Function normalises legacy `userId`/`playerId` fields to canonical `memberId` across all event result documents

## Firestore migration

**Already run in production (2026-05-05).** Result: `{ scanned: 2, updated: 2, errors: 0 }`. All event result documents now use `memberId` exclusively.

The `runMigrateMemberIds` function remains deployed and is idempotent — safe to re-run if new legacy documents appear. Secret is stored in Firebase Secret Manager as `MIGRATION_SECRET`. Function is live at `https://us-central1-golf-society-managment.cloudfunctions.net/runMigrateMemberIds`.

## Key architectural decisions

| Decision | Rationale |
|---|---|
| `VisualTokens` is a plain Dart view-object, not a Freezed model | Avoids `build_runner` requirement for a non-persisted wrapper |
| `ScoringStrategy` uses `extends` not `implements` | Allows default `compareScores()` implementation on the abstract class |
| God files split with `part`/`part of` where private state is shared | Avoids refactoring all consumers; internal classes stay accessible |
| `ScrambleStrategy.isTeamBased == true` but `texas`/`florida` subtypes are not in the strategy | Those are format overlays, not pure format differences; handled separately in the processor |
| Stacked PRs should each target `main` directly | Merging stacked branches into each other causes commits to land on feature branches, not main |

### Phase 6 — Post-audit sweep (PRs #7–#11, merged 2026-05-05)
- **Guest ID sweep** — 72 raw `'_guest'` string patterns across ~20 files replaced with `GuestIdHelper`; added `GuestIdHelper.buildId()` and `GuestIdHelper.isGuestId()` to the helper
- **God file splits** — `event_admin_grouping_screen.dart` (1234L→851L), `event_user_details_tab.dart` (1147L→198L), `match_play_draw_manager_screen.dart` (1080L→492L)
- **`isStableford` → `higherIsBetter`** — `TieBreakerLogic` parameter renamed to be format-agnostic
- **49 new unit tests** — `ScoringStrategy` (26), `TieBreakerLogic` (9), `HandicapCalculator` (14)

## What comes next

- **Production infrastructure** — CI/CD (GitHub Actions or Codemagic), TestFlight internal beta, Google Play internal track
- **Run the Firestore migration** — `runMigrateMemberIds` Cloud Function against production data
- The refactoring backlog in `docs/06_ROADMAP_TODO.md` § 7 is now fully complete — those checkboxes are stale and can be marked done

## Key files to know

| File | Purpose |
|---|---|
| `lib/domain/scoring/scoring_strategy.dart` | Per-format sort strategy (`ScoringStrategyRegistry.forRules()`) |
| `lib/domain/scoring/tie_breaker_logic.dart` | Countback logic (`higherIsBetter` param) |
| `test/domain/scoring_strategy_test.dart` | 26 strategy tests |
| `test/domain/tie_breaker_logic_test.dart` | 9 countback tests |
| `test/domain/handicap_calculator_test.dart` | 14 handicap tests |
| `lib/domain/scoring/scorecard_factory.dart` | Canonical scorecard construction |
| `lib/domain/scoring/scorecard_constants.dart` | ID prefixes, sentinels |
| `lib/utils/firestore_normalizer.dart` | Canonical Firestore ID resolution |
| `lib/utils/guest_id_helper.dart` | Guest player ID handling |
| `lib/features/events/logic/scoring/scoring_utils.dart` | Scoring status, tie-break, handshake |
| `lib/features/events/presentation/widgets/scorecard_resolver.dart` | Resolves which scorecard to display |
| `lib/design_system/design_system.dart` | Single barrel import for all UI |
| `lib/design_system/theme/theme_controller.dart` | `visualTokensProvider`, `financialConfigProvider` |
| `firebase/functions/src/migrate_member_ids.ts` | Firestore memberId migration |
| `docs/CODEBASE_AUDIT_REPORT.md` | Full May 2026 audit findings |
| `CLAUDE.md` | Agent instructions (conventions, tokens, git rules) |
