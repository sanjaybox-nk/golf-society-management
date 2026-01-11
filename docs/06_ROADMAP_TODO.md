# Launch Roadmap & ToDo

This document tracks the remaining work required to take **Golf Society Management (BoxyArt)** from prototype to production.

## 1. Backend & Infrastructure
- [ ] **Firebase Setup (Production)**
    - [ ] Create `prod` project in Firebase Console.
    - [ ] Configure Firestore Security Rules (Strict ownership checks).
    - [ ] Set up Cloud Functions for scheduled logic (e.g., closing event registration).
- [ ] **Authentication**
    - [ ] Implement `FirebaseAuth` (Email/Password).
    - [ ] Build **Login Screen** (using BoxyArt inputs).
    - [ ] Build **Sign Up Screen** and Onboarding flow.
    - [ ] Implement "Forgot Password" flow.
- [ ] **Data Migration**
    - [ ] Replace all "Mock Repositories" with "Firestore Repositories".
    - [ ] Create data models for `User`, `Event`, `Result`.

## 2. Core Features Completion
- [ ] **Events**
    - [ ] **Event Details Screen**: View full info, seeing who registered.
    - [ ] **Payment Integration**: Stripe/Apple Pay for event fees.
    - [ ] **Check-in System**: Scanner or manual toggle for day-of events.
- [ ] **Scorecard & Results**
    - [ ] **Digital Scorecard**: Input strokes hole-by-hole.
    - [ ] **Live Leaderboard**: Real-time ranking calculation (Stableford).
    - [ ] **Result Verification**: Admin approval workflow.
- [ ] **Locker Room (Profile)**
    - [x] **Edit Profile**: Form to update handicap, phone, etc.
    - [x] **Photo Upload**: Profile picture management (5MB limit).
    - [ ] **Stats Engine**: Calculate real trends from Firestore data.
- [x] **Communications & Notifications**
    - [x] **Dynamic Home Notifications**: Real-time alerts on Member Home.
    - [x] **Notification Inbox**: History view for all society alerts.
    - [x] **Communications Hub (Admin)**: Tabbed interface for composing alerts and managing audiences.
    - [x] **Audience Manager**: Custom distribution list creation and management.
    - [x] **Notification History (Admin)**: Searchable archive of sent society alerts.

## 3. Policy & Compliance
- [ ] **Legal Documents**
    - [ ] Privacy Policy URL (Required for App Store).
    - [ ] Terms of Service.
- [ ] **App Store Assets**
    - [ ] App Icon (High Res).
    - [ ] Screenshots (iPhone 6.5", iPhone 5.5", iPad).
    - [ ] Feature Graphic (Google Play).

## 4. Quality Assurance (QA)
- [ ] **Device Testing**
    - [ ] Test on physical iOS device.
    - [ ] Test on physical Android device.
    - [ ] Verify "notch" and "dynamic island" safe areas.
- [ ] **Performance**
    - [ ] Check list scrolling performance (should be 60fps).
    - [ ] Verify memory usage (image caching).
- [ ] **Corner Cases**
    - [ ] No internet connection (Offline handling).
    - [ ] Large text sizes (Accessibility).

## 5. Deployment
- [ ] **CI/CD**
    - [ ] Set up GitHub Actions or Codemagic.
- [ ] **Beta Testing**
    - [ ] TestFlight (iOS) Internal Beta.
    - [ ] Google Play Internal Track.
- [ ] **Public Launch**
    - [ ] Submit for Review.
