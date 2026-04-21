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

- **Random**: Standard placement in the bracket, ensuring a fair and unbiased tournament start.

### The Draw Manager Workflow
Launched directly from an event, the manager (Design 4.x):
1. **Dual-Sync Registration**: Automatically pulls confirmed entrants and pairings. If an admin manually adds a member to the draw, the system automatically registers that member for the underlying GolfEvent.
2. **Draft Persistence**: Draft draws, round deadlines, and administrative notes are faithfully persisted and restored through the `matchPlayTournamentProvider`.
3. **High-Fidelity Aesthetics**: Uses a divider-free "Command Center" layout with Title Case typographic standards and state-aware primary action controls.
4. **Validates Counts**: Ensures the entrant count fits a standard bracket (8, 16, 32) or handles "Byes".
5. **Generates Matrix**: Builds the complete `MatchDefinition` list for the tournament lifecycle.
6. **Manual Swapping**: Committee members can manually swap opponents between matches in the **Draft** phase by tapping two players. Selection state is visually confirmed via primary-color borders and haptic feedback.
7. **Administrative Overrides (Live)**: Once published, committee members can manage uncompleted matches through the **MANAGE** toolkit. Tapping a live match provides options for **Walkovers**, **Withdrawals**, and **Manual Score Entry** (e.g., 3&2). Manual results are indicated with an amber status identifier and take precedence over automatic scorecard calculations.
8. **Shell Persistence**: The Draw Manager is integrated into the event administration hub using `hubPage` routing. This ensures that the event context and shell state (tabs, header) remain stable and persistent when navigating between the draw and other event tools.

## 5. Result States & Derivement

Matches track status using a standardized format derived centrally:
- **`2 UP`**: Leading by 2 holes.
- **`A/S`** (All Square): Match is tied.
- **`Dormie`**: Leading player is ahead by the same number of holes remaining.
- **`3 & 2`**: Match ended on the 16th hole with one player 3 up.

## 6. Automated Reminders

The Matchplay module features a robust **Automated Reminder System** designed to keep tournament progression on schedule.

- **Cadence**: Reminders are triggered exactly **5 days** before a round cutoff.
- **Logic**: The system audits all published tournaments, excluding completed matches and byes.
- **Participants**: Notifications are dispatched simultaneously to both players (or teams) involved in an uncompleted match.
- **Administrative Control**: While typically automated via Cloud Functions, committee members can manually trigger a reminder sync directly from the **Match Play Draw Manager** (Alarm icon). This performs an on-demand scan of the bracket for overdue or soon-due matches.

## 7. Implementation Status (Updated April 2026)

- [x] Data Models (`MatchPlayTournament`, `MatchDefinition`)
- [x] Handicap & Automated Strokes Logic
- [x] Leaderboard Format Awareness
- [x] Visual Bracket Tree UI (Design 4.x)
- [x] Match Play Draw Manager (Event-Bound)
- [x] Partner Handshake Registration Logic
- [x] Season Tournament Subtype (`matchPlaySeason`)
- [x] Streamlined Fair Draw Logic (Random only)
- [x] Automated 5-Day Pre-Deadline Reminders
- [x] Manual Opponent Swapping UI (Draft Phase)
- [x] Manual Pre-Deadline Reminder Pulse Trigger
- [x] Administrative Result Overrides (Walkovers/Manual Scores)
- [x] Withdrawal & Walkover Persistence Logic
