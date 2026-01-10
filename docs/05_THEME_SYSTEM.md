# Theme System (BoxyArt)

The design system, widely referred to as **BoxyArt**, is centralized in `lib/core/theme/`.

## Key Files
-   **`app_theme.dart`**: Defines the `ThemeData` (Colors, Typography, Component Themes).
-   **`app_shadows.dart`**: Defines the custom static shadow lists.
-   **`boxy_art_widgets.dart`**: Contains reusable UI components implementing the system.

## Design Rules

### 1. Colors
-   **Primary**: `#F7D354` (Mustard Yellow) - Used for highlights, buttons, and active states.
-   **Surface**: `#FFFFFF` (White) - Used for cards and "floating" elements.
-   **Background**: `#F5F5F5` (Light Grey) - The canvas behind cards.
-   **Text**: `#000000` (Black) on Primary/White. `GoogleFonts.poppins`.

### 2. Shadows (`AppShadows`)
Do **NOT** use default Material Elevation. Use these defined styles:
-   **`softScale`**: For main content cards (`_EventCard`, `BoxyArtFloatingCard`).
    -   *Look*: Double-layered, soft diffusion. 12% & 8% opacity.
-   **`floatingAlt`**: For floating controls (Nav buttons, Search bar).
    -   *Look*: Stronger, defines edges on white-on-white. 20% opacity.
-   **`primaryButtonGlow`**: For Yellow Action Buttons.
    -   *Look*: Colored shadow (Dark Yellow), 80% opacity. Gives a "glow" effect.

### 3. Shapes
-   **Cards**: `BorderRadius.circular(30)`.
-   **Buttons/Inputs**: `StadiumBorder` or `BorderRadius.circular(100)` (Pill shape).

### 4. Implementation Pattern
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
-   `BoxyArtChatBubble`: For messaging interfaces.
