# Event Registration Logic

The registration system in Golf Society Management follows a **Fair Play, Confirmation-Driven** model. It ensures that members have priority, waitlists are accurate, and metrics only reflect committed participants.

## Core Principles

1.  **Members First**: Members always take priority over guests in the registration queue.
2.  **FCFS (First-Come, First-Served)**: Within their respective tiers (Members vs. Guests), participants are prioritized by the time they registered.
3.  **Confirmation-Driven Availability**: A participant is only considered "Playing" once they are **Confirmed** (usually after payment).
4.  **Waitlist Accuracy**: "Waitlist" status is only triggered when the event's capacity is fully reached by *Confirmed* players.

---

## Registration Statuses

| Status | Color | Description |
| :--- | :--- | :--- |
| **Confirmed** | Green | The player is confirmed and has a guaranteed spot in the event. |
| **Reserved** | Amber | The default status for new registrants. They are in the "active" queue but not yet confirmed. |
| **Waitlist** | Red | Triggered when the confirmed player count meets the event's max capacity. |
| **Dinner Only**| Blue | The member is attending the dinner portion only, not playing golf. |
| **Withdrawn** | Grey | The participant has cancelled their registration. |
| **Social Event** | N/A | For non-golf events, statuses focus on attendance and payment rather than tee-off eligibility. |

---

## Status Calculation Logic

The system automatically calculates a participant's status based on the following rules (in order):

1.  **Manual Override**: If an Admin has set a specific status override (e.g., manually confirming a member who hasn't paid yet), this takes precedence over all other logic.
2.  **Explicit Confirmation**: If the user has paid and been marked `isConfirmed` in the database, they are **Confirmed**, provided there is capacity.
3.  **Event Open**: Use **Reserved** status.
4.  **Capacity Check**: If the event is full (Confirmed Count >= Capacity), the status becomes **Waitlist**.
5.  **Withdrawn**: If the user withdraws, they become **Withdrawn**.
6.  **Social Events**: For Social events, the logic considers anyone registered and confirmed as "Attending" without the need for golf-specific slots.

### Strict Promotion Rules
To ensure groupings are accurate and stable:
1.  **Member Auto-Promotion**: Unconfirmed members remain in **Reserved** status until the **Registration Deadline passes**. Once the deadline is reached, they are automatically promoted to **Confirmed** (if space available).
2.  **Guest Auto-Promotion**: Guests remain in **Reserved** status until the **Registration Deadline passes**. Once the deadline is reached, they are automatically promoted to **Confirmed** (if space available after members have been processed).
3.  **Manual Promotion**: Admins can use **Status Overrides** to promote a member or guest to **Confirmed** at any time.

Once a player is **Confirmed**, they are eligible for inclusion in the Tee Sheet.

---

## Member App UI Behavior

The Registration Card dynamically adjusts to the event's state and the user's status:

| Scene | Header Text | Button Title | State |
| :--- | :--- | :--- | :--- |
| **New Member / Space Available** | "Secure your spot" | "Register Now" | Active |
| **New Member / Event Full** | "Registration closed" | "Event full" | Disabled |
| **Already Registered** | *Shows registration status* | "Edit my registration" | Active |
| **Past Deadline (Registered)** | "Registration closed" | "Edit registration" (Disabled) | Read-Only |
| **Draft / Cancelled** | **Hidden** | - | Hidden |
| **Past Deadline (Not Reg)** | **Hidden** | - | Hidden |
| **In-play / Completed** | **Hidden** | - | Hidden |

### Dynamic Lifecycle & Status Visibility
To prioritize transparency and active competition:
- **Automatic Auto-Hide (Non-registrants)**: The registration card is entirely hidden from members who haven't registered once the registration deadline passes.
- **Global Suppression (Live/Completed)**: Once an event is marked as `InPlay` or `Completed`, the registration card is hidden for all users.
- **Cancelled/Draft Suppression**: Registration is automatically suppressed for any event not in a `Published` or `Live` state.
- **Cancelled Awareness**: For events in the `Cancelled` state, a high-impact red banner and status badge are displayed in the Event Details screen to provide immediate administrative feedback to members.

### Data Resilience
- **Event Edits**: The system is designed to preserve all participant registrations even if an admin modifies the event's date, time, cost, or description.
- **FCFS Integrity**: The original `registeredAt` timestamp is preserved when a member edits their registration, maintaining their position in the queue.

### Guest ID Normalization
To ensure consistent resolution across scoring and registration:
- **ID Format**: All guest entries must use the `GUEST_` prefix (e.g., `GUEST_123`).
- **Resolution**: Scoring views and the `markerSelectionProvider` use this prefix to distinguish between society members and one-off guest entries, ensuring that tee-specific Pars and SIs are resolved correctly even without a member profile.

---

## Metrics & Reporting

The Admin Dashboard provides real-time metrics. Here is how they are calculated:

### 1. Playing
The large number represents **Confirmed Members Only**.
*   **Withdrawn Bracket**: Use format `Total (Withdrawn)`. e.g., `13 (1)`.
    *   The value in brackets represents withdrawn participants who *would have been confirmed* had they not withdrawn. It simulates the queue logic on the full list of registrants to determine if the withdrawn user held a valid spot. This helps track "lost" confirmed players.

### 2. Guests
A simple count of distinct guest registrations.

### 3. Reserve
Count of all participants (Members + Guests) currently in the **Reserved** state (neither confirmed nor waitlisted).

### 4. Waitlist
Count of participants who cannot be confirmed because the event is at capacity.

### 5. Financials
Sum of payments received vs. potential income from all registrations (including projected meal costs).

---

## History Logging

The system maintains a detailed audit trail of all registration movements.
*   **Admin Actions**: When an admin changes a status (e.g., Reserve -> Confirm), toggles a buggy, or adds a guest, a log entry is created: `Timestamp | Actor: Admin | Action: Status Update | Description: Changed status to Confirmed`.
*   **Member Actions**: When a member registers or updates their details via the app, it is logged: `Timestamp | Actor: [Member Name] | Action: Updated Details`.

This history is stored with the event registration record and can be used for reporting on member engagement and registration patterns over the season.
