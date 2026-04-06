# Demo Data & Seeding

The Demo Seeding system is a powerful administrative tool used to populate the society management app with realistic, high-quality data for testing, training, and demonstration purposes.

## Location
- **Settings Hub** (Gear Icon) > **INFRASTRUCTURE**

## Features

### 1. Seeding Base Foundation
-   **Function**: Seeds **75 members** (20 female, 55 male) with realistic handicap distributions.
-   **Hero Account**: Includes "Sanjay Patel" as a consistent Admin/Hero user for personal stats verification.
-   **Automatic Scaling**: Generates a full multi-year history (Jan 2025 - March 2026) with realistic attendance (12-32 players per event).
-   **2025-26 Season Synchronization**: Implements a professional 12-month calendar (March 12 opener) with 8 Season (Stableford) and 4 Invitational (Mixed Format) events.
-   **Multi-Tee Architecture**: All seeded courses feature full **Yellow (Men's Standard)** and **Red (Ladies)** tee sets to verify mixed-gender equity.
-   **Explicit Mapping**: Seeded events now include an explicit `selectedFemaleTeeName: 'Red'`, ensuring accurate Par/SI resolution even in complex mixed-gender competitions.
-   **Financial & Fines Seeding**: Generates realistic payment statuses, custom prize distributions, ad-hoc member fines (paid/unpaid), and event-wide charity pots to verify the **Reporting Hub** metrics.

### 2. Historical Data Generation
The seeding engine populates the society history with various scenarios:
- **Individual Play**: Stableford, Medal, and Max Score events.
- **Team Logistics**: Texas Scramble and 4BBB Pairs events with team-to-individual point attribution.
- **Match Play**: Events with configured matches and calculated winners.
- **Season Standings**: Populates Order of Merit, Birdie Tree, and Eclectic leaderboards.

## Technical Details

### `SeedingService`
The core engine for generating believable competition data.
-   **Stroke-First Approach**: Instead of seeding random points, the engine generates raw hole-by-hole strokes (3-8 per hole) biased by handicap. This allows the same result set to be viewed across different game formats.
-   **Authoritative Course Config**: Seeded events store the full course configuration (Tees, Pars, SIs, Yardages) at the time of creation. Fallback logic in `SeedingService` ensures that even if manual marker selection is not present, the `holes` map defaults to the authoritative Men's (Yellow) or Ladies' (Red) set to prevent resolution errors.
-   **Unused Data Purge**: Each seeding run starts with a `clearAllData()` call to ensure a perfectly clean and consistent state.

### Unit Test Complement
While seeding verifies the **UI and Integration**, raw **Logic Accuracy** is enforced via unit tests:
- `test/scoring_engine_test.dart`: Texas Scramble and 4BBB math.
- `test/handicap_calculation_test.dart`: PHC and allowance logic.
- `test/match_play_calculator_test.dart`: Matchplay status and termination.
