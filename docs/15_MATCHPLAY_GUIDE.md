# Matchplay Module Technical Guide

The Matchplay module introduces head-to-head competitive logic to the society. It supports standalone knockout tournaments, "layered" matches during regular events, and structured **Season Tournaments**.

## 1. Core Architecture

The system uses specialized models and services isolated within the `matchplay` feature module:

- **`MatchPlayTournament`**: The primary container for a tournament lifecycle (Seeds, Entrants, Draws, Divisions).
- **`MatchPlayEntrant`**: Represents a competing unit (Singles player or a Pair). 
- **`MatchDefinition`**: Unified model for individual match contests, supporting automated strokes and derived status.
- **`MatchPlayEntrantService`**: Logic for mapping event registrations or leaderboards into tournament entrants.

## 2. Competitive Modes

### Standalone / Layered Knockouts
Matches can be played independently or as an overlay on a regular society event.
- **Derived Status**: Real-time calculation of "Holes Up" using the `MatchPlayCalculator`. Parity is maintained across all views (Leaderboard, Scorecard, Grouping).

### Season Tournaments (`matchPlaySeason`)
Structured competitions typically spanning multiple events or months.
- **Knockout Bracket**: Standard single-elimination tournament.
- **Divisions (Round Robin)**: Players are grouped into divisions, playing every other member before advancing to a final knockout stage.

## 3. Registration & Partner Handshaking

When a "Pairs" Match Play event is published, the registration flow undergoes a specialized transformation:

### The Handshake Workflow
1. **Selection**: A member selects their partner from the society roster during registration.
2. **Persistence**: The registration record stores `partnerId` and `partnerName`.
3. **Validation**: The system ensures a "handshake" consistency (e.g., if Player A picks Player B, Player B is automatically registered as Player A's partner).

## 4. Seeding & Draw Management

The **Match Play Draw Manager** (Design 4.x) is the administrative hub for bracket generation.

### Seeding Logic
- **Random**: Arbitrary placement in the bracket.
- **Seeded**: Positions assigned based on current WHS Handicap Index.
- **Merit (Ranking)**: Positions assigned based on the current Order of Merit (OOM) standings.

### The Draw Manager Workflow
Launched directly from an event, the manager:
1. **Syncs Registrations**: Automatically pulls confirmed entrants and pairings.
2. **Validates Counts**: Ensures the entrant count fits a standard bracket (8, 16, 32) or handles "Byes".
3. **Generates Matrix**: Builds the complete `MatchDefinition` list for the tournament lifecycle.

## 5. Result States & Derivement

Matches track status using a standardized format derived centrally:
- **`2 UP`**: Leading by 2 holes.
- **`A/S`** (All Square): Match is tied.
- **`Dormie`**: Leading player is ahead by the same number of holes remaining.
- **`3 & 2`**: Match ended on the 16th hole with one player 3 up.

## 6. Implementation Status (Updated April 2026)

- [x] Data Models (`MatchPlayTournament`, `MatchDefinition`)
- [x] Handicap & Automated Strokes Logic
- [x] Leaderboard Format Awareness
- [x] Visual Bracket Tree UI (Design 4.x)
- [x] Match Play Draw Manager (Event-Bound)
- [x] Partner Handshake Registration Logic
- [x] Season Tournament Subtype (`matchPlaySeason`)
- [x] Seeding Logic (Random, Seeded, Merit)
