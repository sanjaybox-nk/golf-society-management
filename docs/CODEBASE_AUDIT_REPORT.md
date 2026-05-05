# Golf Society Management — Codebase Audit Report
> Generated: May 2026 | Codebase: 361 source files · ~79,368 LOC (excl. generated code)

---

## Executive Summary

The codebase is architecturally sound in its intentions — Riverpod providers, domain models via Freezed, a shared design system, and a clean feature-folder structure all point toward a well-considered initial architecture. However, **three years of iterative feature additions** have introduced significant bloat, coupling, and duplication that now impede readability, performance, and future extensibility.

| Category | Severity | Count of Issues |
|---|---|---|
| God files / oversized widgets | 🔴 Critical | 8 files |
| Business logic inside `build()` / UI layers | 🔴 Critical | 12+ locations |
| Scorecard construction duplication | 🟠 High | 10 sites |
| ID-resolution (`memberId ?? userId ?? playerId`) | 🟠 High | 160+ lines |
| `debugPrint` / log statements in production code | 🟡 Medium | 72 instances |
| Duplicate file + barrel structure (design system) | 🟡 Medium | 15+ phantom files |
| `SocietyConfig` token overload (single Freezed object) | 🟡 Medium | 133 properties |
| `GroupingCard` — inline lambda `buildParticipantTile` | 🟡 Medium | 1 critical site |
| `ScorecardModal.show()` — mixed resolve + UI in 600+ line static method | 🔴 Critical | 1 critical site |
| Orphan/wrapper files in design system | 🟢 Low | ~6 files |

---

## Section 1: God Files & Oversized Widgets

These files are doing too much. Each exceeds 700 LOC, mixing UI rendering, business logic, and state management in ways that make them impossible to test in isolation.

| File | LOC | Problem |
|---|---|---|
| `member_home_screen.dart` | 1,324 | Full dashboard: multiple conditional sections, inline builders, scoring logic |
| `event_admin_grouping_screen.dart` | 1,234 | Admin grouping UI + drag logic + match play overlay management |
| `event_user_details_tab.dart` | 1,146 | Single tab with 5+ distinct UI sections and domain lookups |
| `match_play_draw_manager_screen.dart` | 1,075 | Full seeding, bracket, and match management in one screen |
| `grouping_widgets.dart` | 1,062 | Three unrelated widgets + complex rendering logic in one file |
| `scorecard_modal.dart` | 963 | Score resolution waterfall (7 fallback strategies) + UI + match play computation |
| `vertical_hole_scoring_list.dart` | 768 | Scoring input, state, persistence, and page management |
| `event_scoring_processor.dart` | 775 | Core engine — but mixes format-specific logic into one giant switch block |

### Recommended Split Pattern
Each of these should become a **folder**, not a file:

```
event_scoring_processor/
  ├── stableford_processor.dart
  ├── stroke_processor.dart
  ├── scramble_processor.dart
  ├── match_play_processor.dart
  └── event_scoring_processor.dart  ← thin orchestrator
```

---

## Section 2: Business Logic Inside `build()` Methods

This is the most pervasive issue. Multiple screens compute derived state, run sorting algorithms, and perform O(n²) lookups **during widget builds** — meaning they re-run on every `setState()` or provider update.

### Critical Sites

**`scorecard_modal.dart` — `ScorecardModal.show()`** (lines 44–600)
- The entire 7-step scorecard resolution waterfall (`isScorecardEmpty` chain) runs synchronously inside `showModalBottomSheet` before any UI is shown.
- Match Play calculation (lines 440–534) rebuilds `MatchDefinition`, resolves all `courseConfigs` and `playerIndices`, and calls `MatchPlayCalculator.calculate()` inside `builder: (context) {...}`.
- **Fix**: Extract to an `AsyncNotifier` or pre-compute via `ref.read()` before opening the sheet.

**`grouping_widgets.dart` — `GroupingCard.build()`** (lines 388–800)
- `buildParticipantTile` is defined as an inline closure **inside the build method** (line 554–590), then called in 3 different code paths — and **duplicated entirely** at lines 711–741 as `baseTile` with nearly identical parameters.
- Match play relative strokes calculation (lines 426–438) runs on every rebuild.
- **Fix**: Extract `buildParticipantTile` to a private `_buildTile()` method. Cache `relativePhcMap` in a `useMemoized` or provider.

**`event_scores_hub_tab.dart`** (513 LOC)
- Contains `_buildPinnedScoring` which resolves active scorecard status and markers — logic duplicated from `vertical_hole_scoring_list.dart`.
- Mixed `ref.watch()` and `ref.read()` usage patterns suggest reactive state isn't consistently managed.

**`member_home_screen.dart`** (1,324 LOC)
- Home screen computes upcoming events, registration status, leaderboard positions, and renewal alerts all inline. This drives 5+ re-renders per user interaction.
- **Fix**: Introduce a `HomeScreenViewModel` AsyncNotifier that pre-aggregates all required data.

---

## Section 3: Scorecard Construction Duplication (Critical)

The same `Scorecard(id: '...', competitionId: ..., roundId: '1', ...)` construction pattern is repeated in **at least 10 locations** across the codebase:

```
scorecard_modal.dart            — lines 49-60, 125-138, 143-152, 500-503
vertical_hole_scoring_list.dart — score persistence block
scoring_entry_view.dart         — 586 LOC
scoring_verification_view.dart  — 636 LOC
event_scoring_processor.dart    — results reconstruction
event_admin_scorecard_editor_screen.dart
admin_scorecard_list.dart
```

Every construction hardcodes `roundId: '1'` (a magic string), `submittedByUserId: 'system'` (a magic sentinel), and `createdAt/updatedAt: DateTime.now()`. Any future model change (e.g., multi-round support) requires touching all 10+ sites.

**Fix**: Introduce a `ScorecardFactory`:

```dart
// lib/domain/scoring/scorecard_factory.dart
class ScorecardFactory {
  static Scorecard createEmpty({required String entryId, required String competitionId}) => Scorecard(
    id: 'empty_$entryId',
    competitionId: competitionId,
    roundId: ScorecardConstants.defaultRoundId,
    entryId: entryId,
    submittedByUserId: ScorecardConstants.systemUserId,
    status: ScorecardStatus.draft,
    holeScores: List.generate(18, (_) => null),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static Scorecard fromSeededResult({...}) {...}
  static Scorecard fromDirectBridge({...}) {...}
}
```

---

## Section 4: ID-Resolution Fragility (The Hydra Pattern)

The pattern `(r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString()` appears **160+ times** across the codebase. This is a symptom of Firestore data inconsistency where the same conceptual field was stored under three different key names at different points in the app's history.

### Current Blast Radius
- `scorecard_modal.dart` — 5 occurrences
- `event_scoring_processor.dart` — multiple
- `seeding_service.dart` — multiple
- `event_seeder.dart` — multiple (723 LOC seeder)

**Fix**:
1. Create a `FirestoreNormalizer` utility that resolves the canonical member ID on read:

```dart
// lib/utils/firestore_normalizer.dart
class FirestoreNormalizer {
  static String resolveMemberId(Map<String, dynamic> record) =>
    (record['memberId'] ?? record['userId'] ?? record['playerId'] ?? 'unknown').toString();
}
```

2. Long-term: Run a one-time Firestore migration to normalize all result documents to `memberId`.

---

## Section 5: Design System — Orphan Files & Barrel Confusion

The design system has **two parallel structures** that both exist and both export components, creating confusion about the canonical import source.

### Orphan / Shadow Files
These flat files at `lib/design_system/widgets/` are wrappers that just re-export from subdirectories:

| Flat File | Re-exports From |
|---|---|
| `badges.dart` | `badges/badges.dart` |
| `inputs.dart` | `inputs/inputs.dart` |
| `layout.dart` | `layout/layout.dart` |
| `info_rows.dart` | `layout/info_rows.dart` |

Meanwhile, `app_bar.dart`, `bottom_sheets.dart`, `member_cards.dart`, `metrics.dart`, `navigation.dart`, `selectors.dart` appear to be **orphan flat files** with no subdirectory equivalent. They should either be migrated into a subdirectory or left as canonical atoms.

**Fix**: Consolidate. The master barrel `design_system.dart` should be the only external import. Internally, organize as atoms → molecules → organisms:

```
design_system/
  atoms/        ← individual components (Button, Avatar, Pill)
  molecules/    ← composed components (MemberRow, GroupingCard)
  organisms/    ← page-level scaffolds (HeadlessScaffold)
  design_system.dart ← single re-export barrel
```

### `SocietyConfig` Token Overload
`SocietyConfig` carries **133 properties** in a single Freezed object. This includes:
- Visual tokens (colors, radius, shadows) — ~50 props
- Financial/commerce settings — ~8 props
- Handicap system settings — ~5 props
- Renewal/membership lifecycle — ~6 props
- Scoring palette — ~6 props

This violates single-responsibility. The entire object is re-read by every `ref.watch(themeControllerProvider)`, meaning a financial setting change triggers a full widget tree rebuild for every consumer.

**Fix**: Split into domain-specific sub-configs:

```dart
SocietyConfig        ← identity (name, logo, fontFamily, themeMode)
VisualTokens         ← all color/shape/shadow properties
FinancialConfig      ← currency, markup, fines
MembershipConfig     ← renewal, societyCut, handicapSystem
```

---

## Section 6: Architecture Smells

### 6.1 Competing Scoring Pipelines
`event_scoring_processor.dart` (775 LOC) and `scoring_calculator.dart` (503 LOC) overlap in responsibility. The processor calls the calculator, but both contain format-detection logic (`isStableford`, `isScramble`) that leads to drift between what each considers "the format."

### 6.2 Two Seeding Services — Intentional, Temporary Overlap
`seeding_service.dart` (789 LOC) and `services/seeding/event_seeder.dart` (723 LOC) do **different things** and are both currently needed. `event_seeder.dart` is the newer implementation that will eventually replace `seeding_service.dart` once all test scenarios are verified. **Do not delete either** until that transition is confirmed complete. Track as a migration task in the Phase 5 backlog.

### 6.3 `GroupingPlayerTile` Duplication in `GroupingCard`
Inside `GroupingCard.build()`, `GroupingPlayerTile` is constructed **twice** with near-identical parameters:
- Once via the extracted `buildParticipantTile` lambda (lines 558–590)
- Once directly as `baseTile` in the legacy flat-list path (lines 711–741)

Both carry 15+ named parameters. A change to one doesn't propagate to the other.

### 6.4 `ScorecardModal` as a Static Class
`ScorecardModal` is a `class` with only `static` methods and no state. This is an anti-pattern — it should be a plain top-level function (or split into a `ScorecardResolver` service + `ScorecardSheet` widget).

### 6.5 Magic Constants
- `roundId: '1'` — appears 10+ times, never explained
- `submittedByUserId: 'system'` — sentinel value with no enum
- `'direct_'`, `'temp_'`, `'empty_'` ID prefixes — string-based type tags
- `holeLimit` passed as nullable `int?` through 4+ layers

---

## Section 7: `debugPrint` / Log Hygiene

**72 `debugPrint` / `print()` calls** exist in production code. The densest cluster is in `scorecard_modal.dart` (lines 36–42) where the modal resolution path is fully instrumented — useful during development, but adds noise and minor overhead in release builds.

**Fix**: Replace with a `kDebugMode`-gated logger or adopt `package:logger` / `package:talker`.

```dart
// Before
debugPrint("--- SCORECARD MODAL SHOW: ${entry.playerName} ---");

// After (development only)
if (kDebugMode) ScoringLogger.trace('scorecard_modal', entry.playerName);
```

---

## Section 8: Router Complexity

`app_router.dart` (1,017 LOC) is the second-largest file. It handles:
- Static route definitions
- Guard logic (admin, auth)
- Deep-link parameter parsing
- Named sub-routes for every admin screen

**Fix**: Split into route families:

```
navigation/
  routes/
    auth_routes.dart
    event_routes.dart
    admin_routes.dart
    member_routes.dart
  app_router.dart  ← thin composition root
```

---

## Phased Refactoring Roadmap

> **Principle**: Every phase must leave the app in a working, zero-error state. No speculative rewrites.

---

### Phase 1 — Zero-Risk Hygiene (1–2 days) 🟢

These changes are safe, additive, and don't alter any runtime behavior.

| Task | File(s) | Effort |
|---|---|---|
| Create `ScorecardFactory` with `createEmpty`, `fromSeededResult`, `fromDirectBridge` | NEW `lib/domain/scoring/scorecard_factory.dart` | 1h |
| Create `FirestoreNormalizer.resolveMemberId()` | NEW `lib/utils/firestore_normalizer.dart` | 30m |
| Replace all `debugPrint` with `kDebugMode`-gated calls | All 72 sites | 2h |
| Remove `roundId: '1'` magic constant → `ScorecardConstants.defaultRoundId` | NEW constants file | 30m |
| Delete or consolidate the flat wrapper files in design_system/widgets | `badges.dart`, `inputs.dart`, `layout.dart` | 30m |
| Add `submittedByUserId` sentinel enum: `ScorecardConstants.systemUserId` | `scorecard.dart` domain model | 30m |

---

### Phase 2 — Extract Shared Logic (2–3 days) 🟡

Extract duplicated runtime logic into testable units. UI is unchanged.

| Task | File(s) | Effort |
|---|---|---|
| Replace all 10+ inline `Scorecard(...)` constructions with `ScorecardFactory` | All scoring views | 3h |
| Replace all 160+ `memberId ?? userId ?? playerId` with `FirestoreNormalizer.resolveMemberId()` | All seeder/processor files | 4h |
| Extract `buildParticipantTile` closure from `GroupingCard.build()` → `_buildTile()` private method | `grouping_widgets.dart` | 2h |
| Delete the duplicate `GroupingPlayerTile` construction in the legacy flat-list path | `grouping_widgets.dart:711-741` | 1h |
| Audit `seeding_service.dart` vs `event_seeder.dart` — identify & delete the orphan | Both seeder files | 2h |
| Split `SocietyConfig` into `SocietyConfig` + `VisualTokens` sub-objects | `society_config.dart` + all consumers | 5h |

---

### Phase 3 — Decompose God Files (3–5 days) 🟠

Split the 8 oversized files without changing external APIs or provider shapes.

| Task | Target Split | Effort |
|---|---|---|
| `scorecard_modal.dart` → `ScorecardResolver` (service) + `ScorecardSheet` (widget) | Score resolution extracted to service; sheet is pure UI | 4h |
| `event_scoring_processor.dart` → per-format processors + thin orchestrator | 4 format files + `event_scoring_processor.dart` | 6h |
| `grouping_widgets.dart` → 3 separate files | `grouping_player_avatar.dart`, `grouping_player_tile.dart`, `grouping_card.dart` | 2h |
| `app_router.dart` → 4 route family files | `auth_routes.dart`, `event_routes.dart`, `admin_routes.dart`, `member_routes.dart` | 4h |
| `member_home_screen.dart` → screen + `HomeScreenViewModel` | Extract all data-computation to `AsyncNotifier` | 6h |

---

### Phase 4 — Move Logic Out of `build()` (3–5 days) 🟠

Fix reactive performance issues caused by expensive computations in build methods.

| Task | File(s) | Effort |
|---|---|---|
| Pre-compute scorecard resolution in `ScorecardResolver` before opening sheet | `scorecard_modal.dart` | 3h |
| Move match play computation out of `ScorecardModal` builder | `scorecard_modal.dart:440-534` | 3h |
| Cache `relativePhcMap` computation in `GroupingCard` via local variable (not inline) | `grouping_widgets.dart:426-438` | 1h |
| Introduce `HomeScreenViewModel` provider to pre-aggregate home data | `member_home_screen.dart` | 4h |
| Extract `_buildPinnedScoring` resolution logic from `event_scores_hub_tab.dart` | `event_scores_hub_tab.dart` | 2h |

---

### Phase 5 — Architecture Upgrade (Optional, Long-term) 🔵

Only after Phases 1–4 are stable. These are higher-risk structural changes.

| Task | Notes |
|---|---|
| Normalize Firestore result documents to canonical `memberId` field | One-time migration Cloud Function |
| Split `SocietyConfig` provider into domain-specific providers | Reduces widget rebuild surface area |
| Introduce per-format `ScoringStrategy` interface | Enables clean addition of new formats without touching existing code |
| Add unit tests for `ScorecardFactory`, `FirestoreNormalizer`, `HandicapCalculator` | Currently zero test coverage on domain logic |
| Design system: formal atoms/molecules/organisms folder structure | Full reorganization of `lib/design_system/` |

---

## Quick Reference: Where NOT to Touch Yet

These files are large but functionally cohesive and low-risk. Leave them for Phase 5 or later:

- `scoring_calculator.dart` (503 LOC) — dense but well-structured domain logic
- `handicap_calculator.dart` — pure functions, no side effects
- `society_config.dart` — the split is desirable but carries broad consumer impact; do it in Phase 2
- `boxy_art_member_row.dart` (462 LOC) — highly parameterized but correctly single-purpose

---

## Summary Priority Matrix

```
🔴 Do First (Phase 1-2):
  • ScorecardFactory
  • FirestoreNormalizer
  • Remove debugPrints
  • Fix GroupingCard duplicate tile build

🟠 Do Second (Phase 3-4):
  • Split scorecard_modal.dart
  • Split event_scoring_processor.dart
  • Move logic out of build() methods
  • HomeScreenViewModel

🟡 Do Third (Phase 4-5):
  • SocietyConfig split
  • Router decomposition
  • Design system folder cleanup

🔵 Long-term (Phase 5):
  • Firestore normalization
  • Test coverage
  • Full design system atoms/molecules/organisms
```

---

*This report should be reviewed before any sprint planning and updated as phases complete.*

---

## Section 9: Resource Leaks & Memory Management

> Added: May 2026 (post-audit supplement)

### 9.1 Provider Lifecycle — Critically Under-using `autoDispose`

**Only 4 providers** across the entire codebase use `autoDispose` or `.family`:
- `renewalFilteredMembersProvider`
- `debtSummariesProvider`
- `adminEditorHoleProvider`
- `reportsControllerProvider`

There are **27 `StateNotifierProvider` / `NotifierProvider` / `StreamProvider` declarations** (confirmed count) with **no `autoDispose`**. This means:

- Providers for event-specific data (scorecards, groupings, match play) stay alive in memory for the entire app session, even after the user navigates away.
- `markerSelectionProvider` is a global `NotifierProvider` (not autoDispose) — its SharedPreferences state persists across events correctly, but its in-memory `markerAssignments` map accumulates without bound for the session lifetime.
- Each scoring view creates provider subscriptions that are never torn down until a full app restart.

**Fix**: Apply `autoDispose` to all event-scoped, screen-scoped, and transient providers. Only truly global app-state providers (auth, members, society config) should remain non-disposable.

```dart
// Before — lives forever
final adminEditorHoleProvider = NotifierProvider<...>(...); // already fixed ✓

// Pattern to apply to all event-scoped providers:
final eventScoringControllerProvider = NotifierProvider.autoDispose.family<...>(...);
```

### 9.2 Confirmed Controller Leaks

**`currency_selection_screen.dart`** — `TextEditingController _searchController` declared at field level with **no `dispose()` override**. Confirmed missing.

**`boxy_art_rich_editor.dart` (lines 175–176)** — Two `TextEditingController` instances created inside a `showDialog` callback as local variables. They are **never explicitly disposed**. When the dialog closes the controllers linger until GC (which may be delayed).

**`match_play_draw_manager_screen.dart` (line 729)** — `TextEditingController` created inside `showDialog` builder, not disposed.

**`committee_roles_screen.dart` (line 177)** — Same pattern: controller created inline inside a dialog builder, not disposed.

**`treasury_settings_screen.dart` (line 40)** — `TextEditingController(text: ...)` passed directly as `controller:` argument inside a `build()` method. Creates a **new controller on every rebuild** — this is a guaranteed leak as no reference is held and `dispose()` is never called.

**`boxy_art_input_field.dart` (line 269)** — Same leak pattern: `TextEditingController(text: initialValue)` created inline and passed as widget prop.

**Fix pattern** for all dialog controller leaks:
```dart
// Bad — leaks
showDialog(builder: (ctx) {
  final controller = TextEditingController();
  return AlertDialog(content: TextField(controller: controller));
});

// Good — owned and disposed
class _MyState extends State<...> {
  late final TextEditingController _dialogController;
  @override void initState() { super.initState(); _dialogController = TextEditingController(); }
  @override void dispose() { _dialogController.dispose(); super.dispose(); }
}
```

**Fix pattern** for `build()` controller leaks — use `useMemoized` (hooks) or move to `initState`:
```dart
// Bad — new controller every rebuild
TextField(controller: TextEditingController(text: initialValue))

// Good — stable reference
late final _ctrl = TextEditingController(text: widget.initialValue);
@override void dispose() { _ctrl.dispose(); super.dispose(); }
```

### 9.3 Firestore Stream Leak Risk

**88 Firestore `.collection()` / `.snapshots()` calls** are open across the codebase. Most are correctly managed by Riverpod `StreamProvider` — which handles the subscription lifecycle. However:

- **No explicit `ref.onDispose`** hooks are registered anywhere to cancel subscriptions on navigational teardown for non-autoDispose providers.
- Since most event providers are not `autoDispose`, their Firestore streams **remain open** even after the user leaves an event screen.

This is likely the single largest battery and data consumption issue in the app today.

**Fix**: Add `autoDispose` to all event-scoped streaming providers, or explicitly register cleanup:
```dart
final eventScorecardStreamProvider = StreamProvider.autoDispose.family<...>(...);
```

---

## Section 10: API Robustness & Firestore Hygiene

### 10.1 Null-Safety Gaps in `event_scoring_processor.dart`

Line 135: `(seededResult['holeScores'] as List).cast<int?>()` — the `.cast<int?>()` call on a raw Firestore `List` **will throw at runtime** if any element is not an `int` or `null`. Firestore can store doubles (e.g., `1.0`) if data was written from a different client.

**Fix**:
```dart
// Fragile
holeScores = (seededResult['holeScores'] as List).cast<int?>();

// Robust
holeScores = (seededResult['holeScores'] as List)
    .map((e) => e == null ? null : (e as num).toInt())
    .toList();
```

Line 103: `double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0` — silent fallback to 18.0 hides bad data. A guest with a mistyped handicap (e.g. `'n/a'`) will silently play off 18. Should log a warning.

### 10.2 Guest ID Construction Is Repeated Inline

The pattern `p['isGuest'] == true ? '${pid}_guest' : pid` appears in **at least 12 locations** across `event_scoring_processor.dart`, `grouping_widgets.dart`, `marker_selection_sheet.dart`, and `event_scores_hub_tab.dart`. Each implementation is slightly different:

- `marker_selection_sheet.dart` (line 136): Has a complex compound condition checking both `isGuest` field AND `_guest` suffix
- `event_scoring_processor.dart` (lines 34, 58–64): Uses `endsWith('_guest')` / `replaceFirst`
- `grouping_widgets.dart`: Uses the flag only

This will inevitably diverge. **Fix**: Central `GuestIdHelper.resolveEffectiveId(Map player)` util.

### 10.3 Firestore Writes Without Error Handling

Multiple Firestore write paths in the scoring flow use `await doc.set(...)` or `await doc.update(...)` with no `try/catch`. If a write fails (network drop mid-round), the UI shows no feedback and state silently diverges.

Affected files: `vertical_hole_scoring_list.dart` (`_updateScore`), `scorecard_modal.dart` (several write paths), `admin_scorecard_list.dart`.

**Fix**: Wrap all Firestore writes in a `try/catch` with a user-facing error toast and local rollback.

### 10.4 `markerSelectionProvider` — Partially Wired State

`MarkerSelection` has two fields that are **written but never read** outside the marker system:
- `isGroupScorer` — read by `vertical_hole_scoring_list.dart` (line 70) only ✓
- `markerAssignments` — **set** via `assignMarker()` in the sheet UI, but **never consumed** anywhere in the scoring pipeline

The `markerAssignments` map accumulates entries every time the sheet is opened, but `EventScoringProcessor.process()` doesn't receive or use it. This is dead state that hints at an incomplete feature implementation.

**Action**: Either wire `markerAssignments` into the scoring pipeline where it belongs, or remove it to prevent stale state accumulation.

---

## Section 11: Marker Selection System — Gaps

### 11.1 Group Player Lookup Is Fragile
`MarkerSelectionSheet.show()` (lines 24–40) resolves the current user's group by iterating all groups and matching on `p['id'] ?? p['registrationMemberId']`. If the user is a guest, this lookup may fail silently (returns empty `groupPlayersRaw`), showing an empty sheet with no explanation.

### 11.2 No Stale Selection Cleanup on Event Change
`markerSelectionProvider` persists targets to SharedPreferences keyed by `userId`. It calls `validateTargets()` when `vertical_hole_scoring_list.dart` initializes — but only if the user navigates to the scoring view. If a user opens Marker Selection for Event A, then navigates directly to Event B's sheet without visiting scoring first, the stale Event A targets remain checked.

**Fix**: Invalidate marker targets when the event ID changes — add a `clearTargets(String eventId)` method and call it when the active event changes in the event provider.

### 11.3 `[LAB MODE]` Comment in Production Provider
`marker_selection_provider.dart` line 7: `// [LAB MODE] Persistence for Marker Selection`. This suggests the feature was shipped while still in experimental status. The comment should be removed and the feature formally documented.

---

## Updated Summary Table

| Category | Severity | Count |
|---|---|---|
| God files / oversized widgets | 🔴 Critical | 8 files |
| Business logic inside `build()` / UI layers | 🔴 Critical | 12+ locations |
| `autoDispose` missing on event-scoped providers | 🔴 Critical | ~23 providers |
| Firestore streams open indefinitely | 🔴 Critical | ~88 stream sites |
| Controller leaks (no dispose) | 🔴 Critical | 5 confirmed sites |
| Scorecard construction duplication | 🟠 High | 10 sites |
| ID-resolution (`memberId ?? userId ?? playerId`) | 🟠 High | 160+ lines |
| Guest ID construction duplicated | 🟠 High | 12+ sites |
| Firestore writes without error handling | 🟠 High | 3+ confirmed |
| Unimplemented state (`markerAssignments`) | 🟡 Medium | 1 |
| `debugPrint` in production | 🟡 Medium | 72 instances |
| Null-unsafe Firestore List casts | 🟡 Medium | 2 confirmed |
| Design system barrel confusion | 🟡 Medium | 15+ files |
| `SocietyConfig` token overload | 🟡 Medium | 133 props |
| `[LAB MODE]` comment in production | 🟢 Low | 1 |
| Stale marker selection on event change | 🟢 Low | 1 |

---

## Updated Phase 1 Tasks (add these to the original)

| Task | File(s) | Effort |
|---|---|---|
| Add `dispose()` to `currency_selection_screen.dart` | `currency_selection_screen.dart` | 10m |
| Fix inline `TextEditingController` in `treasury_settings_screen.dart` build | `treasury_settings_screen.dart:40` | 15m |
| Fix inline `TextEditingController` in `boxy_art_input_field.dart` build | `boxy_art_input_field.dart:269` | 15m |
| Fix dialog controller leaks in `boxy_art_rich_editor.dart` | Lines 175–176 | 20m |
| Fix dialog controller leaks in `match_play_draw_manager_screen.dart` | Line 729 | 10m |
| Fix dialog controller leaks in `committee_roles_screen.dart` | Line 177 | 10m |
| Remove `[LAB MODE]` comment; formalize marker provider | `marker_selection_provider.dart:7` | 5m |
| Create `GuestIdHelper.resolveEffectiveId()` util | NEW `lib/utils/guest_id_helper.dart` | 30m |

## Updated Phase 2 Tasks (add these to the original)

| Task | File(s) | Effort |
|---|---|---|
| Apply `autoDispose` to all event-scoped providers | ~23 provider files | 3h |
| Wrap all Firestore writes in `try/catch` with toast feedback | `vertical_hole_scoring_list.dart`, `scorecard_modal.dart`, `admin_scorecard_list.dart` | 3h |
| Fix Firestore `List.cast<int?>()` → safe `num.toInt()` conversion | `event_scoring_processor.dart:135` | 30m |
| Replace 12+ guest ID constructions with `GuestIdHelper` | All scoring/grouping files | 2h |
| Resolve or remove `markerAssignments` dead state | `marker_selection_provider.dart`, scoring pipeline | 2h |
| Add `clearTargets(eventId)` to marker provider; call on event change | `marker_selection_provider.dart` | 1h |

*This report should be reviewed before any sprint planning and updated as phases complete.*
