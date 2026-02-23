# Team Scoring & Handicap System

This document explains the technical implementation of team-based scoring (Scramble, Pairs) within the Golf Society Management system. This system ensures consistency across the Leaderboard, Group Hub, and individual Scorecards.

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

---

## 3. UI Presentation Standards

### 3.1 Leaderboard (`EventLeaderboard`)
-   **Consolidated Entries**: Teams appear as a single row.
-   **PHC Labeling**: The handicap column explicitly uses the "Team PHC" calculated via the weighted method.
-   **Member Visibility**: Tapping the entry lists all names (Player A, Player B, etc.).

### 3.2 Scorecard Modal (`ScorecardModal`)
-   **Multi-Player Header**: Displays all team members at the top.
-   **Handicap Context**: Labels stats as `team hc` and `team phc` to differentiate from individual baseline handicaps.
-   **Absolute Stats**: The summary row (`CourseInfoCard`) displays both the raw strokes and the relative-to-par value for maximum clarity.

### 3.3 Group Hub (`GroupingCard`)
-   **Scramble/Team Scores**: All members of a team in the group hub show the identical "Live" net score.
-   **Fourball Individual Scores**: In Fourball (Pairs), each player shows their **own individual** Stableford/Stroke score, not the shared team score.
-   **Better-Ball Footer**: The footer displays pre-computed better-ball (BB) aggregate scores per pair as colored pills — **orange** pill for Side A, **blue** pill for Side B — matching the individual score badge shape.
-   **PHC Overrides**: Individual player tiles in a team game display the **Team PHC** rather than their personal index, reflecting the collective nature of the format.

### 3.4 Florida Scramble & Shot Attributions
For **Florida Scramble**, where the player whose shot was chosen must "step aside" for the next stroke, the system provides integrated UI support:
- **Shot Selector**: Markers can select which player's shot was chosen for the drive (and subsequent shots if needed).
- **Step-Aside Visuals**: The UI automatically applies a "Step-Aside" indicator to the player who hit the chosen shot on the previous hole/stroke, guiding players through the complex rotation.
- **Minimum Drives**: The `shotAttributions` map (`Hole Index -> Member ID`) is persisted in the `Scorecard` model, allowing admins to verify that each player has met the required number of drives (e.g., "Minimum 4 drives per player").

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

#### B. Match Play
- **Relative PHCs**: Players display PHCs **relative to the lowest player** in the group (who is zeroed).
- **Themed Display**: Handicaps are shown below names using the standard format: `HC: 14.5 • PHC: 12`, where PHC is highlighted in the primary theme color.
- **Reasoning**: In Match Play, only the *difference* in strokes matters. This simplifies on-course tracking.

### 7.3 Score Propagation (Marker vs. Player)
To prevent "missing score" confusion:
- The **Marker's Card** (`playerVerifierScores`) automatically falls back to displaying the **Official Card** (`holeScores`) if the marker has not yet entered their own record. This ensures a consistent "Live" view for everyone in the group.

---
*Last Updated: February 19, 2026*

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
-   **Standard**: Automatically sorts tied players by Back 9 score.
-   **Playoff (Manual)**: Disables automatic sorting. Tied players remain in their original order (or entry order) until an admin manually adjusts the result or enters a playoff score.
