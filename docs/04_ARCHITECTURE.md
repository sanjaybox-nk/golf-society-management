# Architecture & Project Structure

The project follows a **Feature-First** architecture combined with Riverpod for state management.

## Folder Structure (`lib/`)

```
lib/
├── core/                   # Shared resources across the app
│   ├── theme/              # AppTheme, AppShadows, StatusColors, ContrastHelper
│   ├── shared_ui/          # Modular UI library (buttons, cards, inputs, badges, layout)
│   ├── widgets/            # Legacy facade (boxy_art_widgets.dart)
│   ├── utils/              # Helper functions (dates, formatters)
│   └── constants/          # Environment vars, static keys
├── features/               # distinct domains of the application
├── home/               # Member Dashboard & Notifications
├── events/             # Events listing & details
│   ├── domain/         # Business logic (RegistrationLogic.dart)
│   ├── presentation/   # UI Tabs and Registration Cards
├── members/            # Directory & Locker Room
├── admin/              # Management Console (Events, Members, Communications)
└── auth/               # Login & Registration flows
├── models/                 # Shared Data Models (Freezed classes)
├── main.dart               # Entry point
└── router.dart             # GoRouter configuration
```

## State Management (Riverpod)
We use `riverpod_generator` (`@riverpod` annotation) which auto-generates providers.
- **Repositories**: `MembersRepository` (Firestore), `EventsRepository` (Firestore), `CompetitionsRepository` (Firestore)
- **Services**: 
    - `AuthService` (Firebase Auth)
    - `StorageService` (Firebase Storage - Image Uploads)
    - `SeedingService` (Testing Lab - Iterative data initialization)
    - `LeaderboardInvokerService` (Season Standings Calculator)
- **Providers**: Defined in `feature/presentation/provider_name.dart`.
- **Consumption**: Widgets extend `ConsumerWidget` and use `ref.watch(provider)`.
- **Cache Management**: 
    - For mutable Firestore data that is deep-linked (e.g., editing a Competition from within an Event Form), we use explicit cache invalidation.
    - `ref.invalidate(provider(id))` is called after a successful save to ensure subsequent loads retrieve the latest document from the repository.

## Domain Logic
Complex business rules are encapsulated in standalone logic classes within the `domain/` folder of each feature.
- **RegistrationLogic**: Centralized helper for calculating FCFS positions, status pills, and buggy allocations. Ensures consistency between Member and Admin apps.
- **Scoring Calculators**: Domain-specific engines for calculating standings (OOM, Stableford, Eclectic, etc.).
- **RegistrationItem**: A "View Model" bridge that flattens complex nested registration data for simple rendering in UI components.

## Navigation (GoRouter)
The app uses `StatefulShellRoute` to implement the persistent bottom navigation bar.
-   **Shell**: `ScaffoldWithNavBar` wraps the 5 main tabs.
-   **Routes**: Defined in `lib/router.dart`.
-   **Push**: Use `context.push('/path')` or `context.go('/path')`.

## Data Models
Models are immutable and generated using `freezed`.
-   **Location**: `lib/models/`
-   **Extension**: `.freezed.dart` and `.g.dart` (JsonSerializable).
-   **Key Models**:
    -   `Member`: Core user profile.
    -   `GolfEvent`: Tournament/Event data.
    -   `Competition`: Scoring rules, formats, and configurations.
## Code Quality & Hardening
The project maintains a strict standard for code quality and reliability:
- **Strict Linting**: Powered by `analysis_options.yaml` (including `flutter_lints`).
- **Async Safety**: Use of `mounted` guards and localized navigator state ensures `BuildContext` is never used invalidly across async gaps.
- **Type Safety**: Heavy reliance on `freezed` for immutable models and `riverpod_generator` for type-safe state management.
- **Dead Code Policing**: Regular audits to remove unused imports, variables, and private methods.
