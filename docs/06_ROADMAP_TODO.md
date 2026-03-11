# Launch Roadmap & ToDo

This document tracks the remaining work required to take **Golf Society Management (BoxyArt)** from prototype to production and beyond into a multi-tenant SaaS platform.

> [!NOTE]
> For the long-term strategic vision (Divisions, SaaS Architecture, Payments), see the authoritative [Product Roadmap](file:///Users/sanjaypatel/.gemini/antigravity/brain/f128c89b-0d2d-44f8-9635-ae6310603889/product_roadmap.md).

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
    - [x] **Social & AGM Support**: Tailored admin UI and models for non-golf events.
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
    - [x] **Dynamic Member Standings**: Live season rank and performance statistics on member profiles.
    - [x] **Team Attribution**: Individual credit for team/pairs events.
    - [x] **Matchplay Engine**: Independent knockouts and event-layered head-to-head.
        - [x] **Secondary Overlays**: Run matchplay alongside Stableford/Medal.
        - [x] **Interactive Grouping**: Tap-to-Swap pairing logic on the tee sheet.
    - [x] **Unified Scorecard View**: Consistent `ScorecardModal` across member/admin leaderboards.
    - [x] **Admin Scoring Controls**: Manual 'Force Active' and 'Score Lock' lifecycle management.
    - [x] **Manual Society Cuts**: Per-event handicap adjustments with automated group sync.
    - [x] **Stability Hardening**: Resolved null safety errors in scorecard state syncing.
    - [ ] **Result Verification**: Admin approval workflow.
- [ ] **Divisions & Groups**
    - [ ] **Categorization**: Support for both fixed (Strict), tagged (Flexible), and handicap-based (Dynamic) groupings.
    - [ ] **Management UI**: Dedicated Admin screen for defining society-wide divisions.
    - [ ] **Member Assignment**: Easy allocation of members to one or more divisions.
    - [ ] **Per-Division Leaderboards**: Filterable OOM and Eclectic reports targeting specific player categories.
- [ ] **Locker Room (Profile)**
    - [x] **Edit Profile**: Form to update handicap, phone, etc.
    - [x] **Profile Input Stability**: ListenableBuilder refactor to prevent cursor jumping.
    - [x] **Photo Upload**: Profile picture management (5MB limit).
    - [x] **Stats Engine**: Rich Stats Dashboard with Society & Personal comparative views (WHS Net Differential calculation).
- [x] **Communications & Notifications**
    - [x] **Event Broadcast CMS**: Unified `EventFeedItem` model replacing legacy notes/flash updates.
    - [x] **CMS Configurator**: Admin interface for creating/managing event broadcasts (Drafts, Pinned).
    - [x] **Dynamic Member Feed**: Event Home tab rebuilt to dynamically render broadcast cards.
    - [x] **Dynamic Home Notifications**: Real-time alerts on Member Home.
    - [x] **Notification Inbox**: History view for all society alerts.
    - [x] **Communications Hub (Admin)**: Tabbed interface for composing alerts and managing audiences.
    - [x] **Audience Manager**: Custom distribution list creation and management.
    - [x] **Notification History (Admin)**: Searchable archive of sent society alerts.
- [x] **Society Surveys**: Multi-question survey system with dedicated admin manager.
- [x] **Interactive Polls**: Live event-room polls with real-time member voting results.
- [x] **Society Branding & Theme System**
    - [x] **Dynamic Theme Engine**: Configurable seed color with automatic contrast calculation.
    - [x] **Branding Settings Screen**: Live preview, color picker, dark mode policy, and granular shadow/border control.
    - [x] **Status Color System**: Semantic palette for consistent status indicators.
    - [x] **Contrast Helper**: Automatic text color calculation for accessibility.
- [x] **Society Reporting Hub (Premium Suite)**
    - [x] **Executive Dashboard**: Season progress, society pulse, and treasury overview.
    - [x] **Financial Tracking**: Treasury ledger with markup analysis and uncollected revenue alerts.
    - [x] **Engagement Analytics**: Retention rates, churn alerts, and attendance rankings.
    - [x] **Professional Exports**: Native Export to PDF and CSV support.
- [x] **Admin Design 3.1 Hardening**
    - [x] **Full UI Refactor**: Dashboard, Settings, Members, Notifications, and Seasons aligned to Boxy Art 3.1.
    - [x] **Typography & Rhythm Audit**: Standardized all spacing and font tokens using Design 3.1 primitives.
- [x] **True Minimal v3.7 Redesign**
    - [x] **Universal Title Case**: Elimination of all-caps across entire app interface.
    - [x] **Pill-to-Legend Shift**: Converted badge components to minimalist dot + text indicators.
    - [x] **Member Card Refinement**: Relocated status legends for cleaner data hierarchy.
- [x] **Tournament UX & Radius Hardening (v3.8)**
    - [x] **Flattened Navigation**: Implementation of 5-tab "Tournament Mode" shell.
    - [x] **Radius Sync**: Resolved visual mismatches across cards using authoritative clipping.
    - [x] **Direct Scoring Access**: Added "ENTER SCORE" shortcuts to main event hubs.
    - [x] **Refined Logic Display**: Updated scorecard summaries with MATCH status and improved typo hierarchies.
- [x] **Codebase Hardening & Audit**
    - [x] **Duplicate Elimination**: Deleted legacy `ModernMemberCard` and feature-specific pills.
    - [x] **Library Standardized**: Cleaned up `metrics.dart` and standardized `BoxyArtPill` as single source of truth.

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
    - [x] **Full Demo Seeding**: Multi-phase engine for generating historical data.
    - [x] **Phase 3 (Teams)**: Scramble/Pairs logic verification.
    - [x] **Phase 4 (Hardening)**: Stress-test for ties and countbacks.
    - [x] **Match Play Simulation**: Automated match outcomes and standings verification.
    - [x] **Code Quality Hardening**: Achievement of "Zero Error" state across the entire codebase (Feb 2026).
    - [x] **Scaling Verification**: Simulation of 60+ member seasons with realistic data distribution.

## 5. Deployment
- [ ] **CI/CD**
    - [ ] Set up GitHub Actions or Codemagic.
- [ ] **Beta Testing**
    - [ ] TestFlight (iOS) Internal Beta.
    - [ ] Google Play Internal Track.
- [ ] **Public Launch**
    - [ ] Submit for Review.
