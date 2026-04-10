# Theme System (v4.1 — True Minimal)

The BoxyArt theme system is the single source of truth for all visual tokens in the application. It is fully configurable via the Branding Console.

- **Core Location**: `lib/design_system/theme/`
- **Key Files**: `app_colors.dart`, `app_typography.dart`, `app_shapes.dart`, `app_spacing.dart`

---

## 1. Colors (`AppColors`)

### Opacity-Based Text Strategy
All text colors are derived from the `onSurface` base color using semantic opacity levels:

| Token | Opacity | Usage |
|---|---|---|
| `textPrimary` | 0.9 (`opacityStrong`) | Main content |
| `textSecondary` | 0.6 (`opacitySecondary`) | Supporting text |
| `textTertiary` | 0.3 (`opacitySubtle`) | Placeholders, quiet metadata |

### Semantic Entity Colors
Hardcoded entity colors replaced with semantic branding tokens:
- `AppColors.guestPurple` — `#8E44AD`
- `AppColors.mealBreakfast` — `#8D6E63`
- `AppColors.mealDinner` — `#673AB7`
- `AppColors.mealLunch` — `#2ECC71`
- `AppColors.teamA` / `AppColors.teamB` — Team identity

### Status Colors (`StatusColors`)
Semantic palette for consistent status indicators:
- `StatusColors.positive` — Success / Confirmed
- `StatusColors.negative` — Error / Declined
- `StatusColors.warning` — Caution / Pending

### Opacity Constants
Use these instead of `withOpacity(0.X)`:
- `AppColors.opacityStrong` (0.9)
- `AppColors.opacityHigh` (0.7)
- `AppColors.opacitySecondary` (0.6)
- `AppColors.opacityMuted` (0.4)
- `AppColors.opacityLow` (0.2)
- `AppColors.opacitySubtle` (0.1)
- `AppColors.opacityHalf` (0.5)

---

## 2. Typography (`AppTypography`)

### Standard Scale (5 Levels)

| Token | Size | Usage |
|---|---|---|
| `displayHeading` | 32px | Hero headers, modals |
| `headline` | 20px | Section titles, card headers |
| `body` | 16px | Default reading, card content |
| `label` / `labelStrong` | 13px | Buttons, metadata, tags |
| `micro` | 10px | Captions, pill labels, financial subtext |

### Standard Weights (3 Levels)

| Token | Weight | Usage |
|---|---|---|
| `weightHeavy` / `weightExtraBold` | 800 | Headers, emphasized titles |
| `weightBold` / `weightSemibold` | 600–700 | Labels, secondary emphasis |
| `weightRegular` | 400 | Body text |

### Letter Spacing
- `AppTypography.lsLabel` — Standard label letter-spacing (used with UPPERCASE micro labels).

---

## 3. Spacing (`AppSpacing`)

Standardized on a 4-tier scale.

| Tier | Token | Value | Usage |
|---|---|---|---|
| Atomic | `xs` / `sm` | 4–8px | Internal gaps, icon buffers |
| Standard | `md` / `lg` / `xl` | 12–24px | Card gaps, card padding |
| Section | `x2l` / `x3l` / `cardToLabel` | 32px | Section rhythm |
| Hero | `x4l` / `sectionGap` | 48–64px | Major structural voids |

> [!TIP]
> Always use `BoxyArtSectionTitle` to automatically enforce vertical rhythm — it handles top/bottom padding internally.

---

## 4. Dynamic Spacing Tokens (`AppSpacingTokens`)

For density-sensitive areas (Admin Console, settings screens), use the live extension tokens:

```dart
final spacing = Theme.of(context).extension<AppSpacingTokens>();
SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard)
```

| Token | Purpose |
|---|---|
| `labelToCard` | Vertical gap from a Section Label to its Card |
| `cardToLabel` | Vertical gap from a Card to the next Section Label |
| `cardToCard` | Vertical gap between adjacent cards in a list |
| `cardVerticalPadding` | Internal vertical padding for `BoxyArtCard` |
| `cardHorizontalPadding` | Internal horizontal padding for `BoxyArtCard` |

> [!IMPORTANT]
> Always access these via `Theme.of(context).extension<AppSpacingTokens>()`. Never hardcode these values or they will break in "Zero Spacing" and other density modes.

---

## 5. Shapes (`AppShapes`)

### Border Radius Constants
| Token | Value | Usage |
|---|---|---|
| `rXs` | 4px | Tiny elements |
| `rSm` / `sm` | 8px | Small badges |
| `rMd` / `md` | 12px | Input fields |
| `rLg` / `lg` | 16px | Standard cards |
| `rXl` / `xl` | 18px | Main cards |
| `pill` | 999px | Pills, fully-rounded |

### Border Thickness
- `borderThin` — 1px (default)
- `borderMedium` — 1.5px (selected states)

### Icon Scales
- `iconXs` — 14px
- `iconSm` / `iconSmall` — 16px
- `iconMd` / `iconMedium` — 24px (standard)
- `iconLg` / `iconLarge` — 32px
- `iconXl` — 40px

---

## 5.1 Design System Extensions (`AppShapeTokens`)

The shapes system is extended with tokenized badge metrics injected from the `SocietyConfig`:

| Token | Purpose |
|---|---|
| `iconBadgeSize` | The base square side-length for brand-tinted badges. |
| `iconBadgeIconSize` | The inner icon size for brand-tinted badges. |

> [!NOTE]
> These tokens ensure that specialized badges like `BoxyArtIconBadge` remain perfectly synchronized across all hubs.

---

## 6. Branding Architecture (v4.2 Separation)

The branding system is now split into two distinct tiers to ensure an admin-friendly experience while maintaining deep technical control.

### Tier 1: Society Identity (Admin Hub)
High-level assets and "atmosphere" controls found in the **Society Identity Screen**.
- **Society Name**: Global identity used in titles and communications.
- **Society Logo**: The brand mark used in scaffolds and auth flows.
- **Theme Mode**: Global preference (Light / Dark / System).

### Tier 2: Technical Design Tokens (Management Console)
Granular, token-based controls used for technical design system alignment.
- **Radii**: Card, Input, Button, and Hero corner configurations.
- **Shadows**: Global intensity, spread, and opacity overrides.
- **Vertical Spacing**: `cardToLabel`, `labelToCard`, and `cardToCard` rhythm.

> [!IMPORTANT]
> The **Management Console** (legacy Branding Hub) is reserved for future developer utilities and is hidden from standard administrative navigation. Most day-to-day administrative tasks should take place in the **Society Identity** hub.


---

## 7. Design 4.x Standard ("True Minimal")

### Universal Title Case
- **Policy**: All UI labels, headers, and buttons MUST use Title Case.
- **Prohibited**: `ALL-CAPS` section titles, `UPPERCASE` tab labels, shouting pill labels.
- **Exception**: Acronyms (GPS, OoM, HC, PHC) may retain caps.

### Admin Identity Standard
All primary administrative `HeadlessScaffold` screens must include:
```dart
titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
```
This is a non-negotiable visual signifier of administrative context.

### isPeeking Pattern
The first `BoxyArtSectionTitle` in any `HeadlessScaffold` sliver list must use `isPeeking: true` to eliminate the redundant top margin:
```dart
const BoxyArtSectionTitle(title: 'Section Name', isPeeking: true),
```

### Section Header Rhythm (32/8)
- **Before** section title: `32px` (Section tier)
- **After** section title to card: `8px` (Atomic tier, handled internally by `BoxyArtSectionTitle`)

### Dynamic Card Rhythm
All vertical gaps between cards in list views must use dynamic tokens:
```dart
SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard)
```

### Universal Card Title (Admin Gallery Screens)
All main titles in administrative gallery cards (Templates, Roles, Types) must use:
```dart
style: AppTypography.headline.copyWith(fontWeight: AppTypography.weightExtraBold)
```

---

## 8. Motion Standard (v3.9+)

| Transition | Description | Duration |
|---|---|---|
| `boxyPage` | Fade + Subtle Slide Up (0.05 offset) | 400ms (`AppAnimations.medium`) |
| `AppAnimations.fast` | For micro-interactions (e.g. `AnimatedContainer`) | 200ms |

All route movements including bottom nav switches and back-button pops use `boxyPage`.

---

## 9. Hardening Policy (v4.0 Audit)

1. **Zero Hardcoding**: No `Color(0x...)`, `Colors.X`, or `fontSize: X` in feature widgets.
2. **Token Usage**: All styles must reference `AppColors`, `AppTypography`, `AppSpacing`, or `AppShapes`.
3. **Semantic Colors**: Prefer `AppColors.textPrimary` over `AppColors.dark90`.
4. **Consolidated Opacity**: Use `AppColors.opacityX` tokens — prefer `withValues(alpha: ...)` in modern Flutter 3.41+.
5. **Const Correctness**: `HeadlessScaffold` with a non-const `titleSuffix` must NOT be wrapped in `const`.

### Common Deviations (Prohibited)
- `SizedBox(height: 10)` → use `AppSpacing.md` (12) or `AppSpacing.sm` (8)
- `BorderRadius.circular(10)` → use `AppShapes.md` (12) or `AppShapes.rMd`
- Local `TextStyle(...)` → extend `AppTypography.body.copyWith(...)`
- `Switch(activeColor: ...)` → use `activeTrackColor` + `activeThumbColor`
