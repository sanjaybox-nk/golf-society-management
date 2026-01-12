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
│   ├── home/               # Member Dashboard & Notifications
│   ├── events/             # Events listing & details
│   ├── members/            # Directory & Locker Room
│   ├── admin/              # Management Console (Events, Members, Communications)
│   └── auth/               # Login & Registration flows
├── models/                 # Shared Data Models (Freezed classes)
├── main.dart               # Entry point
└── router.dart             # GoRouter configuration
```

## State Management (Riverpod)
We use `riverpod_generator` (`@riverpod` annotation) which auto-generates providers.
- **Repositories**: `MembersRepository` (Firestore), `EventsRepository` (Firestore)
- **Services**: `AuthService` (Firebase Auth), `StorageService` (Firebase Storage - Image Uploads)
- **Providers**: Defined in `feature/presentation/provider_name.dart`.
-   **Consumption**: Widgets extend `ConsumerWidget` and use `ref.watch(provider)`.

## Navigation (GoRouter)
The app uses `StatefulShellRoute` to implement the persistent bottom navigation bar.
-   **Shell**: `ScaffoldWithNavBar` wraps the 5 main tabs.
-   **Routes**: Defined in `lib/router.dart`.
-   **Push**: Use `context.push('/path')` or `context.go('/path')`.

## Data Models
Models are immutable and generated using `freezed`.
-   **Location**: `lib/models/`
-   **Extension**: `.freezed.dart` and `.g.dart` (JsonSerializable).
