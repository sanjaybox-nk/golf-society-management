# Golf Society — Agent Instructions

## Stack
- Flutter/Dart `^3.8.0`, Riverpod `^3.3.1`, go_router `^17.2.0`
- Firebase (Auth, Firestore, Storage)
- Freezed `^3.2.3` for domain models — run `dart run build_runner build` after changing any `.freezed.dart` model
- Cloud Functions in TypeScript at `firebase/functions/src/`

## Architecture

```
lib/
  domain/         # Pure models, scoring logic, no Flutter imports
  features/       # Feature modules: data/ logic/ presentation/
  design_system/  # UI library — atoms/ molecules/ organisms/ theme/
  navigation/     # app_router.dart + routes/ (part files)
  utils/          # Stateless helpers (no providers)
  services/       # App-wide services (seeding, storage)
```

**Feature layout**: `features/<name>/data/` → `logic/` → `presentation/state/` → `presentation/widgets/`

## Riverpod rules
- Providers that are screen-scoped **must** use `.autoDispose`
- Notifier classes extend `Notifier<T>` — the **provider** declaration carries `.autoDispose`, not the class
- Derived screen state uses `Provider.autoDispose.family<State, Param>`
- Never use `ref.read` inside `build()` — use `ref.watch`

## Domain conventions
- Player IDs: always use `GuestIdHelper.resolveEffectiveId(map)` for raw maps — never inline `?? userId ?? playerId` chains
- Firestore result maps: use `FirestoreNormalizer.resolveMemberId(map)` — canonical field is `memberId`
- Scorecard construction: use `ScorecardFactory` methods (`createEmpty`, `fromSeededResult`, `fromDirectBridge`) — never inline `Scorecard(...)` with magic string IDs
- ID prefixes live in `ScorecardConstants` (`emptyIdPrefix`, `tempIdPrefix`, `directIdPrefix`)
- Format-aware sorting: use `ScoringStrategyRegistry.forRules(rules).compareScores()` — never check `format == CompetitionFormat.stableford` inline

## Enums (don't guess)
- `CompetitionMode`: `singles`, `pairs`, `teams`
- `CompetitionFormat`: `stroke`, `stableford`, `maxScore`, `scramble`, `matchPlay`
- `ScorecardStatus`: `draft`, `submitted`, `finalScore`
- `ScoringStatus`: `ok`, `nr`, `wd`, `dq`

## Design system

**Always import via the barrel — never import individual widget files directly:**
```dart
import 'package:golf_society/design_system/design_system.dart';
```

Layer boundaries: `atoms/` → `molecules/` → `organisms/`. Atoms have no domain imports. Organisms may use domain models and Riverpod.

### Two token surfaces

| Use case | Source | How to access |
|---|---|---|
| Static primitives (non-configurable) | `AppColors`, `AppTypography`, `AppSpacing` | Direct class reference |
| Society-configured (per-club customisation) | `VisualTokens` | `ref.watch(visualTokensProvider)` |
| Layout/spacing at widget level | `AppSpacingTokens` ThemeExtension | `Theme.of(context).extension<AppSpacingTokens>()` |
| Shape radii at widget level | `AppShapeTokens` ThemeExtension | `Theme.of(context).extension<AppShapeTokens>()` |
| Shadows at widget level | `AppShadows` ThemeExtension | `Theme.of(context).extension<AppShadows>()` |

**Rule**: use `visualTokensProvider` in widgets that need society-customised colors (primary, card, score palette). Use `AppColors` static constants only for fixed structural colors (dark scale, coral, amber) that are never user-configurable.

### Colours — `AppColors`

Dark-first neutral scale (background → surface → border → text):
```
dark800 → page bg    dark700 → card surface    dark600 → elevated card
dark500 → border     dark200 → tertiary text    dark150 → secondary text
dark60  → primary text
```

Brand primitives: `lime500` (primary green), `coral500` (over-par/alerts), `amber500` (achievement).

Score state: `scoreEagle` `scoreBirdie` `scorePar` `scoreBogey` `scoreDouble` `scoreTriplePlus`.

Semantic: `guestPurple`, `teamA` (deep blue), `teamB` (deep green), `actionMidnight`.

Opacity constants: `opacityStrong 0.9` → `opacitySubtle` → `opacityFaint` — use these instead of raw floats.

For light/dark branching: `Theme.of(context).brightness == Brightness.dark` then use `AppColors.pureWhite` vs `AppColors.dark900`.

### Typography — `AppTypography`

Five canonical sizes — use these, no others:
```
sizeDisplay  24pt  — hero headers
sizeHeadline 20pt  — section headers
sizeBody     16pt  — primary reading
sizeLabel    13pt  — metadata, buttons
sizeMicro    11pt  — captions
```

Named text styles: `AppTypography.displaySection`, `.body`, `.label`, `.micro` — call `.copyWith()` to adjust color/weight.

Weight tokens: `weightHeavy w800`, `weightBold w700`, `weightStrong w600`, `weightRegular w400`.

Letterspace tokens: `lsHero -0.2`, `lsStandard 0.2`, `lsLabel 1.0`.

Font: **Plus Jakarta Sans** via `google_fonts`.

### Spacing — `AppSpacing`

4-tier scale (8pt grid):
```
atomic   8pt  — gaps between related elements
standard 16pt — card & page padding
large    18pt — enhanced card padding
section  32pt — between sections
hero     64pt — large structural breaks
```

Semantic aliases: `pagePadding`, `cardPadding`, `elementGap`, `labelToCard`, `cardToLabel`, `tabToContent`.

At widget level, prefer the `AppSpacingTokens` ThemeExtension (society-overridable):
```dart
final spacing = Theme.of(context).extension<AppSpacingTokens>();
SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic)
```

### Shapes — `AppShapeTokens`

Access via `Theme.of(context).extension<AppShapeTokens>()`. Named `BorderRadius` getters:
`tokens.card`, `tokens.button`, `tokens.input`, `tokens.pill`, `tokens.hero`, `tokens.accent`.

Never hardcode `BorderRadius.circular(12)` — use the token.

### Shadows — `AppShadows`

Access via `Theme.of(context).extension<AppShadows>()`. Named shadow sets:
- `shadows.softScale` — main content cards (layered, subtle lift)
- `shadows.inputSoft` — form inputs (minimal)
- `shadows.floatingAlt` — floating bars, FABs
- `shadows.primaryButtonGlow` — primary CTA buttons
- `shadows.textHighlight` — text on coloured backgrounds

`AppShadows.useShadows` may be false (user preference) — always access via the extension, never hardcode `BoxShadow` inline.

### Society-configured colours — `VisualTokens`

For any color the society admin can customise, use `VisualTokens`:
```dart
final tokens = ref.watch(visualTokensProvider);
Color primary = Color(tokens.primaryColor);
Color card    = Color(tokens.cardColor);
```

Key groups: `primaryColor`, `cardColor`, `backgroundColor`, score palette (`scoreEagleColor`…`scoreTriplePlusColor`), status pills, team colors, hero gradient.

## Code style
- No comments unless the *why* is non-obvious (hidden constraint, workaround, invariant)
- No trailing summary comments — name things clearly instead
- Num casts from Firestore: always `(value as num).toInt()`, never `as int` directly
- `part` / `part of` for large files that share private state — directives go after imports, before first declaration
- `kDebugMode` guard all `debugPrint` calls

## Testing
Tests live in `test/domain/`. Use plain `flutter_test` — no mocks, no generated fakes.
Run: `flutter test test/domain/`

## Git
- Branch naming: `feature/<name>`, `fix/<name>`, `refactor/<name>`
- Stacked PRs must each target `main` as base — not the previous feature branch
- Commit messages follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Never force-push main
