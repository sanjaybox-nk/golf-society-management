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

## 3. Cards (`cards.dart`)

### `BoxyArtFloatingCard`
Generic container with "Soft Scale" shadow and rounded corners. Use for lists or content blocks.
- **Properties**:
  - `padding`: Custom EdgeInsets for content spacing.
  - `onTap`: Makes the card interactive.

### `BoxyArtSettingsCard`
Grouped settings container.

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

## 5. Layout (`layout.dart`)

### `BoxyArtAppBar`
Standard screen header.
- `title` (String): Display text.
- `isLarge` (bool): If true, creates a 88dp colored header (Primary color).
- `showBack` (bool): Optional back button.
- `actions` (List<Widget>): Custom action buttons.

### `BoxyArtSectionTitle`
Grey, uppercase bold label (12pt) used to group content. Always visible even in empty states.

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
