# Changelog

All notable changes to the Golf Society Management (BoxyArt) project will be documented in this file.

## [Unreleased]

### Hardening & Code Quality (2026-02-11)
- **Lint Cleanup**: Addressed over 50 lint warnings and informational messages across the entire codebase.
- **Async Safety**: Hardened `use_build_context_synchronously` checks in `EventFormScreen` and other critical flows using proper `mounted` guards and localizing navigator state.
- **Dead Code Removal**: Excised unused imports, variables, and private methods in 15+ screen and widget files.
- **Style Hardening**: Standardized use of `SizedBox` for whitespace and optimized `Container` usage.
- **Project Health**: Achieved a near-clean `flutter analyze` report, drastically reducing technical debt.

### Core Features
- **Matchplay Engine**: Implemented independent and event-layered matchplay scoring.
- **Tee Sheet UI**: Added tap-to-swap grouping logic and interactive pairings management.
- **Admin Scores**: Consolidating admin scoring controls and scorecard status tracking.

### Design System
- **BoxyArt Evolution**: Refined the high-contrast design system with better shadow scaling and premium card aesthetics.
