# Tee Sheet Grouping Logic

The grouping system automatically generates balanced and varied tee sheets for society events. It aims to maximize player enjoyment by ensuring variety in pairings and balancing playing ability (Handicap).

## Generation Workflow

### 1. Participant Selection
To ensure field stability, the grouping service ONLY includes participants with **RegistrationStatus.confirmed**. 

- **Reserved** (unconfirmed) members and guests are ignored during the initial generation.
- This ensures that only players who have paid or been manually vetted by the Admin are assigned tee times.

### 2. Locked Pairs (Guests)
To ensure a positive guest experience, **Guests are always locked to their host member**. The algorithm treats them as a single "slot" of 2 players that cannot be split during the initial distribution or optimization passes.

### 3. Group Size Calculation
The system favors **4-balls** but supports **3-balls** when the total player count requires it. 
- The algorithm calculates the combination of 3 and 4 player groups that uses all players while maximizing 4-balls.
- **3-balls are placed at the front** of the tee sheet to maintain a good pace of play.

### 4. Greedy Distribution
Initial groups are filled using a greedy approach:
- Slots (individuals or host-guest pairs) are sorted by size.
- Slots are placed into the first available group with enough capacity.

---

## The Optimization Engine

Once the initial groups are filled, the system runs a **Greedy Optimization Pass** (500 iterations) to refine the pairings.

### The Cost Function
The optimizer evaluates swaps between groups using a "Cost Function" that considers:

1.  **Pairing Variety (Primary Weight)**:
    - The system scans historical events in the current season.
    - It penalizes pairings of members who have played together frequently.
    - Swaps that separate "frequent flyers" are favored.

2.  **Handicap Balance (Secondary Weight)**:
    - The system calculates the total handicap of each group.
    - It aims to minimize the handicap difference between groups to ensure competitive balance across the field.

### 5. Buggy Integration & Resource Constraints
The grouping system automatically manages golf buggy availability:
- **Available Capacity**: Total Buggy Seats = `Available Buggies * 2`.
- **Priority Queue**: Buggy allocation follows the **Members First** principle. If there are more requests than seats, guests are moved to the buggy waitlist first.
- **Pairing Strategy**: The UI attempts to pair buggy users within the same tee group to maximize buggy efficiency. If a group has an odd number of buggy users (e.g., 3), the system identifies the "shared" buggy status.

### 6. Buggy Co-location Optimization
The optimization engine includes a weighted factor for **Buggy Efficiency**:
- **Goal**: Pair confirmed buggy users together in the same group (2 users sharing 1 buggy).
- **Penalty**: Groups with a single buggy user (or an odd number of buggy users) incur a "Buggy Efficiency Penalty" in the cost function.
- **Effect**: This drives the algorithm to swap buggy users into the same groups.
- **Solos**: If the total number of confirmed buggy users is **odd**, the system accepts that exactly one group will have a solo buggy rider.

---

### Swapping Rules
- **Non-Movable Players**: Hosts with guests and the guests themselves are "locked" and cannot be swapped between groups.
- **Buggy Locking**: The system tries to keep members who *must* have a buggy in groups where they can be paired, though they remain movable if the resource count allows it.

---

After optimization, the system performs a final pass to:
- **Assign Captains**: Each group is assigned a Captain (prioritizing members).
- **Synchronize Buggy Status**: Every player's `buggyStatus` is recalculated based on the final group composition and the global available capacity.
- **Team Scoring (Best X)**: In Scoring Mode, the grouping card automatically calculates the "Team Total" based on the `teamBestXCount` defined in the competition rules. The top X points/scores for the group are summed dynamically.
- **Winner Indicators**: The top-performing group(s) in each flight (or overall) are highlighted with a **Trophy Icon** on the grouping card.

---

## 7. Squad Pool & Late Changes
The grouping system is dynamic. If the field changes after groupings are generated (due to late confirmations or withdrawals), the Admin can manage the field via the **Squad Pool**:

- **Unassigned Players**: Players promoted to **Confirmed** status (automatically after the deadline or manually) who are not in a group will appear in the **Squad Pool** at the top of the grouping screen.
- **Manual Assignment (Drag & Drop)**: Admins can drag players from the Squad Pool into any group with an **Empty Slot**.
- **Swapping**: Players can be swapped between groups, or moved from a group back to the pool (by clicking "Remove").
- **Late Withdrawals**: Admins can "Withdraw" a player directly from their grouping tile. This removes them from the group AND updates their registration status to **Withdrawn** in Firestore.
