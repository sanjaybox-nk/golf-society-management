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
-   **rLg (18.0)**: The authoritative `BoxyArtCard` radius. Synchronized across all headers and footers using parent-level clipping.
-   **r2xl (28.0)**: High-impact hero containers.
-   **rPill (999.0)**: For buttons and status tags.

### 3. Typography (`AppTypography`)
-   **Fredoka**: Used strictly for `displayHero` (Large Hero headers).
-   **Inter**: Switched to **Inter** as the primary typeface for all `body`, `label`, and `caption` styles to ensure a clean, professional, and readable interface.
-   **Weight**: Headers and primary values use `FontWeight.w800` (ExtraBold) with `letterSpacing: -0.8` for a crisp, pro-grade feel. `w900` (Black) is reserved for specialized hero stats.

## Legend System Taxonomy (BoxyArtPill)

v3.7 introduces the **True Minimal** Legend system, prioritizing a clean **Title Case Text** approach. Leading icons/dots are removed unless functionally required.

1.  **Format Legend**: `.format()` factory. Used for competition formats (Stableford, Matchplay). Emerald/Lime styling.
2.  **Type Legend**: `.type()` factory. Used for entity classification (Invitational, Player Badge). Dark/Neutral styling.
3.  **Status Legend**: `.status(color: ...)` factory. Used for lifecycle and registration states. Semantic color mapping.
4.  **Tee Legend**: `.tee(color: ...)` factory. Specialized legend for golf tee colors. Uses a **12x12px** distinct indicator with a subtle **1px border** (0.1 opacity) for visibility against all background shades.

## Universal Title Case Policy

As of v3.7, **ALL CAPS are strictly deprecated** across the entire application interface. 
- All labels, headers (`BoxyArtSectionTitle`), and dynamic status text must use clean **Title Case**.
- This improves legibility and reinforces the premium "True Minimal" aesthetic.

## Component Implementation Pattern

**Always use the centralized design system widgets from `lib/design_system/`**:
-   `BoxyArtCard`: Implements authoritative radius and **automatic internal clipping** (`ClipRRect`).
-   `BoxyArtPill`: Implements the 4-family Tag Taxonomy.
-   `BoxyArtInputField`: Handles v3.1 labeling and input decoration.
-   `BoxyArtAppBar`: Standardized header with v3.1 typography.

### Radius Synchronization & "White Corners"
As of v3.8, inner surfaces (e.g., Header/Footer rows) must NOT declare their own radii if they are flush with the card boundary. `BoxyArtCard` uses `ClipRRect` to ensure all children inherit the authoritative curve, preventing visual artifacts ("white corners") caused by radius mismatches (e.g., 16px nested in 18px).

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

## Branding Control & Granular Styles (v3.1+)

Societies can fine-tune their visual identity through the **Branding Settings** (Admin suite). This persists a `SocietyConfig` object that dynamically adapts the theme.

- **Shadow Intensity**: A granular slider (0.0 to 2.0) that controls the depth and blur of `BoxyArtCard` shadows. 
- **Border Granularity**: Toggleable borders with adjustable widths.
- **Corner Smoothing**: Independent sliders for `Pill` and `Button` radii, overriding standard `AppShapes` for local brand flavor.
- **Branding Style Presets**:
    - `classic`: 8pt corners, conservative depth.
    - `boxy`: 18pt corners, medium depth.
    - `modern`: 28pt corners, high-diffusion air-glass shadows.

### Dynamic Shadow Implementation
`BoxyArtCard` automatically scales its `BoxShadow` based on `config.shadowIntensity`:
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.12 * config.shadowIntensity.clamp(0.0, 1.0)),
    blurRadius: 15 * config.shadowIntensity,
    offset: Offset(0, 4 * config.shadowIntensity),
  ),
]
```
