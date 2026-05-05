---
trigger: always_on
---

## Hard constraints

- Never import design system widgets directly — always use the `design_system.dart` barrel
- Never hardcode scorecard IDs, round IDs, or user sentinels — use `ScorecardConstants`
- Never construct `Scorecard(...)` inline — use `ScorecardFactory`
- Never resolve player IDs with `?? userId ?? playerId` chains — use `FirestoreNormalizer` or `GuestIdHelper`
- Never check `format == CompetitionFormat.stableford` for sort direction — use `ScoringStrategyRegistry`
- Never hardcode `BorderRadius.circular()` or `BoxShadow` inline — use `AppShapeTokens` / `AppShadows` ThemeExtensions
- Never use raw float opacity values — use `AppColors.opacityStrong` / `opacitySubtle` / `opacityFaint`
- Never use `ref.read` inside `build()` — use `ref.watch`
- Never add `.autoDispose` to the Notifier class — add it to the provider declaration only
- Never target a feature branch as a PR base — always target `main`
- Never cast Firestore numeric values with `as int` — use `(value as num).toInt()`
- Never add `debugPrint` without a `kDebugMode` guard

## Preferred patterns

- Society-customised colors → `ref.watch(visualTokensProvider)`; fixed structural colors → `AppColors`
- Spacing in widgets → `Theme.of(context).extension<AppSpacingTokens>()` with `AppSpacing` fallback
- Shape radii → `Theme.of(context).extension<AppShapeTokens>()` named getters (`.card`, `.button`, `.pill`…)
- Shadows → `Theme.of(context).extension<AppShadows>()` named sets (`softScale`, `floatingAlt`…)
- Screen-scoped state → `Provider.autoDispose.family`
- Large files sharing private state → `part` / `part of` (directives after imports, before declarations)
- Tests → plain `flutter_test`, no mocks, lives in `test/domain/`
- Commit messages → Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`)
