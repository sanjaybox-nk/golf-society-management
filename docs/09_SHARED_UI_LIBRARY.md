# Shared UI Library

The BoxyArt Shared UI Library is a modular system of reusable widgets designed to enforce the "BoxyArt" Boxy/Clean aesthetic across the application.

## Location
`lib/core/shared_ui/`

## 1. Buttons (`buttons.dart`)

### `BoxyArtButton`
The primary button component.
- **Properties**:
  - `title`: String
  - `onTap`: VoidCallback
  - `isPrimary`: (Default true) Yellow pill, black text.
  - `isSecondary`: White pill, black text, soft shadow.
  - `isGhost`: Transparent, grey text.
  - `icon`: Optional IconData.
  - `isLoading`: Shows spinner.
  - `fullWidth`: (Default false) Expands to match parent width.

### `BoxyArtCircularIconBtn`
Small circular button (e.g., Back button, Menu button).

### `ModernButton` (New)
Refined `ElevatedButton` wrapper used in modernized screens.
- Standard rounded shape (`12px` - `16px`).
- Consistent shadow and padding.

## 2. Inputs (`inputs.dart`)

### `BoxyArtFormField`
Standard text input with pill shape and soft shadow.
- `label`: Field label.
- `controller`: TextEditingController.
- `validator`: Form validation.
- `maxLines`: (Default 1) Supports multi-line input.
- `focusNode`: Optional FocusNode for external control (e.g. Autocomplete).

### `BoxyArtDropdownField<T>`
pill-shaped dropdown.

### `BoxyArtDatePickerField`
- **Shape**: Uses `RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))` for standard appearance.
- **Behavior**: Read-only field that looks like a standard input but triggers a tap callback (usually for `showDatePicker`).

### `BoxyArtSwitchField`
Switch tile with styled track/thumb.

### `BoxyArtSearchBar`
Standalone search bar with icon.

## 2b. Modern Inputs (`inputs.dart`)
*Recommended for administrative and modernized screens.*

### `ModernTextField`
A cleaner, filled input style with integrated labeling.
- `label`: Bold upstairs label.
- `icon`: Integrated icon on the label row.
- `filled`: uses `0.05` opacity of text color for background.
- `borderRadius`: `16px`.

### `ModernDropdownField<T>`
Consistent with modern text fields, providing a unified selection UI in a filled container.

### `ModernSwitchRow`
A full-width row design combining a descriptive label, icon, and a Switch. Preferred over `BoxyArtSwitchField` for complex forms.

## 3. Cards (`cards.dart`)

### `BoxyArtFloatingCard`
Generic container with "Soft Scale" shadow and rounded corners. Use for lists or content blocks.
- **Properties**:
  - `padding`: Custom EdgeInsets for content spacing.
  - `onTap`: Makes the card interactive.

### `BoxyArtSettingsCard`
Grouped settings container.

## 3b. Modern Cards (`modern_card.dart`)

### `ModernCard`
The core building block of the Modern Card design system.
- **Properties**:
  - `child`: Content widget.
  - `padding`: Default `16-20px`.
  - `onTap`: Interactive callback.
  - `showGlow`: Optional subtle primary-colored glow.
- **Design**: Rounded corners (`24px`), extremely subtle borders, and background tint support.

### `BoxyArtMemberHeaderCard`
A high-impact header component for the Member Detail screen.
- **Identity Section**: Circular avatar with "Since [Year]" label positioned underneath. Top-right section for Name, handicap, and iGolf/WHS stats.
- **Admin Controls**: Includes interactive `BoxyArtStatusPill` and `BoxyArtFeePill` when in edit mode or viewed by an admin. 
- **Theming**: Automatically uses the society's primary color for role badges and interactive highlights.

### `HomeNotificationCard`
Specialized widget for the Home Screen feed.
- **Features**: Status-based icons (Urgent/Info), truncated body text, and relative timestamps.

### `RegistrationCard`
The core widget for event participation management. Used in both Member and Admin apps.
- **Modes**:
  - **Display Only**: Regular list view for members.
  - **Interactive (Admin)**: Allows toggling of Paid/Golf/Buggy/Dinner statuses via direct icon clicks.
- **Indicators**:
  - **Status Pill**: Shows Confirmed, Reserved, etc.
  - **Position Badge**: Shows FCFS list position.
- **Interaction Icons**: Golf Club (Golf), Electric Car (Buggy), Restaurant (Dinner).

### `ScorecardModal`
A reusable modal for viewing detailed player scores. Used by both members (leaderboard) and admins (scoring list).
- **Properties**:
  - `entry`: The `LeaderboardEntry` data.
  - `scorecards`: List of historical or active scorecards.
  - `isAdmin`: When true, displays an **Edit (Pencil)** icon in the header.
- **Features**:
  - **Dynamic Calculation**: Reconstructs hole-by-hole points based on current competition rules and PHC.
  - **Fallback Logic**: Gracefully handles missing live scorecards by showing seeded results.
  - **Consistent Experience**: Unifies the tap action across all leaderboard-style lists.

### `MemberTile`
The standard list item for member directories.
- **Layout**: Features a left-side avatar, central name/stats section, and right-aligned context indicators.
- **Admin Enhancements**:
  - **Quick Toggles**: Admins can tap the Status pill to open a change menu or tap the Fee pill to toggle payment status directly from the list.
  - **Committee Badge**: Displays high-priority society roles (e.g., PRESIDENT) in a right-aligned primary-colored badge.
  - **Interaction Guard**: Tapping specific badges (e.g., Committee roles) does not trigger navigation, ensuring specialized clicks are captured correctly.

## 4. Badges (`badges.dart`)

### `BoxyArtStatusPill`
Semantic status indicator with automatic light/dark mode adaptation.
- **Properties**:
  - `text`: Display text (e.g., "Active", "Paid", "Confirmed", "Dinner", "Waitlist")
  - `baseColor`: Semantic color from `StatusColors` (Positive/Green, Warning/Orange, Negative/Red, Neutral/Grey, Info/Blue)
- **Special States**:
  - **Confirmed**: Positive (Green)
  - **Reserved/Pending**: Warning (Orange)
  - **Waitlist**: Negative (Red)
  - **Dinner Only**: Info (Blue)
  - **Withdrawn/Off**: Neutral (Grey)
- **Behavior**: 
  - Automatically adjusts text color using `ContrastHelper` for optimal readability.
  - Automatically adjusts background opacity based on theme brightness.

### `StatusChip`
Black pill with white text for role badges.

### `BoxyArtFeePill`
Interactive toggle for Fee Status (Paid/Due).
- Uses `StatusColors.positive` (green) for Paid
- Uses `StatusColors.warning` (orange) for Due

### `NotificationBadge`
Red/Yellow dot wrapper for unread counts.

## 5. Usage Patterns

### Rich Rule Summaries
Used for summarizing complex configurations (like Competition Rules) into a compact card.
- **Implementation**: Combine `BoxyArtFloatingCard` with a `Wrap` containing multiple `BoxyArtStatusPill` widgets.
- **Styling**: 
    - Use bold, black/neutral pills for the primary identity (e.g., format name).
    - Use semantic colors for properties (Red for GROSS, Teal for NET, Orange for special drives/rules).
    - Only show non-default properties to keep the UI clean.

## 6. Layout (`layout.dart`)

### `HeadlessScaffold`
The base layout for the "Pro Max" / Headerless Modern design.
- **Properties**:
  - `title`: Primary screen title (large, bold).
  - `subtitle`: Optional secondary context.
  - `showBack`: Controls back button visibility.
  - `slivers`: List of widgets to display in the nested scroll view.
- **Design**: Implements the signature blurred glass header and floating search bar integration.

### `FloatingBottomSearch`
The signature "Floating Dock" for Search and Filter.

### `BoxyArtSectionTitle`
A standardized section header used throughout the application. 
- **Style**: Uppercase, Bold, Grey text, Letter spacing 1.2.
- **Usage**: Used for grouping logically related content on a page (e.g. "EVENT DETAILS", "COSTS").

### `BoxyArtFloatingActionBar` (`floating_action_bar.dart`)
A premium floating bar for Save/Cancel actions.
- **Properties**:
  - `onSave`: VoidCallback
  - `onCancel`: VoidCallback
  - `saveLabel`: (Default 'Save Changes')
  - `isLoading`: Shows spinner on save button.
  - `isVisible`: For animated entry/exit.

## Usage
Import everything via:
```dart
import 'package:golf_society/core/shared_ui/shared_ui.dart';
// OR compatible legacy import
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
```

---

## Rich Stats Dashboard Widgets
Used in the `RichStatsTab` to provide deep analysis of society and personal performance.

- `ScoringTypeDistributionChart`: Bar chart showing Eagle/Birdie/Par/Bogey breakdown.
- `StablefordDistributionChart`: Point range distribution across the field.
- `SplitPerformanceCard`: Front 9 vs Back 9 comparison.
- `ParTypeBreakdown`: Performance badges for Par 3, 4, and 5 holes.
- `DifficultyHeatmap`: Grid view of hole difficulty relative to par.
- `HoleDifficultyChart`: Progress-bar based view of the toughest holes.
- `SocietyRecapSummaryCard`: Premium gradient card for event conclusion.
- `PersonalBenchmarkingCard`: Me vs Field comparative stat rows.
- `HoleComparisonHeatmap`: Star-based "Beat the Field" indicator grid.
- `ConsistencyStatCard`: Round variance vs field average stability card.
- `NetComparisonCard`: User net score vs societal average net.
- `HoleNemesisComparison`: Personal Toughest vs Field Toughest side-by-side.
- `BounceBackStatCard`: Comparative stat for recovery rate.
- `HoleScoreCard`: Standalone card for a single hole's detail. Features +/- controls (Active Mode) or Read-Only display. Consistent across scoring and summaries.
- `CourseInfoCard`: Provides a real-time summary of the course (Par, Slopes, Tees) and the player's performance vs. their PHC (Playing Handicap).
- `HoleByHoleScoringWidget`: The core engine for scorecard entry. Features an interactive hole swiper and "Active Marker" mode. Fully standardized across Admin and User views for 1:1 visual parity.

## 7. Universal Visual Parity
Starting in Feb 2026, all scorecard components follow a unified "Universal Parity" standard:
- **Typography**: Primary labels (`TOTAL`, `HOLE`, `SCORES`) use `FontWeight.w900` and `letterSpacing: 2.0`.
- **Metadata**: Status labels (e.g., "BIRDIE", "PAR", "BOGEY") use `FontWeight.w900` and `letterSpacing: 0.5`.
- **Layout Alignment**: Admin scorecard editors must include the exact same `HC / PHC` info row as member views to ensure admin-member alignment.
