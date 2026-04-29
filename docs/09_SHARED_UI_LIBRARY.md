# Shared UI Library (v4.1 — BoxyArt True Minimal)

The BoxyArt UI Library is the canonical source of all visual components in Golf Society Management. It is fully tokenised, premium-first, and enforces Design 4.x standards throughout.

**Central Export**: `package:golf_society/design_system/design_system.dart`
**Central Export**: `package:golf_society/design_system/design_system.dart`
**Location**: `lib/design_system/`
- `atoms/`: Small, reusable components (Inputs, Badges, Layout)
- `widgets/`: Complex, structural layouts (Cards, Scaffolds)
- `theme/`: Design tokens and system configuration

> [!IMPORTANT]
> All feature code must import ONLY via the central barrel. Never import individual design system files directly.

---

## 1. Scaffolds

### `HeadlessScaffold`
The standard shell for all top-level screens. Manages the `CustomScrollView` sliver pattern, header bar, back navigation, and action slots.

```dart
HeadlessScaffold(
  title: 'Screen Title',
  subtitle: 'Context line',
  titleSuffix: BoxyArtPill.committee(label: 'ADMIN'), // Standard for all admin screens
  showBack: true,
  actions: [ ... ], // Actions are now reserved for functional buttons only
  slivers: [ ... ],
)
```

> [!IMPORTANT]
> The `titleSuffix` slot is the authoritative location for the **ADMIN** identity pill. The legacy `actions` pattern (placing the pill in the actions list) is **deprecated** for administrative context and must be avoided. This ensures branding remains centered and stable regardless of functional action buttons.

---

## 2. Cards & Containers (`card.dart`)

### `BoxyArtCard`
The foundational container for all UI blocks.
- **Dynamic Radius**: `config.cardRadius` from `SocietyConfig` (default: 18px).
- **Dynamic Padding**: `config.cardVerticalPadding` / `config.cardHorizontalPadding` (default: 16px).
- **Dynamic Shadows**: Auto-scales with `config.shadowIntensity`.
- **Clipping**: Internal `ClipRRect` forces all children to respect the dynamic curve.
- **Key Parameters**: `onTap`, `padding`, `backgroundColor`, `gradient`, `border`, `showShadow`.
- **Single-Card Architecture**: (v4.x) Recommended for grouping lists. Use a single `BoxyArtCard` to wrap multiple `BoxyArtMemberRow(useCard: false)` items, separated by horizontal dividers.

### `ModernNoteCard`
A premium card for displaying broadcasted notes, announcements, or event updates.
- **ConsumerWidget**: Dynamically inherits `config.cardRadius` (with internal 0.5x scaling for media) to ensure visual coordination with the society's branding.
- **Features**: Supports optional titles (ALL-CAPS), rich content, and network image integration with high-fidelity error placeholders.

### `BoxyArtSquareBadge`
Fixed-size identity icon container with optional tint.
```dart
BoxyArtSquareBadge(size: 48, isTinted: true, child: Icon(Icons.quiz_rounded))
```

---

## 3. Forms & Inputs (`inputs.dart`)

### `BoxyArtInputField` / `BoxyArtFormField`
Unified design-first input field.
- **Dynamic Radius**: `config.inputRadius` (default: 12px).
- **Typography**: `AppTypography.body` for text; `AppTypography.label` (13px bold) for labels.
- **Label Case**: **ALL-CAPS Metadata Standard**. Field labels are automatically converted to uppercase with 1.2 letter spacing and bold weight to distinguish context from user-entered content.
- **Suffix Indicator**: Supports `suffixText` for administrative unit markers (e.g., "mins", "yards"). Suffixes are automatically converted to uppercase for visual consistency.

### `BoxyArtRichEditor`
Premium WYSIWYG editor powered by `flutter_quill`.
- Emits and consumes **Quill Delta JSON** strings.
- Supports: bold, italic, lists, links.
- Visually unified with `BoxyArtInputField` (same radius/label treatment).

### `BoxyArtDropdownField<T>`
Typed dropdown wrapper with label, hint, and `DropdownMenuItem<T>` support.

### `BoxyArtDatePickerField`
Read-only field that triggers a date/time picker on tap.

### `BoxyArtSwitchField`
Label + `Switch` in a single row layout. Active state uses `activeTrackColor` (not deprecated `activeColor`).

### `BoxyArtFormColumn`
Vertical column wrapper with standardised gap between form fields.

### `BoxyArtSlider`
Premium configuration slider with dynamic range support and Design 4.x compliance.
- **Monochromatic Mode**: Set `isNeutral: true` to use the professional administrative greyscale palette (darker tracks, high-contrast thumbs) instead of branded colors. **Mandatory** for all administrative configuration screens (e.g. Branding, Rule Settings).
- **Style Sync**: Automatically inherits the society's structural tokens for `shadows`, `borders`, and `radius`.
- **Key Parameters**: `value`, `min`, `max`, `divisions`, `label`, `isNeutral`, `onChanged`.

### `BoxyArtFormActionRow`
Standard "Save / Cancel" row for form footers.

---

## 4. Buttons (`buttons.dart`)

### `BoxyArtButton`
Multipurpose action button.
- **Dynamic Radius**: shares `inputRadius` token.
- **Variants**: `isPrimary`, `isSecondary`, `isTertiary`, `isGhost`, `isSmall`, `fullWidth`, `isLoading`.
- **Primary Variant**: Uses the `actionColor` (Vivid Emerald/Primary) token.
- **Tertiary Variant**: Uses the `tertiaryColor` (Foundation - Slate) token for solid backgrounds.
- **Typography**: `AppTypography.label` + `weightBold`.
- **Flexible Layout (v4.x)**: As of April 2026, buttons NO LONGER truncate text. They are allowed to wrap or expand to ensure labels like "CLEAR ACTIVITY" remain legible. Use `fullWidth: true` for primary actions.

### `BoxyArtGlassIconButton`
Compact glass-style icon button. Used for header actions, inline card actions.
- Parameters: `icon`, `iconColor`, `iconSize`, `onPressed`, `tooltip`.

---

## 5. Section Headers

### `BoxyArtSectionTitle`
Enforces the **32/8 vertical rhythm** (32px above, 8px below).

```dart
const BoxyArtSectionTitle(title: 'Section Name')        // Standard
const BoxyArtSectionTitle(title: 'Section Name', isPeeking: true)  // First in sliver — removes top margin
BoxyArtSectionTitle(title: 'Count', trailing: someWidget) // With right-aligned action
```

- **Typography**: 10px (`micro`) or 13px (`label`) + **Bold weight** + **ALL-CAPS**.
- **Transformation**: The `BoxyArtSectionTitle` automatically handles `.toUpperCase()` and enforces the 1.2 letter-spacing rhythm.
- **`isPeeking: true`**: Mandatory for the first title in any `HeadlessScaffold` sliver list or tab view to remove redundant top margin.
- **Secondary Sections**: Subsequent sections (e.g., 'Past Events') must use `isPeeking: false` to maintain vertical breathing room.

---

## 5.1 Vertical Rhythm Standards (4.x)
To ensure a consistent "Fairway" feel across all hubs, the following spacing tokens must be used:

| Location | Spacing Token | Pixels |
|---|---|---|
| Header to Filter Bar | `AppSpacing.standard` | 16px |
| Filter Bar to Cards | `AppSpacing.standard` | 16px |
| Search Input to Cards | `AppSpacing.standard` | 16px |
| Between Cards | `AppSpacing.md` | 12px |
| Section Title (Top) | `AppSpacing.x2l` | 24px |
| Section Title (Peeking) | `AppSpacing.standard` | 16px |

---

## 6. Motion & Transitions (`staggered_entrance.dart`)

### `StaggeredEntrance`
Canonical entrance animation for lists and feature cards.
- **index**: Sequential order (0, 1, 2...) to determine staggered delay.
- **child**: The widget to animate (Slide + Fade Up).
- **Standard**: All Rich Stats cards and Leaderboard cards should utilize `StaggeredEntrance` for consistent feel.

---

## 7. Badges & Indicators (`badges.dart`)

### `BoxyArtPill`
The standard for status, format, and type classification.

| Factory | Usage |
|---|---|
| `BoxyArtPill.committee(label: 'ADMIN')` | Administrative identity tag |
| `BoxyArtPill.status(label: ..., color: ...)` | Dot + text legend |
| `BoxyArtPill.guest()` | Guest indicator |
| `BoxyArtPill.meal(type: ...)` | Meal preference |

> [!CAUTION]
> `BoxyArtPill.committee()` is NOT a `const` constructor. When providing it to `titleSuffix`, the parent `HeadlessScaffold` itself cannot be prefixed with `const`. However, the `actions` list should still be marked `const []` if it is empty to maintain code quality.

### `BoxyArtPill` Dot Legend mode
For all `status`, `format`, and `type` pills: renders an 8px coloured dot + text (no background fill, no icon).

### `BoxyArtStatusPill`
Toggleable "Paid / Unpaid" or "Visible / Hidden" double-state pill with tap-to-toggle support.

### `BoxyArtNumberBadge`
Circular numbered position badge (used in leaderboards).

### `BoxyArtIconBadge`
Square icon badge with optional tint fill.
- **Variants**: Supports `isPrimary` (Lime), `isSecondary` (Green), and `isTertiary` (Slate/Foundation).
- **Synchronized**: Size and inner icon scale are controlled via the `AppShapeTokens` extension.
- **Usage**: Standardized for empty states (`BoxyArtEmptyCard`) and feature identity headers.

### `BoxyArtMemberRow`
The unified row for displaying members across the application.
- **`name`**: Primary member name.
- **`teamNames`**: (List<String>) Optional list of names for multi-line display (e.g. Scramble teams). If provided, `name` is ignored in the primary content area.
- **`isCaptain`**: Triggers the amber shield badge and background identity on the avatar.
- **`initials`**: Explicit initials for the avatar (overrides name-derived initials).
- **`useCard`**: Whether to wrap in a `BoxyArtCard` (default: true). Set to `false` for internal list items.
- **`showChevron`**: Toggle the right-aligned interaction chevron.

### `BoxyArtIndicator` (Modern Handicap & Status Standards)
The authoritative component for handicap and interactive status display. 

| Factory | Color | Usage |
|---|---|---|
| `BoxyArtIndicator.hc(label: '8.8')` | Neutral (dark300) | Global Base Index (1 decimal) |
| `BoxyArtIndicator.phc(label: '10')` | Amber (amber500) | Contextual Playing Handicap |
| `BoxyArtIndicator.tee(label: 'White')` | Tee specific | Course Tee Marker |

#### Interactive "Status Button" Affordance (v4.x)
If a `BoxyArtIndicator` (or `BoxyArtStatusPill`) is provided with an `onTap` or `onToggle` callback, it automatically transforms into a "Status Button":
- **Background**: Gains a subtle 8% opacity background tint and 15% opacity border matching the dot color.
- **Pencil Icon (✎)**: Automatically appends `Icons.edit_rounded` to indicate a state change is possible.
- **Notification Icon (🔔)**: Can be overridden with a custom icon (e.g., `Icons.notifications_active_rounded`) for actions like "Nudging" members.

---

## 7. Info Rows

### `ModernInfoRow`
Standard label + value row with optional icon:
```dart
ModernInfoRow(label: 'Course', value: 'St Andrews', icon: Icons.location_on_rounded)
```

---

## 8. Empty States

### `BoxyArtEmptyState` (DEPRECATED)
Legacy centered column. DO NOT USE for new 4.x layouts. Use `BoxyArtEmptyCard` instead.

### `BoxyArtEmptyCard`
Premium Design 4.x empty state. Uses a `BoxyArtCard` with brand-tinted icon badges and supports an optional action button.

```dart
BoxyArtEmptyCard(
  title: 'Season Finished',
  message: 'All fixtures are completed for the current season.',
  icon: Icons.emoji_events_outlined,
  actionLabel: 'View Archives', // Optional
  onAction: () => ... , // Optional
)
```

> [!IMPORTANT]
> Always wrap `BoxyArtEmptyCard` in a `Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: ...))` when used as a full-screen placeholder.

---

## 9. Images

### `BoxyArtImage`
Network image with loading/error state handling, configurable `fit`, `borderRadius`, and `errorWidget`.

> [!NOTE]
> All images must use `BoxyArtImage` — never `Image.network()` in production UI.

---

## 9. Navigation Bar Visibility & Behavior

### Branch Reset-on-Tap (v4.x)
The `GlobalAppShell` enforces a **"Fresh Entry"** policy for bottom navigation:
- **Resets on Switch**: Tapping a different tab (e.g. switching from Members to Dashboard) always resets that branch to its initial root location. This prevents administrators from getting "lost" in deep sub-menus when jumping between functional areas.
- **Resets on Active Tap**: Tapping the currently active tab also resets it to the root.

### `BoxyArtBottomSheet`
Canonical bottom sheet wrapper with branded drag handle, title, and `DraggableScrollableSheet`.

```dart
BoxyArtBottomSheet.show(
  context: context,
  title: 'Sheet Title',
  child: MyContent(),
  // useRootNavigator defaults to FALSE
);
```

- **Clipping Prevention (v4.x)**: Automatically accounts for the floating bottom navigation bar when `useRootNavigator` is false. It injects a 100px bottom spacer to ensure the entire layout is scrollable and visible above the shell's navigation bar.
- **`addNavBarPadding`**: Manual override flag available if custom padding is required.

> [!CAUTION]
> **ALL `showModalBottomSheet` calls MUST use `useRootNavigator: false`.**
> Using `true` (Flutter default) pushes the sheet above `GlobalAppShell`, hiding the bottom navigation bar.

Enforced screens:
- `MemberDetailsModal.show()` — explicit `false`
- `ScorecardModal.show()` — explicit `false`, `maxChildSize: 0.92`
- `GroupingModals.showGroupingRules()` — explicit `false`
- `EventFinesWorkbenchScreen._showIssueFineModal()` — explicit `false`
- `SeasonStandingsScreen._showDetails()` — explicit `false`
- `AudienceManagerScreen._showCreateListDialog()` — explicit `false`

**`maxChildSize` cap:** All draggable sheets cap at **0.92** to keep the nav bar visible at max drag.

---

## 10. Dialogs

### `showBoxyArtDialog`
Managed wrapper for `BoxyArtDialog`. **Mandatory** for all administrative and critical user confirmations (deleting templates, closing events, sync actions).

```dart
final result = await showBoxyArtDialog<bool>(
  context: context,
  title: 'Confirm?',
  message: 'This action is irreversible.',
  confirmText: 'Confirm',
  isDangerous: true, // Use for destructive actions (Delete/Withdraw)
  onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  onConfirm: () async { Navigator.of(context, rootNavigator: true).pop(true); },
);
```

- **Standards**: Replaces legacy `AlertDialog`. Always use `rootNavigator: true` to ensure the dialog appears above the bottom navigation bar.
- **Dangerous Mode**: Setting `isDangerous: true` tints the confirm button with `coral500`.
- **Responsive Layout (v4.x)**: As of April 2026, all dialogs use `OverflowBar` and `AppSpacing.standard` for inset padding. This ensures that action buttons have maximum horizontal space and will automatically stack vertically if labels are too long, preventing text truncation.

---

## 11. Motion & Transitions

| Transition | Description | Duration |
|---|---|---|
| `boxyPage` | Fade + Subtle Slide Up | 400ms |
| `AppAnimations.fast` | Micro-interactions | 200ms |
| `AppAnimations.medium` | Standard | 400ms |

`boxyPage` implements the **Salted PageKey Strategy** (`state.pageKey` + `state.matchedLocation`) to prevent duplicate navigation key crashes in nested shell routes.

---

## 13. Navigation & Tabs (`navigation.dart`)

### `ModernUnderlinedFilterBar<T>`
A horizontally scrolling, underlined filter bar used as a sleek alternative to pill chips.
- **`ModernFilterTab<T>`**: Represents a single tab with `label`, `value`, and optional `icon`.
- **`isExpanded: true`**: Evenly distributes tabs across the full width (ideal for 2-3 tabs).
- **Icon Support**: Supports optional iconography for improved visual scanability.

### `ModernUnderlinedTabBar`
A standard Material `TabController` driven underlined tab bar.
- **`tabLabels`**: List of strings for the tab titles.
- **`icons`**: Optional list of `IconData` to display alongside labels.
- **Usage**: Use with `DefaultTabController` or a custom `TabController`.

---

## 14. Deprecated Patterns (Do Not Use)

| Deprecated | Replacement |
|---|---|
| `Switch(activeColor: ...)` | `Switch(activeTrackColor: ..., activeThumbColor: ...)` |
| `TextFormField(initialValue: ...)` with `value:` | Use `initialValue:` parameter |
## 13. Branding & Identity

Specialized components for managing society profile data and visual "atmosphere."

### `BoxyArtLogoPicker`
A high-performance asset management widget for society logos.
- **Functionality**: Integrates with `StorageService` for gallery picking and automated cloud uploading (to `/branding/` path).
- **States**: Handles loading (uploading), error messaging, and "Remove Logo" actions.
- **Visuals**: Premium `BoxyArtCard` integration with `AppShapes.xl` (18px) image container.

### `BoxyArtThemeModeTile`
Standardized visual mode selector for branding screens.
- **Functionality**: Controls `ThemeMode` switches (Light/Dark/System).
- **Visuals**: Branded `InkWell` tile with `AppShapes.md` icon background and `accentColor` active indicators.

## 14. Administrative "Settings Row" Standards (v4.3)
When building secondary administrative settings screens (e.g. Handicap Cuts, Notification Preferences), follow the **Actions-Right Alignment** pattern:

### `BoxyArtMetricInput`
Standardized high-density input for numerical settings.
- **Value Font**: `AppTypography.metricValue` (22px, Black weight).
- **Suffix Slot**: Right-aligned micro-label suffix ("pt", "events").
- **Fixed Width**: Input pocket defaults to **140px** to ensure alignment.
- **Selection Indicator**: Displays a **1.5px primary underline** when focused.

### Layout Guidelines
1. **All-Caps Labels**: All structural metadata and field labels must be ALL-CAPS with 1.2 letter spacing.
2. **Title Case Content**: Descriptions, help text, and user data remain in Title Case or Sentence Case.
2. **Branded Toggles**: Use `BoxyArtSwitchField` over standard `SwitchListTile`.
3. **Dividers**: Use `BoxyArtDivider` from the layout library to separate logical rows within a single card.

---

## 15. Admin Control Base Patterns (v4.x)

### `BaseCompetitionControl` (competition controls)
Abstract base class for all game configuration forms (`StablefordControl`, `StrokePlayControl`, etc.).
Provides: `buildInfoCard`, `buildInfoRow`, `buildInfoBubble`, `buildAllowanceSlider`, `buildCapSlider`, `buildSliderField`, `buildGuestSettings`.

### `BaseLeaderboardControlMixin` (leaderboard controls)
Shared mixin for all season leaderboard configuration forms (`OrderOfMeritControl`, `BestOfSeriesControl`, `EclecticControl`, `MarkerCounterControl`).
Located at: `lib/features/admin/presentation/leaderboards/controls/base_leaderboard_control.dart`

| Helper | Purpose |
|---|---|
| `buildInfoCard(rows)` | Primary-colour tinted rule card — adapts to society branding |
| `buildInfoRow(label, value)` | Label row using `theme.colorScheme.primary` |
| `buildInfoBubble(text)` | Monochromatic hint beneath fields |
| `buildPointRow(...)` | Editable position → points row with `BoxyArtPill.format` badges |
| `buildAddButton(...)` | Outlined secondary button for adding items (e.g. "Add next position") |
| `formatEnum(val)` | Converts camelCase enum names to Title Case |
| `ordinal(n)` | Ordinal suffix (1st, 2nd, 3rd…) |
| `isDarkMode` | Convenience getter for brightness check |

> [!IMPORTANT]
> Both mixin families use `theme.colorScheme.primary` for info card label colours — never hardcode `AppColors.lime500` for these elements. This ensures society-level branding (set in `SocietyConfig`) automatically propagates to all admin config screens.

---

## 16. Template Gallery Components (v4.3)
To ensure a consistent "Admin Marketplace" feel, all selection galleries (Competitions, Season Leaderboards) must use the **Rich Rules Card** pattern.

### `CompetitionRulesCard`
Primary card for the Game Template Gallery.
- **Location**: `lib/features/competitions/presentation/widgets/competition_shared_widgets.dart`
- **Features**: Translates `CompetitionRules` into natural language descriptions and surfaces config pills (Format, Scoring, Handicap %).

### `LeaderboardRulesCard`
Standardized card for the Season Leaderboard Gallery.
- **Location**: `lib/features/admin/presentation/leaderboards/widgets/leaderboard_shared_widgets.dart`
- **Features**: Translates `LeaderboardConfig` into natural language descriptions via `LeaderboardRuleTranslator`. Surfaces critical season config (Basis, Best N, Tie Policy) via `LeaderboardBadgeRow`.

### Design Implementation Policy
1. **Badges**: Use `BoxyArtIconBadge` (44px square) with type-specific brand colors.
2. **Dividers**: Include a `BoxyArtDivider(verticalPadding: 0)` between the header and the description.
3. **Typography**: Use `AppTypography.labelStrong` for the template title and `AppTypography.body` for the long description (height 1.5).
4. **Blank Formats**: "Start Blank" cards must use the same `BoxyArtCard` + `BoxyArtIconBadge` layout (omitting description/pills) to maintain visual rhythm.

---

## 17. Badge & Icon Token Branding (v4.5)

To ensure high-contrast and society-specific branding across the application, use the standardized badge system which links directly to the **Branding Console**.

### `BoxyArtIconBadge` & `BoxyArtSquareBadge`
These components automatically consume global branding tokens:
- **Fill Color**: Linked to `iconBadgeFillColor` (Society secondary color by default).
- **Icon Color**: Linked to `iconBadgeIconColor` (Society secondary color by default).
- **Opacity**: Controlled by `iconBadgeOpacity`. **IMPORTANT**: Default is **0.15** to ensure the icon glyph remains sharp and high-contrast against the tinted background.

### Standard Information Rows
- **`ModernInfoRow`**: The primary component for event details. It now defaults to the **Global Branding** tokens (no flags required).
- **`BoxyArtSwitchTile` / `BoxyArtNavTile`**: Use these for settings and navigation. They automatically apply branding tokens to their leading icons.

### Implementation Best Practices
1. **Prefer Branding Tokens**: Avoid passing `isPrimary` or `isSecondary` flags for standard informational icons. Let them fall back to the branding tokens for maximum administrative control.
2. **Override with Intent**: Only use `isPrimary`, `isSecondary`, or `isTertiary` flags when the icon represents a specific state or "brand action" that MUST remain distinct from the global theme.
3. **Typography Alignment**: All badge-adjacent labels must follow the **v4.5 ALL-CAPS standard** (`AppTypography.micro` with `letterSpacing: 1.2`).
