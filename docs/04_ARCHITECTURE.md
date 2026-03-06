# Architecture & Project Structure

The project follows a **Feature-First** architecture combined with Riverpod for state management.

## Folder Structure (`lib/`)

lib/
├── design_system/          # Clean UI system (Atoms, Widgets, Theme)
│   ├── atoms/              # Base components (Buttons, Inputs)
│   ├── widgets/            # Complex layouts (AppBars, Cards)
│   ├── theme/              # AppTheme, Shadows, Palettes
│   └── design_system.dart  # Central export layer
├── features/               # Domain-specific features
│   ├── home/               # Dashboard
│   ├── events/             # Scoring & Event Management
│   ├── members/            # Directory
│   ├── admin/              # Admin Console
│   └── matchplay/          # Specialized Match Play Logic
├── domain/                 # Core Business Logic & Entities
│   ├── models/             # Shared Data Models (Freezed)
│   ├── scoring/            # Scoring engines
│   └── handicap/           # Calculation logic
├── services/               # Infrastructure (Auth, Firebase, Persistence)
├── utils/                  # Helper functions (Dates, Strings)
├── constants/              # Static keys & Config
├── navigation/             # App Router (GoRouter)
└── main.dart               # Entry point

## State Management (Riverpod)
We use `riverpod_generator` (`@riverpod` annotation) which auto-generates providers.
- **Repositories**: Standardized Firestore repositories using `withConverter` for type safety and automatic JSON mapping.
    - `FirestoreEventsRepository`
    - `FirestoreMembersRepository`
    - `FirestoreCompetitionsRepository`
    - `FirestoreSeasonsRepository`
    - `FirestoreAuditRepository` (Real-time activity tracking)
- **Services**: 
    - `AuthService` (Firebase Auth)
    - `StorageService` (Firebase Storage - Image Uploads)
    - `SeedingService` (Historical data initialization)
    - `LeaderboardInvokerService` (Season Standings Calculator)
- **Providers**: Defined in `feature/presentation/provider_name.dart`.
- **Consumption**: Widgets extend `ConsumerWidget` and use `ref.watch(provider)`.
- **Cache Management**: 
    - For mutable Firestore data that is deep-linked (e.g., editing a Competition from within an Event Form), we use explicit cache invalidation.
    - `ref.invalidate(provider(id))` is called after a successful save to ensure subsequent loads retrieve the latest document from the repository.

## Domain Logic
Complex business rules are encapsulated in standalone logic classes within the `domain/` folder of each feature or in `core/utils`.
- **Centralized Scoring Engine**: The system uses authoritative calculators to ensure consistency across Scorecard, Grouping, and Leaderboard views.
    - `MatchPlayCalculator`: Authoritative engine for Match Play (Net Match Play, Relative PHC, Fourball/Foursomes status).
    - `ScoringCalculator`: Authoritative engine for Stroke, Stableford, and Max Score capping logic.
    - Pattern: **Calculate Once, Display Everywhere**. Views must NOT implement their own scoring logic.
- **RegistrationLogic**: Centralized helper for calculating FCFS positions, status pills, and buggy allocations.

## Complex Form Architecture
For large, multi-domain forms (e.g., `EventFormScreen`), the project uses a modular decomposition strategy:
- **State Management**: A centralized `AsyncNotifier` (e.g., `EventFormNotifier`) manages a composite `Freezed` state.
- **Sub-Widgets**: The monolithic form is broken into functional sections (e.g., `EventLogisticsSection`, `EventCourseSection`) that consume the central notifier.
- **Persistence Orchestration**: The notifier's `save()` method handles complex multi-repository synchronization (e.g., updating both an Event and its associated Competitions) within a single logical unit.

## Navigation (GoRouter)
The app uses `StatefulShellRoute` to implement the persistent bottom navigation bar.
-   **Shell**: `ScaffoldWithNavBar` wraps the 5 main tabs.
-   **Routes**: Defined in `lib/router.dart`.
-   **Push**: Use `context.push('/path')` or `context.go('/path')`.

## Data Models
Models are immutable and generated using `freezed`.
-   **Location**: `lib/domain/models/`
-   **Extension**: `.freezed.dart` and `.g.dart` (JsonSerializable).
-   **Key Models**:
    -   `Member`: Core user profile.
    -   `GolfEvent`: Stores metadata for a specific competition date. Support for multi-day events via `isMultiDay` (defaults to false) and `endDate`. Includes `selectedFemaleTeeName` for explicit gender-based tee mapping.
    -   `Competition`: Scoring rules, formats, and configurations.
## Code Quality & Hardening
The project maintains a strict standard for code quality and reliability:
- **Zero-Warning Static Analysis**: Powered by `analysis_options.yaml`. The project maintains a "Zero Error" policy where `flutter analyze` must return no issues.
- **Global Resilience**: The app is wrapped in `BoxyArtErrorHandler` which uses `PlatformDispatcher.instance.onError` to catch both build-time "red screens" and asynchronous runtime exceptions globally.
- **Async Safety**: Use of `mounted` guards and localized navigator state ensures `BuildContext` is never used invalidly across async gaps (standardized in Feb 2026).
- **Type Safety**: Heavy reliance on `freezed` for immutable models and `riverpod_generator` for type-safe state management.
- **Import Hygiene**: Strict policing of redundant imports. The project uses a centralized `package:golf_society/design_system/design_system.dart` export for all UI components, drastically reducing import noise.
