# Shared UI Library (BoxyArt v3.7 - True Minimal)

The BoxyArt UI Library is the source of truth for all visual components in the Golf Society Management ecosystem. It is optimized for a premium, high-density "Pro" aesthetic.

## Location
`lib/design_system/widgets/`

## 1. Cards & Containers (`card.dart`)

### `BoxyArtCard`
The foundational container for all UI blocks.
- **Properties**:
  - `child`: Inner content.
  - `onTap`: Optional interaction (wraps in `InkWell`).
  - `padding`: Default `24px` (`AppSpacing.x2l`).
  - `borderRadius`: Authoritative `rLg` (18px).
  - `backgroundColor`: Manual color override.
- **Hardening**: Features mandatory **internal clipping** (`ClipRRect`) to ensure all children (like header/footer bands) match the card's curve without manual radius math.

### `BoxyArtEventCard`
The standardized summary card for events, used in both Member and Admin views.
- **Features**: Integrated `BoxyArtDateBadge`, title line, location, and registration time metadata.
- **Pills**: Supports optional `gameTypePill` and `statusPill` for situational context.

### `ModernNoteCard`
A specialized horizontal card for informational notes.
- Includes `title`, `content`, and optional `imageUrl`.
- Automatically handles vertical spacing and image clipping.

### `CompetitionRulesCard` (Hardened Feature Card)
A high-integrity card for displaying complex competition rules.
- **Hardened Architecture**: Standalone implementation with unique background (#151515) and "Alignment Lock" to ensure absolute left-alignment of icons and text regardless of the parent theme.
- **Features**: Specialized header with large game icon, automatic rule translation text, and integrated `CompetitionBadgeRow`.
- **Contexts**: Used in the Game Template Gallery, Event Application screens, and Admin Event forms.

## 2. Forms & Inputs (`inputs.dart`)

### `BoxyArtInputField`
The unified design-first input.
- **Visuals**: Title Case labels (No All-Caps), filled background variants for dark mode, and integrated icon support.

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

### `EventUserShell` (Tournament Mode)
(v3.8) The authoritative flattened navigation shell for tournament events.
- **5-Tab Navigation**: Info, Field, My Card, Scores, Stats.
- **Navigation Shortcuts**: Built-in logic for the `🏠` Home icon in tab headers to return to the Event Dashboard.

## 4. Badges & Indicators (`badges.dart`)

### `BoxyArtPill` (Legacy) / `BoxyArtLegend` (New)
The standard for highlighting status, format, or type classification. Implements the **v3.7 Legend Taxonomy**.
- **The Shift**: v3.7 introduces the "True Minimal" legend—a minimalist **Dot + Text** format that eliminates background "pills" for a cleaner, high-density look.
- **Factories**:
  - `BoxyArtPill.format(label)`: Competition formats (Stableford, Matchplay).
  - `BoxyArtPill.type(label)`: Entity classification (Invitational, Player Role).
  - `BoxyArtPill.status(label, color)`: Lifecycle and registration states.
  - `BoxyArtPill.tee(color)`: (v3.8) Distinctive 12px tee color indicator with a subtle border.
- **Visuals**: No background opacity. Uses a vibrant status color for the indicator dot/tee and matching Title Case text.

### `BoxyArtDateBadge`
Vertical date display for event cards.
- Supports `isMultiDay` detection automatically if `endDate` is provided.
- Displays date ranges (e.g., "15-16") in a high-impact display font.

### `BoxyArtNumberBadge`
Leaderboard rank indicators.
- **Branding**: Rank #1 is always `Amber 500` (Gold). Ranks #2-3 use dark-scale highlights.

## 5. Buttons (`buttons.dart`)

### `BoxyArtButton`
Multipurpose action button targeting v3.1 aesthetics.
- **Primary**: Lime 700 (Dark Mode) or Lime 500 (Light Mode) background.
- **Secondary**: Outlined variant with refined borders.
- **Ghost**: Text-only variant for subtle actions.
- **Loading State**: Displays a `CircularProgressIndicator` while maintaining layout stability.

### `BoxyArtGlassIconButton`
A specialized round icon button with a low-opacity glass background.
- **Context**: Used heavily in Admin headers and grid actions for a premium Feel.

## 6. Layout Utils (`layout.dart`, `sections.dart`)

### `BoxyArtSectionTitle`
Standard Title Case header for grouping content.
- **Typography**: `AppTypography.label` with increased letter spacing, strictly **Title Case**.
- **Dynamic Counts**: Supports an optional `count` property to display participant totals (e.g., "Guests (4)") within the title.
- **Spacing Guidelines**: The `padding` property is strictly **deprecated**. Global spacing harmony is now enforced at the component level to ensure consistent vertical rhythm across all screens. Do not inject ad-hoc `EdgeInsets`.

### `BoxyArtScorecardTile`
The universal component for displaying a player's or team's score.
- **Visuals**: Primary player names are always in `Pure White` (900 weight) for maximum legibility.
- **Features**: Supports individual avatars or `avatarNames` stacks for Pairs/Teams.
- **Metadata**: Fixed-width leading section for ranking badges or avatars.
- **Pro Max Labels**: Optimized for high-density metadata like "THRU 12" or "SUBMITTED 14:15".

### `ModernMetricStat`
High-density data widget for displaying counts (e.g. "Playing: 24/32").
- Supports compact and full-width modes.

## 7. Motion & Transitions (`app_router.dart`)

The BoxyArt system uses unified motion patterns to maintain professional stability and premium feedback.

### `fadePage` (Shell Navigation)
Used for top-level navigation swaps (tabs, major shells).
- **Effect**: Clean cross-fade.
- **Duration**: `AppAnimations.fast` (200ms).
- **Rationale**: Minimal distraction during foundational navigation.

### `boxyPage` (Leaf & Form Navigation)
Used for all sub-screens, detail views, and edit forms.
- **Effect**: Fade + Subtle Slide Up.
- **Duration**: `AppAnimations.medium` (400ms).
- **Curve**: `AppAnimations.entranceCurve`.
- **Rationale**: Matches the `StaggeredEntrance` logic for a premium "opening" feel.
