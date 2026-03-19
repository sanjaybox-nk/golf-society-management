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

> [!NOTE]
> This "Pro" workflow ensures that the committee maintains total control during drafting while the system handles the tedious "gap filling" once the field is live.
