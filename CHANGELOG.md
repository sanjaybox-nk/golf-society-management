# Changelog

All notable changes to the Golf Society Management (BoxyArt) project will be documented in this file.

## [Unreleased]

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
