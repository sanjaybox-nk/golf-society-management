# Team Scoring & Handicap System (v4.5)

This document explains the technical implementation of team-based scoring (Scramble, Pairs) within the Golf Society Management system. This system ensures consistency across the Leaderboard, Group Hub, and individual Scorecards.

### 4.2 Marker Identity & Handoff (Claim the Card)
To ensure data integrity and prevent simultaneous editing conflicts, each team/group scorecard has a designated **Active Marker**.

-   **Visual Identity**: The active marker is identified by a **Green Pill** (Brand Primary tint) in the scorecard header.
-   **Write Access Lock**: Only the Active Marker (or a Society Admin) has write access to the scoring keypad. Other teammates view the card in "Read Only" mode.
-   **Self-Service Handoff**: If the designated marker's phone dies or they wish to hand over scoring duties, any other team member can "Claim the Card":
    1.  Open the team scorecard.
    2.  Tap their own **Name Pill** in the header.
    3.  The system immediately transfers the Marker Role to them, turning their pill green and granting them write access while locking out the previous marker.
-   **Historical Attribution**: Every score entry is attributed to the user who held the Marker role at the time of entry, providing a clear audit trail.

## 1. Team Handicap (PHC) Calculation

Unlike individual formats where each player has their own Playing Handicap (PHC), team formats like Scramble use a unified **Team PHC**.

### 1.1 Team Handicap Calculation Methods
Admins can select one of three calculation methods via the Scramble configurator:

#### A. WHS Recommended (Weighted)
This is the gold standard for fair competition, applying specific weightings to team members based on their handicap rank (Low to High):
-   **4-Person Teams**: 25% / 20% / 15% / 10%
-   **3-Person Teams**: 30% / 20% / 10%
-   **2-Person Teams**: 35% / 15%

#### B. Average (Arithmetic Mean)
Simple calculation: `Sum of Player Course Handicaps ÷ Team Size`.
-   **Example**: Team HCs [10, 15, 20, 25] (Sum 70) ÷ 4 = **17.5** (Rounded to 18).

#### C. Combined Total (Sum)
Simple sum of all player Course Handicaps.
-   **Use Case**: Often used with a very low percentage allowance (e.g. 10% of total).

### 1.2 Team Handicap Allowance (Global Multiplier)
The **"Handicap Allowance"** slider (e.g. 100%, 95%, 10%) acts as a final multiplier on the result of the method above.
-   **WHS**: Typically left at 100% since the weightings are built-in.
-   **Average**: Typically 100%.
-   **Sum**: Often set to 10% or 20%.
24: 
25: ### 1.4 Team Handicap Cap
26: Admins can specify a **Maximum Team Allowance** (Cap) via the Scramble configuration. 
27: - **Logic**: If the final rounded Team PHC exceeds the cap, it is automatically reduced to the capped value.
28: - **Usage**: Commonly used in society golf to prevent "stacked" teams from gaining an unfair advantage (e.g., capping a 4-man team at 18.0).

---

## 2. Net Scoring Engine

### 2.2 Scramble "Underlying Format"
Scramble can now be played using two distinct base scoring systems:
- **Stroke Play**: Traditional "Net Strokes" relative to par.
- **Stableford**: Points awarded based on the team's net score relative to par on each hole.

> [!IMPORTANT]
> The system uses the `underlyingFormat` setting in the `CompetitionRules` to determine which calculation engine to apply to the team's gross strokes.

### 2.3 Single Source of Truth (Team Card)
To simplify scoring and prevent duplication, the system uses a **single team scorecard** per flight.
- **Logic**: Instead of duplicating scores across all partners, the leaderboard greedily identifies the most complete scorecard associated with any member of the team and treats it as the definitive record for the "Team Entry".
- **Benefit**: Markers only need to enter one set of scores for the entire group.

### 2.4 The "To-Par" Focus
The system prioritizes "To-Par" scoring for clarity. A team's net score is calculated dynamically to allow for "Live" tracking even before 18 holes are finished.

**Formula:**
`Net Score = Total Gross - (Team PHC * (Holes Played / 18)) - Par of Holes Played`

> [!NOTE]
> This formula allows for fractional handicap application during a round, ensuring the "Live" Hub score remains accurate as players progress.

### 2.5 Gross vs. Net Parity
-   **Gross Score**: Raw strokes - Par.
-   **Net Score**: (Raw strokes - Handicap) - Par.
-   **Display Example**: `Gross: 67 (-5)` | `Net: 53 (-19)` (assuming a par 72 course and 14 stroke team handicap).

### 2.6 Dual-Scoring (Match Play Overlay)
As of April 2026, the system supports simultaneous scoring for multiple formats.
- **Stableford + Match Play**: The engine calculates Stableford points for the leaderboard while simultaneously deriving a head-to-head match result (e.g., 2 UP) for the match overlay.
- **Shared Logic**: Both scoring streams consume the same hole-by-hole gross strokes, ensuring absolute data parity.

---

## 3. UI Presentation Standards
### 3.1 Leaderboard (`EventLeaderboard`)
-   **Consolidated Entries**: Teams appear as a single row, but each player's name is rendered in its own sub-row within the card for maximum readability.
-   **Captain Indicator**: The team avatar (linked to the captain) is explicitly identified with an **amber shield badge** and background color.
-   **PHC Labeling**: The handicap column explicitly uses the "Team PHC" calculated via the weighted method.
-   **Member Visibility**: The main leaderboard view provides immediate visibility of all team members without needing to tap the entry.
-   **Team Mapping**: In unified formats, the leaderboard bypasses guest separation, ensuring teams stay together in the standings regardless of individual member/guest status.

### 3.2 Scorecard Modal (`ScorecardModal`)
-   **Multi-Player Header**: Displays all team members at the top.
-   **Handicap Context**: Labels stats as `team hc` and `team phc` to differentiate from individual baseline handicaps.
-   **Absolute Stats**: The summary row (`CourseInfoCard`) displays both the raw strokes and the relative-to-par value for maximum clarity.
-   **Drive Attribution Footer**: For Scrambles, the modal footer displays the "DRIVE ATTRIBUTIONS" summary (e.g., "H1: Player A"), allowing for quick verification of drive quotas.

### 3.3 Group Hub (`GroupingCard`)
-   **Unified Team Containers**: In Scramble/Team formats, all members of a team are rendered within a single **BoxyArtCard** wrapper.
-   **Internal Dividers**: Participants are separated by subtle, theme-aware horizontal dividers with standardized 0.8x card padding indents.
-   **High-Density Participant Rows**: Team members are listed using the high-density `GroupingPlayerTile` pattern (`useCard: false`), significantly reducing vertical scroll for large fields while maintaining premium aesthetics.
-   **Team Identity**: Each unified team block is visually grouped to emphasize that the team is the primary competitive unit.
-   **Better-Ball Footer**: In Pairs/Fourball, the footer displays pre-computed better-ball (BB) aggregate scores per pair using the configured society brand colors.

### 3.4 Shared Team Dashboard (My Card)
For unified team formats, the **My Card** tab transforms into a shared team dashboard:
- **Unified Scorecard**: All team members "see" and edit the same authoritative scorecard (attributed to the Team Leader).
- **Team Identity Header**: The tab title is updated to "TEAM SCORECARD" and displays a persistent "TEAM MEMBERS" row at the top of the hub.
- **Member Status**: The team row provides quick-look avatars and names of all teammates, reinforcing the collaborative nature of the format.

### 3.5 Scramble Drive Tracking
In Scramble and Florida Scramble formats, the system includes integrated drive attribution tracking:
- **Chosen Drive Picker**: The `HoleByHoleScoringWidget` displays a "CHOSEN DRIVE" picker below the score keypad.
- **Attribute per Hole**: Markers select which player's drive was used for the hole.
- **Persistence**: Attributions are saved in the `shotAttributions` map within the `Scorecard` model.
- **Compliance Tracking**: This data ensures teams comply with society rules regarding minimum/maximum drive usage per player.

### 3.6 Match View Toggle (Duel Mode)
For all Match Play formats (Singles or Pairs), the scoring widget includes a **"DUEL"** toggle:
- **Solo Mode:** Focuses on the player's own strokes and details.
- **Duel Mode:** Provides a side-by-side view of both match participants on a single screen. This allows for real-time comparison of scores, handicaps, and the calculated match status (e.g., *1 UP*).
- **Conflict Prevention:** By showing both cards on one dashboard, players can instantly identify and resolve scoring discrepancies before moving to the next hole.

---
*Last Updated: April 25, 2026*

---

## 4. Seeding & Testing Consistency

The `DemoSeedingService` is hardcoded to use the same logic as the production UI:
-   It uses `HandicapCalculator.calculateTeamHandicap` to generate seeded results.
-   It injects realistic hole-by-hole scores that sum to the calculated gross/net totals.
-   This ensures that "Testing Lab" events provide 100% accurate visual representation of the scoring system.

---
---

## 7. Fourball (Pairs) Scoring & PHC Conventions

Fourball (4BBB) differs from Scramble in that each player maintains an individual scorecard, but only the "Better Ball" (best score) of the pair counts towards the team total on each hole.

### 7.1 Better-Ball Aggregation
In the **Group Scores** tab and **Leaderboard**, the system dynamically aggregates the team's score:
- **Stableford**: Sum of the higher point value between the two partners on each hole.
- **Stroke Play**: Sum of the lower net score (relative to par) between the two partners on each hole.

### 7.2 PHC Display Conventions
To minimize confusion between Match Play and Stableford variants:

#### A. Stableford (4BBB)
- **Individual PHCs**: Each player displays their **Full PHC** (calculated with mandated 90% allowance).
- **Reasoning**: Stableford points are absolute. Zeroing a player would produce incorrect point totals.

#### B. Match Play Overlay & Tournament Style
- **Relative PHCs**: In head-to-head match views, players display PHCs **relative to the lowest player** in the match (who is zeroed).
- **Dual Metadata**: On the main leaderboard, players retain their full PHC for the base format (e.g. Stableford), but the "Match Result" column reflects the relative lead.
- **v4.5 Metadata Standards**: To ensure administrative distinction, all handicap labels ("HC", "PHC") and team identifiers are rendered in **ALL-CAPS** with 1.2 letter spacing.
- **Themed Display**: Handicaps are displayed using the premium `BoxyArtPill.hc()` and `BoxyArtPill.phc()` components. These pills ensure the index is always formatted to one decimal place (e.g., `8.4`). PHC is rendered using the society-level primary accent or team-specific color as appropriate.
- **Reasoning**: In Match Play, only the *difference* in strokes matters. This simplifies on-course tracking.

### 7.3 Score Propagation (Marker vs. Player)
To prevent "missing score" confusion:
- The **Marker's Card** (`playerVerifierScores`) automatically falls back to displaying the **Official Card** (`holeScores`) if the marker has not yet entered their own record. This ensures a consistent "Live" view for everyone in the group.

---
*Last Updated: April 21, 2026*

---

## 5. Gender Parity & Smart Tees

### 5.1 Overview
Mixed-gender events require that each player's scorecard and handicap calculation uses the correct tee data (Course Rating, Slope, Pars, SIs, Yardages) for their gender. Without this, a woman's Stableford points would be calculated against men's pars and SIs, producing incorrect results.

### 5.2 Event Form: Persisting Tee Data
When an admin creates or edits an event and selects a course, the system now saves:
- `courseConfig.tees`: The full list of all available tees from the course (e.g., White, Yellow, Red).
- `courseConfig.mensTeeName`: The default tee for male players (now defaults to **Yellow**).
- `selectedFemaleTeeName`: The explicit mapped tee for female players (e.g., **Red**).

The Event Form provides two new dropdowns ("Men's Default Tee" and "Ladies' Default Tee") that auto-populate based on common tee name conventions (e.g., "Red" → Ladies, "White" → Men's).

### 5.3 Smart Tee Resolution
The system ensures that the scorecard and handicap math are perfectly matched to each individual's gender:
1. **Explicit Female Tee**: Uses `selectedFemaleTeeName` for female players if set.
2. **Admin-set gender default**: Fallback to `mensTeeName` / `ladiesTeeName` from `courseConfig`.
3. **Auto-detection**: Heuristic search by tee name (Red/Lady → Ladies, Yellow/Men → Men's).
4. **Event baseline tee**: `event.selectedTeeName`.
5. **First available tee**: Final fallback.

This ensures that the `HoleByHoleScoringWidget` dynamically switches Par and SI values based on the player being marked.

### 5.4 Guest Indicator
The `ScorecardModal` now displays a gold **"GUEST"** pill next to the player name for any guest participant. This is determined by the `isGuest` flag on the `LeaderboardEntry` or by the `_guest` suffix on the entry ID.

### 5.5 Backward Compatibility

---

## 6. Advanced Scoring Configurations

### 6.1 Mixed Tee Equity Adjustments (C.R. - Par)
For **Stroke Play** and **Stableford** competitions involving mixed tees (e.g., Men on White, Women on Red), the system offers a **"Mixed Tee Adjustments"** toggle.

-   **Logic**: `Playing Handicap = (Handicap Index * Slope / 113) + (Course Rating - Par)`
-   **Why it matters**: If the White Tee Rating is 72.8 (Par 72) and Red Tee Rating is 74.2 (Par 72), the Red tee is harder. Players on the Red tee receive extra strokes (`74.2 - 72 = +2.2`) to level the playing field against par.
-   **Default**: Defaults to `OFF` (Standard WHS calc). Admins can enable it for precise equity in Medal play.

### 6.2 Tie Break Logic Override
The system supports multiple tie-break methods (Back 9, Back 6, etc.), but now allows for a **Manual Playoff** override.
-   **Standard**: Automatically sorts tied players using a progressive countback (B9, then B6, then B3, then B1). The leaderboard displays these values (B9 • B6 • B3) to provide transparency on tied rankings.
-   **Playoff (Manual)**: Disables automatic sorting. Tied players remain in their original order (or entry order) until an admin manually adjusts the result or enters a playoff score.

#### 6.3 Scoring Aesthetic Standards (Phase 9)
All scoring visualizations (Scorecards, Leaderboards, Results) now utilize the dynamic **Scoring Aesthetics** palette from the `SocietyConfig`.
- **Identity Lock**: Eagle (-2), Birdie (-1), Par (E), Bogey (+1), Double (+2), and Triple+ (+3) indicators use the whitelabel colors defined in the Branding Console.
- **Team Registry**: Team A and Team B color tokens provide a stable identity for Match Play pairings across all hubs.
- **Points Emphasis**: Stableford point totals across the administrative suite and player hubs utilize the `pointsColor` token. This "Hero Metric" standard ensures that the primary score in Stableford formats is visually dominant and customizable for whitelabel parity.
- **Hero Consistency**: The `CourseInfoCard` and `BoxyArtMemberRow` components are the authoritative implementations of this standard, ensuring that point scores are always rendered with the society-specific accent color.
- **Whitelabel Integrity**: By tokenizing the points color, societies can differentiate their scoring aesthetics from standard "Fairway" greens, supporting custom branding for elite or corporate society deployments.

---

## 8. Administrative Navigation & Visibility Standards (v4.x)

### 8.1 "Groups First" Navigation
To prioritize on-day coordination, all Administrative Scoring hubs utilize a **Groups First** navigation pattern.
- **Default Tab**: The **GROUPS** tab (Index 3) is the landing state for administrators, allowing immediate access to pairings and group-level coordination.
- **Standardized Order**: Navigation follows the operational lifecycle: **Groups** -> **Standings** -> **Bracket** -> **Verify**.

### 8.2 "VIEW SCORES" Master Toggle
In the **GROUPS** hub, administrators have access to a persistent visibility toggle to manage high-density data.
- **Organization Mode (OFF)**: Displays players with their Playing Handicaps (PHC) and tee times, optimized for flight management and check-in.
- **Scoring Mode (ON)**: Swaps the trailing metadata with live scores (Stableford Pts or To-Par). 
- **Admin Default**: This toggle defaults to **ON** for administrators to provide an immediate "Live Hub" experience while maintaining the ability to simplify the view for organizational tasks.
- **Visibility Integrity**: The scoring data in the Groups hub is processed for the entire field (all players in groups/scorecards), ensuring admins see results even for participants whose registration status is not yet finalized.

---
*Last Updated: April 23, 2026*
