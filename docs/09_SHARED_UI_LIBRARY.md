# Shared UI Library (BoxyArt v3.1)

The BoxyArt UI Library is the source of truth for all visual components in the Golf Society Management ecosystem. It is optimized for a premium, high-density "Pro" aesthetic.

## Location
`lib/design_system/widgets/`

## 1. Cards & Containers (`card.dart`)

### `BoxyArtCard`
The foundational container for all UI blocks.
- **Properties**:
  - `child`: Inner content.
  - `onTap`: Optional interaction (wraps in `InkWell`).
  - `padding`: Default `24px`.
  - `borderRadius`: Default `16px` (`AppShapes.rLg`).
  - `backgroundColor`: Manual color override.

### `ModernNoteCard`
A specialized horizontal card for informational notes.
- Includes `title`, `content`, and optional `imageUrl`.
- Automatically handles vertical spacing and image clipping.

## 2. Forms & Inputs (`inputs.dart`)

### `BoxyArtInputField`
The unified design-first input.
- **Visuals**: Uppercase labels in `AppTypography.label`, filled background variants for dark mode, and integrated icon support.

### Legacy Aliases (Backward Compatibility)
- `BoxyArtFormField`: Maps to `BoxyArtInputField`. Supports `IconData` or `Widget` for icons.
- `ModernTextField`: Specialized alias for quick-entry fields.
- `ModernSwitchRow`: Full-width row combining a label, optional icon, and `Switch`.

### `BoxyArtDatePickerField`
A labeled trigger for date selection.
- **State**: Supports `readOnly` to disable interactions during loading/processing.

## 3. Headers & Navigation (`app_bar.dart`, `headless_scaffold.dart`)

### `BoxyArtAppBar`
A highly flexible v3.1 compliant app bar.
- **Features**: Subtitle support, `transparent` mode for hero-style headers, and dynamic back button handling.

### `HeadlessScaffold`
The preferred layout for core screens.
- **Sliver Architecture**: Uses `NestedScrollView` and `SliverAppBar` to provide a premium scrolling experience (scrolled-under transparency).

## 4. Badges & Indicators (`badges.dart`)

### `BoxyArtPill`
The standard for highlighting status, format, or type classification. Implements the **v3.1 Tag Taxonomy**.
- **Factories**:
  - `BoxyArtPill.format(label)`: Competition formats (Stableford, Matchplay).
  - `BoxyArtPill.type(label)`: Entity classification (Invitational, Player Role).
  - `BoxyArtPill.status(label, color)`: Lifecycle and registration states.
- **Visuals**: Uses high-opacity labels on low-opacity backgrounds (0.08) with subtle borders (0.18) for a glass-glass look.

### `BoxyArtDateBadge`
Vertical date display for event cards.
- Supports `isMultiDay` detection automatically if `endDate` is provided.
- Displays date ranges (e.g., "15-16") in a high-impact display font.

### `BoxyArtNumberBadge`
Leaderboard rank indicators.
- **Branding**: Rank #1 is always `Amber 500` (Gold). Ranks #2-3 use dark-scale highlights.

## 5. Buttons (`buttons.dart`)

### `BoxyArtButton`
Multipurpose action button.
- **Primary**: Lime 500 background, Dark 950 text.
- **Secondary**: Outlined/Ghost variants for less critical actions.
- **Loading State**: Displays a `CircularProgressIndicator` while maintaining size.

## 6. Layout Utils (`layout.dart`, `sections.dart`)

### `BoxyArtSectionTitle`
Standard uppercase header for grouping content.
- **Typography**: `AppTypography.label` with increased letter spacing.
- **Spacing Guidelines**: The `padding` property is strictly **deprecated**. Global spacing harmony is now enforced at the component level to ensure consistent vertical rhythm across all screens. Do not inject ad-hoc `EdgeInsets`.

### `ModernMetricStat`
High-density data widget for displaying counts (e.g. "Playing: 24/32").
- Supports compact and full-width modes.
