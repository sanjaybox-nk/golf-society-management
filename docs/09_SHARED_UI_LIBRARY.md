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
  titleSuffix: BoxyArtPill.committee(label: 'ADMIN'), // All admin screens
  subtitle: 'Context line',
  showBack: true,
  isPeeking: true, // First section title uses this
  slivers: [ ... ],
)
```

> [!IMPORTANT]
> Do NOT use `const` on `HeadlessScaffold` when `titleSuffix` is a non-const widget (e.g. `BoxyArtPill.committee`).

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
- **Typography**: `AppTypography.body` for text; `sizeMicro` (10px) + `weightHeavy` for labels.
- **Label Case**: UPPERCASE labels for high-density admin aesthetics.

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
- **`isPeeking: true`**: Mandatory for the first title in any `HeadlessScaffold` sliver list.

---

## 6. Badges & Indicators (`badges.dart`)

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
> `BoxyArtPill.committee()` is NOT a `const` constructor. Do not mark its parent `HeadlessScaffold` as `const`.

### `BoxyArtPill` Dot Legend mode
For all `status`, `format`, and `type` pills: renders an 8px coloured dot + text (no background fill, no icon).

### `BoxyArtStatusPill`
Toggleable "Paid / Unpaid" or "Visible / Hidden" double-state pill with tap-to-toggle support.

### `BoxyArtNumberBadge`
Circular numbered position badge (used in leaderboards).

### `BoxyArtIconBadge`
Square icon badge with optional tint fill.

---

## 7. Info Rows

### `ModernInfoRow`
Standard label + value row with optional icon:
```dart
ModernInfoRow(label: 'Course', value: 'St Andrews', icon: Icons.location_on_rounded)
```

---

## 8. Images

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
Standard confirmation dialog.
```dart
final result = await showBoxyArtDialog<bool>(
  context: context,
  title: 'Confirm?',
  message: 'This action is irreversible.',
  confirmText: 'Confirm',
  onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
  onConfirm: () async { /* ... */ },
);
```

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
| `const HeadlessScaffold(titleSuffix: BoxyArtPill.committee(...))` | Remove `const` from scaffold |
| `proxyDecorator: (child, _, __) =>` | `proxyDecorator: (child, index, animation) =>` |
| Inline `TextStyle(fontSize: X, color: Colors.X)` | `AppTypography.X.copyWith(color: AppColors.X)` |
