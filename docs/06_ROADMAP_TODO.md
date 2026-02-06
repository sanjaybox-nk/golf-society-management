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
    - [x] **Event Details Screen**: View full info, seeing who registered.
    - [x] **Interactive Registration (Admin)**: Card-based UI with direct status toggles.
    - [x] **Manual Overrides**: Admins can force registration (Confirmed/Reserved/Waitlist) and buggy status.
    - [x] **Smart Buggy Allocation**: Integrated calculation based on FCFS, payment, and capacity.
    - [x] **Registration History**: Detailed audit trail for status changes and member edits.
    - [x] **Data Resilience**: Protection against registration data loss during event updates.
    - [x] **Event Form Stability**: TextEditingController & FocusNode refactor for Course Config.
    - [ ] **Payment Integration**: Stripe/Apple Pay for event fees.
    - [ ] **Check-in System**: Scanner or manual toggle for day-of events.
- [ ] **Scorecard & Results**
    - [x] **Competition Setup**: Define rules, formats, and handicap allowances.
        - [x] **Customization Flow**: On-the-fly creation and deep-linked rules editing.
        - [x] **Rich Visualization**: Rule-summarizing cards with dynamic status pills.
    - [x] **Template Gallery**: Reusable society-approved game formats.
    - [x] **Marker Counter (Birdie Tree)**: Track birdies/eagles across season.
    - [x] **Eclectic**: Best hole scores across multiple rounds.
    - [x] **Digital Scorecard**: Input strokes hole-by-hole with real-time format extraction.
    - [x] **Live Leaderboard**: Real-time ranking with dynamic support for Stableford/Medal.
    - [x] **Order of Merit (OoM) Points**: Industry standard point conversion (25, 18, 15, 12).
    - [x] **Best N Selection**: Automatically count only the top $N$ rounds for season standings.
    - [x] **Team Attribution**: Individual credit for team/pairs events.
    - [x] **Matchplay Engine**: Independent knockouts and event-layered head-to-head.
    - [x] **Admin Scoring Controls**: Manual 'Force Active' and 'Score Lock' lifecycle management.
    - [ ] **Result Verification**: Admin approval workflow.
- [ ] **Locker Room (Profile)**
    - [x] **Edit Profile**: Form to update handicap, phone, etc.
    - [x] **Profile Input Stability**: ListenableBuilder refactor to prevent cursor jumping.
    - [x] **Photo Upload**: Profile picture management (5MB limit).
    - [ ] **Stats Engine**: Calculate real trends from Firestore data.
- [x] **Communications & Notifications**
    - [x] **Dynamic Home Notifications**: Real-time alerts on Member Home.
    - [x] **Notification Inbox**: History view for all society alerts.
    - [x] **Communications Hub (Admin)**: Tabbed interface for composing alerts and managing audiences.
    - [x] **Audience Manager**: Custom distribution list creation and management.
    - [x] **Notification History (Admin)**: Searchable archive of sent society alerts.
- [x] **Society Branding & Theme System**
    - [x] **Dynamic Theme Engine**: Configurable seed color with automatic contrast calculation.
    - [x] **Branding Settings Screen**: Live preview, color picker, dark mode policy.
    - [x] **Status Color System**: Semantic palette for consistent status indicators.
    - [x] **Contrast Helper**: Automatic text color calculation for accessibility.

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
- [x] **Testing & Verification**
    - [x] **Iterative Testing Lab**: Multi-phase sandbox for seeding and verification.
    - [x] **Phase 3 (Teams)**: Scramble/Pairs logic verification.
    - [x] **Phase 4 (Hardening)**: Stress-test for ties and countbacks.

## 5. Deployment
- [ ] **CI/CD**
    - [ ] Set up GitHub Actions or Codemagic.
- [ ] **Beta Testing**
    - [ ] TestFlight (iOS) Internal Beta.
    - [ ] Google Play Internal Track.
- [ ] **Public Launch**
    - [ ] Submit for Review.
