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

### 4. Grouping Modes: Standard vs Tournament (April 2026)
The system now distinguishes between two grouping philosophies based on the competition rules:

- **Standard Grouping (Overlay Mode)**: Used when `hasMatchPlayOverlay` is true. The admin uses standard society tools (random/balanced) to create groups. Matches are then automatically formed within those groups.
- **Tournament Style Grouping (Seeded Draw)**: Used for Ryder Cup, Season Match Play, etc. (`isTournamentStyleGrouping` is true). The grouping is determined by a **Seeded Draw** or **Knockout Bracket**. Standard auto-generation tools are disabled.

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
- **Team Scoring (Best X)**: In the **Scores hub**, the grouping card automatically calculates the "Team Total" based on the `teamBestXCount` defined in the competition rules. This data is **hidden in the Field (Draw) tab** to maintain a clean management interface.
- **Winner Indicators**: Top-performing groups are highlighted with a **Trophy Icon** only in the Scores hub. Administrative management views enforce strict data isolation to prevent live scoring leaks.

---

## 7. Squad Pool & Late Changes
The grouping system is dynamic. If the field changes after groupings are generated (due to late confirmations or withdrawals), the Admin can manage the field via the **Squad Pool**:

- **Unassigned Players**: Players promoted to **Confirmed** status (automatically after the deadline or manually) who are not in a group will appear in the **Squad Pool** at the top of the grouping screen.
- **Manual Assignment (Drag & Drop)**: Admins can drag players from the Squad Pool into any group with an **Empty Slot**. This is the primary interface for fine-tuning the field after auto-generation.
- **Swapping**: Players can be swapped between groups, or moved from a group back to the pool (by clicking "Remove").
- **Late Withdrawals**: Admins can "Withdraw" a player directly from their grouping tile. This removes them from the group AND updates their registration status to **Withdrawn** in Firestore.
- **Control Tower Access**: The Manual Grouping screen is accessed via the **Control Tower** (EventAdminControlsScreen) under the "Manage Grouping & Tee Times" navigation tile.

---

## 8. Match Play Overlay & Interactive Pairing
When a standard event (e.g. Stableford) includes a Match Play overlay, the Admin Grouping Screen provides specialized tools for pairing players within their assigned groups.

### Interactive Pairing (Overlay Only)
While in Match Play Mode on standard events:
- **VS-Style Pairing**: Grouping cards reflect the current pairing status (Side A vs Side B).
- **Interactive Grid**: Admins can tap players within a group to swap their side (A or B), determining who plays whom.
- **Persistence**: These pairings are saved as `MatchDefinition` objects within the event's grouping metadata.

### 9. Authoritative Tee Resolution
The grouping UI reflects the authoritative tee resolved for each player.
- **Auto-Assignment**: Tees are initially assigned during registration based on event defaults and gender.
- **Resolution Priority**: The system resolves the playing tee box in this order:
    1. **Manual Admin Override** (Set in Grouping Hub)
    2. **Player Manual Override** (Set in Scorecard Modal)
    3. **Registration Default** (Set at signup)
    4. **Event Default** (Course-wide)

### 10. Administrative Tee Overrides
Admins have the final authority to override any player's tee box within the **Grouping Hub**.
- **Interactive Tapping**: Admins can tap the tee indicator on a player's tile to open the **Tee Selector**.
- **Admin Popup Menu**: The "Change Tee..." option is also available in the player's leading popup menu.
- **Persistence**: Changes are synchronized back to the `EventRegistration` in Firestore and snapshotted in the `TeeGroupParticipant` for consistency across re-generations.

---

## 10. Admin Grouping Hub Card
The grouping screen features a unified **Grouping Hub Card** for managing the field generation and publishing the schedule. This replaces the legacy toolbar with a more process-oriented UI.

### Core Controls
- **Generation Strategy**: Toggle between **Random**, **Balanced**, and **Power Groups** directly on the card.
- **Tee Time Seed**: High-precision time picker for the first group's tee-off.
- **Tee Interval**: Configure the gap between groups (e.g., 8, 10, 12 minutes).

### Core Actions
- **Lock/Unlock**: Prevents or allows editing of the grouping.
- **Generate**: Executes the selected strategy. It pulls all **Confirmed** participants from the registration list and populates the tee sheet.
- **Reset**: Clears all current groups and moves all participants back into the **Squad Pool** for manual re-assignment or re-generation.
- **Publish (Live Toggle)**: A primary action button that toggles the grouping between **Draft** and **Live** status. When "Live", tee times are visible to members in the event home tab.
- **Save**: Persists any manual swaps, changes to the seed time, or interval to the backend.

### UI Consistency & Stability
The grouping interface follows the **BoxyArt Design 4.1 (True Minimal)** standards for a premium, editorial feel:
-   **Single Card Architecture**: Every tee time group is encapsulated within a single **BoxyArtCard** wrapper. This provides a clear visual container for the entire flight.
-   **Themed Internal Dividers**: Individual player rows inside the group card are separated by subtle, theme-aware horizontal dividers. These dividers include a standardized **0.8x card padding indent** to maintain vertical rhythm while maximizing space.
-   **Vertical Rhythm**: Uses standardized `AppSpacingTokens` (e.g., `spacing?.cardToLabel` for tab-to-list gaps, `spacing?.cardToCard` for list item spacing).
-   **Card Styling**: Grouping cards use a clean **Surface background** (`AppColors.surface`) with high corner radii and soft shadows.
- **Full-Width Actions**: Buttons like **Generate** and **Reset** are standardized to full-width for better touch targets and visual balance within the Hub.
- **Edge-to-Edge Layout (Design 4.x)**: The grouping interface utilizes the full width of the screen by aligning `BoxyArtCard` containers flush with the 16px (`AppSpacing.lg`) gutters provided by the `BoxyArtBottomSheet`. Any internal horizontal padding within these containers is minimized to ensure complex elements like Tee Dropdowns and Marker Toggles have sufficient horizontal space to prevent layout overflow.
- **Vertical Alignment**: Fixed-width containers (e.g., 28px for leading icons) are used to maintain perfect vertical rhythm for administrative controls across multi-player rows.

---

## 13. Marker Accountability & Designation

To maintain scoring integrity, every player in a group is assigned an official **Marker** who is responsible for verifying their final score.

### Manual Designation Workflow
During pre-round setup, the user manually designates their official marker within the **Marker & Tee Selection** sheet:
- **Marker Selection Toggle**: A specialized interaction area on the **left** of each player row allows users to tap a designated icon (`edit_note_rounded`) to set that player as their marker.
- **Visual Feedback**: The active marker is highlighted with a **vibrant lime green** indicator, clearly distinguishing the primary accountability role from secondary administrative actions (like tee selection).
- **Self-Marking**: The system supports "Self-Marking" for cases where a player is playing solo or in a specific non-standard flight configuration.
- **Persistence**: These assignments are managed via the `markerSelectionProvider` and persisted to the local device and cloud to ensure the "Marked By" verification flow surfaces the correct member during the final round sign-off.

---

## 14. Automated Society Cuts (Handicap Adjustments)

The system includes an automated **Society Cuts Engine** that manages temporary handicap adjustments based on recent high-performance finishes.

### Cutting Logic
- **Podium Triggers**: Cuts are automatically applied for 1st, 2nd, and 3rd place finishes.
- **Additive (Stacking) Model**: Cuts are cumulative. If a player wins (e.g., -2.0) and then takes 3rd (e.g., -0.5), their total active cut becomes -2.5. This maintains competitive incentives throughout the season.
- **Calculation Formula**: `Playing Handicap = (Course Handicap * Allowance) - (Manual Cut + Automated Society Cut)`.

### Expiry and Duration
- **Duration Limit**: Admins can configure how many events a cut remains active for (e.g., 3 events). If set to 0, cuts last for the remainder of the season.
- **Validity Types**:
    - **Held events**: The cut expires after a fixed number of society events occur, regardless of whether the member played.
    - **Played events**: The cut only decrements when the member actually participates in an event.

### Eligibility Filtering
Admins can toggle which types of events contribute to and are affected by automated cuts:
- **Season Events**: Standard order-of-merit events.
- **Invitational Events**: Majors or special tournaments.
- **Social Events**: These *never* trigger or apply society cuts.

### Transparency
- **Locker Room Card**: Members can see their active cut status, the breakdown of contributing finishes, and the remaining validity (event countdown) in their private Locker Room.

---

## 12. Administrative Data Isolation (Hardening)

To ensure a professional and focused management experience, the administrative suite enforces strict isolation between "Field Management" (Organization) and "Scoring Hubs" (Results).

### Clean Draw Policy
The **"The Draw" (Field Management)** tab remains clean of live scoring data at all times. This includes:
- **Suppression of Result Labels**: Strings like "Won 3 & 1" or "Lost 2 up" are never visible in the organization views.
- **Zero Scoring Leaks**: The `isScoreMode` and `showScoring` flags are forced to `false` in the `AdminGroupingHubContent` and `EventAdminGroupingScreen`.
- **Interaction Parity**: Admins maintain full drag-and-drop and swap interactivity without the visual clutter of live match-play results.

### Dedicated Scoring Hubs
All live result data, including group totals, winner icons, and match statuses, are centralized in the **"Scores" hub**. This ensures architectural stability and prevents unintended data exposure during pre-event or mid-event field adjustments.
