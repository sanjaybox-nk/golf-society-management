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
| **Phase 2** | Historical Seeding | 3 finalized past events to populate season-long charts and archive. |
| **Phase 3** | Team Logistics | Scramble and 4BBB Pairs events with team-to-individual point attribution. |
| **Phase 4** | Hardening | High-density tie scenarios to verify countback and shared position logic. |

### 3. Lab Event Management
-   **Reset Event**: Clears all registrations and scores for "The Lab Open" to start a fresh test.
-   **Swap Format**: Changes the active template of the lab event (e.g., switch from Stableford to Stroke Play) to test recalculation logic.

## Technical Details

### `SeedingService`
The core engine for generating believable data.
-   **Skill Bias Generator**: Scores are not purely random but follow a normal distribution biased by the member's handicap.
-   **Historical Context**: Ensures past events have timestamps and statuses that allow them to appear in the Archive and Member History correctly.

### Tie-Break Verification (Phase 4)
Phase 4 generates players with identical raw scores (e.g., 36 points) and identical per-hole distributions to stress test the Tie Policy configuration (Countback vs. Shared).
