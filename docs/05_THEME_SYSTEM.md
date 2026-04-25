# Theme System
**v4.x Authority — Boxy Art · High-Fidelity · Performance Admin**

The BoxyArt theme system is the single source of truth for all visual tokens in the application. It is fully configurable via the Branding Console.

- **Core Location**: `lib/design_system/theme/`
- **Design Archetype**: "Boxy Art" (Solid colors, structured hierarchy, high-performance administrative context).

---

## 01 · Color & Opacity

### Primitives
The system is built on a high-contrast dark-first scale.
- **Brand**: `lime500` (#4ADE80)
- **Alert**: `coral500` (#FF5533)
- **Achievement**: `amber500` (#FFAA00)
- **Neutral**: `dark950` down to `dark60` (Primary Text).

### Radical Opacity Consolidation (v4.x)
Never use arbitrary alpha values. Use the consolidated tokens via `.withValues(alpha: AppColors.token)`:

| Token | Value | Usage |
|-------|-------|-------|
| `opacityStrong` | `0.9` | High Emphasis Text |
| `opacitySecondary` | `0.6` | Medium Emphasis Text |
| `opacitySubtle` | `0.3` | Tertiary Text / Disabled / Hints |
| `opacityHalf` | `0.5` | Scrims / Overlays |
| `opacityMuted` | `0.3` | De-emphasized borders |
| `opacityLow` | `0.1` | Surface overlays / Tinted backgrounds |

---

## 02 · Typography (The v4.x Split)

### Plus Jakarta Sans — Display & Scoring
Used for high-impact numeric data and leaderboard "Hero" moments.
- **Leaderboard Scores**: 22pt / 800 weight (`AppTypography.weightBlack`), -0.5 letter spacing.
- **Numeric Rule**: Always use tabular numerals for score/stat alignment.

### Inter — UI & Functional
Used for all interface elements and administrative controls.
- **Body**: 14pt / 400 weight (line-height 1.6).
- **Metadata Standard**: All structural labels (e.g., "PTS", "NET", "STATUS") must use **ALL-CAPS**, 11pt, 800 weight (`AppTypography.weightExtraBold`), and `1.0` letter spacing.

---

## 03 · Spacing (Radical 5-Tier Scale)

All spacing must snap to these tiers to maintain vertical rhythm.

| Tier | Token | Value | Usage |
|------|-------|-------|-------|
| **Atomic** | `atomic` | `8.0` | Internal element gaps, label-to-card |
| **Standard** | `standard` | `16.0` | Card padding, page margins, card-to-label |
| **Large** | `large` | `24.0` | Enhanced breathing room, section gaps |
| **Section** | `section` | `32.0` | Major structural breaks |
| **Hero** | `hero` | `64.0` | Structural layout padding |

---

## 04 · Components & Patterns

### BoxyArtIconBadge
The standard for navigation and settings icons.
- **Spec**: 44pt total size, 22pt icon.
- **Neutral Style**: `dark600` background.
- **Branded Style**: `lime500` background with `opacityLow`.

### Administrative Context
- **Signifier**: `BoxyArtPill.committee(label: 'ADMIN')` in `titleSuffix`.
- **Dialogs**: Must use `OverflowBar` to handle responsive button layouts.
- **Switches**: Use `Switch.adaptive` with `lime500` active colors.

---

## 05 · Branding Tokens (Whitelabel Control)

Societies can customize their visual identity via the Branding Console. These tokens are stored in `SocietyConfig` and managed by the `ThemeController`.

| Token | Default | Usage |
|-------|---------|-------|
| `primaryColor` | `0xFFF7D354` | Main brand color (Yellow) |
| `pointsColor` | `0xFF4ADE80` | Accent for Stableford points emphasis (Use `effectivePointsColor` fallback) |
| `teamAColor` | `0xFF1E40AF` | Team A Identity (Blue) |
| `teamBColor` | `0xFF166534` | Team B Identity (Dark Green) |
| `effectivePointsColor` | `pointsColor ?? primaryColor` | Guaranteed color for Branded Scoring metrics |

---

## 06 · Hardening & Compliance

1. **Zero Hardcoding**: All colors/fonts must reference `AppColors` or `AppTypography`.
2. **Const Correctness**: Avoid `const` if a widget contains a dynamic token provider or suffix.
3. **Flutter 3.41+ Syntax**: Use `withValues(alpha: ...)` instead of `withOpacity(...)`.

---

*Fairway Design System v4.x · Theme Authority.*
