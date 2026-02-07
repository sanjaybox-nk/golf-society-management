# Event Scores Implementation Plan

## Overview
This document outlines the implementation plan for the Event Scores feature, covering both Admin and Member-facing views.

---

## Current State

### ✅ Already Implemented (Member View)
- [x] Live leaderboard display
- [x] "Enter Scorecard" button for self-submission
- [x] Real-time standings with position, name, HC, and score
- [x] Dark theme UI with clean card-based layout
- [x] "My Score" tab with personal scorecard display
- [x] "Stats" tab with score breakdown (Birdies, Pars, Bogeys)
- [x] Real-time Stableford points calculation based on par and handicap

---

## Admin Event Scores Screen

### 1. Event Status Card (Top Section)
- [ ] Display event summary (date, course, weather conditions)
- [ ] Show submission progress bar ("24/28 players submitted")
- [ ] Display key metrics:
  - [ ] Total players who submitted scores
  - [ ] Average score
  - [ ] Lowest/highest scores
  - [ ] Competition status (In Progress / Completed)
- [ ] Quick action buttons:
  - [ ] "Publish Results" toggle
  - [ ] "Send Reminder" (to players who haven't submitted)
  - [ ] "Lock Scores" (prevent further edits)

### 2. Tab 1: Score Entry/Review ✏️
- [ ] List all players (grouped by tee time/group)
- [ ] Each player row displays:
  - [ ] Player name with avatar
  - [ ] Handicap (HC) and Playing Handicap (PHC)
  - [ ] Score input field (if not submitted)
  - [ ] Submitted score with edit icon (if already submitted)
  - [ ] Status indicator:
    - [ ] ✓ Submitted (green)
    - [ ] ⏳ Pending (amber)
    - [ ] ✏️ Admin Entered (blue)
  - [ ] Quick "Enter Scorecard" button per player
- [ ] Filter options:
  - [ ] All players
  - [ ] Submitted only
  - [ ] Pending only
  - [ ] By group/tee time
- [ ] Bulk actions:
  - [ ] "Mark all as submitted"
  - [ ] "Send reminders to pending"
- [ ] Scorecard entry modal:
  - [ ] Quick entry: Total score input
  - [ ] Detailed entry: Hole-by-hole breakdown (expandable accordion)
  - [ ] Validation: Flag impossible scores
  - [ ] Save/Submit button

### 3. Tab 2: Leaderboard Preview 🏆
- [ ] Display same view members see (for verification)
- [ ] Toggle between scoring formats:
  - [ ] Gross scores
  - [ ] Nett scores
  - [ ] Stableford points
- [ ] Position indicators (1st, 2nd, 3rd with medals/badges)
- [ ] Search bar to find specific players
- [ ] "Publish to Members" button
- [ ] "View as Member" preview mode

### 4. Tab 3: Competition Results 🎁
- [ ] Auto-calculate winners based on competition rules
- [ ] Display prize categories:
  - [ ] 1st, 2nd, 3rd place
  - [ ] Category winners (if applicable)
- [ ] Special awards section:
  - [ ] Nearest to pin
  - [ ] Longest drive
  - [ ] Other custom prizes
- [ ] Prize allocation interface
- [ ] Export/Print certificate option
- [ ] Team scores (if team event)

### 5. Tab 4: Statistics 📊
- [ ] Visual charts:
  - [ ] Score distribution histogram
  - [ ] Birdies/Pars/Bogeys breakdown pie chart
  - [ ] Performance trends
- [ ] Competition-specific statistics
- [ ] Comparison with previous events

### 6. Tab 5: Audit Log 📋
- [ ] Track all score changes with timestamps
- [ ] Display who submitted/edited scores
- [ ] Show original vs. modified scores
- [ ] Filter by player or date
- [ ] Export audit trail

### 7. Bottom Actions
- [ ] Export button (CSV/PDF formats)
- [ ] Share results (email/social)
- [ ] Edit competition rules link
- [ ] Delete event scores (with confirmation)

---

## Member Event Scores Screen (Enhancements)

### Current Features (Already Implemented)
- [x] Live standings display
- [x] "Enter Scorecard" button
- [x] Position, name, HC, and score display

### Proposed Enhancements
- [ ] Add filter/toggle for Gross/Nett/Stableford views
- [ ] Show player's own position highlighted
- [x] Add "My Score" quick view card at top
- [x] Display submission status ("Score submitted ✓" or "Submit your score")
- [ ] Show competition prizes/categories
- [ ] Add refresh indicator for live updates
- [ ] Display score submission deadline countdown

---

## Scorecard Entry Modal (Shared Component)

### Quick Entry Mode
- [ ] Single input field for total score
- [ ] Handicap and playing handicap display
- [ ] Auto-calculate nett score
- [ ] Save button

### Detailed Entry Mode
- [x] 18-hole grid layout (Front 9 / Back 9)
- [x] Each hole shows:
  - [x] Hole number
  - [x] Par value
  - [x] Stroke index (SI)
  - [x] Score input
  - [x] Points calculation (if Stableford)
- [x] Running totals:
  - [x] Total score
  - [x] Total vs Par indicator
- [ ] Validation:
  - [ ] Flag scores below par (confirm birdie/eagle)
  - [ ] Flag very high scores (confirm accuracy)
  - [ ] Ensure all holes filled
- [ ] Save draft / Submit final buttons

---

## Data Models & Backend

### Score Entry
- [ ] Create `EventScore` model
  - [ ] eventId
  - [ ] memberId
  - [ ] holes (array of 18 scores)
  - [ ] totalScore
  - [ ] nettScore
  - [ ] stablefordPoints
  - [ ] submittedAt
  - [ ] submittedBy (member or admin)
  - [ ] status (pending/approved/published)
  - [ ] editHistory (audit trail)

### Leaderboard Calculation
- [ ] Implement real-time leaderboard calculation
- [ ] Support multiple scoring formats (Gross/Nett/Stableford)
- [ ] Handle ties (count-back rules)
- [ ] Cache calculations for performance

### Notifications
- [ ] Send reminder to members who haven't submitted
- [ ] Notify members when results are published
- [ ] Alert admin when all scores submitted

---

## Design Considerations

### Color Coding
- [ ] Green: Submitted scores
- [ ] Amber: Pending scores
- [ ] Grey: DNS (Did Not Submit)
- [ ] Blue: Admin-entered scores

### Responsive Design
- [ ] Mobile-first layout
- [ ] Large touch targets for score entry
- [ ] Swipe gestures for navigation
- [ ] Optimized for one-handed use

### Performance
- [ ] Implement real-time updates (WebSocket or polling)
- [ ] Offline support for score entry
- [ ] Sync when connection restored
- [ ] Optimistic UI updates

### Accessibility
- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] High contrast mode
- [ ] Clear error messages

---

## Implementation Phases

### Phase 1: Core Functionality (MVP)
- [ ] Basic scorecard entry (total score only)
- [ ] Simple leaderboard display
- [ ] Admin score management
- [ ] Publish/unpublish results

### Phase 2: Enhanced Features
- [ ] Hole-by-hole entry
- [ ] Multiple scoring formats (Gross/Nett/Stableford)
- [ ] Competition results calculation
- [ ] Audit log

### Phase 3: Advanced Features
- [ ] Statistics and charts
- [ ] Reminders and notifications
- [ ] Export and sharing
- [ ] Offline support

### Phase 4: Polish
- [ ] Animations and transitions
- [ ] Performance optimization
- [ ] User testing and refinement
- [ ] Documentation

---

## Testing Checklist

### Unit Tests
- [ ] Score calculation logic
- [ ] Leaderboard sorting
- [ ] Validation rules
- [ ] Data model serialization

### Integration Tests
- [ ] Score submission flow
- [ ] Admin approval workflow
- [ ] Real-time updates
- [ ] Export functionality

### UI Tests
- [ ] Scorecard entry modal
- [ ] Leaderboard display
- [ ] Filter and search
- [ ] Responsive layouts

### User Acceptance Testing
- [ ] Admin can enter scores for all players
- [ ] Members can submit their own scores
- [ ] Leaderboard updates in real-time
- [ ] Results can be published/unpublished
- [ ] Export works correctly

---

## Notes & Decisions

- **Scoring Format Priority**: Start with Stableford (most common in society golf), then add Gross/Nett
- **Approval Workflow**: Optional - admin can choose to auto-publish or require approval
- **Offline Support**: Critical for courses with poor connectivity
- **Count-back Rules**: Implement standard R&A count-back for ties
- **Historical Data**: Maintain score history for season statistics and trends

---

## Related Documentation
- See `COMPETITION_RULES.md` for scoring format details
- See `API_REFERENCE.md` for backend endpoints
- See `USER_GUIDE.md` for member instructions

---

**Last Updated**: 2026-02-07  
**Status**: Completed ✅  
**Next Review**: Maintenance phase
