# Shared UI Library (v4.1 — BoxyArt True Minimal)

The BoxyArt UI Library is the canonical source of all visual components in Golf Society Management. It is fully tokenised, premium-first, and enforces Design 4.x standards throughout.

**Central Export**: `package:golf_society/design_system/design_system.dart`
**Location**: `lib/design_system/widgets/`

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
- **Label Case**: Universal Title Case (v4.1 Policy). Enforced via the `toTitleCase()` utility to match the **Member Details** forms.

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
Premium configuration slider with dynamic range support.
- **Monochromatic Mode**: Set `isNeutral: true` to use the professional administrative greyscale palette instead of branded colors.
- **Key Parameters**: `value`, `min`, `max`, `divisions`, `label`, `isNeutral`.

### `BoxyArtFormActionRow`
Standard "Save / Cancel" row for form footers.

---

## 4. Buttons (`buttons.dart`)

### `BoxyArtButton`
Multipurpose action button.
- **Dynamic Radius**: shares `inputRadius` token.
- **Variants**: `isPrimary`, `isSecondary`, `isGhost`, `isSmall`, `fullWidth`, `isLoading`.
- **Typography**: `AppTypography.label` + `weightHeavy`.

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

- **Typography**: 13px (`label`) + 800 weight + Title Case.
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
| `BoxyArtPill.hc(index: 18.4)` | Handicap (1 decimal, no icon) |
| `BoxyArtPill.phc(index: 15.2)` | Playing handicap |
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
- **Synchronized**: Size and inner icon scale are controlled via the `AppShapeTokens` extension.
- **Usage**: Standardized for empty states (`BoxyArtEmptyCard`) and feature identity headers.

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

## 9. Navigation Bar Visibility Rules

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

---

## 11. Motion & Transitions

| Transition | Description | Duration |
|---|---|---|
| `boxyPage` | Fade + Subtle Slide Up | 400ms |
| `AppAnimations.fast` | Micro-interactions | 200ms |
| `AppAnimations.medium` | Standard | 400ms |

`boxyPage` implements the **Salted PageKey Strategy** (`state.pageKey` + `state.matchedLocation`) to prevent duplicate navigation key crashes in nested shell routes.

---

## 12. Deprecated Patterns (Do Not Use)

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
1. **Title Case Always**: All labels and descriptions must use Title Case.
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

