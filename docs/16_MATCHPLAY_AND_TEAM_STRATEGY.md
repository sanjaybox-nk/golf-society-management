# Match Play & Team Progression Architecture

## 1. Three Match Play Models

The system supports three distinct match play models. Each has different infrastructure, registration requirements, and event relationships.

---

### Model 1 — Ryder Cup (Team Match Play)

Blue vs Red teams. Points accumulate across matches to determine the winning team.

- **Format**: Multiple sessions — singles, foursomes, fourball. Each session contributes points to the team total.
- **Scope**: Single day OR multi-day (weekend away). Multi-day design is parked — not yet designed.
- **Competition subtype**: `CompetitionSubtype.ryderCup` already exists.
- **Draw**: Each session generates a draw using the standard 2-ball draw algorithm. "Generate Draw" replaces "Generate Groups" on the admin grouping card when match play is detected.
- **UAT sequencing**: Test singles-only first. Add foursomes and fourball sessions only after those pairs formats have been individually UAT'd.

---

### Model 2 — Season-Long Individual Knockout

A dedicated tournament running across the season, independent of regular event registration.

- **Infrastructure**: `MatchPlayTournament` Firestore collection, `MatchPlayDrawManagerScreen` — largely built.
- **Draw modes**:
  - **Full-field**: Single bracket across all entrants.
  - **Division-based**: Separate brackets per handicap band. Bands are defined by `MemberGroupConfig` (handicap split type). Each division produces its own bracket.
- **Match scheduling**: Players arrange matches at mutual convenience. No event registration involved — results entered directly in the tournament screen.
- **Round management**: Admin closes rounds manually, bracket advances to the next round.
- **Byes**: Odd fields at draw time give one player (top seed by default) a scheduled bye. `MatchDefinition` is created with one side as `"BYE"`. Bye player auto-progresses; shown in bracket display.

---

### Model 3 — Overlay Progression (not yet built)

Regular Stableford or Medal events each host one round of a knockout via a match play overlay. Match result is captured within the event's scoring alongside the standard format result.

**Key components required:**

- **Parent/Child Event Tree**: Round 1 event → Round 2 event → … Final. Linked via `previousMatchPlayEventId` on `GolfEvent` (field not yet added).
- **Next Round Generator**: Admin tool that reads winners from the previous event and pre-populates the next event's draw. Required before Stage 3 UAT can begin (or a manual workaround is needed for initial testing).
- **No-show byes**: When the Next Round Generator creates the next round's event, it cross-references qualified players (previous round winners) against registered players:
  - Qualified + registered → match plays normally.
  - Qualified + not registered by deadline → opponent gets a bye, they are eliminated.
  - Qualified + not registered, deadline not yet passed → amber flag shown to admin.
  - After deadline closes → auto-assign bye.

---

## 2. Grouping Architecture

### Standard Events (Stableford / Medal / Max Score)

Generating groups arranges players into tee time slots (3- or 4-balls). This is purely logistical — no competitive consequence.

- **Algorithm options**: balanced, random, or by handicap.
- **Output**: `TeeGroup` objects written to Firestore.
- **UI label**: "Generate Groups".

### Match Play Events (all models)

The same balancing algorithm is used, but output is forced to 2-balls and `MatchDefinition` objects are written alongside `TeeGroup` objects.

- **UI label**: "Generate Draw" — label changes automatically when `isMatchPlay` is detected from competition rules. No new toggle field is needed.
- **Match Play Draw screen**: Single point of truth for brackets and tee order.
- **Field & Tee Times screen**: Read-only tee sheet derived from the draw when matches exist. The "Generate Groups" card is hidden.

### Overlay Events

Overlay IS match play. Groups are 2-ball, same draw process as above. The scoring engine outputs both a match result (holes up/down) and a Stableford or stroke score from a single scorecard per player.

---

## 3. Overlay Architecture (Event-Level)

The match play overlay is attached at the event level, not inside individual game builder controls.

- `buildOverlaySection()` is removed from ALL game builder controls (Stableford, Stroke, Max Score, Scramble, Pairs).
- "Add Match Play Overlay" button lives on the event configuration screen and routes directly to the match play season gallery — skips the format picker entirely.
- "Remove Overlay" requires a confirmation dialog.
- When the event status is `inPlay` or `completed`: both Customize and Remove buttons are hidden on primary and secondary competition cards.

---

## 4. Tie Break Rules (Finalised)

| Format | Tie break method |
|---|---|
| Stableford | Countback only (back 9 → 6 → 3 → 1). No playoff option. |
| Stroke Play (Medal) | Countback OR playoff — admin chooses at competition setup. |
| Max Score | Countback only. |
| Match Play | Always playoff. Hardcoded, no admin choice. |
| Pairs | Countback only (playoff already excluded). |

---

## 5. Registration & Byes

### Odd Numbers at Draw Time (Model 2 and Model 3)

When an odd number of players reaches draw time, one player receives a scheduled bye.

- **Assignment**: Top seed receives the bye by default.
- **Data**: A `MatchDefinition` is written with one side set to the `"BYE"` placeholder string.
- **Progression**: Bye player auto-advances to the next round. The bracket UI displays the bye state clearly.

### No-Show Byes (Model 3 Only — Next Round Generator)

Handled by the Next Round Generator when constructing each subsequent round's event. See §1 Model 3 above for state transitions.

---

## 6. Competition Type Selector

The admin competition type selector reflects the current architecture:

- "SEASON TOURNAMENTS" section renamed to "MATCH PLAY".
- "Season Match Play" tile renamed to "Match Play" with subtitle: "Knockout brackets. Single event or season-long."

---

## 7. UAT Plan (4 Stages — Current Cycle)

### Stage 1 — Grouping

Validate the grouping and tee time workflow before any match play logic is introduced.

- **Seed**: Registration scaffold — event + 16 confirmed members, no game type attached.
- **Seeder**: Single generic "Registration Scaffold" seeder with parameters: number of players, optional game type. Replaces the former Match Play Stage 1/2 seeders.
- **Tests**:
  - Admin manually attaches game type (Stableford or Medal).
  - Generate groups using each algorithm (balanced, random, by handicap).
  - Publish tee times to members.
  - Verify Field & Tee Times screen displays correctly.

### Stage 2 — Single-Day Match Play, then Ryder Cup

Test the 2-ball draw, hole-by-hole match scoring, and bracket display.

- **Seed**: Same registration scaffold (16 confirmed members). Admin attaches match play format.
- **Tests**:
  - "Generate Draw" produces 2-ball pairings and `MatchDefinition` objects.
  - Hole-by-hole scoring produces correct match status (holes up/down/all square).
  - Match result is displayed on the bracket.
  - Bracket advances correctly after round closure.
  - Byes handled correctly on odd-numbered fields.
- **Ryder Cup**: Test singles only first. Foursomes and fourball sessions added to Ryder Cup UAT only after those formats have been individually UAT'd as standalone pairs formats.

### Stage 3 — Overlay Progression

Test the overlay scoring engine and multi-event progression.

- **Prerequisite**: Next Round Generator must be built, or a manual admin workaround must be confirmed acceptable for initial UAT.
- **Setup**: Stableford or Medal event with a match play overlay attached.
- **Tests**:
  - Overlay scoring produces both a Stableford/stroke result and a match result from a single scorecard.
  - Both results visible on the event leaderboard.
  - Next Round Generator reads winners from Round 1 event and pre-populates Round 2 draw.
  - No-show bye states handled correctly.
  - Progress winners through events to the final.

### Stage 4 — Season-Long Knockout

Test the dedicated `MatchPlayTournament` infrastructure end-to-end.

- **Tests**:
  - Full-field draw produces correct single bracket.
  - Division-based draw produces separate brackets per handicap band.
  - Entrants added and removed correctly before draw is generated.
  - Admin closes rounds; bracket advances.
  - Results entered directly in tournament screen (no event registration involved).

### Parked for Next Cycle

- Foursomes and Fourball as standalone formats (must UAT independently before including in Ryder Cup).
- Multi-day events (Ryder Cup weekend away).

---

## 8. Seeder Strategy

Replace the separate Match Play Stage 1 and Stage 2 seeders with a single generic **Registration Scaffold** seeder.

- **Parameters**: number of players, optional game type.
- **Coverage**: One seed serves both Stage 1 (grouping UAT) and Stage 2 (match play draw UAT).
- **Location**: Admin Operations screen.

---

*Status: Active Architecture Document*
*Last Updated: May 2026*
