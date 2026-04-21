# Theme System (v4.1 — True Minimal)

The BoxyArt theme system is the single source of truth for all visual tokens in the application. It is fully configurable via the Branding Console.

- **Core Location**: `lib/design_system/theme/`
- **Key Files**: `app_colors.dart`, `app_typography.dart`, `app_shapes.dart`, `app_spacing.dart`

---

### Semantic Branding Tokens (v4.5)
The theme engine is driven by 15+ semantic branding tokens managed via the **Branding Console**:

| Token | Category | Description |
|---|---|---|
| `primaryColor` | Essence | Main brand accent (e.g. Lime/Yellow) |
| `secondaryColor` | Action | Primary action/success color (e.g. Green) |
| `tertiaryColor` | Foundation | Secondary solid accent (e.g. Slate/Navy) |
| `textPrimary` | Typography | High-contrast main text (config-defined) |
| `textSecondary` | Typography | Mid-contrast supporting text |
| `textMuted` | Typography | Low-contrast hint/metadata text |
| `cardColor` | Surface | Standard card/sheet background |
| `surfaceElevated` | Surface | Floating/Modal elevated background |
| `borderColor` | Mechanical | The color of structural borders |
| `dividerColor` | Mechanical | The color of structural dividers |
| `dividerThickness` | Mechanical | The thickness of structural dividers (default: 1.0) |
| `scoreEagle` | Aesthetics | Color for -2 or better (e.g. Gold) |
| `scoreBirdie` | Aesthetics | Color for -1 (e.g. Blue) |
| `scorePar` | Aesthetics | Color for E (e.g. Dark) |
| `scoreBogey` | Aesthetics | Color for +1 (e.g. Grey) |
| `scoreDouble` | Aesthetics | Color for +2 (e.g. Light Grey) |
| `scoreTriplePlus` | Aesthetics | Color for +3 or worse (e.g. Subtle Grey) |
| `teamAColor` | Aesthetics | Primary team identity (e.g. Lime) |
| `teamBColor` | Aesthetics | Secondary team identity (e.g. Navy) |

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

### Letter Spacing & Rhythm
- `AppTypography.lsLabel` — Standard label letter-spacing (**1.2**). Strictly used with **ALL-CAPS** administrative metadata to ensure a premium, breathable rhythm.
- **Rhythm**: Metadata labels are typically paired with `AppTypography.weightBold` (w700).

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

### Tier 2: Design Token Studio (Branding Console)
Granular, token-based controls for expert design system alignment.
- **Colors**: Full control over Foundation (Tertiary), Typography hierarchy, and Surface tones.
- **Radii**: Card, Input, Button, and Hero corner configurations.
- **Mechanicals**: Border and Divider color/thickness settings.
- **Scoring**: Deep customization of domain-specific scoring and team aesthetics.

> [!IMPORTANT]
> The **Branding Console** is the "Expert Mode" of the society. It allows for full whitelabeling by overriding every semantic token in the design system.


---

## 7. Design 4.x Standard ("True Minimal")

### Administrative Metadata Rhythm
- **Policy**: All administrative labels, metadata headers, and configuration keys MUST use **ALL-CAPS**.
- **Distinction**:
    - **Metadata/Labels**: System-defined keys (e.g. "HANDICAP INDEX", "STATUS") -> **ALL-CAPS + Bold + 1.2 Spacing**.
    - **Content/Titles**: User-entered or dynamic data (e.g. "John Smith", "Society Cup") -> **Title Case**.
- **Exception**: Long descriptions or helper text remain in standard sentence case.

### Admin Identity Standard (titleSuffix v4.3+)
All primary administrative screens (Events, Members, Settings) MUST use the **titleSuffix Identity** pattern. This places the "ADMIN" signifier directly next to the screen title, establishing a consistent administrative context while freeing the `actions` slot for functional buttons.

```dart
HeadlessScaffold(
  title: 'Control Tower',
  titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
  actions: [
    // functional actions only (e.g. Help, Save)
  ],
)
```

### Pocketed Input Pattern (v4.3)
For high-density administrative settings (e.g. Society Cuts), use the **Pocketed Input Pattern**. This places labels and inputs in a single row within a themed "pocket" for maximum data density.

- **Background**: `isDark ? AppColors.dark600 : AppColors.lightHeader`
- **Typography**: `AppTypography.displayLargeBody` or `metricValue` (22px, Black weight) for values.
- **Alignment**: Right-aligned numerical values with a minimum width of **140px** to ensure consistency across different suffixes ("pt", "events").
- **Spacing**: Vertical internal padding `AppSpacing.md` with `BoxyArtDivider` for row separation.

### Admin Content Rhythm (Design 4.x)
To maintain the "Boxy" look across the administrative suite, all slivers must follow the **Card-to-Label (16/32)** rhythm:

| Transition | Spacing Token | Value |
|---|---|---|
| Card to next Label | `spacing.cardToLabel` | 32px |
| Label to next Card | `spacing.labelToCard` | 8px |
| Card to Card (List) | `spacing.cardToCard` | 16px |

> [!IMPORTANT]
> Always extract `AppSpacingTokens` in the `build` method. Never assume `AppSpacing.large` will look correct in high-density modes.

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
