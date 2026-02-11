# Theme System (BoxyArt)

The design system, widely referred to as **BoxyArt**, is centralized in `lib/core/theme/`.

## Key Files
-   **`app_theme.dart`**: Defines the `ThemeData` with dynamic color generation from seed colors.
-   **`app_shadows.dart`**: Defines the custom static shadow lists.
-   **`status_colors.dart`**: Semantic color palette for status indicators.
-   **`contrast_helper.dart`**: Utility for calculating contrasting text colors.
-   **`boxy_art_widgets.dart`**: Contains reusable UI components implementing the system.
-   **`modern_card.dart`**: The core component of the "Headerless Modern" design system.

## Dynamic Theming

The theme system supports **dynamic color generation** based on a configurable seed color:

### Theme Generation
```dart
AppTheme.generateTheme(
  seedColor: Color(0xFFF7D354), // BoxyArt Yellow
  brightness: Brightness.light,
)
```

### Society Branding
Admins can customize the primary color via **Admin Console → Society Branding**. The theme automatically:
-   Generates a cohesive color scheme from the seed color.
-   Calculates contrasting text colors for accessibility.
-   Adapts to Light/Dark mode preferences.
-   Applies selected design palettes (e.g., "Deep Emerald", "Midnight Cobalt") across all modern UI components.

## Modern Card Design System (The "Lab" Standard)

Starting in early 2026, the application transitioned from the classic "Pill & Card" style to a more refined **Modern Card** aesthetic.

### Core Principles
- **Headerless Navigation**: Screens utilize a large, blurred `SliverAppBar` within a `NestedScrollView` rather than a standard flat AppBar.
- **Glassmorphism Hints**: Background tints and subtle gradients create a layered, premium feel.
- **Micro-Animations**: Uses rounded shapes and smooth transitions.
- **Content Hierarchy**: Information is grouped into `ModernCard` containers with consistent `20px` horizontal padding.

### Modern Components
- **`ModernCard`**: Replaces `BoxyArtFloatingCard` with refined borders, better tinting, and optional glass effects.
- **`ModernTextField`**: A cleaner, filled input style with integrated labeling and rounded corners (`16px`).
- **`ModernDropdownField`**: Consistent with the modern text fields, providing a unified selection UI.
- **`ModernSwitchRow`**: Replaces standard toggles with a full-width row design including descriptive labels and icons.

### 1. Colors

#### Primary Colors (Dynamic)
-   **Primary**: Configurable seed color (e.g., Mustard Yellow `#F7D354`, Navy `#1A237E`, Indigo `#3F51B5`).
-   **On Primary**: Automatically calculated for optimal contrast (black or white)
-   **Surface**: Light mode: `#FFFFFF`, Dark mode: `#1E1E1E`
-   **Background**: Light mode: `#F0F2F5`, Dark mode: `#121212`

#### Status Colors (Semantic)
Use `StatusColors` for consistent status indicators:
-   **Positive**: `#4CAF50` (Green) - Success, Active, Paid
-   **Warning**: `#FF9800` (Orange) - Pending, Due
-   **Negative**: `#F44336` (Red) - Error, Inactive
-   **Neutral**: `#9E9E9E` (Grey) - Archived, Default

### 2. Typography & Icons
-   **Weight**: Titles should use `FontWeight.w900` or `FontWeight.bold` for strong hierarchy.
-   **Spacing**: Modern designs use negative `letterSpacing: -0.5` for titles to feel more contemporary.
-   **Icons**: Prefer `Icons.*_rounded` variants (e.g., `Icons.home_rounded` over `Icons.home`) for a friendlier look.

### 2. Text Contrast

The `ContrastHelper` ensures readable text on any background:
```dart
final textColor = ContrastHelper.getContrastingText(backgroundColor);
```
This is automatically applied to:
-   Button text (`onPrimary`)
-   Member card headers
-   Status pills
-   Any component with dynamic backgrounds

### 3. Shadows (`AppShadows`)
Do **NOT** use default Material Elevation. Use these defined styles:
-   **`softScale`**: For main content cards (`_EventCard`, `BoxyArtFloatingCard`).
    -   *Look*: Double-layered, soft diffusion. 12% & 8% opacity.
-   **`floatingAlt`**: For floating controls (Nav buttons, Search bar).
    -   *Look*: Stronger, defines edges on white-on-white. 20% opacity.
-   **`primaryButtonGlow`**: For Yellow Action Buttons.
    -   *Look*: Colored shadow (Dark Yellow), 80% opacity. Gives a "glow" effect.
-   **`inputSoft`**: Specifically for form inputs (`BoxyArtFormField`, `BoxyArtDatePickerField`).
    -   *Look*: Extremely subtle offset (4px) with 5% opacity to maintain clarity on white cards.

### 4. Shapes
-   **Cards**: `BorderRadius.circular(30)` or `BorderRadius.circular(25)`.
-   **Buttons/Inputs**: `BorderRadius.circular(100)` (Pill shape).
    -   *Note*: Use `RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))` for input containers to ensure consistent shadow rendering compared to `StadiumBorder`.
-   **Dialogs**: `BorderRadius.circular(25)`.

### 5. Theme-Aware Development

**Always use `Theme.of(context)` instead of hardcoded colors:**
```dart
// ✅ Correct
color: Theme.of(context).primaryColor
color: Theme.of(context).cardColor
textColor: Theme.of(context).textTheme.bodyLarge?.color

// ❌ Avoid
color: Color(0xFFF7D354)
color: Colors.white
```

### 6. Implementation Pattern
To apply a shadow correctly without clipping:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: AppShadows.softScale, // 1. Shadow on Container
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(30), // 2. Clip Content
    child: ... content ...
  ),
)
```

## Reusable Components
Use components from `lib/core/widgets/boxy_art_widgets.dart` where possible:
-   `BoxyArtAppBar`: Transparent header with circular icon buttons.
-   `BoxyArtFloatingCard`: Standard white card container.
-   `FloatingBottomSearch`: The signature pill-shaped search bar.
-   `HomeNotificationCard`: Premium status-based alert cards for the dashboard.
-   `BoxyArtButton`: Multipurpose action button (Primary, Secondary, Ghost).
-   `BoxyArtFormField`: Unified pill-style input fields.
