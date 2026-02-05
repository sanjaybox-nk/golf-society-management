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
| **Max Score** | None | Stroke play with a cap per hole (e.g., Net Double Bogey). |
| **Match Play** | None | Hole-by-hole competition (1UP, Half, etc.). |
| **Scramble** | Texas, Florida | Team-based "best ball" scramble. |
| **Pairs** | Fourball, Foursomes | Partner-based formats. |

### Handicap & Allowances
-   **Handicap Mode**: `WHS` (World Handicap System), `Local`, or `None`.
-   **Allowance**: Percentage of course handicap (e.g., 95% for Stableford).
-   **Handicap Cap**: Maximum allowed handicap for the competition.
-   **Course Allowance**: Whether to apply the Course Rating/Slope adjustment.

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

## 4. UI Flow

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

## 5. Rule Visualization (Game Card)

The `EventFormScreen` uses a rich, badge-based visualization to summarize the active game rules at a glance.

### Visual Components
- **Identity Badge**: [STABLEFORD] or [TEXAS SCRAMBLE] – Always shown in bold to identify the base format.
- **Scoring Type**: [GROSS] (Red) or [NET] (Teal).
- **Allowance**: [XX% HCP] or [100% DIFF].
- **Mode**: [SINGLES], [PAIRS], or [TEAMS].
- **Specifics**: Only shown if non-default (e.g., [4 DRIVES], [CAP: 10], [SINGLE BEST]).

## 6. Technical Architecture
-   **Repository**: `CompetitionsRepository` manages persistence in Firestore.
-   **Models**: `Competition` (main entity) and `CompetitionRules` (configuration).
-   **Scaffolding**: The builder screens use a `BaseCompetitionControl` pattern to ensure a consistent UX across different game formats.
-   **Cache Handling**: Uses `ref.invalidate(competitionDetailProvider(id))` to force UI refreshes after deep-link edits.
