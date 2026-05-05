# Launch Roadmap & ToDo

This document tracks the remaining work required to take **Golf Society Management (BoxyArt)** from prototype to production and beyond into a multi-tenant SaaS platform.

> [!NOTE]
> For the long-term strategic vision (Divisions, SaaS Architecture, Payments), see the authoritative [Product Roadmap](file:///Users/sanjaypatel/.gemini/antigravity/brain/f128c89b-0d2d-44f8-9635-ae6310603889/product_roadmap.md).

## 1. Backend & Infrastructure
- [ ] **Firebase Setup (Production)**
    - [ ] Create `prod` project in Firebase Console.
    - [ ] Configure Firestore Security Rules (Strict ownership checks).
    - [ ] Set up Cloud Functions for scheduled logic (e.g., closing event registration).
- [x] **Society Cuts UI Standardization** (Completed 2026-04-11)
    - [x] Refactored Global Settings to "Boxy Art" tokens.
    - [x] Moved main access and global rule toggle to Admin Dashboard (Daily Operations).
    - [x] Implemented conditional visibility in Event Controls (Only shows Manual workbench when needed).
    - [x] Removed hardcoded gradients and scaling animations.
    - [!] **Architectural Note**: Implemented dual-level access (Global/Event-specific) to ensure handicap integrity while maintaining operational speed.
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
    - [x] **Control Tower Modernization (v4.0)**: Consolidated fragmented grouping controls into a single "Grouping Hub" navigation tile. Improved vertical rhythm using standardized design tokens.
    - [x] **Grouping Hub Card**: Implemented a unified UI for generation strategy, tee seed, and interval controls, replacing the legacy toolbar.
    - [ ] **Payment Integration**: Stripe/Apple Pay for event fees.
    - [x] **Social & AGM Support**: Tailored admin UI and models for non-golf events.
    - [x] **Event Field Hub Modernization (Design 4.x)** (Completed 2026-04-13): 
        - [x] Migrated Field and Tee Time logic to a centralized `EventFieldHub`.
        - [x] Activated real registration data lists (Entries tab).
        - [x] Refined vertical rhythm and grouping card stability.
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
    - [x] **Matchplay Engine (Overlay Refactor)** (Completed 2026-04-25):
        - [x] Transitioned from standalone "Format" to **Feature Overlay** model (`hasMatchPlayOverlay`).
        - [x] Implemented dual-scoring support for Stableford/Stroke Play + Match Play.
        - [x] Distinguished between **Standard Grouping** (Overlay) and **Tournament Style Grouping** (Seeded Draw).
        - [x] Updated `MatchPlayCalculator` to handle relative PHCs and authoritative results for overlays.
        - [x] Modernized administrative tabs and controls to reflect the "Format + Feature" philosophy.
    - [x] **Digital Scorecard Verification Handshake (v4.7)** (Completed 2026-05-01):
        - [x] **Verification Grid**: Implemented side-by-side comparison of Player vs. Marker scores with conflict highlighting.
        - [x] **Signature Handshake**: Two-way "Sign Off" system (Player + Marker) with automated score-locking.
        - [x] **Story Breakdown**: Integration of all hole attributes (Penalties, Gimmes, Pick Ups) into the verification audit.
        - [x] **Automatic Invalidation**: Implemented logic to clear signatures on any score or tag update to ensure integrity.
        - [x] **Summary Grid**: Added live summary stats for total penalties/gimmes to the main scorecard view.
- [x] **Scoring UX Modernization & Segmented Architecture (v10.5)** (Completed 2026-05-02):
    - [x] **2-Tab Segmented Hub**: Implemented the "SCORING" vs "SCORECARD" split to decouple entry from audit.
    - [x] **Horizontal Paging (Swipe)**: Developed a high-speed, 18-hole `PageView` scoring stream.
    - [x] **Premium Stepper Interface**: Refined cards with large white score boxes and bold blue interaction points for mobile-first speed.
    - [x] **Real-time Conflict Clues**: Integrated "Ghost Scores" (partner records) with **Coral** border highlighting for instant discrepancy detection.
    - [x] **Live Meta-Stats**: Surfaced "Thru" and "Total Points" directly on the swipeable scoring cards.
- [x] **Tee Indicator Refinement**: Replaced full tee pills with streamlined circular dots next to names, including a visibility border for white tees.
- [x] **Live Scorecard UI Modernization (Design 4.x)** (Completed 2026-04-30):
    - [x] **State-aware Indicators**: Implemented "Thru X" vs. authoritative "F" (Finished) logic in `EventScoringProcessor`.
    - [x] **Performance Column Refactor**: Relocated status indicators to the right-hand stack in `BoxyArtMemberRow` for a cleaner visual hierarchy.
    - [x] **Conditional Visibility**: Implemented logic to hide Back Nine metrics during live play, surfacing them only once the event is confirmed/closed by an administrator.
    - [x] **Typographic Standardization**: Applied `dark600` semibold styling to all status indicators for Design 4.x consistency.
- [x] **Gender-Aware Tee Selection & Accessibility Hardening (v4.6)** (Completed 2026-05-01):
    - [x] **Dynamic Tee Resolution**: Implemented player-specific gender lookups in `MarkerSelectionSheet` to automatically assign the correct tee (e.g., Red for females) when 'Auto' is selected.
    - [x] **UI Clarity**: Updated the 'Auto' tee label in dropdowns to show the resolved tee name (e.g., 'Auto (Red)').
    - [x] **Accessibility Standard**: Added a subtle `0.5px` border to all `BoxyArtIndicator` dots globally to ensure visibility of light-colored tee markers on white backgrounds.
- [x] **Branding Console Standardization & Design 4.x Migration** (Completed 2026-04-30):
    - [x] **Design 4.x Vertical Rhythm**: Implemented `followsCard: true` and standardized card spacing across all branding sub-hubs.
    - [x] **Score Color Branding**: Renamed "Score Highlight" to "SCORE COLOR" for clarity and ensured the control is correctly surfaced in the Color Settings hub.
    - [x] **Administrative Labeling**: Standardized all descriptive text and internal labels to `dark600` with Design 4.x semibold/strong typography.
    - [x] **Component Optimization**: Refactored `CompactColorPicker` and `StatusColorRow` with high-fidelity vertical rhythm and responsive wrap-grid logic.
- [x] **Phase 9 Branding Console & Design Token Studio** (Completed 2026-04-21):
    - [x] **Semantic Token System**: Full control over Foundation, Surface, Typography, and Mechanical (Borders/Dividers) properties.
    - [x] **Scoring Aesthetics**: Integrated palette for golf scoring (Eagle to Triple+) and team identity management.
    - [x] **Live Review Hub**: Real-time visualization of branding changes with dark-mode sensitivity.
    - [x] **Architecture Stabilization**: Decoupled technical design tokens (Studio) from daily operational branding (Hub).
    - [x] **Standardized Form Feedback**: Restored `suffixText` (unit indicators) to administrative input fields.
    - [x] **Unified Scorecard View**: Consistent `ScorecardModal` across member/admin leaderboards.
    - [x] **Admin Scoring Controls**: Manual 'Force Active' and 'Score Lock' lifecycle management.
    - [x] **Manual Society Cuts**: Per-event handicap adjustments with automated group sync.
    - [x] **Stability Hardening**: Resolved null safety errors in scorecard state syncing.
    - [x] **Administrative Guest Control (v4.x)**: Implemented "Enable Guest Entry" event-level toggle to conditionally restrict guest participation in invitational or exclusive events.
- [x] **Scoring Interface Refinement & Aesthetic Hardening (v11.0)** (Completed 2026-05-04):
    - [x] **Reactive Token Integration**: Converted player scoring cards to `ConsumerStatefulWidget` for direct synchronization with `effectivePointsColor` branding.
    - [x] **Information Alignment**: Standardized horizontal alignment between "HOLE" headers and scoring cards by eliminating redundant padding.
    - [x] **Vertical Symmetrical Rhythm**: Implemented `CrossAxisAlignment.center` across all card interaction rows for a balanced visual experience.
    - [x] **Hardened Input UI**: Added a subtle, light border to the score input box and increased the font size to **32pt** for hero-level legibility.
    - [x] **Typographic Consolidation**: Reduced "MARKED BY" line height to `1.0` and weight to `w200` to minimize visual intrusion.
    - [x] **Stats Hub Modernization (Design 4.x)** (Completed 2026-04-25):
        - [x] Standardized all comparison heatmaps to 6-column wrap grids with Jakarta Sans w800.
        - [x] Tokenized hole numbers to `microSmall` (10pt) for consistent typographic hierarchy.
        - [x] Refined bubble dimensions (52pt height) for improved touch targets and readability.
    - [x] **Scramble Leaderboard & Grouping Refactor (v4.x)** (Completed 2026-04-25):
        - [x] Implemented multi-line team names in `BoxyArtMemberRow` (each player in own row).
        - [x] Added high-fidelity captain indicator (amber shield + background) to team avatars.
        - [x] Unified grouping hub into a single `BoxyArtCard` architecture with internal themed dividers.
    - [x] **Result Verification**: Admin approval workflow.
- [ ] **Divisions & Groups**
    - [ ] **Categorization**: Support for both fixed (Strict), tagged (Flexible), and handicap-based (Dynamic) groupings.
    - [ ] **Management UI**: Dedicated Admin screen for defining society-wide divisions.
    - [ ] **Member Assignment**: Easy allocation of members to one or more divisions.
    - [ ] **Per-Division Leaderboards**: Filterable OOM and Eclectic reports targeting specific player categories.
- [x] **Member Hub Modernization (Design 4.x)** (Completed 2026-04-27)
    - [x] **Universal Tokenization**: Purged all legacy `Colors.*` constants in favor of branded `AppColors` tokens across all member-facing interfaces.
    - [x] **Branded Async Patterns**: Standardized loading and error states using `BoxyArtLoadingCard` and `BoxyArtEmptyState` components.
    - [x] **Screen Unification (v4.6)**: Merged `MembersScreen` and `AdminMembersScreen` into a single, adaptive component. This eliminated ~350 lines of redundant code and ensures 100% feature parity.
    - [x] **Hardening & Stability**: Resolved critical runtime regressions (`Null` subtype errors) and optimized filtered list calculation for production performance.
    - [x] **Standardized Architecture**: Migrated all member landing pages to the `HeadlessScaffold` pattern for consistent vertical rhythm and navigation shell persistence.
    - [x] **Identity Hub Modernization**: Refactored the `MemberDetailsModal` and `PersonalDetailsForm` with Design 4.x spacing and accessibility standards.
- [x] **Edit Profile**: Form to update handicap, phone, etc.
- [x] **Stats Engine (Design 4.x Upgrade)**: Rich Stats Dashboard with Society & Personal comparative views. Features **StaggeredEntrance** motion, **isPeeking** rhythm, and premium **AppGradients**.
- [x] **Design 4.x Rhythm Archetype**: Standardized vertical "beats" (16pt gap above label, 8pt gap below) across Stats and Leaderboard modules.
- [x] **Communications & Notifications**
    - [x] **Event Comms CMS**: Unified `EventFeedItem` model replacing legacy notes/flash updates.
    - [x] **Event Comms Manager**: Admin interface for reordering/pinning event feed items.
    - [x] **Dynamic Member Feed**: Event Home tab rebuilt to dynamically render broadcast cards.
    - [x] **Dynamic Home Notifications**: Real-time alerts on Member Home.
    - [x] **Notification Inbox**: History view for all society alerts.
    - [x] **Communications Hub (Admin)**: Unified interface for composing alerts, managing event context, and targeting audiences.
        - [x] **Multi-Section Composer (Design 4.x)**: Dynamic, newsletter-style editor supporting multiple content blocks with independent subjects and rich-text.
        - [x] **Save as Draft**: Multi-session persistence for complex newsletter-style notifications using the unified `Campaign` domain model. Includes dual-syncing to the `EventFeed` for immediate "Newsletter Studio" visibility.
    - [x] **Audience Manager**: Custom distribution list creation and management.
    - [x] **Notification History (Admin)**: Searchable archive of sent society alerts.
- [x] **Society Surveys**: Advanced multi-question system with WYSIWYG prompts, drag-and-drop reordering, and Design 4.x "Admin Hub" aesthetic.
- [x] **Interactive Polls**: Live event-room polls with real-time member voting results.
- [x] **Society Branding & Theme System**
    - [x] **Dynamic Theme Engine**: Configurable seed color with automatic contrast calculation.
    - [x] **Branding Settings Screen**: Live preview, color picker, dark mode policy, and granular shadow/border control.
    - [x] **Status Color System**: Semantic palette for consistent status indicators.
    - [x] **Contrast Helper**: Automatic text color calculation for accessibility.
    - [x] **Administrative Identity Modernization (v4.2)**: Extricated Society Identity (Name/Logo) and Appearance (Theme Mode) into a focused admin hub, decoupling daily branding from technical design tokens.
- [x] **Administrative Branding Pill Standardization (v4.3)** (Completed 2026-04-14):
    - [x] Migrated the `ADMIN` branding pill from header `actions` to `titleSuffix` across all 27+ administrative screens.
    - [x] Decoupled branding from functional action buttons to improve vertical rhythm and layout stability.
    - [x] Performed a final global audit to ensure 100% codebase compliance with the new standard.
- [x] **Society Reporting Hub (Premium Suite)**
    - [x] **Executive Dashboard**: Season progress, society pulse, and treasury overview.
    - [x] **Financial Tracking**: Treasury ledger with automated Club Bill logic (Green Fees/Catering) and centralized Miscellaneous Expense management.
    - [x] **Fines & Charity System**: High-fidelity member penalty tracking with 'Paid' status toggles and ad-hoc charity pot collections.
    - [x] **Season Synchronization (2025-26)**: Professional 12-month calendar with balanced Season (8x Stableford) and Invitational (4x Mixed) formats.
    - [x] **Engagement Analytics**: Retention rates, churn alerts, and attendance rankings.
    - [x] **Professional Exports**: Native Export to PDF and CSV support.
- [x] **Admin Design 3.1 Hardening**
    - [x] **Full UI Refactor**: Dashboard, Settings, Members, Notifications, and Seasons aligned to Boxy Art 3.1.
    - [x] **Typography & Rhythm Audit**: Standardized all spacing and font tokens using Design 3.1 primitives.
- [x] **Global Administrative Identity & Vertical Rhythm Standard (v4.x)**: Systematic application of the `ADMIN` pill across all secondary consoles and standardization of tabbed interface spacing using the `cardToLabel` token (16px) for optimized optical rhythm.
- [x] **Administrative Console Phase 2 Standardization (v4.x)**: Refactored Event, Competition, and Settings hubs to eliminate all-caps and implement high-precision vertical rhythm via the `isPeeking: true` token.
- [x] **Design 4.x Empty State Modernization (v4.x)**: Replaced all legacy legacy `BoxyArtEmptyState` components with premium `BoxyArtEmptyCard` across the entire administrative suite (Events, Grouping, Role Management, and Global Errors).
- [x] **Design 4.x Spacing & Card Standardization (v4.3)** (Completed 2026-04-11):
    - [x] Fully tokenized all vertical rhythm using `AppSpacingTokens` in Society Cuts, Control Tower, and Event Forms.
    - [x] Standardized `BoxyArtCard` padding to dynamically inherit society-specific branding.
    - [x] Implemented the **Pocketed Input Pattern** for high-density settings.
- [x] **True Minimal v3.7 Redesign**
    - [x] **Universal Title Case**: Elimination of all-caps across entire app interface.
    - [x] **Pill-to-Legend Shift**: Converted badge components to minimalist dot + text indicators.
    - [x] **Member Card Refinement**: Relocated status legends for cleaner data hierarchy.
- [x] **Handicap Display Standardization (v4.0)**: Consolidated all HC/PHC displays to premium `BoxyArtPill` format with strict 1-decimal index formatting across all modules.
- [x] **Tournament UX & Radius Hardening (v3.8)**
    - [x] **Flattened Navigation (v4.0 Update)**: Implementation of unified 5-tab "Tournament Mode" hub with specialized Admin/Player shells, stable router keys, and isolated navigator stacks.
    - [x] **Radius Sync**: Resolved visual mismatches across cards using authoritative clipping.
    - [x] **Direct Scoring Access**: Added "ENTER SCORE" shortcuts to main event hubs.
    - [x] **Refined Logic Display**: Updated scorecard summaries with MATCH status and improved typo hierarchies.
- [x] **Codebase Hardening & Audit**
    - [x] **Duplicate Elimination**: Deleted legacy `ModernMemberCard` and feature-specific pills.
    - [x] **Library Standardized**: Cleaned up `metrics.dart` and standardized `BoxyArtPill` as single source of truth.
    - [x] **SDK & Theme Restoration (Apr 2026)**: Successful modernization to Flutter 3.41 / Dart 3.11 and synchronization of Design 4.x badge tokens across all hubs.
    - [x] **Administrative Shell Stabilization (v7.1)** (Completed 2026-04-21): 
        - [x] Corrected `StatefulShellBranch` nesting and bracket alignment in `app_router.dart`.
        - [x] Standardized `useRootNavigator: true` for administrative modals to resolve shell-based clipping.
        - [x] Implemented context-aware `eventId` passing for Competition Gallery and Selection flows.
        - [x] Audited and synchronized global administrative edit menus to minimize navigation friction.
    - [x] **Administrative UI Refresh (v4.5)** (Completed 2026-04-22):
    - [x] **Tab Iconography Standardization**: Integrated "Icon + Label" pattern across all navigation hubs (Events, Members, Reports, Renewal, Dashboard, and Match Play).
    - [x] **Navigation Consistency**: Swapped button-style controls for underlined tabs in `EventTypeSection`.
    - [x] **UI Component Expansion**: Updated `ModernUnderlinedTabBar` to support iconography.
    - [x] **Scorecard Stability**: Refactored scorecard rendering to eliminate IIFE-based syntax errors and corrected hole masking logic.
- [x] **Administrative Seeding Infrastructure Consolidation (v4.x)** (Completed 2026-04-23):
    - [x] **Unified Master Seed**: Consolidated fragmented seeding processes into a single "Initialize Demo Season" workflow in `SeedingService`.
    - [x] **Match Play Integration**: Integrated the 36-player Match Play progression scenario directly into the master seeding orchestration.
    - [x] **Infrastructure Hierarchy**: Implemented a clear 3-tier action system (Clear Activity / Master Seed / Factory Reset) with high-fidelity administrative toggles.
    - [x] **UI Responsiveness & Layout**: Refactored `BoxyArtDialog` with `OverflowBar` to prevent button truncation. Standardized "Boxy Art" v4.x tokens across the settings hub.
    - [x] **Typography Hardening**: Applied ALL-CAPS metadata standards and corrected button text fit (e.g. "CLEAR").
    - [x] **Tournament Switchboard**: Controlled via the `showMatchPlayOverlay` toggle in Society Config.
- [x] **Stableford Points Tokenization & Branding Integration (v4.x)** (Completed 2026-04-23):
    - [x] **Dynamic Branding Token**: Added `pointsColor` to `SocietyConfig` for centralized scoring accent control.
    - [x] **Administrative UI**: Integrated the "Points Emphasis" color picker into the Branding Console.
    - [x] **Hero Metric Standardization**: Refactored `CourseInfoCard`, `BoxyArtMemberRow`, and `ScorecardModal` to consume the dynamic token, replacing hardcoded values.
    - [x] **Consistent Logic**: Converted core scoring widgets to `ConsumerWidget` for real-time aesthetic updates across the admin and player suites.
- [x] **Event Scoring Navigation & Visibility Standardization (v4.x)** (Completed 2026-04-23):
    - [x] **Tab Reorganization**: Prioritized "GROUPS" as the default tab, followed by "Standings", "Bracket", and "Verify".
    - [x] **Terminology Alignment**: Renamed "Leaderboard" to "Standings" across all admin and player hubs.
    - [x] **Score Visibility Hub (Admin)**: Implemented a "VIEW SCORES" master toggle in the Admin Groups tab to switch between organization and live result views.
    - [x] **Data Integrity**: Expanded the scoring processor to include all players present in event groups, ensuring admins see results for the entire field.
    - [x] **Responsive Navigation**: Hardened the `HoleByHoleScoringWidget` with flexible layouts to eliminate horizontal overflow regressions.
- [x] **Society Cuts Restructure (Apr 2026)**: Moved global configuration to Admin Dashboard and implemented conditional manual workbench in Event Controls.
- [x] **Smart Tee Visibility & Navigation Fix (v4.x)** (Completed 2026-04-26):
    - [x] **Smart Tee Resolution**: Refactored `ScoringCalculator` to provide authoritative tee resolution (Admin Override > Player Override > Registration > Event Default).
    - [x] **Visual Indicators**: Integrated player-specific tee color markers into the Leaderboard (`BoxyArtMemberRow`) and Grouping (`GroupingPlayerTile`) views.
    - [x] **Navigation Bug Fix**: Resolved the "Page Not Found" error for the Admin Scorecard Editor by defining the missing sub-route in `app_router.dart`.
    - [x] **Code Hardening**: Eliminated ambiguous imports and duplicate code in multiple scoring and grouping widgets.
        - [x] Purged legacy `event_user_placeholders.dart` and standardized direct modular imports.
        - [x] Verified full architectural stability and vertical rhythm across all 30+ administrative hubs.
        - [x] Achieved a perfect, zero-warning state for production readiness.

## 3. Architecture & Patterns
#### Society Cuts Access Logic
Cuts follow a dual-accessibility pattern based on administrative context:
- **Global Configuration**: Accessed via the **Admin Console (Dashboard)**. This Hub allows admins to toggle between *Manual*, *Global*, or *Off* modes and define society-wide penalty rules.
- **Event Manual Overrides**: The workbench tile in the **Control Tower (Event Controls)** is now conditional. It only appears if the global mode is set to **Manual**, ensuring a cleaner workspace for societies using automated or disabled cuts.

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
- [x] **Admin Console Zero-Errors Initiative (Apr 2026)**: Full v4.0/4.1 standardisation across all admin hubs. Resolved all syntax corruption, undefined identifiers, deprecated API usages (`activeColor`, `value`), unused elements, and async-gap context violations. Project exits `flutter analyze` with **exit code 0**.
- [x] **Seeding & Scenario Hardening (Apr 2026)**: Finalized the `VerificationScenario` engine in `ScenarioSeeder`. Implemented surgical data pruning in `MatchPlaySeeder` and resolved all remaining unused variable and import warnings across the seeding suite.
    - [x] **Administrative UI Const Hygiene (v6.2)**: Resolved project-wide compilation errors caused by non-const factory usage (`BoxyArtPill.committee`) in `actions` lists across 16+ administrative screens.
    - [x] **Scaling Verification**: Simulation of 60+ member seasons with realistic data distribution.
    - [x] **Scoring Hardening (Apr 2026)**: Finalized administrative result verification workflow. Implemented Verification Hub in `EventAdminScoresScreen`, bulk scorecard approval, and strict scoring lock enforcement (`isScoringLocked`) in the UI. Overhauled Match Play UI containers with premium BoxyArt components.

## 5. Deployment
- [ ] **CI/CD**
    - [ ] Set up GitHub Actions or Codemagic.
- [ ] **Beta Testing**
    - [ ] TestFlight (iOS) Internal Beta.
    - [ ] Google Play Internal Track.
- [ ] **Public Launch**
    - [ ] Submit for Review.

## 6. Completed Milestones (2026)
- [x] **Matchplay Engine Integration** (v8.0)
- [x] **Administrative Modularization & Architecture Hardening** (v8.0)
- [x] **Event Form UI Hardening (iOS Simulator Stabilization)** (v8.1)
- [ ] **Phase 10: Production Infrastructure** (Pending)
- [x] **Phase 12: Codebase Audit** (Completed 2026-05-04): Comprehensive architectural audit of all 361 source files (~79K LOC). Full report at `docs/CODEBASE_AUDIT_REPORT.md`.

## 7. Refactoring Backlog (Post-Audit)
> See `docs/CODEBASE_AUDIT_REPORT.md` for full analysis. Phases below map to the report's roadmap.

### Phase 1 — Zero-Risk Hygiene 🟢 (Scheduled)
- [ ] Create `ScorecardFactory` (`lib/domain/scoring/scorecard_factory.dart`)
- [ ] Create `FirestoreNormalizer.resolveMemberId()` (`lib/utils/firestore_normalizer.dart`)
- [ ] Replace 72 `debugPrint` calls with `kDebugMode`-gated logging
- [ ] Extract `roundId: '1'` and `'system'` to `ScorecardConstants`
- [ ] Consolidate orphan barrel files in `design_system/widgets/`

### Phase 2 — Extract Shared Logic 🟡 (Scheduled)
- [ ] Replace all 10+ inline `Scorecard(...)` constructions with `ScorecardFactory`
- [ ] Replace all 160+ `memberId ?? userId ?? playerId` chains with `FirestoreNormalizer`
- [ ] Extract `buildParticipantTile` closure to `_buildTile()` in `GroupingCard`
- [ ] Remove duplicate `GroupingPlayerTile` in legacy flat-list path (`grouping_widgets.dart:711-741`)
- [ ] Audit and consolidate `seeding_service.dart` vs `event_seeder.dart` (delete orphan)
- [ ] Split `SocietyConfig` into `SocietyConfig` + `VisualTokens` sub-objects

### Phase 3 — Decompose God Files 🟠 (Scheduled)
- [ ] `scorecard_modal.dart` → `ScorecardResolver` + `ScorecardSheet`
- [ ] `event_scoring_processor.dart` → per-format processors + thin orchestrator
- [ ] `grouping_widgets.dart` → 3 separate widget files
- [ ] `app_router.dart` → 4 route family files
- [ ] `member_home_screen.dart` → screen + `HomeScreenViewModel` AsyncNotifier

### Phase 4 — Move Logic Out of `build()` 🟠 (Scheduled)
- [ ] Pre-compute scorecard resolution before opening `ScorecardSheet`
- [ ] Move match play computation out of `ScorecardModal` builder
- [ ] Cache `relativePhcMap` in `GroupingCard` (not computed inline)
- [ ] Introduce `HomeScreenViewModel` provider

### Phase 5 — Architecture Upgrade 🔵 (Long-term)
- [ ] Normalize Firestore result documents to canonical `memberId` field
- [ ] Introduce per-format `ScoringStrategy` interface
- [ ] Add unit tests for `ScorecardFactory`, `FirestoreNormalizer`, `HandicapCalculator`
- [ ] Design system: formal atoms/molecules/organisms folder structure
