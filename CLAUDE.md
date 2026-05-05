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
Import via the barrel — never import individual widget files directly:
```dart
import 'package:golf_society/design_system/design_system.dart';
```
Layer boundaries: `atoms/` → `molecules/` → `organisms/`. Atoms have no domain imports. Organisms may depend on domain models and Riverpod.

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
