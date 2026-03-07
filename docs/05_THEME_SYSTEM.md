# Theme System (BoxyArt v3.7 - True Minimal)

- **Location**: `lib/theme/`

## Key Files
-   **`app_colors.dart`**: Fairway v3.1 Primitives (Lime, Coral, Amber) and dark-first neutral scale.
-   **`app_typography.dart`**: Unified typography tokens using Fredoka (Display) and Inter (Body/Labels).
-   **`app_shapes.dart`**: Standardized radii (rXs to r2xl) and common UI shapes (Pill, Card).
-   **`app_spacing.dart`**: Layout spacing scale based on an 8pt grid (sm, md, lg, xl, x2l, etc.).
-   **`app_theme.dart`**: Compiles tokens into `ThemeData` for Light and Dark modes.

## Branding v3.1 Evolution

The system has transitioned to a **Vivid Emerald** (Lime) primary palette with a heavy emphasis on dark-mode first design, high-contrast accessibility, and **pro-grade administrative hardening**.

### 1. Colors (`AppColors`)

#### Primitives
-   **Primary (Lime 500)**: `#4ADE80` - The high-impact green used for major actions.
-   **Error (Coral 500)**: `#FF5533` - Used for scorecard alerts and destructive actions.
-   **Achievement (Amber 500)**: `#FFAA00` - Used for Rank #1 and high-value indicators.

#### Neutral Scale (Dark-First)
-   **Dark 950 - 800**: Backgrounds and surfaces.
-   **Dark 600 - 400**: Borders and elevated cards.
-   **Dark 150 - 60**: Semantic text hierarchy from Secondary to Primary.

### 2. Shapes (`AppShapes`)
-   **rXs (4.0)**: Subtle corner smoothing.
-   **rMd (12.0)**: Standard component radius.
-   **rLg (16.0)**: Standard card radius (`cardRadius`).
-   **r2xl (28.0)**: High-impact hero containers.
-   **rPill (999.0)**: For buttons and status tags.

### 3. Typography (`AppTypography`)
-   **Fredoka**: Used strictly for `displayHero` (Large Hero headers).
-   **Inter**: Switched to **Inter** as the primary typeface for all `body`, `label`, and `caption` styles to ensure a clean, professional, and readable interface.
-   **Weight**: Headers use `FontWeight.w900` with `letterSpacing: -0.8` for a contemporary feel.

## Legend System Taxonomy (BoxyArtPill)

v3.7 introduces the **True Minimal** Legend system, replacing background-filled "pills" with a cleaner Dot + Text format.

1.  **Format Legend**: `.format()` factory. Used for competition formats (Stableford, Matchplay). Emerald/Lime styling.
2.  **Type Legend**: `.type()` factory. Used for entity classification (Invitational, Player Badge). Dark/Neutral styling.
3.  **Status Legend**: `.status(color: ...)` factory. Used for lifecycle and registration states. Semantic color mapping.

## Universal Title Case Policy

As of v3.7, **ALL CAPS are strictly deprecated** across the entire application interface. 
- All labels, headers (`BoxyArtSectionTitle`), and dynamic status text must use clean **Title Case**.
- This improves legibility and reinforces the premium "True Minimal" aesthetic.

## Component Implementation Pattern

**Always use the centralized design system widgets from `lib/design_system/`**:
-   `BoxyArtCard`: Implements `rLg` radius and automatic border adaptation.
-   `BoxyArtPill`: Implements the 3-family Tag Taxonomy.
-   `BoxyArtInputField`: Handles v3.1 labeling and input decoration.
-   `BoxyArtAppBar`: Standardized header with v3.1 typography.

### Usage Example
```dart
BoxyArtCard(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: Column(
    children: [
      Text('Stableford', style: AppTypography.displayMedium),
      const SizedBox(height: AppSpacing.md),
      BoxyArtPill.status(
        label: 'Live',
        color: AppColors.lime500,
      ),
    ],
  ),
)
```
