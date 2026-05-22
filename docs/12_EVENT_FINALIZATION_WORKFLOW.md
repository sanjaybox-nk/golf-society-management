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

## 5. Event P&L (Finance) Calculation Rules

The **Manage** tab of the Event Admin hub shows a live P&L view. Key calculation rules (`event_admin_manage_screen.dart`):

| Line | Source |
|---|---|
| **Green Fees cost** | `societyGreenFee × paidGolferCount` |
| **Catering cost** | Uses society-level catering costs (`societyCatering*Cost`), NOT the per-member meal charges |
| **Extra costs** | Named income line items (added individually) |
| **Operational Expenses** | Merged from `event.expenses` + Finance Hub ledger Expenditure entries |

**Removed management sections**: The EXPENSES card and PRIZES & AWARDS card have been removed from the Manage tab. New expenses are created via the Finance Hub ledger; prize management is done in the event form.

---

## 5a. Event Form Design Standards

All form section action buttons (ADD COST, ADD AWARD, ADD FACILITY, etc.) follow these rules:
- Placed **outside** cards, with `cardToCard` spacing above.
- `isTinted: true` on the button.
- Meal options rendered in a plain `Column` (no dividers between options).
- **Buggy** card is separate from the Playing Costs card.

---

## 5c. Event Form: "Non-Season Event" Label

The "Invitational" toggle in `event_logistics_section.dart` has been renamed to **"Non-Season Event"**. When enabled, the event is excluded from season leaderboard calculations. The underlying model field and Firestore key are unchanged.

---

## 6. Automatic Season Leaderboard Recalculation on Close

When an admin closes an event via the **Event Admin Controls** screen (`event_admin_controls_screen.dart`), the `_closeEvent()` handler automatically calls `LeaderboardInvokerService.recalculateAll()` after persisting the closed state. This ensures all season standings (OOM, Eclectic, Best of Series, Marker Counters) are immediately up to date without requiring a separate manual recalculate action.

> [!NOTE]
> `recalculateAll()` runs asynchronously in the background. The admin UI does not block on its completion. If a leaderboard calculation fails it is logged but does not prevent the event close from succeeding.

---

## 7. Post-Event Persistence & Results

When an event is marked as **Completed**, the system performs a final scoring pass via the `EventAnalysisEngine`.

### Tie-Break Label Persistence
To ensure long-term clarity on the Event Dashboard and Leaderboards:
1.  **Metric Calculation**: The engine calculates countback metrics (B9, B6, B3, B1) for all players.
2.  **Decisive Component**: If players are tied, the system identifies the specific metric that decided the rank (e.g., "B6: 11").
3.  **Persistence**: This "Winning Component" is saved as a `tieBreakLabel` within the event's `results` list.
4.  **Display**: The label is rendered beneath the player's total score in the "Top Results" card, providing persistent context for the podium finish.

## 8. Digital Scorecard Verification (Marker Handshake)

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
- **Proactive Hub Alerts**: The main Event Hub display features a dynamic "Conflict" badge if discrepancies are detected, serving as a primary visual cue for the user to resolve issues in the Verify tab.

### Signature Handshake
Both the **Player** and the **Marker** must tap "Sign Off" within the Verify tab to finalize the card.
- **Locking**: Once both signatures are present, the card is visually "locked" for submission.
- **Invalidation**: Any subsequent change to a hole score or a "Story" tag (Penalty/Gimme) automatically clears both signatures, requiring a fresh review.

### Guest Proxy Flow

When a guest does not have a device, a society member enters proxy scores on their behalf via the **Scores hub**.

1. **3-step proxy card**: Displayed in the Scores hub. Step 1 — select guest player. Step 2 — confirm marker. Step 3 — enter scores.
2. **Proxy record entry**: Scores are submitted via the Scoring tab, attributed to the guest's player record.
3. **Hole-18 auto-confirm**: When the proxy card's final hole (18) is entered, the card auto-confirms without requiring a separate submit action.

### Rendering Stability & Integrity
To maintain a professional, crash-free interface during high-stakes sign-offs, the verification UI utilizes a **Hardened Layout Pattern**:
- **Persistent Card Context**: The interface is anchored within a stable `BoxyArtCard` wrapper to prevent rendering tree reconciliation errors during tab switches.
- **Identity Enforcement**: A `ValueKey` is applied to the content tree to ensure Flutter explicitly manages the transition between Entry and Verification states without state leakage.

---

> [!NOTE]
> This "Pro" workflow ensures that the committee maintains total control during drafting while the system handles the tedious "gap filling" once the field is live.
