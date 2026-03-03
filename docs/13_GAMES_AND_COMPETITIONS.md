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
| **Match Play** | Knockout, League | Head-to-head competition. Uses a consolidated calculation engine for total parity. |
| **Scramble** | Texas, Florida | Team-based "best ball" scramble. Supports Stroke Play or Stableford as an `underlyingFormat`. |
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

### 3.2 Advanced Leaderboards
-   **Birdie Tree**: Tracks birdies, eagles, and albatrosses throughout the season.
-   **Eclectic**: Constructs the "perfect round" by taking the best score on each individual hole across all qualifying events.
-   **Best Of Series**: Tracks the best $N$ scores by raw metric (Net, Stableford) without point conversion.

## 4. Seasonal Standings Hub
Introduced in Feb 2026, the Standings Hub provides a premium home for long-term competition.

### 4.1 Admin Oversight
Admins manage seasonal standings via a centralized **SEASON** tab in the Leaderboards section.
- **Multiple Formats**: Admins can track OOM, Eclectic, and Birdie Tree standings simultaneously.
- **Quick Setup**: Direct access to configuration builders for each seasonal format.

### 4.2 Member Experience
Members access the hub via `Locker -> Season Standings`, featuring:
- **Podium View**: Visual highlights for the top 3 players (Gold/Silver/Bronze).
- **Personal Context**: Immediate identification of the member's rank and trajectory on the home screen.
- **Format-Specific Breakdowns**: Tapping a player row opens a deep-dive sheet (e.g., viewing an Eclectic Best Scorecard or Birdie count).

## 4. Enhanced Event Leaderboard

The event leaderboard provides a real-time view of the field with advanced presentation features:

### 4.1 Live Tracking
- **"THRU X" (Holes Played)**: While scoring is active, the leaderboard shows exactly how many holes each player has completed.
- **Dynamic Updates**: Standings re-order in real-time as scores are entered via the swiper.
- **Finalized State**: Progress indicators are automatically hidden once the event is marked as "Published" or "Locked" by the admin.

### 4.2 Automated Tie-Breaking
- **Filtered Display**: Tie-break details (e.g., "Back 9: 18 pts") only appear when two or more players are tied on the same score.
- **Logic**: Follows standard R&A countback methods (Back 9, Back 6, etc.) using the player's specific Playing Handicap (PHC) for the course.

### 4.3 Member/Guest Separation

- **Automatic Identification**: Guests are automatically identified (via the `_guest` suffix or `isGuest` flag) and categorized in the standings.
- **Global Control**: Administrators can set a society-wide default for guest visibility and separation in the **General Settings**.
    - **Include Guests in Standings**: Whether guests appear on leaderboards by default.
    - **Separate Guest Leaderboard**: Whether guests are moved to their own section or mixed with members.
- **Event-Level Overrides**: Each competition can override the global defaults for granular control.
    - **Include Guests**: A specific toggle per event to hide or show guests.
    - **Separation Strategy**: A 3-way choice: *Auto (Follow Global)*, *Always Separate*, or *Always Mixed (Balanced)*.
- **Visual Consistency**: Guests retain their "G" badge for easy identification regardless of the separation strategy.

### 4.4 Unified Scorecard View (Universal Parity)
All player entries on the leaderboard and admin scoring lists share a unified "Universal Parity" layout:
- **Unified Action**: Tapping a player opens the `ScorecardModal` or the `EventAdminScorecardEditorScreen`.
- **Mirror Layout**: The admin scorecard editor is visually identical to the member "Live" view, including:
    - **Handicap Context**: Real-time display of the player's Index (HC) and Playing Handicap (PHC). Handicaps use **decimal precision** (e.g., 14.5) for transparency.
    - **Themed Layout**: Player rows on the leaderboard now feature handicaps directly below the name (e.g., `HC: 14.5 • PHC: 12`) with the PHC highlighted in the primary theme color.
    - **Explicit Tee Support**: The UI dynamically resolves Par/SI values based on the player's gender and the event's explicit tee configuration (`selectedFemaleTeeName`).
    - **Dual Tee Display**: The Event Info Hub (`EventUserDetailsTab`) now displays both male and female tee positions (e.g., "Yellow / Red") when they differ, ensuring absolute clarity for mixed-gender fields.
    - **Header Sync**: Identical title and subtitle typography.
    - **Course Context**: A `CourseInfoCard` showing the tee configuration and performance summaries.
- **Typographic Standard**: Established "Pro Max" standards (w900 weight, 2.0 letter spacing) are applied to all functional labels (`TOTAL`, `HOLE`, `SCORES`) and **player names are consistently rendered in Pure White** for maximum legibility across all scorecard tiles.
- **Manual Society Cuts (Ad-Hoc Adjustments)**: Administrators can apply individual shot adjustments for a specific event via the **Manual Handicap Cuts** interface.
    - **Persistence**: These cuts are stored in the `manualCuts` registry within the `GolfEvent`.
    - **Scoring Impact**: Cuts are subtracted from the player's calculated Playing Handicap (PHC) across all supported formats (Stableford, Medal, etc.).
    - **Dynamic Sync**: Saving cuts automatically triggers a recalculation of any snapshotted group handicaps on the tee sheet to maintain absolute data consistency.

## 5. UI Flow

### Selecting a Format
Admins are presented with a simplified selector:
1.  **Standard Games**: Stroke, Stableford, Max Score.
2.  **Team Games**: Scramble (Texas/Florida).
3.  **Pairs**: Fourball, Foursomes.
4.  **Match Play**: Traditional match play.

### Library & Customization
-   **Pick from Gallery**: Select a template pre-approved by the society committee.
-   **Start Blank**: Create a one-off custom rule set for a special event.
-   **Save as Template**: Any custom game can be saved back to the library for future use.

## 4. Event Customization Workflow

When an Admin creates or edits an event, the system ensures a seamless flow for game rules:

### On-the-Fly Creation
Admins can select a template and immediately click **CUSTOMIZE RULES**. If the event is new, the system prompts to save the basic event details first to generate a stable ID. Once saved, the competition is created on-the-fly using the template as a baseline, allowing the Admin to edit rules without back-and-forth saves.

### Persistence & Syncing
- **ID Preservation**: When customizing a game for an event, the Competition ID is synced to the Event ID.
- **Cache Invalidation**: After saving changes in the Competition Builder, the system explicitly invalidates the `competitionDetailProvider` cache to ensure the Event Form reflects the new rules immediately upon return.
- **Compute Versioning**: Any customized game (not a template) has its `computeVersion` incremented to flag it as "Customized" in the UI.

## 5. Rule Visualization (Hardened Competition Card)

The rules are presented via the `CompetitionRulesCard`, which uses a **Hardened Standalone Architecture** (introduced Feb 2026) to ensure absolute visual parity and visibility across all sections of the app (Template Gallery, Event Detail, and Admin Form).

### Hardened Design Principles
- **Standalone Integrity**: To prevent theme-level transparency or layout conflicts, the card is built as a standalone `Container` with a deep opaque background (`#151515`). It does NOT inherit from general `BoxyArtCard` logic, ensuring a permanent "Alignment Lock."
- **Alignment Lock**: All text elements (Title, Subtitle, Rules, Badges) are explicitly anchored using `Align(Alignment.centerLeft)` to prevent accidental centering by parent themes or widgets.
- **Icon Restoration**: Uses high-contrast, high-alpha icon containers (e.g., Orange for Secondary, Lime for Primary) to ensure the game type is always identifiable.
- **Visibility Hardening**: The card forces a `double.infinity` width and uses standard `Material` wrappers to guarantee correct font rendering and shadow depth.
- **Fallback Protection**: If no dynamic competition data is found for an event, the card automatically renders a generic "SETUP COMPETITION..." template version, ensuring it never disappears or leaves a gap in the UI.

### Visual Components
- **Identity Badge**: [STABLEFORD] or [TEXAS SCRAMBLE] – Always shown in bold to identify the base format on both the event card and rules summary.
- **Scoring Type**: [GROSS] (Red) or [NET] (Teal).
- **Allowance**: [XX% HCP] or [100% DIFF].
- **Mode**: [SINGLES], [PAIRS], or [TEAMS].
- **Duration**: [MULTI-DAY] (Teal) – Shown if the event spans multiple days.
- **Specifics**: Only shown if non-default (e.g., [4 DRIVES], [CAP: 18], [SINGLE BEST], [STABLEFORD BASE]).

## 6. Matchplay Engine

The Matchplay module is designed to be "Event-Aware" but not "Event-Dependent."

### 6.1 Independent Mode (Knockouts)
Matchplay competitions can run as separate entities with their own lifecycle.
- **Visual Bracket**: Automated tree-view for knockout rounds.
- **Deadline Management**: Rounds have fixed deadlines; results can be entered manually as a final score (e.g., "3 & 2").

### 6.3 Secondary Games (Overlays)
Administrators can configure a **Secondary Game** (typically a Match Play overlay) to run alongside the primary competition.
- **Support**: Available when the primary format is Stableford or Stroke Play.
- **Independence**: The secondary game has its own `CompetitionRules` and can be customized independently of the main event rules.
- **UI Card**: Displays as a secondary configuration card in the Event Form with its own badge-based summary.
- **Player View**: Players see rules for both the primary and secondary games in their event details tab.

## 7. Scoring Status Lifecycle

To ensure data integrity, Admin's have granular control over when scoring is available.

| State | Variable | Effect |
| :--- | :--- | :--- |
| **Pending** | Default | Scoring is hidden until the event date. |
| **Live (Manual)** | `scoringForceActive` | Scoring is enabled regardless of the current date. |
| **Locked** | `isScoringLocked` | Scorecards are read-only; final positions are frozen. |

## 9. Scoring Accuracy & Verification

The scoring engine is hardened against edge cases to ensure 100% accuracy and absolute parity across all user and admin views. All competitive logic follows a **"Calculate Once, Display Everywhere"** architecture.

### 9.1 Authoritative Calculators

-   **Centralized Scoring Engine**: The system uses authoritative calculators to ensure consistency across Scorecard, Grouping, and Leaderboard views.
    - `MatchPlayCalculator`: Authoritative engine for Match Play (Net Match Play, Relative PHC, Fourball/Foursomes status).
    - `ScoringCalculator`: Authoritative engine for Stroke, Stableford, and Max Score capping logic.
    - **Authoritative Tee Resolution**: To prevent "Resolution Discrepancy," views must reconstruct the `holes` data map passed to calculators based on the specific tee override (Marker Selection).
    - Pattern: **Calculate Once, Display Everywhere**. Views must NOT implement their own scoring logic.

### 9.2 Universal Visual Parity

Starting in Feb 2026, all competitive UI components follow a unified "Pro Max" standard:
-   **Typography**: Functional labels (`TOTAL`, `HOLE`, `SCORES`) use `FontWeight.w900` and `letterSpacing: 2.0`.
-   **Administrative Alignment**: Admin scorecard editors and competition configuration cards are visually synchronized with member views to ensure a cohesive mental model between players and committees.
-   **Actionable Cards**: Competition config cards include centered, bordered customize buttons and refined vertical spacing for better visual hierarchy.

### 9.3 Automated Unit Tests

Core scoring logic is verified via a comprehensive test suite covering:
-   **Scramble**: WHS team weighting for 2/3/4-man teams with optional team-level caps.
-   **Stableford**: Point allocation across the spectrum and multi-round accumulation.
-   **Matchplay**: Early-victory detection and relative stroke-index assignment.
-   **4BBB**: Partner-based better-ball selection logic.
-   **Tee Mapping**: Gender-aware tee resolution (e.g., Red for Women) for mixed field equity.

### 9.5 Executive Performance Analytics

Introduced in Phase 11, the **Society Hub** provides advanced cross-event analytics to identify performance trends:
- **Course Difficulty Index**: Automatically ranks society courses by average Stableford points/Net strokes per round, identifying the toughest challenges for the membership.
- **Podium Consistency**: A specialized leaderboard tracking members with the highest frequency of Top 3 finishes.
- **Participation & Loyalty**: Deep engagement metrics identifying "Ever-Presents" and members requiring re-engagement based on missed event streaks.
- **Prize Allocation Ledger**: Detailed logging of cash, cups, and vouchers distributed across the season.
