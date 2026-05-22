# Demo Data & Seeding
**v4.x Authority — The "Master Seed" Infrastructure**

The Demo Seeding system is a high-fidelity administrative tool used to populate the society management app with a "production-ready" 2025-26 season state.

## 01 · Location & Access
- **Settings Hub** (Gear Icon) > **INFRASTRUCTURE**
- **Signifier**: Access is gated behind the **ADMIN** pill context in the HeadlessScaffold.

---

## 02 · UAT Testing Pipeline (Active Workflow)

The recommended seeding sequence for UI/UAT testing is a three-step pipeline run in order:

```
1. Clear Activity Data      → wipes all data including guests collection
2. Harden Members Only      → seeds 31 members + 15 guest pool profiles
3. Handshake & Rhythm UAT   → seeds Medal (stroke) + Stableford events with conflict states
```

Additional game-type UAT seeds will be added one at a time as each format is verified.

---

## 03 · The Seeding Actions

### 1. Initialize Demo Season (The "Master Seed")
Full wipe + orchestrated season population.
- Seeds 75 members, 12-month calendar, Match Play bracket progression, financials, comms.

### 2. Clear Activity Data (The "Surgical Wipe")
Wipes all dynamic data while preserving the Society Foundation.
- **Wiped**: Events, registrations, results, member roster, guests, financial entries, surveys.
- **Preserved**: Branding, Course Libraries, Competition Templates.

### 3. Harden Members Only
Refreshes member roster + seeds the guest pool.
- **Members**: Wipes and re-seeds 31 members with full profiles.
- **Guests**: Wipes `guests` collection and seeds 15 fixed guest profiles from `SeedingData.seedGuests`.
- Each guest has a stable email address (e.g. `tom.hargreaves@example.com`) so `findOrCreate` deduplication is exercised when events are subsequently seeded.

### 4. Handshake & Rhythm UAT
Seeds two events for conflict/verification testing:
- **Medal Play Verification** (stroke play, singles) — specific conflict states seeded per hole
- **Rhythm Stableford** (stableford, singles) — progressive scoring states
- Guests in these events use real guest pool IDs (not placeholder `guest_0` IDs).

### 5. Seed Stableford Leaderboard UAT
Seeds a two-event season leaderboard UAT scenario for testing OOM/Eclectic/Marker Counter calculations end-to-end.
- **Access**: Admin Operations → **"Seed Stableford Leaderboard UAT"**
- **Round 1**: Fully approved stableford event with final results.
- **Round 2**: In-play stableford event (scoring active, not yet approved).
- Designed to exercise the season standings hub, leaderboard grouping, shared position display, and tie-breaking logic.

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
- **Sponsorship Hub**: Re-establishes Gold/Silver/Bronze/Partner season sponsors (e.g., Rafiki Golf, Titleist, PING). Sponsors are scoped as Season or Event and grouped by tier on the home screen.
- **Financial Ledger**: Injects sponsorship revenue and society overheads.

### 5. System Factory Reset (The "Deep Wipe")
A total, unrecoverable deletion of all data in the current society context. This returns the app to an unconfigured "Day Zero" state.

---

## 04 · Guest System

Guests are persistent records in the `guests/{uuid}` Firestore collection.

### Data Model
```
guests/{uuid}
  name: string
  email: string        ← unique index, deduplication key
  handicap: double
  firstPlayedAt: timestamp
  lastPlayedAt: timestamp
  eventCount: int
```

### `GuestRepository.findOrCreate(email, name, handicap)`
The core method. Looks up by email — updates if found, creates if not. Called automatically on event registration save. Email is mandatory.

### Seed Guest Pool (`SeedingData.seedGuests`)
15 fixed guests with stable emails. Used by both `seedMembersOnly` and `ScenarioSeeder` so deduplication is exercised: a guest appearing in 3 seeded events will have `eventCount: 3`.

### Admin Guest List
Admin Settings → Members → **Guests** tab. Searchable by name or email. Shows HC and event count.

---

## 05 · Match Play Progression Scenario
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
