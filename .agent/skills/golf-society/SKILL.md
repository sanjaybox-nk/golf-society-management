---
name: golf-society
description: Coding conventions, architecture patterns, and design system rules for the Golf Society Flutter app.
---

# Golf Society — Agent Skill

> For full project history, current state, and key decisions: `docs/PROJECT_CONTEXT.md`

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

Feature layout: `features/<name>/data/` → `logic/` → `presentation/state/` → `presentation/widgets/`

## Riverpod rules
- Screen-scoped providers **must** use `.autoDispose`
- Notifier classes extend `Notifier<T>` — the **provider** declaration carries `.autoDispose`, not the class
- Derived screen state uses `Provider.autoDispose.family<State, Param>`
- Never use `ref.read` inside `build()` — use `ref.watch`

## Domain conventions
- Player IDs: always use `GuestIdHelper.resolveEffectiveId(map)` for raw maps — never inline `?? userId ?? playerId` chains
- Firestore result maps: use `FirestoreNormalizer.resolveMemberId(map)` — canonical field is `memberId`
- Scorecard construction: use `ScorecardFactory` (`createEmpty`, `fromSeededResult`, `fromDirectBridge`) — never inline `Scorecard(...)` with magic string IDs
- ID prefixes live in `ScorecardConstants` (`emptyIdPrefix`, `tempIdPrefix`, `directIdPrefix`)
- Format-aware sorting: use `ScoringStrategyRegistry.forRules(rules).compareScores()` — never check `format == CompetitionFormat.stableford` inline

## Enums (exact values)
- `CompetitionMode`: `singles`, `pairs`, `teams`
- `CompetitionFormat`: `stroke`, `stableford`, `maxScore`, `scramble`, `matchPlay`
- `ScorecardStatus`: `draft`, `submitted`, `finalScore`
- `ScoringStatus`: `ok`, `nr`, `wd`, `dq`

## Design system

Always import via the barrel:
```dart
import 'package:golf_society/design_system/design_system.dart';
```

Layer boundaries: `atoms/` → `molecules/` → `organisms/`. Atoms have no domain imports. Organisms may use domain models and Riverpod.

### Two token surfaces

| Use case | Source | How to access |
|---|---|---|
| Static primitives | `AppColors`, `AppTypography`, `AppSpacing` | Direct class reference |
| Society-configured colors | `VisualTokens` | `ref.watch(visualTokensProvider)` |
| Spacing at widget level | `AppSpacingTokens` ThemeExtension | `Theme.of(context).extension<AppSpacingTokens>()` |
| Shape radii at widget level | `AppShapeTokens` ThemeExtension | `Theme.of(context).extension<AppShapeTokens>()` |
| Shadows at widget level | `AppShadows` ThemeExtension | `Theme.of(context).extension<AppShadows>()` |

Use `visualTokensProvider` for any color the society admin can customise. Use `AppColors` static constants only for fixed structural colors that are never user-configurable.

### Colours — `AppColors`

Dark-first neutral scale: `dark800` page bg → `dark700` card → `dark600` elevated → `dark500` border → `dark200` tertiary text → `dark150` secondary text → `dark60` primary text.

Brand: `lime500` (primary green), `coral500` (over-par/alerts), `amber500` (achievement).

Score state: `scoreEagle` `scoreBirdie` `scorePar` `scoreBogey` `scoreDouble` `scoreTriplePlus`.

Opacity constants: `opacityStrong 0.9` and downward — use these instead of raw floats.

Light/dark branch: `Theme.of(context).brightness == Brightness.dark` → `AppColors.pureWhite` vs `AppColors.dark900`.

### Typography — `AppTypography`

Five canonical sizes — use these, no others:
```
sizeDisplay  24pt  — hero headers
sizeHeadline 20pt  — section headers
sizeBody     16pt  — primary reading
sizeLabel    13pt  — metadata, buttons
sizeMicro    11pt  — captions
```

Named styles: `AppTypography.displaySection`, `.body`, `.label`, `.micro` — call `.copyWith()` to adjust.

Weights: `weightHeavy w800`, `weightBold w700`, `weightStrong w600`, `weightRegular w400`.

Font: **Plus Jakarta Sans** via `google_fonts`.

### Spacing — `AppSpacing`

4-tier scale (8pt grid):
```
atomic   8pt  — gaps between related elements
standard 16pt — card & page padding
large    18pt — enhanced card padding
section  32pt — between sections
```

Semantic aliases: `pagePadding`, `cardPadding`, `labelToCard`, `cardToLabel`, `tabToContent`.

At widget level, prefer the ThemeExtension with fallback:
```dart
final spacing = Theme.of(context).extension<AppSpacingTokens>();
SizedBox(height: spacing?.labelToCard ?? AppSpacing.atomic)
```

### Shapes — `AppShapeTokens`

Named `BorderRadius` getters: `tokens.card`, `tokens.button`, `tokens.input`, `tokens.pill`, `tokens.hero`, `tokens.accent`.

Never hardcode `BorderRadius.circular(12)` — use the token.

### Shadows — `AppShadows`

Named shadow sets:
- `softScale` — main content cards
- `inputSoft` — form inputs
- `floatingAlt` — floating bars, FABs
- `primaryButtonGlow` — primary CTA buttons

`AppShadows.useShadows` may be false — always access via the ThemeExtension, never hardcode `BoxShadow` inline.

### Society-configured colours — `VisualTokens`

```dart
final tokens = ref.watch(visualTokensProvider);
Color primary = Color(tokens.primaryColor);
Color card    = Color(tokens.cardColor);
```

Key groups: `primaryColor`, `cardColor`, `backgroundColor`, score palette, status pills, team colors, hero gradient.

## Code style
- No comments unless the *why* is non-obvious
- Num casts from Firestore: `(value as num).toInt()` — never `as int`
- `part` / `part of` for files sharing private state — directives after imports, before first declaration
- `kDebugMode` guard all `debugPrint` calls

## Testing
Tests in `test/domain/`. Plain `flutter_test` — no mocks, no generated fakes.
Run: `flutter test test/domain/`

## Git
- Branch naming: `feature/<name>`, `fix/<name>`, `refactor/<name>`
- PRs must target `main` as base — never another feature branch
- Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Never force-push main
