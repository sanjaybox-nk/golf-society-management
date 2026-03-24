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

## 2. Forms & Inputs (`inputs.dart`)

### `BoxyArtInputField`
The unified design-first input.
- **Dynamic Radius**: Uses `config.inputRadius` from `SocietyConfig`. Defaults to 12px.
- **Typography**: Uses `AppTypography.body` for input text and `AppTypography.label` for headers.

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

## 4. Badges & Indicators (`badges.dart`)

### `BoxyArtPill`
The standard for highlighting status, format, or type classification.
- **v4.0 Taxonomy**: Minimalist **Dot + Text** format.
- **Semantic Entities**: Supports `BoxyArtPill.hc()`, `BoxyArtPill.phc()`, `BoxyArtPill.guest()`, `BoxyArtPill.meal()` etc.
- **Handicap Formatting**: `hc` and `phc` pills use consistent uppercase labels ("HC:", "PHC:") and support a `hasHorizontalMargin` flag for dense layouts. Index values are strictly formatted to 1 decimal place.

## 5. Typography Standards
As of v4.0, all components are hard-linked to the following tokens:
- **Headers/Titles**: `AppTypography.headline` + `weightHeavy`.
- **Body Content**: `AppTypography.body` + `weightRegular`.
- **Labels/Metadata**: `AppTypography.label` + `weightStrong`.
- **Micro UI**: `AppTypography.micro`.

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
