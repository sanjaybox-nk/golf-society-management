# Matchplay & Team Progression Strategy

This document outlines the architectural vision for implementing Matchplay and Team-based competitions within the Golf Society Management system, with a specific focus on **minimizing UI complexity** and leveraging existing "Event" infrastructure.

## 1. Core Philosophy: Events as Containers
Matchplay and Team games should not be treated as separate "modules" with their own navigation. Instead, they are **behaviors** or **overlays** applied to the standard `Event` model.

### Multi-Game "Overlay" Events
An event can host multiple competitions simultaneously (e.g., a Stableford Society Day + a Knockout Matchplay round).
- **Single Source of Truth**: One scorecard per player per day.
- **Derived Results**: Matchplay results (e.g., "3 & 2") are calculated from the same strokes used for the Stableford leaderboard.
- **UI Exposure**: Add a "Matches" tab to the existing Event screen only when matchplay data is attached.

## 2. Tournament Progression (Series)
To handle winners advancing through rounds, we use a **Parent/Child Event Tree**.

| Stage | Logic |
| :--- | :--- |
| **Round 1** | Random pairing strategy in the `GroupingService`. |
| **Round 2+** | Bracket-based grouping (Winner of Match A plays Winner of Match B). |
| **Side Games** | Casual events (non-society days) that use the same registration/scoring flow but are hidden from the primary calendar. |

## 3. Team Dynamics
Team progression follows the same pattern as individual Matchplay.
- **Team Units**: The "Winner" is a Team/Pair entity.
- **Groupings**: Teams move together as a single unit between events in a series.
- **Aggregation**: Scores are automatically consolidated (Best Ball, Scramble, etc.) based on the team mode.

## 4. Implementation Checklist (Future)
- [ ] **Multi-Comp Event Support**: Update `GolfEvent` model to allow a list of `Competition` rules.
- [ ] **Matchplay Leaderboard Tab**: Implement the "VS" result layout on the Event screen.
- [ ] **"Next Round" Generator**: Admin tool to auto-create a new Event for the winners of a knockout match.
- [ ] **Grouping Mode Extensions**: Add `Bracket` and `Team` strategies to the `GroupingService`.

---
*Status: Planning / Vision Document*
*Last Updated: February 2026*
