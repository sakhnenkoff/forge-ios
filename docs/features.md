# Feature Toggle Reference

Forge uses a feature registry of JSON manifests to determine what gets generated. Each feature maps to one or more `FeatureFlags.swift` constants that enable/disable manager initialization at runtime. Setting a flag to `false` means the corresponding manager is never initialized, reducing startup time and memory usage.

This document serves two audiences:
- **CLI users** choosing features during `forge` generation
- **Developers** extending the feature registry with custom features

---

## Feature Toggle Reference

### Complete Feature Table

| CLI ID | Display Name | Category | Feature Flag | Default | Dependencies | Required Credentials |
|--------|-------------|---------|-------------|---------|-------------|---------------------|
| `firebase-analytics` | Firebase Analytics | analytics | `enableFirebaseAnalytics` | `true` | — | GoogleService-Info.plist |
| `mixpanel` | Mixpanel | analytics | `enableMixpanel` | `true` | — | `MIXPANEL_TOKEN` xcconfig |
| `crashlytics` | Firebase Crashlytics | analytics | `enableCrashlytics` | `true` | `firebase-analytics` | GoogleService-Info.plist (same) |
| `revenuecat` | RevenueCat (IAP) | monetization | `enablePurchases` | `true` | `firebase-analytics` | `REVENUECAT_API_KEY` xcconfig |
| — | Auth | (always present) | `enableAuth` | `true` | — | Firebase Auth in GoogleService-Info.plist |
| `push-notifications` | Push Notifications | notifications | `enablePushNotifications` | `true` | `firebase-analytics` | APNs Key in Firebase Console |
| `ab-testing` | A/B Testing | testing | `enableABTesting` | `true` | `firebase-analytics` | — |
| `onboarding` | Onboarding Flow | module | — (no flag) | included when selected | — | — |
| `image-upload` | Image Upload | module | — (no flag) | included when selected | — | — |

**Note about module features:** `onboarding` and `image-upload` have no `FeatureFlags.swift` toggle — they are always compiled in when selected during generation. To remove them post-generation, delete the feature files.

**Note about auth:** `enableAuth` is always present in `FeatureFlags.swift` and is not a CLI-selectable feature — auth is always included in the template. Toggle it to `false` to disable the sign-in routing after generation.

---

### Flag Details

#### `enableFirebaseAnalytics`

**What it enables:** Firebase SDK initialization, `LogManager` Firebase route, Firebase Analytics event tracking.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift` — the flag itself
- `{ProjectName}/App/AppDelegate.swift` — `Firebase.configure()` call
- `{ProjectName}/App/AppServices.swift` — manager initialization guard
- `{ProjectName}/Managers/LogManager/` — Firebase analytics route

**Dependencies:** None. Other features depend on this one.

**Default:** `true` (enabled when firebase-analytics is selected during generation)

**Required credentials:** `GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist` from Firebase Console → Project Settings → iOS App → Add App

**To disable post-generation:** Set `enableFirebaseAnalytics = false`. Warning: Crashlytics, Push Notifications, A/B Testing, and RevenueCat tracking will stop working if this is disabled while they are enabled.

---

#### `enableMixpanel`

**What it enables:** Mixpanel SDK initialization, `LogManager` Mixpanel analytics route, user behavior tracking.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppServices.swift`
- `{ProjectName}/Managers/LogManager/` — Mixpanel route

**Dependencies:** None.

**Default:** `true` (enabled when mixpanel is selected)

**Required credentials:** `MIXPANEL_TOKEN` in `Configurations/Secrets.xcconfig.local` (from mixpanel.com → Project Settings → Project Token)

---

#### `enableCrashlytics`

**What it enables:** Firebase Crashlytics initialization, crash reporting and stability monitoring.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppDelegate.swift` — Crashlytics initialization
- `{ProjectName}/App/AppServices.swift`

**Dependencies:** `firebase-analytics` (Crashlytics requires the Firebase SDK)

**Default:** `true` (enabled when crashlytics is selected)

**Required credentials:** Same `GoogleService-Info.plist` as Firebase Analytics (no additional setup needed)

---

#### `enablePurchases`

**What it enables:** RevenueCat SDK initialization, `PurchaseManager`, paywall routing via `AppSession.shouldShowPaywall`.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppServices.swift`
- `{ProjectName}/App/AppSession.swift` — `shouldShowPaywall` routing logic
- `{ProjectName}/Managers/PurchaseManager/`

**Dependencies:** `firebase-analytics` (for purchase event tracking)

**Default:** `true` (enabled when subscription or onetime monetization is selected)

**Required credentials:** `REVENUECAT_API_KEY` in `Configurations/Secrets.xcconfig.local` (from app.revenuecat.com → Project → API Keys → Public Apple API key)

---

#### `enableAuth`

**What it enables:** Auth sign-in routing. When `true`, unauthenticated users are shown the sign-in screen (controlled by `AppSession.shouldShowAuth`).

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppSession.swift` — routing logic
- `{ProjectName}/Features/Auth/` — sign-in views and view models

**Dependencies:** None. (Firebase Auth SDK is configured via GoogleService-Info.plist when firebase-analytics is selected)

**Default:** `true` (always present in generated project)

**Note:** This flag controls routing only — the Auth feature files are always compiled in. Setting to `false` bypasses the sign-in screen entirely.

---

#### `enablePushNotifications`

**What it enables:** Push notification registration, `PushManager` initialization, Firebase Cloud Messaging (FCM) setup in AppDelegate.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppDelegate.swift` — remote notification registration and FCM token handling
- `{ProjectName}/App/AppServices.swift`
- `{ProjectName}/Managers/PushManager/`

**Dependencies:** `firebase-analytics` (FCM uses the Firebase SDK)

**Default:** `true` (enabled when push-notifications is selected)

**Required credentials:** APNs Key or Certificate uploaded to Firebase Console → Cloud Messaging → Apple app configuration

---

#### `enableABTesting`

**What it enables:** A/B testing and feature flag management via Firebase Remote Config, `ABTestManager` initialization.

**Files affected:**
- `{ProjectName}/Utilities/FeatureFlags.swift`
- `{ProjectName}/App/AppServices.swift`
- `{ProjectName}/Managers/ABTestManager/`

**Dependencies:** `firebase-analytics` (Remote Config uses the Firebase SDK)

**Default:** `true` (enabled when ab-testing is selected)

**Required credentials:** None (Remote Config is part of the Firebase project — no separate key needed)

---

## Adding Features to the Registry

Features live in `forge-cli/Sources/ForgeCLI/Resources/features/` as JSON files. Each file is a `FeatureManifest`.

### JSON Manifest Schema

```json
{
  "id": "your-feature-id",
  "displayName": "Your Feature",
  "description": "One-line description shown in the wizard",
  "featureFlag": "enableYourFeature",
  "dependencies": [],
  "conflicts": [],
  "xcconfigs": [
    {
      "key": "YOUR_API_KEY",
      "defaultValue": "",
      "description": "Where to find this key (e.g. your-service.com → Settings → API Keys)"
    }
  ],
  "requiredCredentials": [
    {
      "name": "Your API Key",
      "source": "Where to obtain it (displayed in Next Steps after generation)",
      "xconfigKey": "YOUR_API_KEY"
    }
  ],
  "category": "analytics"
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Kebab-case identifier. Used in `--features` flag and dependency references. |
| `displayName` | string | Yes | Human-readable name shown in the wizard and Next Steps output. |
| `description` | string | Yes | One-line description shown in the wizard. |
| `featureFlag` | string | Yes | Property name in `FeatureFlags.swift`. Use `""` if no flag is needed (e.g. pure module). |
| `dependencies` | string[] | Yes | IDs of other features this feature requires. Empty array if none. |
| `conflicts` | string[] | Yes | IDs this feature cannot coexist with. Empty array if none (currently unused in resolver). |
| `xcconfigs` | object[] | Yes | xcconfig keys added to `Secrets.xcconfig.local.example`. Empty array if none. |
| `requiredCredentials` | object[] | Yes | Credentials the developer must supply. Displayed in Next Steps after generation. Empty array if none. |
| `category` | string | Yes | One of: `analytics`, `monetization`, `auth`, `module`, `notifications`, `testing` |

### Steps to Add a New Feature

1. **Create the manifest:** Add `your-feature-id.json` to `forge-cli/Sources/ForgeCLI/Resources/features/`

2. **Add the flag:** Add `static let enableYourFeature = false` to `Forge/Utilities/FeatureFlags.swift` (default `false` in the template source)

3. **Guard initialization:** Add the feature's manager initialization in `AppServices.swift` behind `guard FeatureFlags.enableYourFeature else { return }`

4. **Rebuild the CLI:** Run `swift build` in `forge-cli/` to pick up the new manifest

5. **Test it:** Run `forge` and verify your feature appears in the wizard's feature module selection

For adding the actual Swift implementation (files, manager, integration), see [Adding a Feature](adding-a-feature.md).

---

## See Also

- [CLI Usage Guide](cli-usage.md) — How to select features during generation
- [CLI Flag Reference](cli-flags.md) — `--features` and `--analyticsServices` flags
- [Adding a Feature](adding-a-feature.md) — Swift implementation guide
- [Getting Started](getting-started.md) — First-time setup
