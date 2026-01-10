# Setup Guide

## Prerequisites
-   **Flutter SDK**: Latest Stable (Verified on 3.24+)
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
2.  **Android**: Download `google-services.json` and place it in `android/app/`.
3.  **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
4.  Enable **Authentication** (Email/Password) and **Firestore** Database.

## Running the App
Select your device and run:
```bash
flutter run
```

## Troubleshooting
-   **"Firebase init failed"**: This is normal if you haven't added the config files yet. The app will fallback to mock data or error gracefully in UI.
-   **Shadow Clipping**: If you see shadows cut off on cards, ensure `clipBehavior` is NOT set on the Container. Clipping should be applied via an inner `ClipRRect`.
-   **Android NDK Missing**: If `flutter run` fails with `InstallFailedException ... ndk`, run:
    ```bash
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "ndk;28.2.13676358"
    ```
    Or check "NDK (Side by side)" in Android Studio SDK Tools.
