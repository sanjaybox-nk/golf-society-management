# Project Overview

**Golf Society Management** is a modern Flutter application designed to manage golf societies, events, members, and handicaps. It features a premium **BoxyArt** design system with high-contrast aesthetics and fluid interactions.

## Core Features

1. **Member Dashboard**: Personalized view with dynamic notifications, "Next Match" hero card, Season Sponsors, and quick-access Order of Merit snippet.
2. **Society Reporting Hub**: Comprehensive reporting engine for finances, member engagement, fines, charity tracking, and competition analytics.
3. **Communications Hub (Admin)**: A sophisticated broadcasting system with multi-section rich-text composing, custom distribution lists, draft persistence, and event targeting.
4. **Events Hub**: Comprehensive listing of Upcoming and Past events, with player-facing registration, live scoring, and event feed.
5. **Members Directory**: Searchable roster with live filtering, photo uploads, member status management, and inline admin controls.
6. **Locker Room**: User profile management (Bio, Photo), handicap tracking, WHS Net Differential stats, and season standings.
7. **Season Standings**: Advanced leaderboards (OoM, Birdie Tree, Eclectic) with industry-standard point systems and Best-N selection.
8. **Society Surveys**: Multi-question WYSIWYG survey engine with drag-and-drop reordering, single/multi/text question types, and real-time voting.
9. **Design Token Studio (Branding Console)**: Granular, whitelabel configuration for 30+ semantic design tokens, including mechanical overrides (borders/dividers) and domain-specific scoring aesthetics.
10. **Digital Verification Handshake**: Formalized side-by-side player/marker verification suite with dual-tab "My Scorecard" (SCORE | VERIFY) layout and automated audit locking.
11. **Demo Seeding (Admin)**: Sophisticated multi-phase engine for generating historical member, event, and competition data for development and testing.

## Typography
- **Body / Labels**: Inter
- **Display**: Fredoka

## Code Health & Standards

- **Zero Error State**: The project enforces a strict "Zero Warning/Error" policy. `flutter analyze` must exit with **code 0**. Last verified: **April 2026**.
- **Architecture**: Feature-First Clean Architecture with distinct `domain`, `features`, and `design_system` layers.
- **Async Safety**: Standardized `mounted` guards before all post-`await` `BuildContext` usages across the entire codebase.
- **Universal Parity**: 1:1 visual alignment between Admin and Member scoring and survey components.
- **Design System**: All UI uses the single `package:golf_society/design_system/design_system.dart` export — no ad-hoc styles.

## Detailed Documentation

- [Architecture Registry](./04_ARCHITECTURE.md)
- [Theme System](./05_THEME_SYSTEM.md)
- [Shared UI Library](./09_SHARED_UI_LIBRARY.md)
- [Registration Logic](./10_REGISTRATION_LOGIC.md)
- [Grouping & Tee Sheets](./11_GROUPING_LOGIC.md)
- [Games & Competitions](./13_GAMES_AND_COMPETITIONS.md)
- [Social Events & Surveys](./18_SOCIAL_EVENTS_AND_SURVEYS.md)
- [Demo Data & Seeding](./14_DEMO_DATA_AND_SEEDING.md)
- [Roadmap & ToDo](./06_ROADMAP_TODO.md)

## Visual Identity ("BoxyArt True Minimal" v4.5+)

The app uses a centralized, whitelabellable design system called **BoxyArt**:

- **Dynamic Theme Engine**: Real-time configuration of Primary, Secondary, and Tertiary (Foundation) colors.
- **Scoring Aesthetics**: Society-defined palette for golf scoring (Birdie, Eagle, etc.) and team identities.
- **Mechanical Control**: Granular overrides for border width, divider thickness, and semantic status colors.
- **True Minimal Legend**: Minimalist dot + text indicators (no background pills for status).
- **Universal Title Case**: 100% adherence to Title Case for all content; ALL-CAPS reserved for structural metadata.
- **Shapes**: High border radius (`18px` default); all controlled via Branding Console.
- **Shadows**: Custom "Soft Scale" and "Floating Alt" shadows (no default Material elevation).
- **Admin Identity**: `BoxyArtPill.committee(label: 'ADMIN')` applied as `titleSuffix` on all administrative `HeadlessScaffold` screens.
