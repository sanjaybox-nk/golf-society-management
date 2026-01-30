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

---

## Status Calculation Logic

The system automatically calculates a participant's status based on the following rules (in order):

1.  **Manual Override**: If an Admin has set a specific status override (e.g., manually confirming a member who hasn't paid yet), this takes precedence over all other logic.
2.  **Explicit Confirmation**: If the user has paid and been marked `isConfirmed` in the database, they are **Confirmed**, provided there is capacity.
3.  **Event Open**: Use **Reserved** status.
4.  **Capacity Check**: If the event is full (Confirmed Count >= Capacity), the status becomes **Waitlist**.
5.  **Withdrawn**: If the user withdraws, they become **Withdrawn**.

### Guest Specific Rules
Guests have additional constraints to ensure fair access for members:
1.  **Held in Reserve**: Guests will *always* default to **Reserved** status while the event registration is still **Open**, even if there is plenty of capacity. This guarantees that spots are kept available for members until the registration deadline passes.
2.  **Independent Status**: A Guest's status is independent of their Host Member. If a Member is manually confirmed, the Guest remains **Reserved** until the deadline or until specifically confirmed by an Admin.
3.  **Deadline Allocation**: Once the event hits its Registration Deadline (Event Closed), guests will be automatically allocated to any remaining spots based on FCFS.

---

## Member App UI Behavior

The Registration Card dynamically adjusts to the event's state and the user's status:

| Scene | Header Text | Button Title | State |
| :--- | :--- | :--- | :--- |
| **New Member / Space Available** | "Secure your spot" | "Register Now" | Active |
| **New Member / Event Full** | "Registration Closed" | "Event Full" | Disabled |
| **Already Registered** | *Shows Registration Status* | "Edit My Registration" | Active |
| **Past Deadline** | "Registration Closed" | "Registration closed" | Disabled |

### Data Resilience
- **Event Edits**: The system is designed to preserve all participant registrations even if an admin modifies the event's date, time, cost, or description.
- **FCFS Integrity**: The original `registeredAt` timestamp is preserved when a member edits their registration, maintaining their position in the queue.

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
