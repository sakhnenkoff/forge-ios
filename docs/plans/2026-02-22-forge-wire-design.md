# Design: forge-wire — Backend Connection Skill

**Date:** 2026-02-22
**Status:** Approved

---

## Problem

After forge-app builds a polished app with mock data, the developer needs to connect it to real backend services. Today this is manual — figure out which manager to modify, how to set up Firebase/Supabase, where to add API calls. The Forge template abstracts services behind managers (AuthManager, DataManager, LogManager), but there's no guided process for plugging in a real backend.

## Solution

A conversational skill (`/forge:wire`) that asks which backend services the developer wants, then generates or modifies the manager implementations to connect to real endpoints. Backend-agnostic — supports six backend options, three auth options, and four analytics options.

---

## How It Works

### Phase 1: Service Selection

Ask the developer what they want to wire up. Three domains:

**Data/Backend:**
1. Firebase / Firestore — real-time document database, Google ecosystem
2. Supabase — open-source Firebase alternative, PostgreSQL, row-level security
3. REST API — custom endpoints with POST/GET/PUT/DELETE
4. GraphQL — schema-driven API with typed queries and mutations
5. CloudKit — Apple-native, free tier, iCloud integration
6. Local only (SwiftData) — no sync, on-device persistence only

**Authentication:**
1. Firebase Auth — email, Apple, Google sign-in via Firebase
2. Supabase Auth — email, Apple, Google sign-in via Supabase
3. Custom JWT — token-based auth against a custom API
4. Apple-only — AuthenticationServices (Sign in with Apple only)

**Analytics:**
1. Firebase Analytics — event tracking, user properties, conversion funnels
2. Mixpanel — advanced event analytics, funnel analysis, retention
3. PostHog — open-source product analytics, session replay
4. Custom endpoint — send events to your own API
5. None — disable analytics entirely

### Phase 2: Setup Guidance

For each selected service, the skill checks whether the SDK/credentials are configured:

**Firebase:** Check for `GoogleService-Info.plist`. If missing, guide setup:
- "Go to console.firebase.google.com, create project, download GoogleService-Info.plist, drag into Xcode"
- Verify SPM dependency `firebase-ios-sdk` is added

**Supabase:** Check for Supabase URL and anon key in config. If missing, guide setup:
- "Go to supabase.com, create project, copy URL and anon key"
- Add `supabase-swift` SPM dependency

**REST/GraphQL:** Ask for base URL and auth header format. No SDK setup needed.

**CloudKit:** Check entitlements for iCloud capability. Guide enabling if missing.

### Phase 3: Manager Wiring

The Forge template has these manager abstractions:
- `AuthManager` — handles sign-in, sign-out, current user state
- `DataManager` (or domain-specific managers) — CRUD operations on data models
- `LogManager` — analytics event tracking
- `PurchaseManager` — RevenueCat (already wired, typically no changes needed)

For each manager, the skill:
1. Reads the current mock implementation
2. Generates the real implementation for the selected backend
3. Preserves the existing interface (no View changes needed)
4. Adds error handling, retry logic, and offline fallback where appropriate
5. Updates `FeatureFlags.swift` to enable the real service
6. Updates build configuration files if needed

### Phase 4: Verification

After wiring:
1. Build on Dev scheme (not Mock) to verify real SDK integration compiles
2. Run a basic connectivity check if possible (e.g., Firestore read test)
3. Report what was wired and what the developer needs to do next (deploy Cloud Functions, set up database rules, etc.)

---

## Service-Specific Details

### Firebase / Firestore

**Manager changes:**
- `AuthManager`: Replace mock with `FirebaseAuth` — `Auth.auth().signIn(with:)`, state listener, Apple/Google credential providers
- `DataManager`: Replace mock with `Firestore` — `Firestore.firestore().collection()`, Codable mapping, real-time listeners via `snapshotListener`
- `LogManager`: Replace mock with `Analytics` — `Analytics.logEvent()`, user properties

**Files touched:**
- `Managers/AuthManager.swift`
- `Managers/DataManager.swift` (or domain-specific)
- `Managers/LogManager.swift`
- `Configurations/Secrets.xcconfig.local`
- `FeatureFlags.swift`

### Supabase

**Manager changes:**
- `AuthManager`: Replace with `SupabaseClient.auth.signIn()`, session management, Apple/Google OAuth
- `DataManager`: Replace with `SupabaseClient.database.from().select/insert/update/delete`, RLS policies
- `LogManager`: Custom — Supabase doesn't have built-in analytics, suggest PostHog or custom endpoint

**SPM dependency:** `supabase-swift`

### REST API

**Manager changes:**
- `AuthManager`: URLSession calls to `/auth/login`, `/auth/register`, JWT token storage in Keychain
- `DataManager`: URLSession calls to configured endpoints, Codable request/response, error mapping
- `LogManager`: POST events to analytics endpoint or skip

**Configuration:** Ask for base URL, auth header format (Bearer token, API key), endpoint patterns

### GraphQL

**Manager changes:**
- `AuthManager`: GraphQL mutation for login/register, JWT handling
- `DataManager`: GraphQL queries and mutations with Codable mapping
- `LogManager`: Same as REST (POST events)

**Configuration:** Ask for GraphQL endpoint, provide schema if available, generate typed queries

### CloudKit

**Manager changes:**
- `AuthManager`: iCloud account status check (no explicit login needed)
- `DataManager`: `CKContainer.default().privateCloudDatabase`, `CKRecord` mapping, sync with CKSyncEngine
- `LogManager`: Not applicable via CloudKit — suggest Firebase Analytics or none

**Entitlements:** iCloud capability with CloudKit containers

### Local Only (SwiftData)

**Manager changes:**
- `DataManager`: SwiftData `@Model` classes (likely already created by forge-app), `ModelContext` operations
- No auth changes (keep mock or Apple-only)
- No analytics changes (keep mock or none)

This is the simplest option — data models already exist from forge-app, just need to ensure ModelContainer is properly configured.

---

## Checkpoint System

Same as forge-app: default high autonomy. Wire everything, then present the result. Developer can interrupt at any time.

---

## Token Cost

| Scope | Estimated Tokens | Cost |
|-------|-----------------|------|
| Single service (e.g., Firebase only) | 100K-200K | ~$0.40-0.80 |
| Full stack (data + auth + analytics) | 200K-400K | ~$0.80-1.60 |
| Full stack + setup guidance | 300K-500K | ~$1.20-2.00 |

---

## Dependencies

- **Required:** forge-marketplace skills (MIT)
- **No new dependencies** — this skill modifies existing manager files
- SDKs (Firebase, Supabase, etc.) are added as SPM dependencies but are not bundled with the skill

---

## File Structure

```
forge-wire/
├── claude-code.json
└── skills/
    └── forge-wire/
        ├── SKILL.md              # Main orchestrator
        └── references/
            ├── backends.md       # Service-specific wiring patterns for all 6 backends
            └── setup-guides.md   # SDK setup guidance for Firebase, Supabase, CloudKit
```

---

## Success Criteria

1. Developer goes from mock data to real backend in one session
2. No View code changes needed — only manager implementations change
3. Build compiles on Dev scheme after wiring
4. Error handling and offline fallback included
5. Works with any combination of services (e.g., Supabase data + Firebase analytics)
6. Setup guidance is clear enough for first-time Firebase/Supabase users
