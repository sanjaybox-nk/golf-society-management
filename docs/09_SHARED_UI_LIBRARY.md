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
Read-only field that looks like input but triggers tap.

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
Complex widget for the Member Detail screen header. Handles Avatar, Stats, and Fee toggle.

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

### `_MetricCard` (Pattern)
Internal widget pattern for dashboards (found in `admin_members_screen.dart`). 
- **Style**: Soft shadow, circular icon, large bold value.
- **Layout**: Usually placed inside a `SingleChildScrollView` + `Row` for horizontal scrolling.

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
Transparent app bar with custom circular actions.

### `FloatingBottomSearch`
The signature "Floating Dock" for Search and Filter.

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
