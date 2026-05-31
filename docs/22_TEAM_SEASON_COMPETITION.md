# Team Season Competition

A season-long team competition that runs in parallel with all normal individual events. Players are assigned to two teams at the start of the season. When an event has team play enabled, each player's individual score contributes to their team's aggregate total. The team with the highest cumulative aggregate at season end wins.

---

## Concept

- Everyone plays a normal Stableford or Medal event. The individual leaderboard and OOM are unaffected.
- If the event has team play enabled, each player's score also counts toward their team's aggregate for that event.
- A dedicated **Team Season Leaderboard** accumulates those event aggregates across the season.
- No player-vs-player pairings. No brackets. No draw. Just aggregate totals.

This is distinct from:
- **Match Play Overlay** — which pairs players 1v1.
- **Ryder Cup / Team Match Play** — which uses match results, not aggregate scores.

---

## Season-Level Team Setup

### Data model

`Season` gains a new field:

```dart
teamDivision: Map<String, String>?   // memberId → 'A' | 'B'
```

### Rules

- Admin sets this once at the start of the season, ideally before the first team event.
- The division is a **live source of truth** — recalculating the Team Leaderboard always uses the current map.
- **Reassignment**: if a member switches teams mid-season, all their historical event scores transfer to the new team. The leaderboard recalculates from scratch. This is by design — the admin controls timing.
- **Mid-season join**: assign the new member to a team. The calculator only processes events where they have a valid scorecard, so they naturally contribute only from the point they joined and played.
- **Guests and social members are excluded** from team scoring. They play normally and appear on individual leaderboards, but their scores are never aggregated into either team.

### Admin UI

A "Team Setup" section in the Season Form (or dedicated screen under Admin → Seasons):
- Two columns: Team A / Team B.
- Assign full members by drag or pick from member list.
- Soft guidance text: "Assign teams before the first team event for accurate standings."
- No hard lock — the admin can update at any time and recalculate will handle the rest.
- Show unassigned members (full members not yet in either team).

---

## Event-Level Toggle

`GolfEvent` (or the attached `Competition`) gains:

```dart
teamPlayEnabled: bool  // default false
```

When `true`:
- The system reads the season's `teamDivision`.
- Cross-references it with the event's playing registrations (excluding guests and social members).
- Derives each registered player's team assignment for display purposes (team badges in Field/Tee view).
- The Team Season Calculator processes this event's scores when recalculating.

The toggle lives in the Event Form, in the Competition Rules section. It is only available on Stableford and Medal (stroke) events — not on Match Play, Scramble, or Pairs formats.

---

## Score Aggregation & Balancing

### Per-event calculation

For each closed event where `teamPlayEnabled == true`:

1. Collect all registered playing members (exclude guests, social members).
2. Look up each member's team from the current season `teamDivision`. Skip unassigned members.
3. Split into Team A set and Team B set.
4. **Balance**: if team sizes differ (e.g. 12 vs 11), drop the **lowest scorer(s)** from the larger team until counts are equal.
5. Sum the remaining scores per team. This is that event's team contribution.

### Format rules

| Primary format | What counts |
|---|---|
| Stableford | Net Stableford points (higher is better) |
| Medal (stroke) | Net strokes (lower is better — invert for accumulation) |

The calculator must respect the format's direction when dropping the "lowest" score during balancing: for Stableford, drop the lowest points; for Medal, drop the highest net strokes (weakest performer).

---

## Team Season Leaderboard

### New leaderboard type

A new entry alongside OOM / Eclectic / Best Of / Marker Counter in the leaderboard registry.

### Display structure

**Header strip** — the accumulated season score:
```
TEAM A   247 pts          TEAM B   231 pts
         ▲ Leading by 16
```

**Event breakdown table** — one row per team-play event:

| Event | Date | Team A | Team B | Balance Applied |
|---|---|---|---|---|
| Monthly Stableford | 12 Apr | 112 pts | 98 pts | — |
| Spring Medal | 3 May | 135 pts | 133 pts | 1 player dropped |
| **Season Total** | | **247** | **231** | |

"Balance Applied" indicator shown when team sizes were unequal for that event.

### Placement

This leaderboard appears in the Season Leaderboards hub alongside the existing types. It does **not** appear inside the event's own leaderboard (individual event standings are untouched).

---

## Overlay Restriction

Team Match Play (Ryder Cup / `ryderCup`, `teamMatchPlay` subtypes) is **not permitted as an overlay** on a Stableford/Medal event. The reason: the Draw Manager writes team assignments to `publishSettings` on the competition document; for an overlay, it is unclear whether it writes to the primary or secondary competition document, creating a risk of team badges not loading in the Field view.

This restriction can be lifted once the Draw Manager's overlay-document targeting has been explicitly verified in UAT.

**Singles match play as an overlay remains permitted.**

---

## Implementation Phases

### Phase 1 — Data & Setup
- [ ] Add `teamDivision: Map<String, String>?` to `Season` model + Freezed rebuild
- [ ] Add `teamPlayEnabled: bool` to `GolfEvent` (or `Competition`)
- [ ] Season Form: Team Setup section (assign members to A/B)
- [ ] Event Form: team play toggle (visible on Stableford/Medal only)
- [ ] Team badge derivation in Field/Tee view: source from `season.teamDivision` when `teamPlayEnabled` (instead of `publishSettings['teamAssignments']`)

### Phase 2 — Calculator
- [ ] `TeamSeasonCalculator` — implements leaderboard calculator interface
- [ ] Per-event aggregation with guest/social exclusion
- [ ] Balancing logic (drop lowest from larger team, format-aware)
- [ ] Trigger recalculate on: season team division change, event close (when `teamPlayEnabled`)

### Phase 3 — Leaderboard View
- [ ] New `LeaderboardType.teamSeason` entry
- [ ] `TeamSeasonLeaderboardScreen`: header strip (accumulated totals) + event breakdown table
- [ ] Balance indicator per event row
- [ ] Integrate into Season Leaderboards hub

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Member reassigned mid-season | All their scores move to new team; full season recalculate runs |
| Member joins mid-season | Assigned to a team; contributes only from events they played |
| Unassigned member plays | Score excluded from team totals; counts only on individual leaderboard |
| Both teams equal size | No balancing needed; all scores count |
| Event has 0 eligible team players | Event contributes 0 to both teams |
| Guest plays in team event | Score excluded from team totals regardless of team division |
| Social member plays in team event | Score excluded from team totals |
| Season closed | Team leaderboard frozen alongside all other leaderboards |
