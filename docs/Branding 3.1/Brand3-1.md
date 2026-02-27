# Fairway Design System
**v3.1 — Dark-first · Sport-forward · Modern Golf**

Syne (display) + Plus Jakarta Sans (UI) · `#4ADE80` Vivid Emerald · 4 sections

---

## Philosophy

Three principles that every decision is tested against:

1. **Golf, not golf club** — the app is for the person holding the club, not the committee posting notices on the board
2. **Score is ceremony** — the moment a player sees their total is emotional; the design has to match that weight
3. **Earned simplicity** — every element pays rent; nothing decorates

---

## 01 · Colour

### Primitives

#### Vivid Emerald — primary brand
| Token | Value | Usage |
|-------|-------|-------|
| `--lime-500` | `#4ADE80` ★ | Primary action, brand accent, PHC values |
| `--lime-400` | `#74E89A` | Hover states, ghost button text |
| `--lime-300` | `#9DEFB6` | Light tints |
| `--lime-200` | `#C2F5D2` | Very light tints |
| `--lime-600` | `#22C55E` | Active/pressed states |
| `--lime-700` | `#16A34A` | Light-theme active green |
| `--lime-900` | `#052E16` | Deep dark green (total column, light theme) |

**Rationale:** `#4ADE80` is vivid emerald — sport-forward without crossing into neon. Readable in direct sunlight. Premium against dark surfaces. Not the acid lime of an energy drink, not the pastel sage of a heritage club coat of arms.

#### Coral — over par, alerts, destructive
| Token | Value | Usage |
|-------|-------|-------|
| `--coral-500` | `#FF5533` | Double bogey, destructive actions |
| `--coral-400` | `#FF7A5C` | Bogey, alert state |
| `--coral-300` | `#FFAB99` | Light tint |
| `--coral-100` | `#FFF0ED` | Very light tint (light theme alert bg) |

#### Amber — achievement, gold
| Token | Value | Usage |
|-------|-------|-------|
| `--amber-500` | `#FFAA00` | #1 rank badge, featured tag |
| `--amber-400` | `#FFBF33` | Hover amber |
| `--amber-100` | `#FFF8E6` | Amber tint bg |

#### Neutral — dark-first surface scale
| Token | Value | Role |
|-------|-------|------|
| `--dark-950` | `#0A0A0A` | Near-black, hero panels |
| `--dark-900` | `#111111` | Page background |
| `--dark-800` | `#141414` | ← **Page bg** |
| `--dark-700` | `#1E1E1E` | ← **Card surfaces** |
| `--dark-600` | `#252525` | Elevated cards |
| `--dark-500` | `#303030` | Borders |
| `--dark-400` | `#404040` | Strong borders, muted text floor |
| `--dark-300` | `#606060` | Tertiary text |
| `--dark-200` | `#A0A0A0` | ← **Tertiary text** `--text-tertiary` |
| `--dark-150` | `#C8C8C8` | ← **Secondary text** `--text-secondary` |
| `--dark-100` | `#D0D0D0` | Body text |
| `--dark-60`  | `#F0F0F0` | ← **Primary text** `--text` |
| `--dark-0`   | `#FFFFFF` | Pure white |

### Semantic tokens

```css
:root {
  /* Surfaces */
  --bg:            #141414;
  --bg-raised:     #1E1E1E;
  --bg-elevated:   #252525;

  /* Text — all readable, nothing disappears */
  --text:           #F0F0F0;   /* near-white, not harsh */
  --text-secondary: #C8C8C8;   /* clearly differentiated */
  --text-tertiary:  #A0A0A0;   /* labels, metadata */
  --text-muted:     #707070;   /* placeholders only */
  --text-brand:     #4ADE80;

  /* Borders */
  --border:         #2E2E2E;
  --border-subtle:  #242424;
  --border-brand:   #4ADE80;

  /* Actions */
  --action:         #4ADE80;
  --action-text:    #0A1A0F;   /* dark green-tinted black for lime buttons */
}
```

### Score States

Six states, clean contrast on dark surfaces. Every stroke means something.

| State | Background (dark) | Text (dark) | Background (light) | Text (light) |
|-------|-------------------|-------------|---------------------|--------------|
| Eagle | `rgba(52,211,153,0.16)` | `#34D399` | `#D1FAE5` | `#065F46` |
| Birdie | `rgba(74,222,128,0.14)` | `#4ADE80` | `#DCFCE7` | `#166534` |
| Par | `#252525` | `#A0A0A0` | `#EFEFED` | `#555550` |
| Bogey | `rgba(255,122,92,0.16)` | `#FF7A5C` | `#FEE2D5` | `#C2410C` |
| Double | `rgba(255,85,51,0.2)` | `#FF5533` | `#FECDC0` | `#9A3412` |
| Triple+ | `rgba(255,51,51,0.22)` | `#FF3333` | `#FDB8B0` | `#7F1D1D` |

### Tag Taxonomy — 3 families only

Replaces the previous 8-colour arbitrary system. Every tag belongs to one family.

**Format tags** — what type of competition
- Background: `rgba(74,222,128,0.08)` / Border: `rgba(74,222,128,0.18)` / Text: `--lime-400`
- Examples: Stableford, Strokeplay, Foursomes, Betterball, Matchplay

**Type tags** — character of the event
- Background: `--bg-elevated` / Border: `--border` / Text: `--dark-100`
- Examples: Invitational, Multi-day, Members Only

**Status tags** — lifecycle state
- Published: lime tint
- Completed: muted neutral
- Closing Soon / Waitlist: coral `rgba(255,85,51,0.1)` / `--coral-400`
- Featured: amber tint

---

## 02 · Typography

**Two fonts. Zero serifs.**

### Syne — display & score moments
Variable geometric grotesque by Bonjour Monde. Extraordinary character at weight 800. Used for all display-size text, score totals, headings, and numeric data.

```
Google Fonts: Syne:wght@400;500;600;700;800
```

| Role | Size | Weight | Letter-spacing |
|------|------|--------|----------------|
| display-hero | 80–88pt | 800 | −0.06em |
| display-lg | 48–52pt | 800 | −0.04em |
| display-md | 32pt | 700 | −0.03em |
| display-sm | 22pt | 700 | −0.02em |
| score-data | 22–28pt | 800 | −0.02em + `tnum` |

### Plus Jakarta Sans — UI & body
Humanist grotesque. Warm without being soft. Used for all interface text, labels, body copy, navigation, and metadata.

```
Google Fonts: Plus+Jakarta+Sans:wght@400;500;600;700
```

| Role | Size | Weight | Notes |
|------|------|--------|-------|
| heading | 16pt | 600 | — |
| body | 14pt | 400 | line-height 1.65 |
| label | 11pt | 700 | 0.1em tracking, uppercase |
| caption | 10–11pt | 600 | — |
| micro | 9–10pt | 700 | 0.12em tracking, uppercase |

**Numeric rule:** All score data and statistics use `font-variant-numeric: tabular-nums` + `font-feature-settings: "tnum"` — columns align without a separate monospace face.

---

## 03 · Components

All components use semantic tokens only. No hardcoded hex values in component CSS — ever. Swap the token file, the entire system updates.

### Spacing — 8pt grid
`4 / 8 / 12 / 16 / 20 / 24 / 32 / 40px`

### Radius
| Name | Value | Used on |
|------|-------|---------|
| xs | 4px | — |
| sm | 6–8px | score cells, tags |
| md | 12px | stat tiles, inner elements |
| lg | 16px | cards |
| xl | 20px | scorecards, larger cards |
| 2xl | 28px | device shell |
| pill | 999px | buttons, avatars, badges |

### Event Card
- Date badge: `--g-950` bg (dark) or `rgba(74,222,128,0.07)` tint, Syne 800 day numeral
- Event name: Syne 700 16–20pt
- Tags: 3-family system only (Format / Type / Status)
- Hover: `border-color: rgba(74,222,128,0.25)`

### Member Card
- Avatar: 46px circle, 4-colour ring system (lime / amber / coral / cyan — assigned by `member_id % 4`)
- Name: Syne 700 15pt
- HC value: `--lime-500` colour — PHC is the competition number
- Stats block: tabular-nums, Syne 800

### Grouping Card
- Tee time badge: `--lime-500` bg, Syne 800 dark text, pill shape
- PHC column: Syne 800 `--lime-500` — larger than HC label
- Total PHC footer: right-aligned, lime

### Leaderboard
- Rank #1: `--amber-500` badge
- Rank #2: `--dark-300` grey
- Rank #3: `#CD7F32` bronze
- "You" row: `rgba(74,222,128,0.05)` bg + 2px lime left border
- Score values: Syne 800 22pt — under = birdie green, over = coral, even = text

### Buttons
```
Primary:     #4ADE80 bg / #0A1A0F text
Dark:        #FFFFFF bg / #111111 text
Outline:     transparent / --border — hover to lime border
Ghost:       rgba(74,222,128,0.08) bg / --lime-400 text
Danger:      rgba(255,85,51,0.12) bg / --coral-400 text

Radius: pill (999px)
Font: Plus Jakarta Sans 700 14pt
```

### Tab Bar (5-item)
- Active: white bg (dark mode), dark text
- Live tab when round active: lime tint bg, lime text, breathing dot animation
- Icon: SVG 12px, 1.5px stroke, rounded caps

### Field Stats Grid
- 4-column, 2-row grid
- Syne 800 26pt numerals
- Playing/active numbers: `--lime-500`
- Waitlist/alert numbers: `--coral-400`
- All icons: SVG only, no emoji

---

## 04 · Live Scorecard

The most important screen in the app. Redesigned from the ground up.

### Score Hero Panel — always dark
The hero panel (`background: #0A0A0A`) runs dark in both light and dark themes. The score total is a ceremony — `+9` in coral at 80pt needs unconditional dramatic weight. A white hero panel doesn't land the same way.

- Score total: Syne 800 80pt, semantic colour
  - Under par: `#4ADE80`
  - Over par: `#FF7A5C`
  - Level par: `#F0F0F0`
- Gross: Syne 800 22pt `rgba(255,255,255,0.8)`
- Nett: Syne 800 22pt `#4ADE80` — nett is the competition number
- Topographic line texture: `repeating-linear-gradient` at 2.5% opacity — atmosphere without noise

### Scorecard Table — row hierarchy

Visual priority order (top = most important to the golfer):

1. **STK row** — the hero row. Cells 28×28px, Syne 800. Semantic colour for every score state.
2. Par row — recedes deliberately. Smaller text, muted colour.
3. SI row — smallest, quietest. Reference only.
4. Hole numbers — structural chrome, not data.

### Total Column
- Dark theme: `#0A0A0A` bg / `#4ADE80` totals
- Light theme: `#1A2E20` (forest green) bg / `#4ADE80` totals
- Syne 800 18pt for OUT/IN/Total values

### Theme behaviour
The scorecard supports both dark and light themes via `data-sc-theme` attribute on `.device`. The score hero panel stays `#0A0A0A` in both themes.

#### Dark (default)
- Card surface: `#1A1A1A`
- Row header: `#141414`
- Borders: `#2A2A2A`
- Score cells: translucent colour glows on dark

#### Light
- Card surface: `#FFFFFF`
- Row header: `#F7F7F5`
- Borders: `#E2E2DC`
- Score cells: solid pastel fills (birdie `#DCFCE7`, bogey `#FEE2D5`)

### Legend
Centred below the table. 5 states: Eagle / Birdie / Par / Bogey / Double+. 9×9px coloured squares matching cell colours.

---

## Icon System

All SVG, inline. No emoji anywhere in the app.

**Spec:** 16×16px viewBox, `stroke-width: 1.5`, `stroke-linecap: round`, `stroke-linejoin: round`. All icons use `stroke` only (no fill paths).

### Navigation (5 icons)
`home` · `calendar` (Events) · `users` (Members) · `briefcase` (Locker) · `file-text` (Archive)

### Event Hub Tabs (5 icons)
`clock` (Info) · `grid` (Field) · `star` (Live) · `bar-chart` (Stats) · `image` (Photos)

### Actions
`flag` · `user` · `check` · `share` · `settings` · `info` · `chevron-down` · `coffee` · `utensils` · `activity`

### Colour rules
- Default: `stroke: var(--text-tertiary)` (`#707070` dark / `#888880` light)
- Active tab: `stroke: var(--text)` via `currentColor`
- Live tab: `stroke: #4ADE80`
- Brand actions: `stroke: #4ADE80`

---

## Motion

Five interaction moments. Nothing animated while bugs exist — fix before flourish.

1. **Score entry** — digit rolls up via CSS counter animation; delta badge drops with spring physics (cubic-bezier 0.34, 1.56, 0.64, 1)
2. **Live tab pulse** — trophy icon breathes (scale 1.0→1.05, 1.8s loop) when round is active
3. **Leaderboard position change** — row translates vertically, brief `#4ADE80` flash on upward movement
4. **Theme switch** — all tokens transition in 0.3s ease; score hero excluded (always dark)
5. **Score reveal** — hole cells appear in 60ms stagger, totals arrive last

---

## Critical Bugs (fix order)

1. **`PHC: null` on Leaderboard** — render `—` fallback. Highest priority — visible to all members on live screens
2. Inconsistent tag colours — apply 3-family taxonomy
3. Score badge contrast — current light-blue-on-white fails WCAG AA
4. Final score state — completed scorecards need visual differentiation from in-progress

---

## Implementation Order

```
Day 1   CSS custom properties for all semantic tokens
Day 2   Fix PHC: null; apply tabular-nums globally
Day 3   Load Syne + Plus Jakarta Sans; apply to event names and score heroes
Day 4   Apply 3-family tag taxonomy; remove all 8 arbitrary tag colours
Day 5   Scorecard STK row: semantic cell colours
Day 6   Score hero 80pt Syne — the moment
Day 7   Audit — anything using a raw hex is a bug
```

**Audit rule:** If a component references a hex value directly instead of a CSS custom property, it's a bug and must be refactored to use the token.

---

*Fairway Design System v3.1 · Sport. Premium. Golf.*
