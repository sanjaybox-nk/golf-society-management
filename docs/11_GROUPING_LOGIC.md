# Tee Sheet Grouping Logic

The grouping system automatically generates balanced and varied tee sheets for society events. It aims to maximize player enjoyment by ensuring variety in pairings and balancing playing ability (Handicap).

## Generation Workflow

### 1. Participant Selection
The grouping service only includes participants marked as **Attending Golf**. It handles both members and guests.

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

---

### Swapping Rules
- **Non-Movable Players**: Hosts with guests and the guests themselves are "locked" and cannot be swapped between groups.
- **Buggy Locking**: The system tries to keep members who *must* have a buggy in groups where they can be paired, though they remain movable if the resource count allows it.

---

## Final Post-Processing
After optimization, the system performs a final pass to:
- **Assign Captains**: Each group is assigned a Captain (prioritizing members).
- **Synchronize Buggy Status**: Every player's `buggyStatus` is recalculated based on the final group composition and the global available capacity.
