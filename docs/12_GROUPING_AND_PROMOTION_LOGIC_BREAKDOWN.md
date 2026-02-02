# Logic Breakdown: Registration & Grouping

This document outlines the step-by-step logic used by the system to determine player status and generate tee sheets. **Edit this file to suggest changes to the logic.**

---

## Part 1: Player Status Calculation
This logic runs for every registered person to determine if they are **Confirmed**, **Reserved**, or **Waitlisted**.

1.  **Check for Manual Override**:
    *   If an Admin has manually set a status (e.g., "Confirmed", "Withdrawn"), use that status immediately.
    *   Stop here for this player.

2.  **Check for Manual Confirmation**:
    *   If the player has been manually "Ticked" (Confirmed) by an Admin OR has Paid:
        *   If the event total confirmed count is **less than** capacity: Status = **CONFIRMED**.
        *   If the event is **Full**: Status = **WAITLIST**.
    *   Stop here for this player.

3.  **Check for Post-Deadline Guest Promotion**:
    *   If the **Registration Deadline** has passed:
        *   If the player is a **Guest**:
            *   If there is still room in the event (Total Confirmed < Capacity): Status = **CONFIRMED**.
            *   Otherwise: Status = **WAITLIST**.
        *   If the player is a **Member**:
            *   Remain as **RESERVED** (Wait for manual admin confirmation).
    *   Stop here for this player.

4.  **Default Handling (Event Still Open & No Action)**:
    *   If the total confirmed count already reaches capacity: Status = **WAITLIST**.
    *   Otherwise: Status = **RESERVED**.

---

## Part 2: Generating the Tee Sheet
This logic runs when the Admin clicks "Auto-Generate Grouping".

### Phase A: Field Selection
1.  **Initialize Participant List**:
    *   Scan the registration list.
    *   **Filter**: Only include players whose calculated status (from Part 1) is **CONFIRMED**.
    *   *Result*: Any "Reserved" or "Waitlisted" players are ignored.

### Phase B: Slot Formation
2.  **Binding Pairs**:
    *   Look for guests. 
    *   Bind every Guest to their Host Member into a **single "Locked Slot"** of 2 players.
    *   Treat single members as a "Slot" of 1 player.
    *   *Result*: A list of slots (size 1 or size 2) that can't be split.

### Phase C: Group Allocation (Greedy)
3.  **Sort Slots**: Sort the slots by size (Pairs first).
4.  **Fill Groups**:
    *   Place slots into Group 1 until it has 4 players.
    *   Move to Group 2, etc.
    *   **3-Ball Logic**: If the total player count is not a multiple of 4, the system calculates the number of 3-balls needed and places them at the **start** of the day for better pace of play.

### Phase D: The Optimization Engine (500 iterations)
5.  **Calculate System Cost**: The engine looks at the whole tee sheet and calculates a "Cost" (Penalty). It then tries swapping players between groups to reduce this penalty.

6.  **Penalty 1: Pairing Variety**:
    *   Look at every player in a group. Have they played together this season?
    *   **Award Penalty points** for every time two people have shared a group in the past.
    *   *Goal*: Swap them into different groups to maximize variety.

7.  **Penalty 2: Handicap Balance**:
    *   Calculate the average handicap for the whole field.
    *   Calculate the average handicap for each specific group.
    *   **Award Penalty points** for groups that are significantly higher or lower than the field average.
    *   *Goal*: Ensure every group has a similar mix of ability (Competitive Balance).

8.  **Penalty 3: Buggy Efficiency**:
    *   Check how many players in a group requested a buggy.
    *   **Award Penalty points** for groups with a single buggy user (wasted 2nd seat).
    *   **Reduce Penalty** for groups with exactly 2 buggy users (perfect share).
    *   *Goal*: Pair buggy users together.

### Phase E: Final Cleanup
9.  **Assign Captains**: Select one member in each group to be Captain.
10. **Sync Resources**: Recalculate buggy status based on available buggy count vs. final group placement.

---

## Part 3: Late-Stage Management
If the Admin makes changes after the initial generation:

1.  **Squad Pool**: Any player who is newly "Confirmed" but not in a group appears here.
2.  **Manual Drag & Drop**: Admin can move a player from the Squad Pool into an **Empty Slot** or swap them with an existing player.
3.  **Withdrawal**: If a player is withdrawn, the system removes them from the group, creating an **Empty Slot** that the Admin can fill from the Squad Pool.
