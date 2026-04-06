# Theme System (v4.0 - Radical Simplification)

- **Location**: `lib/theme/`

## Key Files
-   **`app_colors.dart`**: Unified opacity-based color strategy using `onSurface` base.
-   **`app_typography.dart`**: 5 Standard Heights / 3 Standard Weights.
-   **`app_shapes.dart`**: Standardized Icon Scales (Small, Medium, Large).
-   **`app_spacing.dart`**: 4-Tier Scale (Atomic, Standard, Section, Hero).

## Radical Simplification (v4.0)

The system has been radically consolidated to ensure 100% UI consistency and predictability.

### 1. Colors (`AppColors`)

#### Opacity-Based Text Strategy
All text colors are derived from the `onSurface` base color using semantic opacity levels:
-   **`textPrimary`**: `onSurface` @ 0.9 (`opacityStrong`)
-   **`textSecondary`**: `onSurface` @ 0.6 (`opacitySecondary`)
-   **`textTertiary`**: `onSurface` @ 0.3 (`opacitySubtle`)

#### Semantic Entity Colors
Hardcoded entity colors have been replaced with semantic branding tokens:
-   **Guest Purple**: `AppColors.guestPurple` (`#8E44AD`)
-   **Meal Breakfast**: `AppColors.mealBreakfast` (`#8D6E63`)
-   **Meal Dinner**: `AppColors.mealDinner` (`#673AB7`)
-   **Meal Lunch**: `AppColors.mealLunch` (`#2ECC71`)

### 2. Typography (`AppTypography`)

#### Standard Heights (5 Levels)
-   **`Display`**: 32.0 (Hero headers)
-   **`Headline`**: 20.0 (Section titles, Player names)
-   **`Body`**: 16.0 (Default reading)
-   **`Label`**: 13.0 (Buttons, Metadata)
-   **`Micro`**: 10.0 (Captions, Tags, Debt/Financial Subtext)

#### Standard Weights (3 Levels)
-   **`Heavy`**: 800 (ExtraBold) - For headers and emphasized titles.
-   **`Strong`**: 600 (Semibold) - For labels and secondary emphasis.
-   **`Regular`**: 400 (Regular) - For body text.

### 3. Spacing (`AppSpacing`)
Standardized on a 4-tier scale for a predictable, high-density rhythm.

| Tier | Value | Usage |
| :--- | :--- | :--- |
| **Atomic** | 8.0 | Internal gaps, Label-to-Card |
| **Standard** | 16.0 | Page padding, Card padding, Card-to-Card |
| **Section** | 32.0 | Section breaks, Section Title Top |
| **Hero** | 64.0 | Large structural void |

> [!TIP]
> Use `BoxyArtSectionTitle` to automatically enforce this rhythm.

### 5. Dynamic Spacing Tokens (`AppSpacingTokens`)
For the **Admin Console** and other density-sensitive areas, the system uses dynamic tokens that respond to branding configuration:
- **`labelToCard`**: Dynamic vertical gap from a Label to its content Card.
- **`cardToLabel`**: Dynamic vertical gap from a Card to the next Section Label.
- **`cardVerticalPadding`**: Internal vertical padding for `BoxyArtCard` (defaults to 16.0).
- **`cardHorizontalPadding`**: Internal horizontal padding for `BoxyArtCard` (defaults to 16.0).

> [!IMPORTANT]
> Always access these via `Theme.of(context).extension<AppSpacingTokens>()` to support "Zero Spacing" and other user-controlled density modes.

### 4. Icons (`AppShapes`)

#### 3 standard Scales
-   **`Small`**: 16px
-   **`Medium`**: 24px (Standard)
-   **`Large`**: 32px

## Branding Console & Granular Control

The legacy `brandingStyle` presets (`classic`, `boxy`, `modern`) are **deprecated**. The system now uses purely dynamic granular controls:

-   **Card Radius**: 0.0 to 40.0
-   **Input Radius**: 0.0 to 30.0
-   **Button Radius**: 0.0 to 30.0
-   **Shadow Intensity/Spread/Opacity**: Fully adjustable.

This allows for a single "Theme Console" to control the entire application's aesthetic without maintaining hardcoded presets.

## Design 4.x Standard (v4.1 - True Minimal)
As of v4.1, the application enforces a "True Minimal" aesthetic characterized by the elimination of all-caps and refined, high-precision indicators.

### 1. Universal Title Case
-   **Policy**: All UI labels, headers, and buttons must use **Title Case**.
-   **Exception**: Acronyms (e.g., GPS, OS, ARM) may remain in caps if appropriate.
-   **Enforcement**: Explicitly prohibited: `ALL-CAPS` section titles, `UPPERCASE` tab labels, and `SHOUTING` status badges.

### 2. Tab Indicator Standard
-   **Style**: Bold, full-width (with 12px horizontal inset) indicator with rounded top corners.
-   **Dimensions**: 4px height, spanning the tab area with premium insets.
-   **Typography**: Labels must use `AppTypography.displayLocker` for a premium, fixed-width feel (optimized for density).
-   **Implementation**: Use `ModernUnderlinedFilterBar` or `indicatorSize: TabBarIndicatorSize.tab` for standard `TabBar` integrations.

## Motion Standard (v3.9 - BoxyArt Page)

As of v3.9, the application uses a unified transition function to ensure movement feels consistent and premium.

  - **Standard Page (`boxyPage`)**: A synchronized **Fade + Subtle Slide Up** (0.05 offset).
  - **Duration**: `AppAnimations.medium` (400ms).
  - **Global Policy**: This transition is applied to all route movements, including bottom navigation switches and back-button pops, creating a "silky" and stable user experience.

## v4.0 UI Audit & Consolidation (March 2026)

A comprehensive audit was performed to identify and eliminate hardcoded UI values. The following policy is now in effect:

### Hardening Policy
1.  **Zero Hardcoding**: No `Color(0x...)`, `Colors.X`, or `fontSize: X` are permitted in feature widgets.
2.  **Token Usage**: All styles must reference `AppColors`, `AppTypography`, `AppSpacing`, or `AppShapes`.
3.  **Semantic Colors**: Use semantic tokens (e.g., `AppColors.textPrimary`) over primitive tokens (`AppColors.dark60`) where available.
4.  **Consolidated Opacity**: Use the standardized `AppColors.opacityX` tokens instead of `withOpacity(0.X)`.

### Common Deviations (To be avoided)
- Using `SizedBox(height: 10)` instead of `AppSpacing.md` (12) or `AppSpacing.sm` (8).
- Using `BorderRadius.circular(10)` instead of `AppShapes.md` (12).
- Defining local `TextStyle` objects instead of extending `AppTypography`.
