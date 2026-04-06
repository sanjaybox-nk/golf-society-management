# Shared UI Library (v4.0 - Radical Simplification)

The BoxyArt UI Library is the source of truth for all visual components in the Golf Society Management ecosystem. It is optimized for a premium, high-density "Pro" aesthetic and is fully tokenized in v4.0.

## Location
`lib/design_system/widgets/`

## 1. Cards & Containers (`card.dart`)

### `BoxyArtCard`
The foundational container for all UI blocks.
- **Dynamic Radius**: Uses `config.cardRadius` from `SocietyConfig`. Defaults to 18px.
- **Dynamic Padding**: Uses `config.cardVerticalPadding` and `config.cardHorizontalPadding` from `SocietyConfig`. Defaults to 16px.
- **Dynamic Shadows**: Automatic scaling based on `config.shadowIntensity`.
- **Hardening**: Features mandatory **internal clipping** (`ClipRRect`) to ensure all children (like header/footer bands) respect the card's dynamic curve.
- **Vertical Rhythm (Subtext)**: Card subtext items (e.g. metadata lines, debt items) must follow a consistent **8px** (`AppSpacing.sm`) vertical gap logic to prevent typography "crushing" when multiple items are displayed.

## 2. Forms & Inputs (`inputs.dart`)

### `BoxyArtInputField`
The unified design-first input.
- **Dynamic Radius**: Uses `config.inputRadius` from `SocietyConfig`. Defaults to 12px.
- **Typography**: Uses `AppTypography.body` for input text and `AppTypography.sizeMicro` (10px) with `weightHeavy` (w800) for labels.
- **Label Case**: Labels are strictly **UPPERCASE** for high-density elegance.

### `BoxyArtRichEditor` [NEW]
The premium WYSIWYG editor for complex text content (e.g. Question Prompts, Broadcasts).
- **Engine**: Powered by `flutter_quill`.
- **Styling**: Unified with `BoxyArtInputField` regarding radius and label styling.
- **Features**: Supports bold, italic, lists, and links.
- **Persistence**: Emits and consumes Quill Delta JSON strings.

## 3. Buttons (`buttons.dart`)

### `BoxyArtButton`
Multipurpose action button targeting v4.0 aesthetics.
- **Dynamic Radius**: Uses `config.inputRadius` (shared with inputs) or a specialized button radius if configured.
- **Typography**: Strictly uses `AppTypography.label` with `AppTypography.weightHeavy`.
- **Primary**: Brand Lime (`lime500` or `lime700`) with dark contrast text (`actionText`).

### Section Headers (BoxyArtSectionTitle)
Enforces the **32/8 vertical rhythm**. Use for all logical groupings.
- **Typography**: `Label` (13px) + `Heavy` (800) for standard titles.
- **Lowercase/Title Case**: Auto-formatted to Title Case for elegance.
- **Level 2**: `Micro` (10px) style for sub-sections.
- **Metadata Labels**: Use 10px (`sizeMicro`) + `Heavy` (800) + UPPERCASE for data keys (e.g. in `ModernInfoRow`).

## 4. Badges & Indicators (`badges.dart`)

### `BoxyArtPill`
The standard for highlighting status, format, or type classification.
- **v4.0 Taxonomy**: Minimalist **Dot + Text** format (Legend).
- **Dot + Text**: Automatically renders a colored 8px dot instead of a background fill for `status`, `format`, and `type` factories.
- **Iconless**: Icons are suppressed in Legend mode to maintain a cleaner, data-first aesthetic.
- **Semantic Entities**: Supports `BoxyArtPill.hc()`, `BoxyArtPill.phc()`, `BoxyArtPill.guest()`, `BoxyArtPill.meal()` etc.
- **Handicap Formatting**: `hc` and `phc` pills use consistent uppercase labels ("HC:", "PHC:") and have no icons per design v4.1. Index values are strictly formatted to 1 decimal place.

## 5. Typography Standards
As of v4.0, all components are hard-linked to the following tokens:
- **Headers/Titles**: `AppTypography.headline` + `weightHeavy`.
- **Body Content**: `AppTypography.body` + `weightRegular`.
- **Primary Data/Values**: 16px + `weightBold` (w700).
- **Labels/Metadata**: `AppTypography.sizeMicro` (10px) + `weightHeavy` (w800) + UPPERCASE.

- **`Section` (32.0)**: Vertical rhythm between blocks.

## 7. Dividers & Separators
### `BoxyArtDivider`
A standardized, subtle divider for logical separation within cards or between list items.
- **Styling**: Uses 1px thickness with high-transparency `dividerColor`.
- **Spacing**: Configurable `verticalPadding` (defaults to `AppSpacing.xs`).

## 8. Dynamic Vertical Rhythm
For the Admin Console, use `AppSpacingTokens` extensions to provide user-controllable density:
- `spacing?.labelToCard`: Standardized gap above cards.
- `spacing?.cardToLabel`: Standardized gap below cards.
- `spacing?.cardVerticalPadding`: Dynamic vertical padding for all cards.
- `spacing?.cardHorizontalPadding`: Dynamic horizontal padding for all cards.

## 7. Motion & Transitions
All navigation uses the `boxyPage` transition helper:
- **Fade + Subtle Slide Up**
- **Duration**: 400ms (`AppAnimations.medium`)
- **Stability**: Implements **Salted PageKeys** (`state.pageKey` + `state.matchedLocation`) to prevent duplicate navigation key crashes in nested shell routes.

## 8. Bottom Sheets & Navigation Bar Visibility

### `BoxyArtBottomSheet`
The canonical bottom sheet wrapper. Provides a branded drag handle, title, close button, and `DraggableScrollableSheet`.

```dart
BoxyArtBottomSheet.show(
  context: context,
  title: 'Sheet Title',
  child: MyContent(),
  // useRootNavigator defaults to FALSE — keeps global nav bar visible
);
```

### ⚠️ Critical Rule: `useRootNavigator: false`

**All `showModalBottomSheet` calls in this project MUST use `useRootNavigator: false`.**

**Why:** Using `useRootNavigator: true` (the Flutter default) pushes the sheet to the root navigator sittin *above* the `GlobalAppShell`. This visually occludes and hides the bottom navigation bar for the sheet's full lifetime.

With `useRootNavigator: false`, the sheet is scoped to the current branch navigator, so the global nav bar remains visible and interactive behind the sheet.

**Enforced on:**
- `BoxyArtBottomSheet.show()` — `useRootNavigator: false` is the **default**
- `MemberDetailsModal.show()` — explicit `false`
- `ScorecardModal.show()` — explicit `false`, `maxChildSize: 0.92`
- `GroupingModals.showGroupingRules()` — explicit `false`
- `EventFinesWorkbenchScreen._showIssueFineModal()` — explicit `false`
- `SeasonStandingsScreen._showDetails()` — explicit `false`
- `AudienceManagerScreen._showCreateListDialog()` — explicit `false`

**`maxChildSize` cap:** Draggable sheets cap at **0.92** (not 1.0) to ensure the nav bar is never fully covered even at max drag position.
