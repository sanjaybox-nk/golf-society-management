# Architecture & Project Structure

The project follows a **Feature-First** architecture combined with **Riverpod** for state management and **GoRouter** for navigation.

## Folder Structure (`lib/`)

```
lib/
├── design_system/          # Clean UI system (Atoms, Widgets, Theme)
│   ├── atoms/              # Base components (Buttons, Inputs, Badges)
│   │   ├── inputs/         # Specialized input fields (Search, Metric, Date)
│   │   ├── badges/         # Status indicators (Pill, Indicator, Avatar)
│   │   └── layout/         # Structural atoms (Dividers, Spacing)
│   ├── widgets/            # Complex layouts (Cards, Scaffolds, Section Titles)
│   ├── theme/              # AppTheme, Shadows, Palettes (True Minimal v4.1)
│   └── design_system.dart  # Central export layer (single import for all UI)
├── features/               # Domain-specific feature modules
│   ├── home/               # Member Dashboard
│   ├── events/             # Events Hub, Scoring & Registration
│   ├── members/            # Members Directory & Profiles
│   ├── surveys/            # Member-facing Survey screens
│   ├── admin/              # Administrative Console
│   │   ├── application/    # Shared admin application services (AdminActionService)
│   │   ├── competitions/   # Competition setup, templates, scoring review
│   │   ├── events/         # Event management, grouping, registrations
│   │   ├── members/        # Member admin (debt, renewals)
│   │   │   ├── controllers/# Riverpod 2.0 Notifiers for domain logic
│   │   │   └── widgets/    # Atomic feature-specific widgets
│   │   ├── notifications/  # Communications Hub
│   │   ├── reports/        # Reporting Hub (finances, engagement)
│   │   ├── settings/       # Branding, sponsorship, roles
│   │   ├── surveys/        # Survey admin (editor, results)
│   │   └── treasury/       # Debt ledger, fines, charity
│   │       ├── controllers/# Settlement and ledger logic
│   │       └── widgets/    # Specialized finance widgets
│   └── matchplay/          # Specialized Match Play Module (Standalone logic)
├── domain/                 # Core Business Logic & Entities
│   ├── models/             # Shared Data Models (Freezed + JsonSerializable)
│   ├── scoring/            # Centralized Scoring Engine (Stableford, Medal, Scramble)
│   └── handicap/           # WHS / PHC calculation logic
├── services/               # Infrastructure (Auth, Firebase, Storage, Seeding)
├── utils/                  # Helper functions (Dates, Strings, Currency)
├── constants/              # Static keys, route names, config
├── navigation/             # App Router (GoRouter shell + branch definitions)
└── main.dart               # Entry point
```

## State Management (Riverpod)

Using `riverpod_generator` (`@riverpod` annotation) with auto-generated providers.

### Repositories (Firestore)
All repositories use `.withConverter` for type-safe JSON mapping:
- `FirestoreEventsRepository`
- `FirestoreMembersRepository`
- `FirestoreCompetitionsRepository`
- `FirestoreSeasonsRepository`
- `FirestoreAuditRepository` (real-time activity tracking)
- `FirestoreSurveysRepository`
- `FirestoreCampaignsRepository`

### Services
- `AuthService` (Firebase Auth)
- `StorageService` (Firebase Storage — image uploads, 5MB limit)
- `SeedingService` (Historical data initialization for development)
- `LeaderboardInvokerService` (Season Standings Calculator)

### Provider Patterns
- **Defined in**: `feature/presentation/provider_name.dart` or `feature/presentation/controllers/feature_controller.dart`
- **Consumed via**: `ref.watch(provider)` or `ref.watch(featureControllerProvider)`
- **Controller-Based Logic (v8.0)**: (April 2026) Administrative hubs use the **Thin Shell Presentation** pattern. Business logic is moved to `Notifier` controllers, and large screens are decomposed into atomic functional widgets.
- **Cache invalidation**: `ref.invalidate(provider(id))` after successful saves to prevent stale data in deep-linked routes.

## Domain Logic

Complex business rules are encapsulated in standalone classes in `domain/`:

- **Format + Feature Model**: (April 2026) Architecture distinguishes between the **Physical Format** (Stableford, Stroke) and **Scoring Features** (Match Play Overlay). This allows dual-scoring within a single scorecard and leaderboard.
- **`MatchPlayCalculator`**: Authoritative engine for Net Match Play, Relative PHC, Fourball/Foursomes status.
- **`ScoringCalculator`**: Authoritative engine for Stroke, Stableford, and Max Score capping.
- **SSOT Pattern**: *Calculate Once, Display Everywhere.* `LeaderboardEntry` carries all pre-calculated values. Views (e.g. `ScorecardModal`) are **purely presentational** — they must NOT re-calculate scores.
- **`RegistrationLogic`**: Centralised helper for FCFS positions, status legend, and buggy allocations.
- **Automated Financials**:
  - **Club Bill**: Auto-calculated from confirmed registrations and meal preferences.
  - **Indicative Costs** (e.g. Buggy): Treated as member-direct and excluded from society treasury.
- **`SmartAudienceEvaluator`**: Central logic for dynamic audience membership. Handles AND-logic filtering across member status, handicap, debt, and next-event registration status.

## Complex Form Architecture

For large multi-domain forms (e.g. `EventFormScreen`, `SurveyEditorScreen`):
- **State**: Centralised `AsyncNotifier` (e.g. `EventFormNotifier`) manages a composite `Freezed` state.
- **Sub-Widgets**: Monolithic forms decomposed into functional sections (e.g. `EventLogisticsSection`, `EventCourseSection`).
- **Persistence**: Notifier's `save()` handles multi-repository synchronisation in a single logical unit.

## Navigation (GoRouter)

Hierarchical shell architecture:

- **`GlobalAppShell`**: Wraps the 4 primary branches (Home, Events, Members, Admin). Bottom navigation bar is always visible unless the current route is a "Special Form" (creation/edit flow that should fill the screen).
- **`EventAdminShell`**: Context-aware 5-tab hub for event administrators.
- **`EventUserShell`**: Context-aware 5-tab hub for event members. Includes the **2-Tab Segmented Scoring Hub** (v10.5) featuring the "SCORING" stream and "SCORECARD" overview views.
- **Branch Navigators**: Administrative sub-hubs (Renewal Hub, Debt Ledger, Grouping Hub) use branch navigators to maintain `GlobalAppShell` visibility. Pushing to the root navigator for these screens is a known anti-pattern to avoid.
- **Administrative Modal Stabilization**: (v7.1) All global administrative modals (e.g. Edit Menus, Audience Managers) must use `BoxyArtBottomSheet.show(useRootNavigator: true)` or `showModalBottomSheet(useRootNavigator: true)`. This ensures they correctly overlay the `GlobalAppShell` and prevents clipping by the persistent bottom navigation bar.
- **Stable Keys**: Nested shells use stable `ValueKey` assignments via `hubPage` to prevent widget destruction during tab switches.
- **`boxyPage` & `hubPage` Helpers**: All routes use these helpers for unified transitions. `hubPage` specifically manages the persistent `EventAdminShell`/`EventUserShell` wrappers with stable keys.

## Data Models

All models are immutable, generated with `freezed` and `JsonSerializable`:

- **Location**: `lib/domain/models/`
- **Key Models**:
  | Model | Purpose |
  |---|---|
  | `Member` | Core user profile, membership status, handicap |
  | `GolfEvent` | Event metadata, registrations, feed items, multi-day support |
  | `Competition` | Scoring rules, formats, handicap config |
  | `Campaign` | Society broadcast with multi-section `notes[]`, draft/sent lifecycle |
  | `Survey` / `SurveyQuestion` | Multi-question survey with Quill Delta JSON prompts |
  | `FinancialEntry` | Treasury ledger items (sponsorship, donation, expense) |
  | `LeaderboardEntry` | Pre-calculated scoring vehicle — SSOT for all display |
  | `SocietyConfig` | Comprehensive Branding SSOT (Tokens, radii, spacing, mechanicals) |
  | `DistributionList` | Target audience definition with `isDynamic` and `filterCriteria` support |
  | `AudienceFilterRule` | Schema for dynamic filtering (Property, Operator, Value) |

## Code Quality & Hardening

- **Zero-Warning Static Analysis**: `flutter analyze` must exit with **code 0**. Last verified: **April 29, 2026**.
- **Admin Hub Modularization (v10.0)**: (April 2026) Finalized the decomposition of administrative hubs into domain-specific modules. Eliminated legacy placeholder files (`event_user_placeholders.dart`) and standardized direct state imports for increased codebase hygiene.
- **Vertical Rhythm Standardization**: Achievement of "Zero-Warning" milestone included systematic audit of all `HeadlessScaffold` implementations to ensure perfect alignment with BoxyArt v4.x vertical rhythm standards.
- **Deprecated API Policy**: No deprecated Flutter APIs permitted. `activeColor` → `activeTrackColor`/`activeThumbColor`; `value` → `initialValue` on form fields.
- **Async Safety**: All `BuildContext` usages after `await` must be guarded by `if (!mounted) return;`.
- **Global Error Handler**: `BoxyArtErrorHandler` via `PlatformDispatcher.instance.onError` catches both build-time "red screens" and asynchronous runtime exceptions globally.
- **Type Safety**: `freezed` for immutable models, `riverpod_generator` for type-safe state.
- **Import Hygiene**: Single `design_system.dart` barrel import eliminates UI import noise.
- **Const Correctness**: `HeadlessScaffold` with non-const `titleSuffix` (e.g. `BoxyArtPill.committee`) must NOT use `const` on the scaffold itself.
