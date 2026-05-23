# Games & Competitions

This document details the scoring engine and competition configuration system used in the application.

## 1. Core Concepts

A **Competition** defines how scoring and rankings are calculated for an event. It can be created from scratch during event setup or picked from a **Template Gallery** of pre-configured society formats.

### Competition Types
-   **Template**: A predefined set of rules that can be reused across multiple events.
-   **Active**: A competition bound to a specific `GolfEvent` with active scoring.

## 2. Rule Configuration (`CompetitionRules`)

The behavior of a competition is governed by the `CompetitionRules` model.

### Format & Subtype
The primary driver of the scoring logic.

| Format | Subtypes | Description |
| :--- | :--- | :--- |
| **Stableford** | None, Gross Stableford | Points based on score relative to par. |
| **Stroke Play** | None | Traditional medal play (gross or net). |
| **Max Score** | None | Stroke play with a cap per hole (e.g., Net Double Bogey). The UI enforces this cap during entry. |
| **Scramble** | Texas, Florida | Team-based "best ball" scramble. Supports Stroke Play or Stableford as an `underlyingFormat`. |
| **Match Play** | (Feature Overlay) | Head-to-head competition enabled ON TOP of any standard format via the `hasMatchPlayOverlay` flag. |
| **Pairs** | Fourball, Foursomes | Partner-based formats. Fourball shows individual scores per player with better-ball aggregate per pair in the footer. |

### Handicap & Allowances
-   **Handicap Mode**: `WHS` (World Handicap System), `Local`, or `None`.
-   **Allowance**: Percentage of course handicap (e.g., 95% for Stableford).
-   **Handicap Cap**: Maximum allowed handicap for the competition.
-   **Course Allowance**: Whether to apply the Course Rating/Slope adjustment.
-   **Mixed Tee Equity**: Optional C.R-Par adjustment for mixed tee competitions.

### Aggregation & Multi-Round
-   **Rounds Count**: Support for multi-day tournaments (1-4 rounds).
-   **Aggregation**: `Total Sum`, `Single Best`, or `Stableford Sum`.
-   **Tie-Breaks**: Standard countback methods (`Back 9`, `Back 6`, `Back 3`, `Back 1`).

## 3. Season Leaderboards

The system supports long-term season standings with various calculation engines.

### 3.1 Order of Merit (OoM) - Point System
The standard approach for society tour standings.
-   **Point Conversion**: Rankings (1st, 2nd, 3rd...) are converted into points based on a configurable map (e.g., 25, 18, 15, 12...).
-   **Appearance Points**: Bonus points awarded just for participating.
-   **Best N Counting**: Supports "Best X of Y" rules (e.g., only your best 8 rounds out of 11 are totaled).
-   **Individual Credit**: Points for team-based events (Scramble/Pairs) are attributed to each individual member of the entry for their individual season total.
-   **Tied positions share points equally**: When multiple players finish tied at the same rank in a qualifying event, the `OOMCalculator` averages the points across all tied slots. E.g. two players tied 2nd both receive `(2nd points + 3rd points) / 2`.

### 3.2 Advanced Leaderboards
-   **Birdie Tree**: Tracks birdies, eagles, and albatrosses throughout the season.
-   **Eclectic**: Constructs the "perfect round" by taking the best score on each individual hole across all qualifying events.
    -   `EclecticCalculator` is metric-aware: `EclecticMetric.stableford` uses `holePoints`, applies a per-hole maximum, and sorts descending; `EclecticMetric.strokes` uses raw strokes and sorts ascending.
-   **Best Of Series**: Tracks the best $N$ scores by raw metric (Net, Stableford) without point conversion.
-   **Marker Counter (Birdie Tree)**: `MarkerCounterCalculator` now populates two additional fields:
    -   `history` — per-round breakdown of markers earned.
    -   `holeScores` — per-hole detail, populated only for single-type configurations (e.g. birdies-only) to power the hole heat-map UI.

### 3.2a Leaderboard Grouping & Display Order
The `groupLeaderboards()` public helper (in the leaderboards data layer) sorts and groups leaderboard configs by type in the following order for display:
1. Order of Merit
2. Best of Series
3. Eclectic
4. Marker Counters

### 3.2b Tie-Breaking — Phase 1 (Shared Positions)
Shared positions are displayed with an `=` prefix (e.g. `=2`) using `BoxyArtNumberBadge(prefix: '=')`. The `season_leaderboard_detail_screen.dart` podium and standings list both implement this convention. OOM tied positions share points equally (see §3.1 above).

### 3.2c Season Date Filter — Known Gotcha
The season end date **must include all event dates** that should count towards standings. If any event date falls after the season end date, that event's results are silently excluded from all leaderboard calculations and the standings will appear empty or incomplete. Always extend the season end date past the last scheduled event when configuring a season.

### 3.2d Member Group Filter (May 2026)
Each leaderboard config supports a `groupFilter: String?` field (a group ID from the season's linked `MemberGroupConfig`). When set, `LeaderboardInvokerService` filters the calculated standings to only include members who belong to that group, using `MemberGroupHelper.memberBelongsToGroup(memberId, groupFilter, groupConfig, members)`. See §3.5 Member Groups for the group system architecture.

### 3.2e Frozen Standings — Season Close (May 2026)
When a season is archived via the admin season form, standings are frozen in three ways:
1. A final `recalculateAll(seasonId)` is run before the `closeSeason()` write to Firestore, ensuring standings are up-to-date at the exact moment of close.
2. `LeaderboardInvokerService.recalculateAll()` returns early if `season.status == SeasonStatus.closed`, preventing any subsequent sync from overwriting frozen standings.
3. The Admin Operations "Sync Standings" button shows a snackbar and exits if the season is closed.

Both `season_standings_screen.dart` and `season_leaderboard_detail_screen.dart` display an amber lock banner when the season is closed: *"Season closed — standings are final and will not change."*

### 3.5 Member Groups System (May 2026)
Replaced the old `DivisionConfig` / `DivisionTemplate` system with `MemberGroupConfig` — a flexible, society-defined grouping system.

#### Split types
| Type | Behaviour |
|---|---|
| `handicap` | Members are auto-assigned to a group based on their HC falling within a named range (e.g. 0–12 = "A Division", 12.1–28 = "B Division") |
| `gender` | Members are auto-split by gender field |
| `custom` | Admin manually assigns members to named groups via the member picker |

#### Admin screens
- `DivisionTemplateGalleryScreen` — lists all saved `MemberGroupConfig` templates for the society; accessed from Admin → Seasons
- `DivisionTemplateEditorScreen` — full editor for a `MemberGroupConfig`: set split type, name groups, configure ranges or manually assign members; opens via `showDialog(Dialog.fullscreen(...))` from the gallery

#### Member picker
`_MemberPickerScreen` is a plain `StatefulWidget` (not a ConsumerWidget) rendered inside `Dialog.fullscreen()`. It uses `Material + SafeArea + Column` layout (not `HeadlessScaffold`) to avoid constraint issues in dialogs. Supports search, multi-select with check-circle, and confirms with a disabled-until-selection `BoxyArtButton`.

#### Key helper
`MemberGroupHelper.memberBelongsToGroup(memberId, groupId, config, members)` — returns `true` if the member belongs to the named group under the current config's split type. Used by `LeaderboardInvokerService` for the group filter.

### 3.3 Leaderboard Edit Controls — Design 4.x (April 2026)

All four leaderboard configuration screens have been refactored to **Design 4.x True Minimal** standards:

| Control | File |
|---|---|
| Order of Merit | `controls/oom_control.dart` |
| Best Of Series | `controls/best_of_control.dart` |
| Eclectic | `controls/eclectic_control.dart` |
| Birdie Tree (Marker Counter) | `controls/marker_counter_control.dart` |

#### Architecture: `BaseLeaderboardControlMixin`
A shared mixin (`controls/base_leaderboard_control.dart`) provides all controls with standardised Design 4.x helpers — mirroring the `BaseCompetitionControl` pattern used for game controls:

- **`buildInfoCard(rows)`** — Primary-colour tinted rule summary card (replaces raw green `Container`)
- **`buildInfoRow(label, value)`** — Single label + description row using `theme.colorScheme.primary` for labels
- **`buildInfoBubble(text)`** — Monochromatic hint text beneath fields
- **`buildPointRow(...)`** — Reusable Design 4.x position points editor row
- **`formatEnum(val)`** — camelCase → Title Case for enum display
- **`ordinal(n)`** — Ordinal suffix helper (1st, 2nd…)

#### Functional Hardening (April 2026)
- **Auto Re-indexing**: The builder now features "Sliding Rank" logic. If an Admin deletes a middle rank (e.g., 3rd place), the system automatically slides up all subsequent ranks to fill the gap, ensuring the list remains contiguous without manual re-entry.
- **Branded Numeric Inputs**: Points and rank inputs now utilize the society's dynamic **inputRadius** and **borderColor** tokens.
- **Micro-Typography Labels**: Section metadata like "PLACE" and "PTS" now use a specialized 11pt bold style (`AppTypography.micro`) to maximize vertical space in dense configuration lists.

#### Tokenisation Summary
- **Section Titles**: `BoxyArtSectionTitle(title: 'SECTION NAME', isPeeking: true)` with ALL CAPS labels.
- **Text Fields**: `ModernTextField` with inherited `SocietyConfig` branding tokens.
- **Info Cards**: Tinted with `theme.colorScheme.primary` (adapts to light/dark and society branding).
- **Handicap Badges**: `BoxyArtPill.format(...)` for consistent rules display.
- **Points Logic**: Values are validated in real-time to prevent negative or non-integer entry.
- **Save Action**: Uses the dynamic `primaryColor` token with context-aware labels (Create vs. Save).

## 4. Seasonal Standings Hub & Spoke
Introduced in early 2026 and modernized in April 2026, the Standings Hub provides a premium home for long-term competition using a discoverable **Hub & Spoke** architecture.

### 4.1 Hub Design (Design 4.x)
Members access the hub via `Locker -> Season Standings`.
- **Peeking Header**: Uses the premium Design 4.x "Peeking" title pattern, where the season name and standings year are integrated into a high-fidelity header transition.
- **Discoverable Menu**: Leaderboards (OoM, Eclectic, etc.) are presented as interactive cards with standardized `BoxyArtIconBadge` icons.
- **Live Leader Info**: Each card displays the current 1st place player and their total points, with a specific "YOU" highlight if the authenticated member is the leader.

### 4.2 High-Fidelity Detail View (Spoke)
Tapping a hub card navigates to the specific leaderboard detail screen (`SeasonLeaderboardDetailScreen`).
- **Premium Podium**: Visual highlights for the top 3 players (Gold/Silver/Bronze) featuring high-fidelity avatar rings, member photos, and rank badges. Shared `=2` positions are displayed with the `=` prefix.
- **Branded Stage**: A dedicated "Stage" component at the podium base provides visual depth and thematic anchoring.
- **Standing List**: A tight, data-dense list of the entire field featuring tokenized borders and personal best indicators for the current member. Tied positions show `=N` via `BoxyArtNumberBadge(prefix: '=')`.
- **Rules Card & Sheet**: A rules summary card is shown inline; tapping it opens a full rules bottom sheet.
- **Type-Aware Player Detail Sheet**: Tapping a player row opens a detail sheet that adapts its content to the leaderboard type (OOM shows points history per event; Eclectic shows best hole breakdown; Marker Counter shows marker history).
- **Summary Sheets**: Tapping a player row opens a deep-dive performance sheet showing rounds played, handicap trajectory, and best round metrics.

### 4.3 Admin Oversight
Admins manage seasonal standings via a centralized **SEASON** tab in the Leaderboards section.
- **Multiple Formats**: Track OoM, Eclectic, and Birdie Tree standings simultaneously.
- **Action Bolt**: Quick access to calculation overrides and refresh triggers via the standardized administrative "Bolt" menu.

## 5. Enhanced Event Leaderboard

The event leaderboard provides a real-time view of the field with advanced presentation features:

### 4.1 Live Tracking
- **Flattened Tournament Navigation**: (v3.8) Consolidates the event experience into a 5-tab shell: **Info**, **Field**, **My Card**, **Scores**, **Stats**.
- **"ENTER SCORE" Shortcut**: Direct access to the scorecard via a prominent Hero action on the Event Home.
- **"THRU X" (Holes Played)**: While scoring is active, the leaderboard shows exactly how many holes each player has completed.
- **Dynamic Updates**: Standings re-order in real-time as scores are entered.
- **Finalized State**: Progress indicators are automatically hidden once the event is marked as "Published" or "Locked".

### 4.2 Automated Tie-Breaking
- **Filtered Display**: Tie-break details (e.g., "Back 9: 18 pts") only appear when two or more players are tied on the same score.
- **Logic**: Follows standard R&A countback methods (Back 9, Back 6, etc.) using the player's specific Playing Handicap (PHC) for the course.

### 4.3 Member/Guest Separation

- **Automatic Identification**: Guests are automatically identified (via the `_guest` suffix or `isGuest` flag) and categorized in the standings.
- **Global Control**: Administrators can set a society-wide default for guest visibility and separation in the **General Settings**.
    - **Include Guests in Standings**: Whether guests appear on leaderboards by default.
    - **Separate Guest Leaderboard**: Whether guests are moved to their own section or mixed with members.
- **Event-Level Overrides**: Each competition can override the global defaults for granular control.
    - **Hidden (No Guests)**: Scrub guests from the leaderboard entirely.
    - **Separate Section**: Force guests into a distinct table with their own relative rankings (1, 2, 3), ensuring they don't displace society members from the main podium.
    - **Auto (Follow Global)**: (Default) The competition dynamically inherits the society's current global policy.
- **Visual Consistency**: Guests retain their "G" badge for easy identification.

### 4.4 Unified Scorecard View (Universal Parity)
All player entries on the leaderboard and admin scoring lists share a unified "Universal Parity" layout:
- **Unified Action**: Tapping a player opens the `ScorecardModal` or the `EventAdminScorecardEditorScreen`.
- **Mirror Layout**: The admin scorecard editor is visually identical to the member "Live" view, including:
    - **Handicap Context**: Real-time display of the player's Index (HC) and Playing Handicap (PHC). Handicaps use **decimal precision** (e.g., 14.5) for transparency.
    - **Themed Layout**: Player rows on the leaderboard now feature handicaps directly below the name using the premium `BoxyArtPill.hc()` and `BoxyArtPill.phc()` components. These pills ensure the index is always formatted to one decimal place (e.g., `8.4`).
    - **Explicit Tee Support**: The UI dynamically resolves Par/SI values based on the player's gender and the event's explicit tee configuration (`selectedFemaleTeeName`).
    - **Dual Tee Display**: The Event Info Hub (`EventUserDetailsTab`) now displays both male and female tee positions (e.g., "Yellow / Red") when they differ, ensuring absolute clarity for mixed-gender fields.
    - **Header Sync**: Identical title and subtitle typography.
    - **Course Context**: A `CourseInfoCard` or `SlidingCourseInfoCard` showing the tee configuration and performance summaries.
- **Scramble Multi-Line Display**: In Scramble and unified team formats, each player's name is listed on its own sub-row within the card. This ensures that even large 4-man teams are displayed clearly without text clipping or horizontal crowding.
- ### 5.3 Marker Responsibility & Identity
In team and unified formats, one player is designated as the authoritative **Marker**.

-   **The Green Pill**: Identified by a green status pill in the scorecard modal.
-   **Device Lock**: The scoring keypad is only active on the marker's device to prevent concurrent edit conflicts.
-   **Self-Service Handoff**: Any team member can "Claim" the marker role by tapping their own name in the scorecard modal, enabling seamless transition if a device loses power.
-   **Admin Overrides**: Administrators can bypass the marker lock to correct scores manually at any time.
- **Typographic Standard**: (v3.8 Refined)
    - **PAR Row**: Bold weight, background color matches the selected Tee color.
    - **SI Row**: Font size reduced by 1pt for better hierarchy.
    - **Distance Row**: Thin weight (YDS/MTR).
    - **MATCH Status**: Integrated W/L/H indicators for matchplay overlays.
    - **REL column**: Relative to Par (+/-) display in `CourseInfoCard`.
    - Player names are consistently rendered in Title Case with `AppTypography.headline` (20pt) and `weightExtraBold` (800) for maximum legibility.
- **Manual Society Cuts (Ad-Hoc Adjustments)**: Administrators can apply individual shot adjustments for a specific event via the **Manual Handicap Cuts** interface.
    - **Persistence**: These cuts are stored in the `manualCuts` registry within the `GolfEvent`.
    - **Scoring Impact**: Cuts are subtracted from the player's calculated Playing Handicap (PHC) across all supported formats (Stableford, Medal, etc.).
    - **Dynamic Sync**: Saving cuts automatically triggers a recalculation of any snapshotted group handicaps on the tee sheet to maintain absolute data consistency.

### 4.5 Dynamic Scoring Aesthetics (Phase 9)
The visual identity of scores and team lineups is now context-sensitive and society-driven.
- **Branded Scoring Palette**: Score indicators (Eagle, Birdie, Par, Bogey, Double, Triple+) no longer use static colors. They are dynamically generated from the `SocietyConfig` aesthetics palette.
- **Team Identities**: Match Play and Team events utilize `teamAColor` and `teamBColor` tokens to distinguish pairings, ensuring the "Red vs Blue" or "Lime vs Navy" rivalry is perfectly whitelabeled to the society's specific colors.
- **Live Sync**: Any aesthetic changes made in the **Design Token Studio** (Admin > Branding) propagate immediately to the `LeaderboardWidget` and `ScorecardModal` via the `ThemeController`.

## 6. UI Flow

### Selecting a Format
Admins are presented with a simplified selector:
1.  **Standard Games**: Stroke, Stableford, Max Score.
2.  **Team Games**: Scramble (Texas/Florida).
3.  **Pairs**: Fourball, Foursomes.
4.  **Match Play Feature**: Toggle the "Match Play Overlay" on any of the above formats to enable head-to-head results.
5.  **Tournament Modes**: Dedicated Match Play events (Ryder Cup, Knockouts) using seeded draws.

### Library & Customization
-   **Pick from Gallery**: Select a template pre-approved by the society committee. The gallery is context-aware and preserves the current `eventId` through the selection flow.
-   **Start Blank**: Create a one-off custom rule set for a special event. The selection screen (`CompetitionTypeSelectionScreen`) automatically anchors the new competition to the triggering `eventId`.
-   **Save as Template**: Any custom game can be saved back to the library for future use.

## 7. Event Customization Workflow

When an Admin creates or edits an event, the system ensures a seamless flow for game rules. Starting in April 2026, the editor (Competition Builder) has been modernized to adhere to **Design 4.x (True Minimal)** standards.

### Consolidated Administrative Interface
The Competition Builder interface uses a "Consolidated Card" pattern to reduce visual noise and improve configuration focus:
- **Identity Card**: The Game/Template Name is isolated in its own `BoxyArtCard`, separating the competition's identity from its technical rules.
- **Thematic Logic Cards**: Rule settings are grouped into logical, high-contrast `BoxyArtCard` containers (e.g., [HANDICAP], [SCORING], [ROUNDS]).
- **Internal Dividers**: Related fields within a card are separated by `BoxyArtDivider` components with 0px vertical padding, leveraging the card's internal spacing for a cleaner look.
- **Vertical Rhythm**: A standardized **24px (`AppSpacing.x3l`)** gap is applied before all monochromatic section titles, ensuring a consistent rhythm across different competition formats.
- **Synchronized Typography**: (Design 4.x) Field labels are synchronized with the **Member Details** forms:
    - **Casing**: Title Case is enforced for all manual labels (e.g., "Handicap Allowance").
    - **Tokens**: Labels use the **13pt Bold `AppTypography.label`** token to match standard input fields.
    - **Neutral Configuration**: Administrative controls use a **Monochromatic Neutral** palette. Configuration sliders are rendered in greyscale to distinguish technical setup from branded player-facing UI.

### On-the-Fly Creation
Admins can select a template (via **Add game format**) or immediately click **CUSTOMIZE RULES**. If the event is new, the system prompts to save the basic event details (Name, Date, Venue) first to generate a stable ID. Once saved, the competition is created on-the-fly using the template as a baseline, allowing the Admin to edit rules without back-and-forth saves. This workflow ensures that all competition rules are anchored to a valid, persistent event identity.

### Persistence & Syncing
- **ID Preservation**: When customizing a game for an event, the Competition ID is synced to the Event ID.
- **Cache Invalidation**: After saving changes in the Competition Builder, the system explicitly invalidates the `competitionDetailProvider` cache to ensure the Event Form reflects the new rules immediately.
- **Compute Versioning**: Any customized game (not a template) has its `computeVersion` incremented to flag it as "Customized" in the UI.

## 8. Rule Visualization (Hardened Competition Card)

The rules are presented via the `CompetitionRulesCard`, which uses a **Hardened Standalone Architecture** (introduced Feb 2026) to ensure absolute visual parity and visibility across all sections of the app (Template Gallery, Event Detail, and Admin Form).

### Hardened Design Principles
- **Standalone Integrity**: To prevent theme-level transparency or layout conflicts, the card is built as a standalone `Container` with a deep opaque background (`#151515`). It does NOT inherit from general `BoxyArtCard` logic, ensuring a permanent "Alignment Lock."
- **Alignment Lock**: All text elements (Title, Subtitle, Rules, Badges) are explicitly anchored using `Align(Alignment.centerLeft)` to prevent accidental centering by parent themes or widgets.
- **Icon Restoration**: Uses high-contrast, high-alpha icon containers (e.g., Orange for Secondary, Lime for Primary) to ensure the game type is always identifiable.
- **Visibility Hardening**: The card forces a `double.infinity` width and uses standard `Material` wrappers to guarantee correct font rendering and shadow depth.
- **Fallback Protection**: If no dynamic competition data is found for an event, the card automatically renders a generic "SETUP COMPETITION..." template version, ensuring it never disappears or leaves a gap in the UI.
- **Automatic Header Clipping**: Parent-level radius (18px) is applied via clipping, ensuring the background color striping is perfectly flush with the card's curve.

### Visual Components
- **Identity Badge**: [Stableford] or [Texas Scramble] – Always shown in bold to identify the base format on both the event card and rules summary.
- **Scoring Type**: [Gross] (Red) or [Net] (Teal).
- **Allowance**: [XX% Hcp] or [100% Diff].
- **Mode**: [Singles], [Pairs], or [Teams].
- **Duration**: [Multi-day] (Teal) – Shown if the event spans multiple days.
- **Specifics**: Only shown if non-default (e.g., [4 Drives], [Cap: 18], [Single Best], [Stableford Base]).

## 9. Match Play Management (Design 4.x)

Introduced in April 2026, the Match Play management system provides a professional-grade administrative workflow for specialized tournaments.

### 9.1 The Draw Manager
The **Draw Manager** is an "Event-Aware" hub that centralizes the creation of bracket and division structures directly from event data.
- **Contextual Initialization**: When launched from an event, it automatically syncs confirmed registrations and inherits competition rules (Singles/Pairs, Seeding Logic).
- **Entrant Mapping**: Utilizes the `MatchPlayEntrantService` to convert event registrations into competition units (including Partner Handshakes).

### 9.2 Competition Modes
- **Standalone Knockouts**: Automated tree-view for single-elimination rounds with fixed deadlines.
- **Divisions (Round Robin)**: Grouping logic for league-style play where winners advance to a final knockout bracket.
- **Secondary Game Overlays**: Match Play can run as a secondary competition overlaying a standard Stableford/Stroke Play event.

### 9.3 Visual Bracket Tree
Members interact with the tournament via a high-fidelity, scrollable bracket featuring:
- **Stroke Transparency**: Automated display of handicap adjustments (strokes received) per match.
- **Live Scoring**: Derived "Holes Up" status synced from live scorecards.
- **Interactive Navigation**: Seamless switching between Division standings and the Knockout bracket.

### 9.4 Seeding & Grouping Rules (Hardened)
To maintain the professional integrity of matchplay competitions, the seeding engine enforces several strict constraints:
- **Member-Only Seeding**: Guests are strictly excluded from Match Play seeding. The engine automatically filters out guest registrations during the "Auto-Group" process.
- **Head-to-Head Parity**: The field size is automatically balanced to an even number. If an odd number of players is confirmed, the system holds the last registrant out of the initial seeding to ensure every player has an opponent.
- **Strict Group Sizes**: Match Play groups are restricted to **2-balls** or **4-balls**. 3-balls are disallowed as they break the head-to-head rhythm of the competition.
- **Vertical Rhythm**: Tee sheets use a "Match-First" vertical rhythm, grouping cards under `MATCH N` headers with minimal `v` separators.

## 10. Scoring Status Lifecycle

To ensure data integrity, Admin's have granular control over when scoring is available.

| **Locked** | `isScoringLocked` | Scorecards are read-only; final positions are frozen. |

## 11. Story-Based Scoring (Penalties & Gimmes)

To enrich member progress tracking and auditability, the scorecard system supports "Hole Story" attributes that go beyond raw numbers.

### Penalty Tracking
Members can record ad-hoc penalties (Stroke and Distance, Water Hazard, etc.) for each hole.
- **Audit Ledger**: Penalties are stored as time-stamped tags within the `Scorecard` model.
- **Financial Integration**: If the **Charity Fine System** is enabled in `SocietyConfig`, these penalties are automatically totaled and reflected in the event's financial summary as "Suggested Donations."

### Gimmes & Pick Ups
- **Gimme Tracking**: Optional "Gimme" tag for non-competitive recording.
- **Pick Up (X)**: Standardized logic for "Pick Up" holes (X). The score is automatically set to the Max Hole Score (if configured) or marked as NR for the hole.
- **Not Played (-)**: Used for shortened rounds or injury withdrawals mid-round.

### Verification Handshake (SCORE | VERIFY)
To ensure data integrity, the system implements a formalized two-way sign-off:
- **SCORE Tab**: The primary entry interface for strokes and "Hole Stories."
- **VERIFY Tab**: A dedicated audit suite featuring a horizontal comparison grid (Player vs. Marker) and conflict highlighting.
- **Signature Lock**: Both Player and Marker must sign off to authorize the card.
- **Auto-Invalidation**: Any change to scores or tags post-sign-off automatically resets the verification status.

## 11. Scoring Accuracy & Verification

The scoring engine is hardened against edge cases to ensure 100% accuracy and absolute parity across all user and admin views. All competitive logic follows a **"Calculate Once, Display Everywhere"** architecture.

### 9.1 Authoritative Calculators

-   **Centralized Scoring Engine**: The system uses authoritative calculators to ensure consistency across Scorecard, Grouping, and Leaderboard views.
    - `MatchPlayCalculator`: Authoritative engine for Match Play (Net Match Play, Relative PHC, Fourball/Foursomes status).
    - `ScoringCalculator`: Authoritative engine for Stroke, Stableford, and Max Score capping logic.
    - **Authoritative Tee Resolution**: To prevent "Resolution Discrepancy," views must reconstruct the `holes` data map passed to calculators based on the specific tee override (Marker Selection).
    - Pattern: **Calculate Once, Display Everywhere**. Views must NOT implement their own scoring logic.

### 9.2 Universal Visual Parity

Starting in Feb 2026, all competitive UI components follow a unified "Pro Max" standard:
-   **Typography**: Functional labels (`Total`, `Hole`, `Scores`) use `FontWeight.w900` and `letterSpacing: 2.0`.
-   **Administrative Alignment**: Admin scorecard editors and competition configuration cards are visually synchronized with member views to ensure a cohesive mental model between players and committees.
-   **Actionable Cards**: Competition config cards include centered, bordered customize buttons when in active administrative "Edit Mode" (e.g., during event setup or management). These controls are hidden in standard view-only modes to maintain a clean, visual-first presentation.
-   **Adaptive Controls**: The button label dynamically shifts from "Customize" to "Customized" (Design 4.x) based on the competition's `computeVersion`.

### 9.3 Automated Unit Tests

Core scoring logic is verified via a comprehensive test suite covering:
-   **Scramble**: WHS team weighting for 2/3/4-man teams with optional team-level caps.
-   **Stableford**: Point allocation across the spectrum and multi-round accumulation.
-   **Matchplay**: Early-victory detection and relative stroke-index assignment.
-   **4BBB**: Partner-based better-ball selection logic.
-   **Tee Mapping**: Gender-aware tee resolution (e.g., Red for Women) for mixed field equity.

### 9.5 Stableford Visual Emphasis (v4.x Refined)
To prioritize the primary performance goal in Stableford competitions, the UI implements a specialized "Hero Metric" pattern:
- **Individual Scorecards**: Hole-by-hole point values use `AppTypography.weightBold` (w700) instead of dimmed styles.
- **Summary Footers**: The "Points" total is rendered as a Hero Metric (24pt, `AppTypography.display`) to separate it from strokes and par metadata.
- **Leaderboards**: Stableford point totals are emphasized with a 22pt `AppTypography.weightBlack` (w800) font, making the winning scores unmistakable in dense lists.
- **Color Accent**: Total points utilize the society's brand color (typically `AppColors.lime500` or `AppColors.dark900`) for maximum visual anchoring.

### 9.6 Executive Performance Analytics

Introduced in Phase 11, the **Society Hub** provides advanced cross-event analytics to identify performance trends:
- **Course Difficulty Index**: Automatically ranks society courses by average Stableford points/Net strokes per round, identifying the toughest challenges for the membership.
- **Podium Consistency**: A specialized leaderboard tracking members with the highest frequency of Top 3 finishes.
- **Participation & Loyalty**: Deep engagement metrics identifying "Ever-Presents" and members requiring re-engagement based on missed event streaks.
- **Prize Allocation Ledger**: Detailed logging of cash, cups, and vouchers distributed across the season.
