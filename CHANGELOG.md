### Tee Resolution, UX Hardening & Selection Grid (2026-02-27)
- **Authoritative Tee Resolution**: Fixed a critical scoring discrepancy by ensuring `ScoringCalculator` receives accurate Par/SI maps derived from the specific tee override.
- **High-Efficiency Selection Layout**: Replaced legacy dropdowns with a sleek, 2-column horizontal selection grid (Chips) for one-tap tee changes.
- **Marker Selection Provider**: Centralized manual tee state using `markerSelectionProvider` to ensure absolute parity across all views.
- **Guest ID Normalization**: Standardized handling of `GUEST_` prefixed IDs to ensure robust data resolution for non-member entries.
- **Zero-Warning Final Audit**: Achieved 100% clean analysis in `flutter analyze` and resolved all remaining compilation errors in `DemoSeedingService`.
- **Documentation Hardening**: Updated `13_GAMES_AND_COMPETITIONS.md` and `04_ARCHITECTURE.md` to record authoritative scoring patterns.

### Design System Hardening & Typography (2026-02-25)
- **Typography Migration to Inter**: Switched the primary typeface from `Nunito` to `Inter` across the entire application for a more modern and premium aesthetic.
- **Theme Hardening**: Centralized all font configurations within `AppTheme` and audited components for font family inheritance.

### Design System Hardening & UI Refinement (2026-02-23)
- **Branded Input Library**: Upgraded the `BoxyArt` input library (`lib/core/shared_ui/inputs.dart`) to use primary-themed labels and subtle branded backgrounds.
- **Registration Lifecycle UI**: Implemented intelligent visibility rules for the registration card. It now hides automatically for non-registrants after the deadline and for everyone once the event is Live (InPlay) or Completed.
- **Administrative Spacing Refinement**: Optimized the vertical rhythm in administrative views, including centered and bordered "CUSTOMIZE" buttons in `EventFormScreen` and reduced gaps in `BaseCompetitionControl`.
- **Matchplay Result Consistency**: Synchronized the Hero view, Grouping Card, and Leaderboard to use the authoritative `MatchPlayCalculator`, ensuring 100% parity across all match status displays.

### Scoring Centralization & Authoritative Engines (2026-02-22)
- **Centralized Match Play Engine**: Implemented `MatchPlayCalculator.calculateRelativeStrokes` to provide a single source of truth for Net Match Play calculations.
- **Unified Match Parity**: Synchronized `ScorecardModal`, `GroupingCard`, and `EventLeaderboard` to use the same Match Play engine, resolving discrepancies in "holes up" statuses.
- **Authoritative Max Score Capping**: Centralized hole-level capping logic in `ScoringCalculator.applyMaxScoreCap`, ensuring consistency across real-time entry and final reporting.
- **Architecture Standard**: Established the **"Calculate Once, Display Everywhere"** pattern for all complex scoring domains.
- **Static Analysis Perfected**: Achieved and maintained zero warnings across all refactored modules.

### Explicit Female Tees & Leaderboard Refinements (2026-02-20)
- **Explicit Female Tee Selection**: Added `selectedFemaleTeeName` to the `GolfEvent` model and Admin Form, allowing precise mapping of female tees (e.g. Red) for mixed-gender play.
- **Dynamic Scorecard UI**: Updated `HoleByHoleScoringWidget` to dynamically resolve Par and SI values based on the gender of the player currently being marked.
- **Themed Handicap Display**: Redesigned the Leaderboard UI to display individual handicaps below player names using a themed separator (`HC: 14.5 • PHC: 12`).
- **Decimal HC Index Support**: Switched to `double` for individual handicaps in the leaderboard model to support WHS-standard decimal indices.
- **Seeder Society Defaults**: Updated `DemoSeedingService` to use **Yellow** as the default men's tee and **Red** as the explicit female tee for all seeded data.
- **Static Analysis Hardened**: Resolved all compilation errors and Freezed model synchronization issues.

### Fourball Better-Ball Group Display (2026-02-19)
- **Individual Scores**: Fourball group cards now show each player's own Stableford/Stroke score instead of a duplicated team score.
- **Better-Ball Footer**: Footer displays pre-computed hole-by-hole better-ball aggregate per pair as colored pills (orange = Side A, blue = Side B).
- **Pair-Level Calculation**: BB aggregates split correctly by pair (first 2 / last 2 players) using `ScoringCalculator` with individual PHCs.
- **Seeding Fix**: Removed 10% random null "pick-up" injection from `DemoSeedingService` to ensure complete 18-hole scorecards.

### Scoring Precision & Gender Parity (2026-02-18)
- **Mixed Tee Adjustments**: Added optional "C.R. - Par" adjustment toggle for Stroke Play and Stableford competitions, ensuring fair equity when mixed tees are in play.
- **Scramble Customization**: Enhanced Scramble configurator with a "Team Handicap Method" dropdown, offering **WHS Recommended** (Weighted), **Average** (Total ÷ N), and **Sum** (Combined Total) calculations.
- **Tie Break Logic**: Updated leaderboard engine so selecting "Playoff" (Manual) explicitly disables automatic back-9 countback sorting, respecting manual result entry.
- **Smart Tees**: Implemented gender-aware tee defaulting in Event forms and per-player Course Rating/Slope resolution in the scorecard engine.

### Seasonal Standings Hub (2026-02-17)
- **Multi-Format Hub**: Implemented a unified seasonal standings center for members, supporting Order of Merit, Eclectic, Birdie Tree, and Best of Series.
- **Admin Oversight**: Added a dedicated "SEASON" tab to the Admin Leaderboards for centralized configuration and tracking of seasonal competitions.
- **Premium Visualization**: Introduced high-fidelity podium headers, personalized ranking trajectories, and format-specific data widgets (Master Scorecards, Birdie Gallery).
- **Reporting Integration**: Enhanced society reports with seasonal performance previews and quick-access standing links.

### Build Hardening & Zero-Error State (2026-02-17)
- **Analyzer Perfection**: Achieved a true "Zero Error" state in `flutter analyze`, resolving all remaining warnings, lints, and redundant imports.
- **Import Standardization**: Systematically cleaned up `headless_scaffold`, `go_router`, and `boxy_art_widgets` imports across the entire admin and member modules.
- **Async Robustness**: Consolidated `context.mounted` guards throughout the application, specifically in complex form and navigation flows.
- **Project Structure**: Standardized the use of `HeadlessScaffold` as the primary layout for modernized screens.

### Repository Cleanup & UI Modularization (2026-02-17)
- **Data Layer Standardization**: Refactored core Firestore repositories (`Events`, `Competitions`, `Seasons`, `Course`, `Scorecard`) to use `withConverter` for type-safe data mapping and reduced boilerplate.
- **UI Modularization**: Reduced `MemberDetailsModal` complexity by extracting logic into standalone widgets (`MemberRolePicker`, `SocietyRolePicker`, `PersonalDetailsForm`).
- **Design System Consolidation**: Deprecated and removed legacy `cards.dart`, merging all components into the `modern_cards.dart` library for a unified design system.
- **Enhanced Test Coverage**: Added comprehensive unit tests for business-critical scoring logic including Texas Scramble, Stableford, and 4BBB calculations.

### Advanced Seeding & Data Fidelity (2026-02-17)
- **Expanded Roster**: Increased demo seeding to 75 members, including a designated 20-women cohort and a "Hero" admin account (Sanjay Patel) for deep testing.
- **Gender Integration**: Added `gender` field to `Member` model to support future mixed/gender-specific leaderboards.
- **Pro-Level Grouping**: Implemented **Progressive Grouping** strategy (Low Handicaps first) for non-invitational demo events, simulating realistic competition committee pairings.
- **Full Data Reset**: Added "Wipe & Re-Seed" functionality to Developer Tools for a complete environment reset.

### Core Features
- **Matchplay Engine**: Implemented independent and event-layered matchplay scoring.
- **Tee Sheet UI**: Added tap-to-swap grouping logic and interactive pairings management.
- **Admin Scores**: Consolidating admin scoring controls and scorecard status tracking.

### Design System
- **BoxyArt Evolution**: Refined the high-contrast design system with better shadow scaling and premium card aesthetics.
