# Theme System (BoxyArt v3.1)

- **Location**: `lib/theme/`

## Key Files
-   **`app_colors.dart`**: Fairway v3.1 Primitives (Lime, Coral, Amber) and dark-first neutral scale.
-   **`app_typography.dart`**: Unified typography tokens using Fredoka (Display) and Nunito (Body).
-   **`app_shapes.dart`**: Standardized radii (rXs to r2xl) and common UI shapes (Pill, Card).
-   **`app_spacing.dart`**: Layout spacing scale (sm, md, lg, xl).
-   **`app_theme.dart`**: Compiles tokens into `ThemeData` for Light and Dark modes.

## Branding v3.1 Evolution

The system has transitioned to a **Vivid Emerald** (Lime) primary palette with a heavy emphasis on dark-mode first design and high-contrast accessibility.

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
-   **Fredoka**: Used for `displayHero` and `label` (Headers/Uppercase labels).
-   **Weight**: Headers use `FontWeight.w900` with `letterSpacing: -0.8` for a contemporary feel.
-   **Nunito**: Standard body font for readability.

## Tag System Taxonomy (BoxyArtPill)

v3.1 introduces a 3-family taxonomy for all tags and pills:

1.  **Format Tags**: `.format()` factory. Used for competition formats (Stableford, Matchplay). Emerald/Lime styling.
2.  **Type Tags**: `.type()` factory. Used for entity classification (Invitational, Player Badge). Dark/Neutral styling.
3.  **Status Tags**: `.status(color: ...)` factory. Used for lifecycle and registration states. Semantic color mapping.

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
