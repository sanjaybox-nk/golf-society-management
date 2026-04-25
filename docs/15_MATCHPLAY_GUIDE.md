# Matchplay Module Technical Guide: The Overlay Model

As of April 2026, the Matchplay module has transitioned from a standalone "Competition Format" to a **Feature Overlay**. This "Format + Feature" architecture allows Match Play to coexist with Stableford or Stroke Play, enabling dual-scoring events (e.g., a society day where you play for Stableford points while simultaneously competing in a Match Play knockout).

## 1. Core Architecture: Format + Feature

The system distinguishes between the **Physical Format** (how you record shots) and the **Scoring Feature** (how those shots are interpreted).

- **Base Format**: Stableford, Stroke Play, Max Score, or Scramble.
- **Match Play Overlay**: Enabled via the `hasMatchPlayOverlay` flag in `CompetitionRules`.
- **Detection**: Use the `rules.isMatchPlay` extension, which returns true if either the overlay is active OR the competition is a dedicated tournament subtype (Ryder Cup, Season Match Play).

## 2. Competitive Modes

### A. Match Play Overlay (Side-Game)
Enabled on top of a standard event.
- **UI**: Displayed as a "MATCH PLAY ENABLED" badge on competition cards.
- **Grouping**: Uses the standard society grouping tool (random/progressive). Pairing occurs within the group.
- **Scoring**: Both Stableford points and Match status (e.g., 2 UP) are calculated from the same hole-by-hole scorecard.

### B. Tournament Style (Seeded Draw)
Dedicated events like **Ryder Cup**, **Team Match Play**, or **Season Tournament**.
- **Grouping**: Restricted. Pairing is determined by a **Seeded Draw** or **Knockout Bracket**.
- **UI**: The admin "Grouping" tab is replaced by "The Draw".
- **Logic**: Detected via `rules.isTournamentStyleGrouping`.

## 3. Authoritative Match Calculation

The `MatchPlayCalculator` is the central brain for all match logic. It is triggered automatically across the app whenever `isMatchPlay` is true:

- **Scorecard Modal**: Displays a hole-by-hole breakdown of the match status (Won/Lost/Halved) alongside gross/net scores.
- **Leaderboard**: In Match Play mode, the "Score" column reflects the match lead (e.g., 3 & 2) and the entries are sorted by margin of victory.
- **Central Scoring Controller**: The `eventScoringController` computes both standard leaderboard data and match results simultaneously.

## 4. Administrative Workflows

### Enabling the Overlay
Admin can toggle the "Match Play Overlay" on any standard competition format (Stableford, Stroke, etc.) during event setup or customization.

### Grouping vs. Draw
- **Overlay Events**: Admin uses the standard grouping tool. If the competition is "Pairs", the grouping tool enforces even numbers and partner pairing.
- **Tournament Events**: Admin uses the **Match Play Draw Manager** to build brackets or pairings. This draw is then "locked" into the event groupings.

### Match Synchronization
- If `hasMatchPlayOverlay` is active, the system looks for `MatchDefinition` objects within the event's `grouping` data.
- Matches are typically auto-generated within groups (e.g., Player 1 vs Player 2 in Group 1).

## 5. Result States & Derivement

Matches track status using a standardized format:
- **`2 UP`**: Leading by 2 holes (Match in play).
- **`A/S`** (All Square): Match is tied.
- **`Dormie`**: Leading player is ahead by the same number of holes remaining.
- **`3 & 2`**: Match ended on the 16th hole with one player 3 up.
- **`HALVED`**: Match completed as a tie.

## 6. Implementation Status (Updated April 2026)

- [x] **Overlay Model**: Coexistence of Stableford/Stroke + Match Play.
- [x] **Logic Refactor**: All checks migrated to `rules.isMatchPlay` extension.
- [x] **Tournament vs Overlay Separation**: Distinction between seeded draws and standard groupings.
- [x] **Leaderboard Dual-Awareness**: Correct sorting and labeling for match results.
- [x] **Admin Hub Synchronization**: Tab awareness (Tee Time vs The Draw) and Draw Manager integration.
- [x] **Seeding Support**: `EventSeeder` and `ScenarioSeeder` updated for overlay testing.
