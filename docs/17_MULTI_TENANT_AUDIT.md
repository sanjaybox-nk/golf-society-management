# Audit: Multi-Tenant Architecture Transition

This document outlines the strategy for converting the Golf Society Management app into a multi-tenant (SaaS) platform.

## 1. Current State Assessment
- **Single-Tenant**: All data resides in top-level Firestore collections (`members`, `events`, `competitions`, etc.).
- **Implicit Context**: The application assumes one society. No `societyId` or tenant context is currently injected into providers or repositories.
- **Authentication**: Users are authenticated via Firebase Auth, but there is no mapping between a `UID` and multiple `Societies`.

## 2. Proposed Architecture: Sub-collection Isolation
We recommend moving to a nested collection structure for all domain-specific data.

### Data Structure Mapping
| Collection | Current Path | Proposed Tenanted Path |
| :--- | :--- | :--- |
| **Societies** | N/A | `/societies/{societyId}` |
| **Members** | `/members/{id}` | `/societies/{societyId}/members/{id}` |
| **Events** | `/events/{id}` | `/societies/{societyId}/events/{id}` |
| **Seasons** | `/seasons/{id}` | `/societies/{societyId}/seasons/{id}` |
| **Committees** | `/committees/{id}` | `/societies/{societyId}/committees/{id}` |

### Shared Resources (Global)
Some resources should remain global or be duplicated across tenants:
- **Course Library**: Could remain global (shared database of golf courses) or be duplicated per tenant to allow custom pars/SIs.
- **Handicap Systems**: Global enum/logic.

## 3. Access & Platforms
To cater to different user roles and management needs, the platform will utilize a multi-channel approach.

### 3.1 Member Access (Mobile-First)
- **Platforms**: iPhone & Android (Native cross-platform via Flutter).
- **Core Activities**: Registration, Live Scoring, Locker Room, Leaderboards.

### 3.2 Admin Access (Multi-Channel)
- **Mobile App**: Real-time management (Grouping, Live Score Adjustments, Tee Sheets).
- **Admin Web Console**: Focused on heavy lifting and bulk operations.
    - **Features**: Event Creation, Member Imports, Comms Hub (Email/Push templates), Branding, Financial Reporting.
    - **Standard**: Secure web-based login scoped to the active society ID.

### 3.3 Master Console (Super Admin)
A high-level dashboard for platform owners to manage the entire ecosystem.
- **Tenant Management**: Create/Suspend/Archive society tenants.
- **Global Course Master**: Manage the root-level `/courses` collection.
- **Metrics Dashboard**: Aggregate data across all societies (Total users, entries, traffic).
- **System Health**: View error logs and broadcast global "System Maintenance" messages.

## 4. Technical Implementation Steps

### A. Tenant Context & Selection
1. **Multi-Society Access**: A single user account (UID) can be associated with multiple societies.
2. **Society Selector**: A "Launchpad" screen will be implemented as the initial view after login, allowing users to select which society they wish to access.
3. **Portal Entry**: A single domain (e.g., `app.boxyart.com`) will serve all tenants, avoiding the complexity of subdomains.

### B. Data & Course Management
1. **Global Course Library**: A centralized `/courses` collection will exist at the root level. Societies can browse and "attach" these courses to their events.
2. **Local Overrides**: Societies will have the ability to store local overrides (e.g., specific Pars or Stroke Indices) within their own tenant if they deviate from the global standard.

### C. Onboarding & Demo Environment
1. **Default Demo Tenant**: The system will ship with a persistent `demo_society` tenant.
2. **New User Experience**: New sign-ups will be automatically granted "Viewer" or "Member" access to the Demo Tenant to explore features before creating their own society.

## 4. Security & Isolation Logic
Firestore Security Rules will enforce that a user's UID must be present in the `/societies/{id}/members` collection to grant access to that society's data.
