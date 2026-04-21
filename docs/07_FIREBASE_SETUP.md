# Firebase Integration Guide

You are ready to connect your app to the Firestore Console!

## Phase 1: Configuration (User Action Required)
Because these files contain secret API keys, you must download them manually from your Firebase Console.

### 1. Download Android Config
1.  Go to **Project Settings** (Gear icon ⚙️ at top left).
2.  Scroll down to "Your apps".
3.  Select the **Android** app (`com.golfsociety.golf_society`).
4.  Click **Download google-services.json**.
5.  **Move file to**: `android/app/google-services.json` in your project folder.

### 2. Download iOS Config
1.  In "Your apps", select the **iOS** app (`com.golfsociety.golf_society`).
2.  Click **Download GoogleService-Info.plist**.
3.  **Move file to**: `ios/Runner/GoogleService-Info.plist`.

### 3. Link File in Xcode (Critical for iOS)
Simply copying the file isn't enough; Xcode needs to know about it.
1.  Open `ios/Runner.xcworkspace` by double-clicking it or using `open ios/Runner.xcworkspace`.
2.  In Xcode, look at the left sidebar (Project Navigator).
3.  Right-click the yellow **Runner** folder.
### Storage
- **Bucket**: Default bucket
- **Rules**: Allow read/write for authenticated users only (Required for App Logic)
  ```javascript
  allow read, write: if request.auth != null;
  ```
- **Path Structure**: `avatars/{memberId}_{timestamp}.jpg` (Unique filenames for cache busting)

### Authentication
- **Anonymous Auth**: Must be enabled in the Firebase Console (Build > Authentication > Sign-in method).
  - *Reason*: The app signs in as an anonymous user to satisfy the "authenticated only" storage rule.
4.  Select **Add Files to "Runner"...**.
5.  Select `GoogleService-Info.plist` from the list.
6.  **Important**: Ensure "Add to targets: Runner" is CHECKED.
7.  Click **Add**.

## Phase 2: Verify Connection
Once files are in place:
1.  Stop the running app.
2.  Run `flutter run` again.
3.  The error `Firebase init failed` should disappear from the logs.

## Phase 3: Cloud Functions Setup (Developer Action)

The project includes a robust set of Cloud Functions located in the `firebase/functions` directory. These functions handle automated tasks such as Match Play reminders and scoring.

### 1. Structure Initialization
If the environment is missing, the following files must be present:
- `firebase/functions/package.json`: Manages Node.js dependencies (`firebase-admin`, `firebase-functions`).
- `firebase/functions/tsconfig.json`: Configures the TypeScript compiler.
- `firebase/functions/src/index.ts`: The central entry point for all function triggers.

### 2. Development Workflow
To install dependencies and build the functions:
```bash
cd firebase/functions
npm install
npm run build
```

### 3. Deployment
Register the functions directory in the root `firebase.json`:
```json
{
  "functions": {
    "source": "firebase/functions"
  }
}
```
Deploy using the Firebase CLI:
```bash
firebase deploy --only functions
```

## Phase 4: Data Migration (Developer Action)
Once connected, I will update the code to:
1.  Stop using "Mock Data".
2.  Read from the `events` collection in Firestore.
3.  You will then create documents in the Console (as shown in your screenshot) to populate the app.
