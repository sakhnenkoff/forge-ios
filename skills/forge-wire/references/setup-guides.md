# Service Setup Guides

Step-by-step setup instructions for every backend service supported by forge-wire. Each guide covers account creation, SDK installation, credential configuration, and verification.

---

## Firebase

Firebase provides authentication, real-time database (Firestore), analytics, crash reporting, and more through a single SDK. Most Forge apps that use Firebase will enable Firestore + Firebase Auth + Firebase Analytics together.

### 1. Create a Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project**
3. Enter your project name (e.g., "MyApp Production")
4. Choose whether to enable Google Analytics (recommended — it is free)
5. Select or create a Google Analytics account
6. Click **Create project** and wait for provisioning (~30 seconds)

### 2. Add an iOS App

1. In the Firebase console, click the **iOS** icon on the project overview page
2. Enter your **bundle ID** — find it in Xcode under your target's General tab (e.g., `com.yourcompany.yourapp`)
3. Optionally enter an App nickname and App Store ID
4. Click **Register app**

### 3. Download GoogleService-Info.plist

1. Firebase presents a download button for `GoogleService-Info.plist`
2. Download the file
3. In Xcode, drag the file into your project root directory (the same level as your `.xcodeproj`)
4. In the dialog, ensure:
   - **Copy items if needed** is checked
   - Your app target is selected under **Add to targets**
5. Click **Finish**

**Verification:** Open the plist in Xcode. Confirm it contains keys like `API_KEY`, `GCM_SENDER_ID`, `PROJECT_ID`, `BUNDLE_ID` (matching your app), `GOOGLE_APP_ID`.

### 4. Add Firebase SDK via SPM

1. In Xcode: **File > Add Package Dependencies...**
2. Enter the URL: `https://github.com/firebase/firebase-ios-sdk`
3. Set the dependency rule to **Up to Next Major Version** (current: 11.x)
4. Click **Add Package** and wait for resolution
5. Select the products you need:
   - `FirebaseFirestore` — for Firestore database
   - `FirebaseAuth` — for authentication
   - `FirebaseAnalytics` — for analytics (or `FirebaseAnalyticsWithoutAdIdSupport` if you do not use IDFA)
   - `FirebaseCrashlytics` — optional, for crash reporting
6. Click **Add Package**

### 5. Initialize Firebase

In your app entry point (`{AppName}App.swift` or `AppDelegate.swift`):

```swift
import FirebaseCore

// In the App init() or application(_:didFinishLaunchingWithOptions:):
FirebaseApp.configure()
```

This must be called before any other Firebase service is used.

### 6. Firestore Setup

1. In the Firebase console, go to **Build > Firestore Database**
2. Click **Create database**
3. Choose a location (pick the region closest to your users)
4. Start in **test mode** for development (allows all reads/writes for 30 days)
5. Click **Enable**

**Security rules (before shipping):**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 7. Firebase Auth Setup

1. In the Firebase console, go to **Build > Authentication**
2. Click **Get started**
3. Enable the sign-in providers you need:
   - **Email/Password** — toggle on
   - **Google** — toggle on, configure OAuth consent screen
   - **Apple** — toggle on, configure Sign in with Apple in your Apple Developer account
4. For Google Sign-In, download the updated `GoogleService-Info.plist` (it now contains the OAuth client ID)

### 8. Multiple Environments

For Dev vs Prod, create two Firebase projects:
- `MyApp-Dev` with its own `GoogleService-Info.plist`
- `MyApp-Prod` with its own `GoogleService-Info.plist`

Rename the plist files to include the environment (e.g., `GoogleService-Info-Dev.plist`, `GoogleService-Info-Prod.plist`) and configure your build settings to copy the correct one at build time.

---

## Supabase

Supabase is an open-source Firebase alternative built on PostgreSQL. It provides a database, authentication, storage, edge functions, and real-time subscriptions.

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in (GitHub, email, or SSO)
2. Click **New Project**
3. Select an organization (or create one)
4. Enter:
   - **Project name** (e.g., "myapp-production")
   - **Database password** — save this securely, you will need it for direct database access
   - **Region** — pick the closest to your users
5. Click **Create new project**
6. Wait for provisioning (~2 minutes)

### 2. Get API Keys

1. Once the project is ready, go to **Settings > API**
2. Copy:
   - **Project URL** (e.g., `https://abc123.supabase.co`)
   - **anon / public key** (starts with `eyJ...`)
   - **service_role key** — for server-side only, NEVER put this in the iOS app

### 3. Configure Credentials

Create `Secrets.xcconfig.local` in your project root:

```
// Secrets.xcconfig.local
// DO NOT commit this file — add to .gitignore

SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...your-key
```

Add to `.gitignore`:
```
Secrets.xcconfig.local
```

In your `Info.plist` (or build settings), reference these values:
```xml
<key>SUPABASE_URL</key>
<string>$(SUPABASE_URL)</string>
<key>SUPABASE_ANON_KEY</key>
<string>$(SUPABASE_ANON_KEY)</string>
```

### 4. Add Supabase SDK via SPM

1. In Xcode: **File > Add Package Dependencies...**
2. Enter the URL: `https://github.com/supabase/supabase-swift`
3. Set the dependency rule to **Up to Next Major Version**
4. Click **Add Package**
5. Select: `Supabase`
6. Click **Add Package**

### 5. Initialize Supabase Client

Create a shared client instance:

```swift
import Supabase

let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: Configuration.supabaseURL)!,
    supabaseKey: Configuration.supabaseAnonKey
)
```

### 6. Create Database Tables

In the Supabase dashboard, go to **Table Editor** or use the **SQL Editor**:

```sql
-- Example: items table
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Policy: users can only access their own items
CREATE POLICY "Users can read own items"
    ON items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items"
    ON items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items"
    ON items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items"
    ON items FOR DELETE
    USING (auth.uid() = user_id);
```

### 7. Supabase Auth Setup

1. In the dashboard, go to **Authentication > Providers**
2. Enable the providers you need:
   - **Email** — enabled by default
   - **Apple** — requires Apple Developer account setup (see Apple-only section below)
   - **Google** — requires Google Cloud OAuth credentials
3. Configure redirect URLs under **Authentication > URL Configuration**

### 8. Multiple Environments

Create two Supabase projects:
- Development project with test data
- Production project with real data

Use different `Secrets.xcconfig.local` files per build configuration, or use environment-based xcconfig inheritance.

---

## CloudKit

CloudKit is Apple's native cloud database. It is free (with generous limits), integrates with iCloud, provides automatic user accounts (via Apple ID), and requires no separate backend setup.

### 1. Enable iCloud Capability

1. Open your project in Xcode
2. Select your app target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Search for and add **iCloud**
6. Under the iCloud section, check **CloudKit**

### 2. Create a CloudKit Container

1. In the iCloud capability section, click the **+** button under Containers
2. Enter a container identifier (e.g., `iCloud.com.yourcompany.yourapp`)
3. Click **OK**
4. Xcode will create the container in your Apple Developer account

### 3. Define Record Types

1. Go to [developer.apple.com/icloud/dashboard](https://developer.apple.com/icloud/dashboard)
2. Or use CloudKit Console: [icloud.developer.apple.com](https://icloud.developer.apple.com)
3. Select your container
4. Go to **Schema > Record Types**
5. Create record types matching your data models:

Example for an `Item` record type:
- **Field name:** `title` — **Type:** String
- **Field name:** `description` — **Type:** String
- **Field name:** `createdAt` — **Type:** Date/Time
- **Field name:** `updatedAt` — **Type:** Date/Time

6. Add indexes for fields you will query or sort by:
   - `createdAt` — Sortable
   - `title` — Queryable, Searchable

### 4. Choose Database Scope

CloudKit offers three database scopes:

| Scope | Visibility | Use Case |
|-------|------------|----------|
| **Private** | Only the user who created the data | Personal data (habits, journal entries, preferences) |
| **Public** | All users | Shared content (posts, recipes, reviews) |
| **Shared** | Invited users | Collaborative data (shared lists, team projects) |

Most Forge apps should start with **Private** (user-owned data) or **Public** (community content).

### 5. Entitlements Verification

After enabling CloudKit, verify your `.entitlements` file contains:

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.yourcompany.yourapp</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### 6. No SPM Dependency Needed

CloudKit is a system framework. Import it directly:

```swift
import CloudKit
```

### 7. Testing

- CloudKit works in the Simulator but requires an iCloud account signed in
- Use the **Development** environment in CloudKit Console for testing
- Push to **Production** when ready to ship (this is separate from App Store deployment)
- Data in Development and Production environments are completely isolated

### 8. Limits

CloudKit free tier (per user):
- **Storage:** 25 GB asset storage, 5 GB database storage (public), plus user's own iCloud storage (private)
- **Requests:** 40 requests/second per user, 400 requests/second per app
- **Transfer:** 250 MB/day asset download

These limits are very generous for most apps. They scale with your user count.

---

## REST API

REST APIs work with any backend language and framework. No SDK is needed — Foundation's URLSession handles all HTTP communication.

### 1. Determine Base URL

You need the base URL for your API. Examples:
- Development: `https://dev-api.yourapp.com/v1`
- Production: `https://api.yourapp.com/v1`
- Local development: `http://localhost:3000/api`

### 2. Configure Base URL

Add to your xcconfig or Info.plist:

```
// Dev.xcconfig
API_BASE_URL = https://dev-api.yourapp.com/v1

// Prod.xcconfig
API_BASE_URL = https://api.yourapp.com/v1
```

In Info.plist:
```xml
<key>API_BASE_URL</key>
<string>$(API_BASE_URL)</string>
```

### 3. Authentication Header Format

Determine how your API authenticates requests:

| Method | Header | Example |
|--------|--------|---------|
| Bearer token (JWT) | `Authorization: Bearer <token>` | Most common for mobile apps |
| API key | `X-API-Key: <key>` | For server-to-server or simple auth |
| Cookie | `Cookie: session=<value>` | Less common for mobile |
| Basic auth | `Authorization: Basic <base64>` | For simple setups |

### 4. App Transport Security

If your API uses HTTPS (recommended), no additional configuration is needed.

If you need to connect to HTTP endpoints during development (e.g., `localhost`), add to Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

Do NOT use `NSAllowsArbitraryLoads` — it disables all transport security and will be flagged during App Store review.

### 5. API Documentation

If you have API documentation (OpenAPI/Swagger spec, Postman collection, or README), share it during the wiring phase. forge-wire will use it to generate correctly typed request/response models.

If no documentation exists, forge-wire will ask for example requests and responses for each endpoint:
- `GET /items` — list all items
- `GET /items/:id` — get single item
- `POST /items` — create item (what's the request body?)
- `PUT /items/:id` — update item
- `DELETE /items/:id` — delete item

### 6. Error Response Format

Tell forge-wire how your API returns errors:

```json
// Common format 1:
{ "error": "Not found", "code": "ITEM_NOT_FOUND" }

// Common format 2:
{ "message": "Validation failed", "errors": [{ "field": "title", "message": "is required" }] }

// Common format 3:
{ "status": 422, "detail": "Title cannot be empty" }
```

This determines how the error handling code maps API errors to `AppError` cases.

---

## GraphQL API

GraphQL uses a single endpoint with typed queries and mutations. No SDK is required for basic usage — Foundation's URLSession can send GraphQL requests as JSON POST bodies.

### 1. Determine Endpoint URL

GraphQL APIs have a single endpoint. Examples:
- `https://api.yourapp.com/graphql`
- `https://yourapp.hasura.app/v1/graphql`

### 2. Configure Endpoint

Same as REST — add to xcconfig:

```
API_GRAPHQL_ENDPOINT = https://api.yourapp.com/graphql
```

### 3. Authentication

GraphQL APIs typically use the same auth patterns as REST:
- Bearer token in `Authorization` header (most common)
- API key in a custom header (e.g., `x-hasura-admin-secret` for Hasura)

### 4. Schema

If you have a GraphQL schema file (`.graphql` or `.graphqls`), share it during wiring. forge-wire will generate query strings and response types from it.

If no schema exists, forge-wire will ask for example queries:

```graphql
# What queries does your API support?
query GetItems {
  items {
    id
    title
    createdAt
  }
}

# What mutations?
mutation CreateItem($input: CreateItemInput!) {
  createItem(input: $input) {
    id
    title
  }
}
```

### 5. Optional: Apollo iOS

For advanced GraphQL features (automatic caching, code generation, normalized cache, subscription websockets), consider Apollo iOS:

1. SPM URL: `https://github.com/apollographql/apollo-ios`
2. Install the Apollo CLI for code generation: `npm install -g apollo`
3. Generate types from your schema: `apollo codegen:generate`

forge-wire defaults to the lightweight URLSession approach. It will suggest Apollo only if the developer's use case benefits from it (complex queries, subscriptions, or optimistic UI updates).

---

## Mixpanel

Mixpanel is a product analytics platform focused on user behavior tracking, funnels, retention, and cohort analysis.

### 1. Create a Mixpanel Account

1. Go to [mixpanel.com](https://mixpanel.com)
2. Sign up with email or Google
3. Create an organization and project

### 2. Get Project Token

1. Go to **Settings** (gear icon) > **Project Settings**
2. Copy the **Project Token** (a hexadecimal string like `abc123def456...`)
3. This is NOT a secret — it is safe to include in the app binary (Mixpanel uses this for event routing, not authorization)

### 3. Configure Token

Add to `Secrets.xcconfig.local`:

```
MIXPANEL_TOKEN = your-project-token-here
```

In Info.plist:
```xml
<key>MIXPANEL_TOKEN</key>
<string>$(MIXPANEL_TOKEN)</string>
```

### 4. Add Mixpanel SDK via SPM

1. In Xcode: **File > Add Package Dependencies...**
2. URL: `https://github.com/mixpanel/mixpanel-swift`
3. Select: `Mixpanel`
4. Click **Add Package**

### 5. Initialize Mixpanel

In your app entry point:

```swift
import Mixpanel

// In App init():
Mixpanel.initialize(token: Configuration.mixpanelToken, trackAutomaticEvents: true)
```

`trackAutomaticEvents: true` enables automatic tracking of app opens, sessions, and other lifecycle events.

### 6. Verify Integration

1. Track a test event in your app
2. Go to the Mixpanel dashboard > **Events**
3. You should see the event appear within ~60 seconds
4. If events do not appear, check:
   - The token is correct
   - The SDK is initialized before tracking
   - The device has network connectivity

---

## PostHog

PostHog is an open-source product analytics platform. It offers event tracking, session replay, feature flags, A/B testing, and surveys. It can be self-hosted or used as a cloud service.

### 1. Create a PostHog Account

1. Go to [app.posthog.com](https://app.posthog.com)
2. Sign up (Google, GitHub, or email)
3. Create a project

### 2. Get API Key and Host

1. Go to **Project Settings**
2. Copy:
   - **Project API Key** (starts with `phc_...`)
   - **Host URL** — typically `https://us.i.posthog.com` (US) or `https://eu.i.posthog.com` (EU)

For self-hosted instances, the host is your own PostHog server URL.

### 3. Configure Credentials

Add to `Secrets.xcconfig.local`:

```
POSTHOG_API_KEY = phc_your-api-key-here
POSTHOG_HOST = https://us.i.posthog.com
```

In Info.plist:
```xml
<key>POSTHOG_API_KEY</key>
<string>$(POSTHOG_API_KEY)</string>
<key>POSTHOG_HOST</key>
<string>$(POSTHOG_HOST)</string>
```

### 4. Add PostHog SDK via SPM

1. In Xcode: **File > Add Package Dependencies...**
2. URL: `https://github.com/PostHog/posthog-ios`
3. Select: `PostHog`
4. Click **Add Package**

### 5. Initialize PostHog

In your app entry point:

```swift
import PostHog

// In App init():
let config = PostHogConfig(apiKey: Configuration.posthogAPIKey)
config.host = Configuration.posthogHost
PostHogSDK.shared.setup(config)
```

### 6. Verify Integration

1. Track a test event
2. Go to the PostHog dashboard > **Activity** or **Events**
3. Events should appear within ~60 seconds
4. PostHog also captures `$screen` events automatically for screen views

### 7. Optional Features

PostHog offers additional features that can be enabled:

- **Session replay:** Records user sessions for debugging. Enable in PostHog dashboard under **Session Recording**.
- **Feature flags:** Control feature rollout remotely. Use `PostHogSDK.shared.isFeatureEnabled("flag-name")`.
- **Surveys:** In-app surveys triggered by events or user properties.

These features are beyond forge-wire's scope but are worth exploring after wiring is complete.

---

## Sign in with Apple (for Apple-Only Auth)

If you chose Apple-only authentication, you need to configure Sign in with Apple in your Apple Developer account and Xcode project.

### 1. Enable Sign in with Apple Capability

1. In Xcode, select your app target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Search for and add **Sign in with Apple**

### 2. Configure in Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com)
2. Go to **Certificates, Identifiers & Profiles > Identifiers**
3. Select your App ID
4. Under Capabilities, ensure **Sign in with Apple** is checked
5. Click **Save**

### 3. Handle Credential Revocation

Apple requires apps to handle credential revocation. Register for the revocation notification:

```swift
NotificationCenter.default.addObserver(
    forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
    object: nil,
    queue: nil
) { _ in
    // Sign the user out
    Task { @MainActor in
        try? authManager.signOut()
    }
}
```

### 4. Privacy Requirements

If you use Sign in with Apple, you must also offer it if you offer any other third-party sign-in (Google, Facebook, etc.). This is an App Store requirement.

### 5. No SPM Dependency Needed

`AuthenticationServices` is a system framework:

```swift
import AuthenticationServices
```

---

## Multiple Environment Configuration

Most apps need at least two environments: Development and Production. Here is how to configure different backend credentials per environment.

### Using xcconfig Files

Create environment-specific xcconfig files:

```
// Config/Dev.xcconfig
SUPABASE_URL = https://dev-project.supabase.co
SUPABASE_ANON_KEY = dev-key-here
API_BASE_URL = https://dev-api.yourapp.com/v1
MIXPANEL_TOKEN = dev-mixpanel-token

// Config/Prod.xcconfig
SUPABASE_URL = https://prod-project.supabase.co
SUPABASE_ANON_KEY = prod-key-here
API_BASE_URL = https://api.yourapp.com/v1
MIXPANEL_TOKEN = prod-mixpanel-token
```

Create a local secrets overlay (not committed to git):

```
// Config/Secrets.xcconfig.local (in .gitignore)
#include "Dev.xcconfig"
// Override with actual secret values:
SUPABASE_ANON_KEY = eyJ...actual-key
```

### Using Build Configurations in Xcode

1. In Xcode, go to Project (not target) settings
2. Under **Info > Configurations**, you should see Debug and Release
3. Set the xcconfig file for each:
   - Debug: `Config/Dev.xcconfig`
   - Release: `Config/Prod.xcconfig`

### Using Schemes

Forge apps typically have three schemes:
- **{AppName} - Mock** — uses mock managers, no real backend
- **{AppName} - Dev** — uses real managers with development credentials
- **{AppName} - Prod** — uses real managers with production credentials

forge-wire modifies the Dev and Prod implementations. The Mock scheme continues to work with mock data.

### Firebase Multi-Environment

Firebase requires separate `GoogleService-Info.plist` files per environment:

1. Create two Firebase projects: `MyApp-Dev` and `MyApp-Prod`
2. Download each project's plist
3. Rename them: `GoogleService-Info-Dev.plist`, `GoogleService-Info-Prod.plist`
4. Add a Run Script build phase to copy the correct one:

```bash
if [ "${CONFIGURATION}" == "Release" ]; then
    cp "${PROJECT_DIR}/GoogleService-Info-Prod.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
else
    cp "${PROJECT_DIR}/GoogleService-Info-Dev.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi
```

---

## Verification Checklist

After setup, verify each service before wiring:

### Firebase
- [ ] `GoogleService-Info.plist` is in the project and added to the app target
- [ ] `firebase-ios-sdk` is added via SPM with the correct products
- [ ] `FirebaseApp.configure()` is called before any Firebase usage
- [ ] Firestore database is created in the Firebase console
- [ ] Auth providers are enabled in the Firebase console

### Supabase
- [ ] Project URL and anon key are in `Secrets.xcconfig.local`
- [ ] `Secrets.xcconfig.local` is in `.gitignore`
- [ ] Values are referenced in Info.plist via `$(SUPABASE_URL)` etc.
- [ ] `supabase-swift` is added via SPM
- [ ] Database tables are created with RLS enabled

### CloudKit
- [ ] iCloud capability is added with CloudKit checked
- [ ] Container identifier is set
- [ ] Record types are defined in CloudKit Console
- [ ] Indexes are set for queryable/sortable fields

### REST / GraphQL
- [ ] Base URL / endpoint is configured per environment
- [ ] Auth header format is documented
- [ ] API is accessible from the development machine
- [ ] App Transport Security allows the API domain

### Mixpanel
- [ ] Project token is configured
- [ ] `mixpanel-swift` is added via SPM
- [ ] `Mixpanel.initialize()` is called at app launch
- [ ] Test event appears in dashboard

### PostHog
- [ ] API key and host are configured
- [ ] `posthog-ios` is added via SPM
- [ ] `PostHogSDK.shared.setup()` is called at app launch
- [ ] Test event appears in dashboard

### Sign in with Apple
- [ ] Capability is added in Xcode
- [ ] App ID has Sign in with Apple enabled in Developer Portal
- [ ] Credential revocation notification is handled
