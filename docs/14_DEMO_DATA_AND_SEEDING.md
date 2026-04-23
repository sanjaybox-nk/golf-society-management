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

### 3. System Factory Reset (The "Deep Wipe")
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
