---
name: forge-wire
description: >
  Connect a Forge app to real backend services. Asks which data, auth, and
  analytics backends the developer wants, then wires manager implementations.
  Backend-agnostic: 6 data backends, 4 auth options, 5 analytics options. Works
  by modifying manager implementations — no View code changes. Use when the user
  says "connect my app", "wire up Firebase", "add Supabase", "connect to my API",
  or "/forge:wire".
license: MIT
---

# Forge Wire

This skill connects a polished Forge app to real backend services. It replaces mock manager implementations with production-ready code that talks to Firebase, Supabase, REST APIs, GraphQL endpoints, CloudKit, or local SwiftData — without touching any View or ViewModel code.

The design is backend-agnostic. The developer picks their preferred stack for data, auth, and analytics independently. Each combination is valid. The skill modifies only the manager layer, preserving the MVVM architecture and DS components that forge-app and forge-feature built.

**Part of the Forge ecosystem:**

```
forge-workspace -> forge-app -> forge-wire -> forge-ship
   (setup)          (build)      (connect)     (submit)
```

Each skill is independent and invocable separately. They chain naturally: forge-workspace sets up the project, forge-app builds screens, forge-wire connects backends, and forge-ship prepares for App Store submission. But any skill can be used alone — a developer who already has a running app can jump straight to forge-wire.

---

## 1. Prerequisites Check

Before starting, verify the project is a valid Forge workspace with manager files ready for wiring.

```
[ ] *.xcodeproj exists in working directory
[ ] AGENTS.md exists in working directory
[ ] Manager files exist (AuthManager, LogManager, etc.)
[ ] Current wiring state detected (mock vs. real)
```

Run these checks:

1. `ls *.xcodeproj` — must find exactly one. Extract the app name from the filename (e.g., `MyApp.xcodeproj` means the app name is `MyApp`).
2. `ls AGENTS.md` — must exist. Read it to understand the project's manager patterns, protocol-based architecture, and configuration approach.
3. Search for manager files. Look in `{AppName}/Managers/` for:
   - `AuthManager` (or `AuthService`, `AuthenticationManager`) — handles sign-in/sign-out
   - `LogManager` (or `AnalyticsManager`, `LogService`) — handles event tracking
   - Any feature managers created by forge-craft-agent (e.g., `HabitManager`, `TransactionManager`)
     — these follow the pattern in AGENTS.md "Adding a Feature Manager": protocol + mock
     implementation. Your job is to replace the mock with a real backend implementation.
   - `PurchaseManager` (if it exists — not wired by this skill, but good to know about)

4. Detect current wiring state for each manager found:
   - Read the manager's implementation file
   - Check if it uses mock/placeholder data (hardcoded arrays, `Task.sleep`, `print()` statements instead of real SDK calls)
   - Check if it imports any backend SDKs (`FirebaseAuth`, `Supabase`, etc.)
   - Classify each manager as `mock` (needs wiring) or `wired` (already connected)

5. Check for existing SDK configuration:
   - `ls GoogleService-Info.plist` — Firebase configured?
   - Search for `SUPABASE_URL` or `supabaseURL` in config files — Supabase configured?
   - Check entitlements for `com.apple.developer.icloud-container-identifiers` — CloudKit configured?
   - Check `Package.swift` or `.xcodeproj` for SPM dependencies — which SDKs are already added?

If the xcodeproj or AGENTS.md is missing, stop and tell the user what is wrong. If manager files are missing, suggest running `/forge:app` or `/forge:feature` first to build screens with managers.

**Concurrency note:** The app target defaults to `@MainActor` with strict concurrency. Mock managers are implicitly `@MainActor`. When replacing with real backend implementations that perform network I/O, the manager protocol may need updating — add `@Sendable` or convert to an `actor` if the SDK callbacks run off the main actor. Check AGENTS.md "Architecture > Concurrency" for the project's concurrency baseline.

Report the detected state:

> "Found {AppName} with {N} managers. Current state:
> - AuthManager: {mock/wired to X}
> - LogManager: {mock/wired to X}
> - {Other managers}: {mock/wired to X}
>
> SDKs detected: {list any existing SDK imports or config files}
>
> Ready to wire."

---

## 2. Phase 1: Service Selection

Ask ONE question at a time. Wait for the answer before asking the next. Each answer shapes subsequent questions — skip questions that become irrelevant based on earlier choices.

### Question 1 — Data Backend

> "What backend should your app use for data?"

Present these options with brief descriptions:

| Option | Description |
|--------|-------------|
| **Firebase / Firestore** | Google ecosystem, real-time sync, generous free tier, offline support built-in |
| **Supabase** | Open-source Firebase alternative, PostgreSQL under the hood, row-level security, real-time subscriptions |
| **REST API** | Your own endpoints (POST/GET/PUT/DELETE), works with any backend language |
| **GraphQL** | Schema-driven typed queries, single endpoint, request exactly the data you need |
| **CloudKit** | Apple-native, free with Apple Developer account, iCloud integration, automatic user accounts |
| **Local only (SwiftData)** | No network sync, on-device storage only, zero setup, works offline always |

If the developer has already mentioned a preference (e.g., they said "wire up Firebase" in the trigger), confirm rather than re-ask:

> "Confirmed: using Firebase/Firestore for data. Next question..."

### Question 2 — Authentication

> "What should handle authentication?"

Present options based on the data backend choice. Highlight the natural pairing:

| Option | Notes |
|--------|-------|
| **Firebase Auth** | Natural fit if using Firestore. Google, Apple, email/password sign-in. |
| **Supabase Auth** | Natural fit if using Supabase. Email, magic link, OAuth providers. |
| **Custom JWT** | Against your own API. You handle user creation, login returns a JWT token. |
| **Apple-only (Sign in with Apple)** | Minimal auth. Apple identity only. Good for privacy-focused apps. |
| **Keep mock** | No real auth — keep the current mock implementation. |

If the developer chose a backend that pairs naturally with an auth provider, suggest the pairing:

> "Since you're using Firestore, Firebase Auth is the natural fit. Want to go with that, or prefer something else?"

### Question 3 — Analytics

> "What analytics service should track events?"

| Option | Notes |
|--------|-------|
| **Firebase Analytics** | Free, integrates with Firestore and Crashlytics. Already in Firebase SDK. |
| **Mixpanel** | Powerful funnels and retention analysis. Generous free tier. |
| **PostHog** | Open-source, self-hostable. Product analytics with session replay. |
| **Custom endpoint** | POST events to your own API. Full control over data. |
| **None** | Keep the mock/no-op implementation. No event tracking. |

Again, suggest natural pairings:

> "Since you're already using Firebase, Firebase Analytics comes free with the SDK. Want that, or prefer a separate service?"

### Selection Summary

After all three questions, summarize the choices:

> "Here's your backend stack:
> - **Data:** {choice}
> - **Auth:** {choice}
> - **Analytics:** {choice}
>
> I'll now check if each service is configured. If anything is missing, I'll walk you through setup before wiring."

---

## 3. Phase 2: Setup Guidance

For each selected service, verify that the SDK and credentials are properly configured. Check in this order: data backend, auth backend, analytics backend.

### Firebase Setup

**Check for:** `GoogleService-Info.plist` in the project root or app directory.

**If found:** Verify it contains valid keys (API key, project ID, bundle ID).

> "Found GoogleService-Info.plist. Firebase is configured."

**If missing:** Walk through setup step by step:

> "Firebase needs a GoogleService-Info.plist. Here's how to set it up:
>
> 1. Go to [console.firebase.google.com](https://console.firebase.google.com)
> 2. Click 'Add project' (or select an existing project)
> 3. In the project, click the iOS icon to add an iOS app
> 4. Enter your bundle ID: {read from xcodeproj build settings}
> 5. Download the `GoogleService-Info.plist` file
> 6. Drag it into your Xcode project root (make sure 'Copy items if needed' is checked and the app target is selected)
>
> For the SDK, add `firebase-ios-sdk` via Swift Package Manager:
> 1. In Xcode: File > Add Package Dependencies
> 2. URL: `https://github.com/firebase/firebase-ios-sdk`
> 3. Select the products you need:
>    - `FirebaseFirestore` (for data)
>    - `FirebaseAuth` (if using Firebase Auth)
>    - `FirebaseAnalytics` (if using Firebase Analytics)
>
> Let me know when the plist is in place and the package is added."

Wait for the developer to confirm before proceeding.

**Check for Firebase initialization:** Search for `FirebaseApp.configure()` in the App entry point. If missing, note that it will be added during wiring.

### Supabase Setup

**Check for:** Supabase URL and anon key in configuration files.

Search for:
- `SUPABASE_URL` or `supabaseURL` in `.xcconfig` files, `Info.plist`, or Swift config files
- `SUPABASE_ANON_KEY` or `supabaseAnonKey` in the same locations

**If found:**

> "Found Supabase configuration. URL: {url}, key: {masked}."

**If missing:**

> "Supabase needs a project URL and anon key. Here's how:
>
> 1. Go to [supabase.com](https://supabase.com) and sign in
> 2. Click 'New Project', choose a name and region, set a database password
> 3. Wait for the project to provision (takes ~2 minutes)
> 4. Go to Settings > API
> 5. Copy the **Project URL** and **anon/public key**
> 6. Create a file `Secrets.xcconfig.local` in your project root (add to .gitignore):
>    ```
>    SUPABASE_URL = https://your-project.supabase.co
>    SUPABASE_ANON_KEY = eyJ...your-anon-key
>    ```
> 7. Add `supabase-swift` via Swift Package Manager:
>    - URL: `https://github.com/supabase/supabase-swift`
>    - Select: `Supabase`
>
> Let me know when the config file is in place and the package is added."

### CloudKit Setup

**Check for:** iCloud entitlement and container identifier.

Search in `.entitlements` files for:
- `com.apple.developer.icloud-container-identifiers`
- `com.apple.developer.icloud-services` containing `CloudKit`

**If found:**

> "Found CloudKit entitlement with container: {container ID}."

**If missing:**

> "CloudKit needs iCloud capabilities enabled. Here's how:
>
> 1. In Xcode, select your app target
> 2. Go to Signing & Capabilities
> 3. Click '+ Capability' and add 'iCloud'
> 4. Check 'CloudKit' under Services
> 5. Click '+' under Containers and create a container (e.g., `iCloud.com.yourcompany.yourapp`)
> 6. Go to [developer.apple.com/icloud/dashboard](https://developer.apple.com/icloud/dashboard) to manage your schema
>
> No SPM package needed — CloudKit is a system framework.
>
> Let me know when the capability is enabled."

### REST API Setup

**No SDK needed.** Ask for configuration:

> "For your REST API, I need a few details:
> 1. What's the base URL? (e.g., `https://api.yourapp.com/v1`)
> 2. How does authentication work? (Bearer token, API key header, cookie?)
> 3. Do you have API documentation or an example endpoint I can reference?"

Store the answers for use during wiring.

### GraphQL Setup

**No SDK needed** (uses URLSession). Ask for configuration:

> "For your GraphQL endpoint:
> 1. What's the endpoint URL? (e.g., `https://api.yourapp.com/graphql`)
> 2. How does authentication work? (Bearer token in Authorization header?)
> 3. Do you have a schema file (.graphql) or example queries?"

### SwiftData (Local Only)

**No setup needed.** Verify that SwiftData models exist or will be created during wiring.

> "SwiftData needs no external setup. I'll configure the ModelContainer in your app entry point and convert your data models to @Model classes."

### Analytics SDK Setup

**Mixpanel:**

Check for Mixpanel token in config files. If missing:

> "Mixpanel needs a project token:
> 1. Go to [mixpanel.com](https://mixpanel.com), create a project
> 2. Copy the project token from Settings > Project Settings
> 3. Add to `Secrets.xcconfig.local`:
>    ```
>    MIXPANEL_TOKEN = your-token-here
>    ```
> 4. Add `mixpanel-swift` via SPM: `https://github.com/mixpanel/mixpanel-swift`"

**PostHog:**

Check for PostHog API key. If missing:

> "PostHog needs an API key and host:
> 1. Go to [app.posthog.com](https://app.posthog.com), create a project
> 2. Copy the API key from Project Settings
> 3. Add to `Secrets.xcconfig.local`:
>    ```
>    POSTHOG_API_KEY = phc_your-key-here
>    POSTHOG_HOST = https://us.i.posthog.com
>    ```
> 4. Add `posthog-ios` via SPM: `https://github.com/PostHog/posthog-ios`"

**Custom endpoint:** Ask for the events API URL and payload format.

### Ready Check

After verifying all selected services are configured:

> "All services are configured and ready. Here's what I'll modify:
> - **AuthManager** — replace mock with {auth backend} implementation
> - **LogManager** — replace mock with {analytics backend} implementation
> - **{DataManagers}** — replace mock with {data backend} implementation
>
> Ready to wire? I'll modify your manager files now."

Wait for explicit confirmation before proceeding to Phase 3.

---

## 4. Phase 3: Manager Wiring

This is the core of the skill. For each manager, replace the mock implementation with real backend code. Work through managers one at a time: AuthManager first, then data managers, then LogManager.

**Critical rule:** Only modify manager implementation files. Never touch View or ViewModel files. The MVVM architecture means views talk to managers through protocols — swapping the implementation behind the protocol is invisible to the rest of the app.

### Before Wiring Any Manager

1. Read AGENTS.md to understand the project's manager pattern (protocol + Mock/Prod split).
2. Read the current manager implementation to understand:
   - The protocol it conforms to
   - All methods and properties that need real implementations
   - How errors are currently handled
   - Whether it uses `@MainActor` isolation
3. Read `FeatureFlags.swift` to understand how mock vs. real implementations are toggled.

### AuthManager Wiring

Read the AuthManager protocol to identify all methods that need implementation. Common methods:
- `signIn(email:password:)` or `signIn(with provider:)`
- `signUp(email:password:)`
- `signOut()`
- `currentUser` property
- `isSignedIn` property
- `authStateListener` or similar observation pattern

#### Firebase Auth Pattern

Load `references/backends.md` for the complete code pattern. Key changes:

```swift
import FirebaseAuth

// Replace mock sign-in with:
func signIn(email: String, password: String) async throws {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    self.currentUser = mapFirebaseUser(result.user)
}

// Add auth state listener in init:
Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
    self?.currentUser = firebaseUser.map { self?.mapFirebaseUser($0) } ?? nil
    self?.isSignedIn = firebaseUser != nil
}
```

#### Supabase Auth Pattern

```swift
import Supabase

func signIn(email: String, password: String) async throws {
    try await supabaseClient.auth.signIn(email: email, password: password)
    let session = try await supabaseClient.auth.session
    self.currentUser = mapSupabaseUser(session.user)
}
```

#### Custom JWT Pattern

```swift
func signIn(email: String, password: String) async throws {
    let body = LoginRequest(email: email, password: password)
    let request = try makeRequest(path: "/auth/login", method: "POST", body: body)
    let (data, response) = try await URLSession.shared.data(for: request)
    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
    try KeychainManager.save(token: loginResponse.token)
    self.currentUser = loginResponse.user
}
```

#### Apple-Only Pattern

```swift
import AuthenticationServices

func signInWithApple() async throws {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    let result = try await performAppleSignIn(request: request)
    // Extract credential and create/update user
}
```

**After wiring AuthManager:**

1. Build to verify compilation:
   ```bash
   xcodebuild -project *.xcodeproj -scheme "{AppName} - Dev" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build 2>&1 | tail -20
   ```
2. Fix any compile errors (missing imports, type mismatches, protocol conformance gaps).
3. Commit:
   ```bash
   git add {files modified}
   git commit -m "feat: wire AuthManager with {backend}"
   ```

### Data Manager Wiring

For each data manager (there may be multiple — one per domain entity or one shared), replace mock CRUD operations with real backend calls.

Read the manager's protocol to identify operations:
- `fetch()` or `getAll()` — list items
- `get(id:)` — single item
- `create(_:)` — add item
- `update(_:)` — modify item
- `delete(id:)` — remove item
- Any real-time listeners or sync methods

#### Firestore Pattern

```swift
import FirebaseFirestore

private let db = Firestore.firestore()
private let collectionName = "items"

func fetch() async throws -> [Item] {
    let snapshot = try await db.collection(collectionName).getDocuments()
    return snapshot.documents.compactMap { doc in
        try? doc.data(as: Item.self)
    }
}

func create(_ item: Item) async throws {
    try db.collection(collectionName).document(item.id).setData(from: item)
}

func update(_ item: Item) async throws {
    try db.collection(collectionName).document(item.id).setData(from: item, merge: true)
}

func delete(id: String) async throws {
    try await db.collection(collectionName).document(id).delete()
}

// Real-time listener
func observeItems() -> AsyncStream<[Item]> {
    AsyncStream { continuation in
        let listener = db.collection(collectionName)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let items = documents.compactMap { try? $0.data(as: Item.self) }
                continuation.yield(items)
            }
        continuation.onTermination = { _ in listener.remove() }
    }
}
```

#### Supabase Pattern

```swift
import Supabase

func fetch() async throws -> [Item] {
    try await supabaseClient.database
        .from("items")
        .select()
        .execute()
        .value
}

func create(_ item: Item) async throws {
    try await supabaseClient.database
        .from("items")
        .insert(item)
        .execute()
}

func update(_ item: Item) async throws {
    try await supabaseClient.database
        .from("items")
        .update(item)
        .eq("id", value: item.id)
        .execute()
}

func delete(id: String) async throws {
    try await supabaseClient.database
        .from("items")
        .delete()
        .eq("id", value: id)
        .execute()
}
```

#### REST API Pattern

```swift
func fetch() async throws -> [Item] {
    let request = try makeRequest(path: "/items", method: "GET")
    let (data, response) = try await URLSession.shared.data(for: request)
    try validateResponse(response)
    return try JSONDecoder().decode([Item].self, from: data)
}

func create(_ item: Item) async throws {
    let request = try makeRequest(path: "/items", method: "POST", body: item)
    let (_, response) = try await URLSession.shared.data(for: request)
    try validateResponse(response)
}

func update(_ item: Item) async throws {
    let request = try makeRequest(path: "/items/\(item.id)", method: "PUT", body: item)
    let (_, response) = try await URLSession.shared.data(for: request)
    try validateResponse(response)
}

func delete(id: String) async throws {
    let request = try makeRequest(path: "/items/\(id)", method: "DELETE")
    let (_, response) = try await URLSession.shared.data(for: request)
    try validateResponse(response)
}
```

#### GraphQL Pattern

```swift
func fetch() async throws -> [Item] {
    let query = """
    query {
        items {
            id
            title
            createdAt
        }
    }
    """
    let response: GraphQLResponse<ItemsData> = try await executeQuery(query)
    return response.data.items
}

func create(_ item: Item) async throws {
    let mutation = """
    mutation CreateItem($input: CreateItemInput!) {
        createItem(input: $input) {
            id
            title
            createdAt
        }
    }
    """
    let variables: [String: Any] = [
        "input": ["title": item.title, "createdAt": item.createdAt.iso8601]
    ]
    let _: GraphQLResponse<CreateItemData> = try await executeQuery(mutation, variables: variables)
}
```

#### CloudKit Pattern

```swift
import CloudKit

private let container = CKContainer.default()
private let database = CKContainer.default().privateCloudDatabase
private let recordType = "Item"

func fetch() async throws -> [Item] {
    let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    let (results, _) = try await database.records(matching: query)
    return results.compactMap { _, result in
        guard case .success(let record) = result else { return nil }
        return Item(from: record)
    }
}

func create(_ item: Item) async throws {
    let record = item.toCKRecord()
    try await database.save(record)
}

func delete(id: String) async throws {
    let recordID = CKRecord.ID(recordName: id)
    try await database.deleteRecord(withID: recordID)
}
```

#### SwiftData Pattern

```swift
import SwiftData

// Models become @Model classes:
@Model
final class ItemModel {
    var id: String
    var title: String
    var createdAt: Date

    init(id: String, title: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

// Manager uses ModelContext:
func fetch() throws -> [Item] {
    let descriptor = FetchDescriptor<ItemModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
    let models = try modelContext.fetch(descriptor)
    return models.map { $0.toItem() }
}

func create(_ item: Item) throws {
    let model = ItemModel(from: item)
    modelContext.insert(model)
    try modelContext.save()
}
```

**After wiring each data manager:**

1. Build to verify compilation.
2. Fix compile errors.
3. Commit:
   ```bash
   git add {files modified}
   git commit -m "feat: wire {ManagerName} with {backend}"
   ```

### LogManager Wiring

Replace the mock event tracking with real analytics SDK calls. The LogManager typically conforms to a protocol with methods like:
- `trackEvent(event: LoggableEvent)`
- `setUserProperty(name:value:)`
- `setUserId(_:)`

#### Firebase Analytics Pattern

```swift
import FirebaseAnalytics

func trackEvent(event: LoggableEvent) {
    switch event.type {
    case .analytic:
        Analytics.logEvent(event.eventName, parameters: event.parameters)
    case .error:
        Analytics.logEvent("error_\(event.eventName)", parameters: event.parameters)
    case .debug:
        #if DEBUG
        print("[Analytics] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }
}

func setUserProperty(name: String, value: String?) {
    Analytics.setUserProperty(value, forName: name)
}

func setUserId(_ id: String?) {
    Analytics.setUserID(id)
}
```

#### Mixpanel Pattern

```swift
import Mixpanel

func trackEvent(event: LoggableEvent) {
    switch event.type {
    case .analytic:
        let properties = (event.parameters ?? [:]).reduce(into: Properties()) { result, pair in
            result[pair.key] = MixpanelType(pair.value)
        }
        Mixpanel.mainInstance().track(event: event.eventName, properties: properties)
    case .error:
        Mixpanel.mainInstance().track(event: "error_\(event.eventName)", properties: properties)
    case .debug:
        #if DEBUG
        print("[Mixpanel] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }
}

func setUserProperty(name: String, value: String?) {
    if let value {
        Mixpanel.mainInstance().people.set(property: name, to: value)
    }
}

func setUserId(_ id: String?) {
    if let id {
        Mixpanel.mainInstance().identify(distinctId: id)
    }
}
```

#### PostHog Pattern

```swift
import PostHog

func trackEvent(event: LoggableEvent) {
    switch event.type {
    case .analytic:
        PostHogSDK.shared.capture(event.eventName, properties: event.parameters)
    case .error:
        PostHogSDK.shared.capture("error_\(event.eventName)", properties: event.parameters)
    case .debug:
        #if DEBUG
        print("[PostHog] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }
}

func setUserProperty(name: String, value: String?) {
    if let value {
        PostHogSDK.shared.capture("$set", userProperties: [name: value])
    }
}

func setUserId(_ id: String?) {
    if let id {
        PostHogSDK.shared.identify(id)
    }
}
```

#### Custom Endpoint Pattern

```swift
func trackEvent(event: LoggableEvent) {
    switch event.type {
    case .analytic, .error:
        Task {
            let payload = EventPayload(
                name: event.eventName,
                parameters: event.parameters,
                timestamp: Date(),
                userId: currentUserId
            )
            let request = try makeRequest(path: "/events", method: "POST", body: payload)
            try await URLSession.shared.data(for: request)
        }
    case .debug:
        #if DEBUG
        print("[Analytics] \(event.eventName): \(event.parameters ?? [:])")
        #endif
    }
}
```

#### None (Keep Mock)

No changes needed. The existing mock/no-op implementation stays as-is.

**After wiring LogManager:**

1. Build to verify compilation.
2. Fix compile errors.
3. Commit:
   ```bash
   git add {files modified}
   git commit -m "feat: wire LogManager with {backend}"
   ```

### SDK Initialization

After all managers are wired, ensure the SDKs are initialized at app launch. Check the app entry point (usually `{AppName}App.swift` or `AppDelegate.swift`):

**Firebase:** Add `FirebaseApp.configure()` in the app initializer or `didFinishLaunching`.

**Supabase:** Create a shared `SupabaseClient` instance:
```swift
let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: Configuration.supabaseURL)!,
    supabaseKey: Configuration.supabaseAnonKey
)
```

**Mixpanel:** `Mixpanel.initialize(token: Configuration.mixpanelToken, trackAutomaticEvents: true)`

**PostHog:** Configure PostHog with API key and host:
```swift
let config = PostHogConfig(apiKey: Configuration.posthogAPIKey, host: Configuration.posthogHost)
PostHogSDK.shared.setup(config)
```

**CloudKit:** No explicit initialization needed — CKContainer is configured via entitlements.

**SwiftData:** Add ModelContainer to the app:
```swift
.modelContainer(for: [ItemModel.self, ...])
```

Build and commit:
```bash
git add {files modified}
git commit -m "feat: initialize {SDK names} at app launch"
```

---

## 5. Phase 4: Verification

After all managers are wired and SDKs initialized, run a comprehensive verification.

### Build Verification

Build on the Dev scheme (not Mock) to ensure real SDK imports resolve:

```bash
xcodebuild -project *.xcodeproj -scheme "{AppName} - Dev" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build 2>&1 | tail -30
```

If the Dev scheme does not exist, build on the default scheme without "Mock" in the name.

If the build fails:
1. Read the error output.
2. Common issues at this stage:
   - Missing SPM package dependencies (SDK not added)
   - Missing `import` statements for SDK frameworks
   - Type mismatches between SDK types and app models
   - Protocol conformance gaps (mock had methods that real implementation is missing)
   - `@Sendable` or concurrency issues with SDK callbacks
3. Fix each error.
4. Rebuild until clean.

Warnings from app code are blockers — fix them. Warnings from external packages are acceptable.

### Feature Flag Update

Read `FeatureFlags.swift` (or equivalent configuration file). Update flags to enable real services:

- Set `useFirebase` / `useSupabase` / `useRealAuth` etc. to `true` for Dev/Prod configurations
- Ensure Mock configuration still uses mock implementations
- Verify the flag-based switching logic correctly routes to the new real implementations

Commit:
```bash
git add {files modified}
git commit -m "feat: enable real services in Dev/Prod feature flags"
```

### Wiring Report

Present a summary of everything that was wired:

```
## Wiring Complete: {AppName}

**Data backend:** {choice} — wired in {list of data managers}
**Auth backend:** {choice} — wired in AuthManager
**Analytics:** {choice} — wired in LogManager

### Managers Modified

| Manager | Before | After |
|---------|--------|-------|
| AuthManager | Mock (hardcoded user) | {backend} (real sign-in/sign-out) |
| {DataManager} | Mock (in-memory array) | {backend} (real CRUD operations) |
| LogManager | Mock (print statements) | {backend} (real event tracking) |

### SDKs Added

- {SDK name} via SPM — {what it handles}
- {SDK name} via SPM — {what it handles}

### Configuration Files

- {file}: {what was added/changed}
- {file}: {what was added/changed}

### Follow-Up Tasks

These items are outside forge-wire's scope but should be addressed before shipping:

- [ ] **Database rules/security:** {Set up Firestore security rules / Supabase RLS policies / CloudKit permissions}
- [ ] **Error handling:** Review error messages shown to users — replace generic errors with user-friendly copy
- [ ] **Offline support:** {Configure Firestore offline persistence / implement local caching for REST/GraphQL}
- [ ] **Cloud Functions/Edge Functions:** {Deploy server-side logic if needed: email triggers, data validation, webhooks}
- [ ] **Environment config:** Verify Dev vs Prod credentials point to different projects/environments
- [ ] **Rate limiting:** Add retry logic with exponential backoff for API calls
- [ ] **Data migration:** Plan data migration if moving from mock to real (existing test data)

### Next Step

Your app is now connected to real services. To prepare for App Store submission, use `/forge:ship` (coming soon).
```

---

## 6. Token Optimization Notes

<!-- Model hints for token optimization:
- Phase 1 (service selection): Use current model (adaptive questioning, context-sensitive suggestions)
- Phase 2 (setup guidance): Can use sonnet model if available (step-by-step instructions are templated)
- Phase 3 (manager wiring): Use current model for the first manager of each type (pattern establishment), then sonnet for subsequent managers following the same pattern
- Phase 4 (verification): Can use haiku model (mechanical build check and flag update)

Context management:
- Phase 1 conversation is lightweight — 3 questions with short answers
- Phase 2 setup guidance can be loaded from references/setup-guides.md on demand
- Phase 3 wiring patterns can be loaded from references/backends.md on demand
- Each manager wiring is independent — pass only the relevant protocol definition and backend pattern
- The verification step needs the list of modified files but not the full wiring history
- After Phase 1 selection, the conversation history is no longer needed — only the selection summary matters
-->

---

## 7. Skill Boundaries

| Domain | forge-wire Handles | Defers To |
|--------|-------------------|-----------|
| Service selection | Guiding the developer through data/auth/analytics choices | -- |
| SDK setup | Verifying configuration, walking through credential setup | Developer for console actions (creating projects, downloading plists) |
| Manager wiring | Replacing mock implementations with real backend code | -- |
| SDK initialization | Adding configure/setup calls to app entry point | -- |
| Feature flags | Updating flags to enable real services | -- |
| Build verification | Ensuring the wired app compiles on Dev scheme | -- |
| Database rules | -- | Developer (Firestore rules, Supabase RLS, CloudKit permissions) |
| Server-side logic | -- | Developer (Cloud Functions, Edge Functions, API endpoints) |
| View/ViewModel changes | -- | Never touched by this skill — MVVM architecture isolates the change |
| App Store submission | -- | Future: `forge-ship` for privacy manifest, metadata, screenshots |
| Screen building | -- | `forge-app` / `forge-feature` for UI and screen creation |
| Project setup | -- | `forge-workspace` for initial template configuration |
| Design polish | -- | `forge-craft` for mood-driven UI design (unaffected by backend wiring) |
