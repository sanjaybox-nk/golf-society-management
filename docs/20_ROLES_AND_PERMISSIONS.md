# 20 — Roles & Permissions

## Role Hierarchy

```
superAdmin > admin > restrictedAdmin > scorer
                                     > viewer
                                     > member > socialMember
```

## Role Definitions

| Role | Display Name | `hasAdminAccess` | `isScorer` | `isSocialMember` | `isFullMember` |
|---|---|---|---|---|---|
| `superAdmin` | Super Admin | ✅ | ❌ | ❌ | ✅ |
| `admin` | Admin | ✅ | ❌ | ❌ | ✅ |
| `restrictedAdmin` | Event Officer | ✅ | ❌ | ❌ | ✅ |
| `scorer` | Scorer | ❌ | ✅ | ❌ | ✅ |
| `viewer` | Observer (Read-Only) | ❌ | ❌ | ❌ | ❌ |
| `member` | Society Member | ❌ | ❌ | ❌ | ✅ |
| `socialMember` | Social Member | ❌ | ❌ | ✅ | ❌ |

## Access Matrix

### Navigation (bottom nav bar)

| Role | Nav shown |
|---|---|
| superAdmin / admin / restrictedAdmin | Dashboard · Golf Events · Members · Comms · Operations |
| scorer | Golf Events only |
| viewer | Home · Golf Events · Members · Locker · Archive (member nav) |
| member | Home · Golf Events · Members · Locker · Archive |
| socialMember | Home · Golf Events · Members · Locker · Archive |

### Admin Console

| Area | superAdmin | admin | restrictedAdmin | scorer | viewer |
|---|---|---|---|---|---|
| Dashboard | ✅ | ✅ | ✅ | ❌ (redirected) | ❌ |
| Golf Events (list) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Event manage tower | ✅ | ✅ | ✅ | ✅ (events only) | ❌ |
| — Verify tab | ✅ | ✅ | ✅ | ✅ | ❌ |
| — Manage tab | ✅ | ✅ | ✅ | ❌ | ❌ |
| Members admin | ✅ | ✅ | ✅ | ❌ | ❌ |
| Operations hub | ✅ | ✅ | ✅ | ❌ | ❌ |
| — Society Config | ✅ | ✅ | ✅ | ❌ | ❌ |
| — Roles & Permissions | ✅ (assign all) | ✅ (assign non-super) | ✅ | ❌ | ❌ |
| — Treasury / Financials | ✅ | ✅ | ✅ | ❌ | ❌ |
| — Member Renewals | ✅ | ✅ | ✅ | ❌ | ❌ |
| — Dev Tools (kDebugMode) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Comms / Notifications | ✅ | ✅ | ✅ | ❌ | ❌ |

### Event Hub (member-facing, per-event nav bar)

| Tab | member | socialMember | scorer |
|---|---|---|---|
| Info | ✅ | ✅ | ✅ |
| Field | ✅ | ✅ | ✅ |
| My Card (scoring) | ✅ (golf events) | ❌ hidden | ✅ |
| Scores | ✅ | ✅ | ✅ |
| Stats | ✅ | ✅ | ✅ |

### Event Registration

| Role | Golf events | Social events |
|---|---|---|
| member | ✅ | ✅ |
| socialMember | ❌ blocked | ✅ |
| scorer | ✅ | ✅ |
| viewer | ✅ | ✅ |

## Social Membership Tier

Social membership is a society-level feature controlled by `SocietyConfig.enableSocialMembership`.

**When OFF (default):** No social members can be created. Existing members with `socialMember` role retain their restrictions (historical access preserved).

**When ON:**
- Admin can assign `socialMember` role to members
- Social member fee (`SocietyConfig.socialMemberFee`) applies at renewal
- Members can self-request upgrade to full membership at renewal
- Admin promotes via member profile → Administrative Controls → "Promote to Full Member" (sets `role = member`, `status = active`)

**Social member app experience:**
- Can view all events, field lists, scores, leaderboards, season standings
- Blocked from registering for golf events (message shown)
- My Card tab hidden in event hub
- Can register for and attend social events

## Role Assignment

- **superAdmin** can assign any role including superAdmin
- **admin** can assign all roles except superAdmin
- Role picker shown in member profile edit mode (admin context only)
- Role change takes effect immediately on save

## Known Gaps (enforcement not yet implemented)

| Gap | Roles affected | Priority |
|---|---|---|
| `viewer` has member-level access — admin reporting/stats not visible | viewer | Medium |
| No route-level guards — deep-links to admin screens bypass nav redirects | scorer, viewer, member | Low (internal app, no deep-link exposure) |

### viewer intent (not yet enforced)
Currently viewer has no `hasAdminAccess`, so they land on the member nav — they see what regular members see. Intent is read-only access to admin-level reporting and member data. Full implementation requires read-only mode across all admin screens (disabled forms, no edit/delete) before `viewer` can safely be given `hasAdminAccess`. Deferred to a future phase.

### restrictedAdmin — enforced as of 2026-05-19
- Golf Events nav only (same as scorer)
- Redirected from `/admin` → `/admin/events`
- Sees all 5 event tabs including Manage (scorer does not get Manage)
- Cannot access Dashboard, Operations, Society Config, Treasury, Comms, Member admin

## Implementation Files

| Concern | File |
|---|---|
| Role enum + helpers | `lib/domain/models/member.dart` |
| Nav bar logic | `lib/navigation/global_app_shell.dart` |
| Admin route redirect (scorer) | `lib/navigation/routes/admin_routes.dart:12` |
| Event registration gate | `lib/features/events/presentation/event_details_screen.dart` |
| My Card tab hide | `lib/navigation/global_app_shell.dart` |
| Role picker UI | `lib/features/members/presentation/widgets/member_role_picker.dart` |
| Role assignment (admin) | `lib/features/members/presentation/member_details_modal.dart` |
| Roles screen | `lib/features/admin/presentation/settings/roles_screen.dart` |
| Social membership toggle | `SocietyConfig.enableSocialMembership` via Operations hub |
