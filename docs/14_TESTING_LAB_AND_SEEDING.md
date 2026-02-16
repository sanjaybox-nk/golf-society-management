# Testing Lab & Seeding

The Testing Lab is a dedicated developer/admin tool within the society management app designed for end-to-end verification of scoring, leaderboards, and logistics.

## Location
Admin Settings > Testing Lab

## Features

### 1. Seeding Base Foundation
-   **Function**: Seeds 60 randomized members with varying handicaps.
-   **Master Event**: Creates "The Lab Open", a permanent test event where admins can experiment with different game formats.

### 2. Iterative Testing Phases
The lab is organized into phases to isolate specific technical challenges:

| Phase | Description | Key Verification |
| :--- | :--- | :--- |
| **Phase 1** | Foundation & Individual Play | 60 members, individual Stableford scoring, handicap calculations. |
| **Phase 2** | Historical Seeding | 8 finalized past events across 2025-2026 to populate season-long charts and archive. |
| **Phase 3** | Team Logistics | Scramble and 4BBB Pairs events with team-to-individual point attribution. |
| **Phase 4** | Hardening | High-density tie scenarios to verify countback and shared position logic. |
| **Phase 5** | Matchplay & Team Grouping | Advanced grouping scenarios with Side A/B pairing and match overlay status verification. |
| **Phase 6** | Multi-Day Logic | Seeding of events spanning multiple days (e.g., "The Masters Simulation") to verify date range display and scoring aggregation. |

### 3. Lab Event Management
-   **Reset Event**: Clears all registrations and scores for "The Lab Open" to start a fresh test.
-   **Swap Format**: Changes the active template of the lab event (e.g., switch from Stableford to Stroke Play) to test recalculation logic.

## Technical Details

### `MockDataSeeder` & `SeedingController`
The core engine for generating believable competition data.
-   **Stroke-First Approach**: Instead of seeding random points, the engine generates raw hole-by-hole strokes (3-8 per hole) biased by handicap. This allows the same result set to be viewed as Stableford or Medal.
-   **Registration Awareness**: The seeder prioritizes actual event registrations if they exist, matching scores to real members.
-   **Guest Injection**: The `SeedingController` automatically injects 2 mock guest registrations into empty events during regeneration to facilitate testing Guest Leaderboards.
-   **Leaderboard Segmentation**: The UI automatically detects these guests and displays them in a dedicated "Guest Leaderboard" section, keeping them separate from society members while still including them in group score totals.
-   **Dynamic Scaling**: For empty events, the engine randomized the field size (typically 12-32 players) to simulate natural society attendance variety.
-   **Bulk Action**: Admins can trigger "Initialize Demo Season" from the General Settings to rapidly populate a multi-year history (Jan 2025 - Feb 2026) including multi-day events.

### Tie-Break Verification (Phase 4)
Phase 4 generates players with identical raw scores (e.g., 36 points) and identical per-hole distributions to stress test the Tie Policy configuration (Countback vs. Shared).
