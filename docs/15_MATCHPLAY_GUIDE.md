# Matchplay Module Technical Guide

The Matchplay module introduces head-to-head competitive logic to the society. It supports both standalone knockout tournaments and "layered" matches that occur during regular society events.

## 1. Core Architecture

The system uses three primary models to manage matchplay:

- **`MatchplayComp`**: The container for a tournament (e.g., "2026 Knockout Cup").
- **`MatchplayRound`**: Represents a stage in the tournament (e.g., "Round of 16" or "Quarter Finals").
- **`MatchplayMatch`**: An individual contest between two opponents.

## 2. Competitive Modes

### Standalone Knockouts
Matches are played independently of society events.
- **Manual Entry**: Players or admins enter the final result (e.g., "Won 4 & 3").
- **Bracket Management**: The system automatically advances winners to the next `MatchplayRound`.

### Layered Matches
Matches are played *during* a regular society event.
- **Unified Scorecard**: Players enter strokes for the society event.
- **Derived Status**: The match status is calculated in real-time by comparing net scores hole-by-hole.
- **Relative Handicap**: Strokes are received by the higher-handicap player based on the difference between the two opponents (usually 90% or 100% of the difference).

## 3. Handicap Logic (`MatchplayHandicapCalculator`)

Matchplay uses **Relative Strokes Received**.
1. Calculate the Course Handicap for both players.
2. Determine the difference between the two (e.g., Player A: 12, Player B: 18 -> Difference: 6).
3. Apply the Competition Allowance (e.g., 90% of 6 = 5.4, rounded to 5).
4. Assign strokes to the 5 holes with the lowest Stroke Index (SI 1 through 5).

## 4. Result States

Matches track status using a standardized format:
- **`2 UP`**: Player A is leading by 2 holes.
- **`A/S`** (All Square): The match is currently tied.
- **`Dormie`**: The leading player is ahead by the same number of holes remaining.
- **`3 & 2`**: The match ended on the 16th hole with one player 3 up.

## 6. Admin Workflow (Layered Matches)

1. **Event Setup**: Select a Match Play template as a **Secondary Game** overlay in the `EventFormScreen`.
2. **Customization**: Use the **CUSTOMIZE RULES** button on the secondary card to fine-tune handicap allowances or tie-break methods specifically for the match overlay.
3. **Pairings**: On the **Grouping Screen**, toggle on **Match Play Mode**.
4. **Interactive Setup**: Use the **Tap-to-Swap** feature on the tee group cards to quickly assign players to Side A and Side B of each match.
5. **Sync**: Matches are automatically synced to the event's match definitions upon saving the tee sheet.

## 7. Implementation Status

- [x] Data Models (`MatchplayComp`, `MatchplayRound`, etc.)
- [x] Handicap & Strokes Received Logic
- [x] Leaderboard Format Awareness
- [x] Secondary Game (Overlay) Toggle & Independent Customization
- [x] Interactive Match Pairing (Tap-to-Swap) on Grouping Screen
- [ ] Visual Bracket Tree UI
- [x] Layered Match Overlay in Scorecard Entry (via Derived Status)
