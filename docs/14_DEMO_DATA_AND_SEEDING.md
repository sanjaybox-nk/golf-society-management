# Demo Data & Seeding
**v4.x Authority — The "Master Seed" Infrastructure**

The Demo Seeding system is a high-fidelity administrative tool used to populate the society management app with a "production-ready" 2025-26 season state.

## 01 · Location & Access
- **Settings Hub** (Gear Icon) > **INFRASTRUCTURE**
- **Signifier**: Access is gated behind the **ADMIN** pill context in the HeadlessScaffold.

---

## 02 · The 3-Tier Infrastructure Hierarchy

As of the April 2026 consolidation, administrative infrastructure controls are streamlined into three high-fidelity actions:

### 1. Initialize Demo Season (The "Master Seed")
The primary tool for environment generation. It performs a surgical wipe and then orchestrates a full multi-module population.
- **Stableford Foundation**: Seeds 75 members and a full 12-month calendar (March 2025 - March 2026).
- **Match Play Progression**: Automatically instantiates a 36-player Match Play tournament, including the "Season Opener" hybrid event, guest exclusion logic, and automated bracket progression.
- **Financial State**: Seeds central debt ledger entries, vouchers, and charitable contributions.
- **Communications**: Populates the Note Studio and Survey Hub with realistic participation data.

### 2. Clear Activity Data (The "Surgical Wipe")
Wipes all dynamic "Activity" while preserving the "Society Foundation."
- **Wiped**: Events, registrations, results, member roster, financial entries, and surveys.
- **Preserved**: Society name/logo (Branding), Course Libraries, and Competition Templates.
- **Usage**: Use this when you want to start a new season from scratch using existing rules and branding.

### 3. Competition Template Gallery
The master seed populates the administrative template library with authoritative, modular blueprints:
- **Stableford Solo**: Standard singles format (95% allowance).
- **Texas Scramble**: 4-man team format with WHS allowance.
- **Singles Match Play (Event)**: One-off match play format for dedicated tournament days.
- **Match Play Season Overlay**: The "Side Game" blueprint used to layer a season-long bracket over a standard Stableford event.
- **Ryder Cup (Team Match Play)**: Unified two-team aggregate format (e.g. Committee vs. Members).

### 4. Round Progression & Checkpoints
The system enforces a strict "Review and Publish" workflow for Match Play:
- **Event Finalization**: When a society event is closed, the system detects any active Match Play overlays.
- **The Progression Wizard**: Admins are prompted to "Generate Next Round" which advances winners into a **DRAFT** state.
- **Manual Overrides**: Admins can manually enter private match results (e.g. Tuesday matches) or award walkovers via the Match Play Hub.
- **Draft Publication**: Pairings remain in a "Draft" state, allowing for player swaps before the admin explicitly publishes the next round to the membership.

### 4. Society Branding & Atmosphere
- **Global Identity**: Restores the society name, logo, and theme mode.
- **Sponsorship Hub**: Re-establishes Gold/Silver/Bronze season partners (e.g., Rafiki Golf, Titleist, PING).
- **Financial Ledger**: Injects sponsorship revenue and society overheads.

### 5. System Factory Reset (The "Deep Wipe")
A total, unrecoverable deletion of all data in the current society context. This returns the app to an unconfigured "Day Zero" state.

---

## 03 · Match Play Progression Scenario
The Match Play engine is now fully integrated into the **Master Seed** to ensure tournament integrity.

- **Hybrid Season Opener**: The first event is seeded as a Stableford game with a Match Play overlay.
- **36 Entries (33 Members + 3 Guests)**:
    - **Guests**: Participate in Stableford but are excluded from brackets.
    - **Bye Member**: The 33rd member receives an automated 1st-round bye.
    - **Strategic Grouping**: The Bye member is grouped with the 3 guests to maintain event rhythm.
- **Tournament Switchboard**: Controlled via the `showMatchPlayOverlay` toggle in Society Config.

---

## 04 · Verification & Lab Scenarios

The seeding engine includes specialized "Lab" scenarios for debugging complex UI states and verifying result verification workflows:

### 1. Verification Test Scenario
Seeds a specific event state designed to test the **Admin Verification Hub**:
- **70% Submitted**: Completed scorecards with final status.
- **20% Draft (Complete)**: 18-hole cards waiting for submission.
- **10% In Play**: Scorecards with partial holes (e.g. 16 holes) for real-time tracking.
- **Usage**: Accessible via the "Seed Verification Scenario" action in Debug settings.

### 2. Match Play Lab Stages
Specialized seeding for Match Play lifecycle testing:
- **Stage 1 (Registration)**: 32 members registered, no draw.
- **Stage 2 (Draw Published)**: Full 16-match bracket generated.
- **Stage 3 (Partial Results)**: 8 matches completed, 8 pending.

---

## 04 · Technical Orchestration

### `SeedingService.seedFullDemoData()`
This is the single source of truth for society initialization.
1. **Purge**: Calls `clearActivityData()` + `clearDemoData()`.
2. **Scaffolding**: Seeds courses and members.
3. **Activity**: Seeds the 12-event season history.
4. **Tournaments**: Calls `MatchPlaySeeder` to generate the 36-player bracket progression.
5. **Hardening**: Flushes all persistence layers and invalidates Riverpod providers to ensure a zero-error UI state.

### Design Standard
All seeding logic adheres to the **Boxy Art (v4.x)** standards:
- **Tabular Numerals**: All score/handicap data is formatted for alignment.
- **ALL-CAPS Metadata**: Seeded labels and statuses use the professional administrative typography.

---

*Fairway Design System v4.x · Seeding Authority.*
