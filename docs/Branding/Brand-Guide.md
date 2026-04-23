# Fairway Design System
**v4.x — Boxy Art · High-Fidelity · Performance Admin**

Fredoka (Display) + Inter (UI/Body) · `#4ADE80` Vivid Emerald

---

## Philosophy

The "Boxy Art" aesthetic represents a transition from "Minimalist Member" to "High-Performance Committee" design. It prioritizes clarity, structural hierarchy, and tactile administrative controls.

1. **Committee-Grade Controls** — Buttons and toggles must feel solid and responsive. No ambiguity.
2. **Structural Rhythm** — Vertical space is intentional. Use the 5-tier spacing scale to create distinct information zones.
3. **Metadata is Architecture** — Labels and system data are ALL-CAPS to differentiate them from user-generated content.
4. **Branded Context** — The society's brand color (Lime) is used sparingly for primary actions and active states to maintain high-contrast focus.

---

## 01 · Color & Opacity

### Primitives

#### Vivid Emerald — primary brand
| Token | Value | Usage |
|-------|-------|-------|
| `lime500` | `#4ADE80` ★ | Primary action, active states, brand accent |
| `lime400` | `#74E89A` | Hover states |
| `lime600` | `#22C55E` | Active/pressed states |
| `lime700` | `#16A34A` | Light-theme primary |

#### Coral — over par, alerts, destructive
| Token | Value | Usage |
|-------|-------|-------|
| `coral500` | `#FF5533` | Destructive actions, double bogey |
| `coral400` | `#FF7A5C` | Bogey, alert state |

#### Amber — achievement, gold
| Token | Value | Usage |
|-------|-------|-------|
| `amber500` | `#FFAA00` | #1 rank, PHC indicator, Committee Pill |

#### Neutral — dark-first surface scale
| Token | Value | Role |
|-------|-------|------|
| `dark950` | `#0A0A0A` | Deepest black, page background |
| `dark900` | `#111111` | Secondary background |
| `dark800` | `#141414` | Card surfaces (Standard) |
| `dark700` | `#1E1E1E` | Card surfaces (Elevated) |
| `dark600` | `#252525` | Icon backgrounds, subtle highlights |
| `dark500` | `#303030` | Borders |
| `dark150` | `#C8C8C8` | Secondary text |
| `dark60`  | `#F0F0F0` | Primary text |

### Radical Opacity Consolidation (v4.x)
Used to create hierarchy without introducing new colors.

| Token | Value | Usage |
|-------|-------|-------|
| `opacityStrong` | `0.9` | High Emphasis Text |
| `opacitySecondary` | `0.6` | Medium Emphasis Text |
| `opacitySubtle` | `0.3` | Tertiary Text / Disabled / Hints |
| `opacityHalf` | `0.5` | Scrims / Overlays |
| `opacityMuted` | `0.3` | De-emphasized borders |
| `opacityLow` | `0.1` | Surface overlays / Tinted backgrounds |

---

## 02 · Spacing & Radius

### Radical Spacing Scale (5-Tier)
All spacing must snap to these tiers. No intermediate values.

| Tier | Value | Usage |
|------|-------|-------|
| **Atomic** | `8.0` | Internal element gaps, label-to-card |
| **Standard** | `16.0` | Card padding, page margins, card-to-label |
| **Large** | `24.0` | Enhanced breathing room, section gaps |
| **Section** | `32.0` | Major structural breaks |
| **Hero** | `64.0` | Structural layout padding |

### Radius Scale
| Name | Value | Used on |
|------|-------|---------|
| `rSm` | `6.0` | Tags, score cells |
| `rMd` | `12.0` | Inner containers, input fields |
| `rLg` | `16.0` | Standard cards |
| `pill` | `999.0` | Buttons, avatars, badges |

---

## 03 · Typography

**The v4.x Split: Fredoka (Emotional) / Inter (Functional)**

### Fredoka — Display & Scoring
Used for "emotional" moments where the user celebrates their progress.
- **Score Totals**: 80pt / 900 weight.
- **Hero Headers**: 32pt+ / 800 weight.
- **Locker Room Numbers**: Tabular numerals.

### Inter — UI & Metadata
Used for all functional interface elements.
- **Body**: 14pt / 400 weight (line-height 1.6).
- **Labels/Metadata**: **ALL-CAPS**, 11pt, 800 weight, `1.2` letter spacing.
- **Captions**: **ALL-CAPS**, 10pt, 600 weight.

---

## 04 · Branded Components

### BoxyArtButton
- **Primary**: Brand color bg, high-contrast text.
- **Secondary**: Outlined, neutral text.
- **Ghost**: Tinted background (`opacityLow`), brand text.
- **Dangerous**: Coral background, high-contrast text.
- **Rule**: All labels are `toUpperCase()` with `weightBold`.

### BoxyArtIconBadge
- **Standard**: 44pt total size, 22pt icon.
- **Context**: Used in `BoxyArtNavTile` and `BoxyArtSwitchTile`.
- **Styling**: Uses `dark600` for neutral background or `lime500` with `opacityLow` for active branding.

### BoxyArtNavTile / SwitchTile
- **Layout**: `Padding(horizontal: Standard, vertical: Atomic)`.
- **Structure**: `IconBadge` + `Column(Label (ALL CAPS), Subtitle)` + `Action (Chevron/Switch)`.

### BoxyArtDialog
- **Constraint**: `insetPadding: horizontal: Standard`.
- **Actions**: Must use `OverflowBar` to automatically stack buttons if labels are long.
- **Buttons**: Side-by-side by default, vertical if "Confirm" label is > 8 characters.

---

## 05 · Administrative Standards

### The "ADMIN" Signifier
Every administrative screen must include the `BoxyArtPill.committee(label: 'ADMIN')` suffix in the `HeadlessScaffold` title area. This provides immediate context to the committee member.

### Infrastructure Actions
Administrative infrastructure actions (Wipe, Seed, Reset) must follow a 3-tier hierarchy:
1. **Initialize Demo Season**: Single master seed for full environment setup.
2. **Clear Activity Data**: Wipe events/members while preserving scaffolding.
3. **System Factory Reset**: Total deep wipe.

---

*Fairway Design System v4.x · High-Performance Administrative Context.*
