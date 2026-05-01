# Event Finalization & Vacancy Management

This document defines the automated workflow for managing tournament tee times, vacancies, and committee communications.

## 1. The "Lock-to-Verify" Workflow

The **Lock Grouping** toggle in the Control Tower (Admin Hub) acts as a **Quality Gate** rather than a simple status update.

### Pre-Lock Validation
When an admin attempts to toggle `isLocked` to **true**, the system performs the following checks:
1.  **Field Integrity**: Are there any "Confirmed" players currently in the **Squad Pool** (unassigned)?
2.  **Group Balance**: Are there any vacancies in the existing tee groups (Groups with < 4 players)?

### The Finalization Dialog
If a mismatch is found (Unassigned Players + Vacancies), the admin is presented with a **Review Dialog**:
-   **Alert**: "There are [X] vacant slots and [Y] unassigned players."
-   **Action**: "Auto-Fill & Lock" — The system automatically populates the first available vacancies with players from the pool and then locks the field.

---

## 2. Automated Vacancy Backfilling

Once the grouping is **Locked**, the system enters a "High-Priority Backfill" mode.

### Withdrawal Trigger
If a player withdraws from a **Locked** event:
1.  **Slot Vacancy**: Their name is removed from the `TeeGroup`, leaving a `null` or "Open" slot.
2.  **Waitlist Promotion**: The `RegistrationLogic` automatically promotes the top person from the **Waitlist** to "Confirmed".
3.  **Auto-Fill**: The system automatically "pulls" this newly confirmed player into the vacant slot in the `TeeGroup`.

---

## 3. Committee Communications

To ensure the society leadership is aware of high-stakes changes, the following notification triggers are implemented.

### Trigger Condition
A **Withdrawal Notification** is sent only if:
-   The player was part of a **Locked** grouping.
-   **OR** The withdrawal occurs within **[X] days** of the event date.

### Recipients
-   All members with the `committee` role.
-   Global administrators.

### Notification Content
-   **Subject**: Withdrawal Alert: [Event Name]
-   **Message**: "[Player Name] has withdrawn from Group [Group Number]. [Auto-Fill Name] has been automatically assigned to this slot."

---

## 4. User Notifications

-   **The Promoted Player**: Receives a notification: "You've been moved from the Waitlist to Group [Number] for [Event Name]!"
-   **The Inviting Member**: If a guest was promoted, the member who invited them is notified.

---

---

## 5. Post-Event Persistence & Results

When an event is marked as **Completed**, the system performs a final scoring pass via the `EventAnalysisEngine`.

### Tie-Break Label Persistence
To ensure long-term clarity on the Event Dashboard and Leaderboards:
1.  **Metric Calculation**: The engine calculates countback metrics (B9, B6, B3, B1) for all players.
2.  **Decisive Component**: If players are tied, the system identifies the specific metric that decided the rank (e.g., "B6: 11").
3.  **Persistence**: This "Winning Component" is saved as a `tieBreakLabel` within the event's `results` list.
4.  **Display**: The label is rendered beneath the player's total score in the "Top Results" card, providing persistent context for the podium finish.

## 6. Digital Scorecard Verification (Marker Handshake)

To ensure tournament integrity, a two-way digital sign-off system is enforced before final submission.

### The Dual-Tab Layout (SCORE | VERIFY)
"My Scorecard" is organized into a primary two-tab navigation system:
- **SCORE**: The active entry view where strokes and "Hole Stories" are recorded.
- **VERIFY**: The comprehensive audit view where scores are cross-referenced and signed off.

### The Verification Grid
The "Verify" tab provides a side-by-side comparison of:
- **Player Scores**: The self-recorded strokes from the player's own card.
- **Marker Scores**: The strokes recorded by the official marker for that player.
- **Conflict Highlighting**: Any discrepancies between the two rows are highlighted in red (Boxy Art Coral).

### Signature Handshake
Both the **Player** and the **Marker** must tap "Sign Off" within the Verify tab to finalize the card.
- **Locking**: Once both signatures are present, the card is visually "locked" for submission.
- **Invalidation**: Any subsequent change to a hole score or a "Story" tag (Penalty/Gimme) automatically clears both signatures, requiring a fresh review.

### Hole Story Audit
All non-numerical scoring attributes (Penalties, Gimmes, Pick Ups) are aggregated into a **Round Story Breakdown** within the Verification view, allowing for a line-by-line audit of the "story of the round" before sign-off.

---

> [!NOTE]
> This "Pro" workflow ensures that the committee maintains total control during drafting while the system handles the tedious "gap filling" once the field is live.
