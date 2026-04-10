# Setup Guide

## Prerequisites
-   **Flutter SDK**: Latest Stable (Verified on 3.41+)
-   **Dart SDK**: Compatible with Flutter version.
-   **Android Studio / Xcode**: For emulator/simulator management.

## Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/your-username/golf-society-management.git
    cd golf-society-management
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

- `iconLg` / `iconLarge` — 32px
- `iconXl` — 40px

---

## 5.1 Design System Extensions (`AppShapeTokens`)

The shapes system is extended with tokenized badge metrics injected from the `SocietyConfig`:

| Token | Purpose |
|---|---|
| `iconBadgeSize` | The base square side-length for brand-tinted badges. |
| `iconBadgeIconSize` | The inner icon size for brand-tinted badges. |

> [!NOTE]
> These tokens ensure that specialized badges like `BoxyArtIconBadge` remain perfectly synchronized across all hubs.

3.  **Run Code Generation**
    This project uses `riverpod_generator` and `freezed`. You must run the build_runner to generate files (e.g., `.g.dart`, `.freezed.dart`).
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
    *Tip: Keep it running in watch mode during development:*
    ```bash
    dart run build_runner watch
    ```

## Firebase Setup (Required for Production/Auth)
*Note: The app currently uses Mock Data for UI development, but Firebase hooks are present.*

1.  Create a project in the [Firebase Console](https://console.firebase.google.com/).
    - [x] **Library Standardized**: Cleaned up `metrics.dart` and standardized `BoxyArtPill` as single source of truth.
    - [x] **SDK & Theme Restoration (Apr 2026)**: Successful modernization to Flutter 3.41 / Dart 3.11 and synchronization of Design 4.x badge tokens across all hubs.
2.  **Android**: Download `google-services.json` and place it in `android/app/`.
3.  **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
4.  Enable **Authentication** (Email/Password) and **Firestore** Database.

## Running the App
Select your device and run:
```bash
flutter run
```

## Quality Assurance
To ensure the codebase remains healthy, every commit must pass static analysis:
```bash
flutter analyze
```
*Note: This project follows a strict **Zero Error/Zero Warning** policy. The command above must exit with code 0.*

### `BoxyArtIconBadge`
Square icon badge with optional tint fill.
- **Synchronized**: Size and inner icon scale are controlled via the `AppShapeTokens` extension.
- **Usage**: Standardized for empty states (`BoxyArtEmptyCard`) and feature identity headers.

## Troubleshooting
-   **"Firebase init failed"**: This is normal if you haven't added the config files yet. The app will fallback to mock data or error gracefully in UI.
-   **Shadow Clipping**: If you see shadows cut off on cards, ensure `clipBehavior` is NOT set on the Container. Clipping should be applied via an inner `ClipRRect`.
4. **Consolidated Opacity**: Use `AppColors.opacityX` tokens — prefer `withValues(alpha: ...)` in modern Flutter 3.41+.
-   **Android NDK Missing**: If `flutter run` fails with `InstallFailedException ... ndk`, run:
    ```bash
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "ndk;28.2.13676358"
    ```
    Or check "NDK (Side by side)" in Android Studio SDK Tools.
