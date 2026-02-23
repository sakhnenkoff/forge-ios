# Getting Started with Forge

## Prerequisites

- **Xcode 16+** (iOS 26 SDK required)
- **Swift 5.9+**
- **macOS 14+** (Sonoma or later)

## Step 1: Clone and Run (No Credentials Needed)

The **Mock build** runs without any Firebase or RevenueCat credentials. It uses local stub data so you can explore the template immediately.

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd forge
   ```

2. Open `Forge.xcodeproj` in Xcode.

3. Select the **Forge - Mock** scheme from the scheme picker.

4. Run on a simulator. The app launches with local stub data — no API keys, no network calls.

> **What Mock mode does:** Replaces Firebase Auth with a pre-signed-in local mock, replaces Firestore with in-memory data, and replaces RevenueCat with mock purchase results. All feature flows are exercisable without a single real credential.

## Step 2: Create Your App from the Template

> **Important:** Never manually copy the template with `cp -R` or `rsync`. Always use one of the methods below — they handle renaming, bundle ID, imports, and directory structure correctly.

### Option A: CLI tool (recommended)

```bash
./scripts/new-app.sh YourAppName ~/Documents/Developer/Apps com.yourcompany.yourapp "Your App"
```

This copies the template to the destination, renames everything, and produces a ready-to-open project.

### Option B: AI-assisted (Claude Code)

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
claude plugin install forge-app@forge-marketplace
```

Then say `/forge:app` — it handles project creation, setup, and builds all your screens.

### Option C: Rename in place

If you've already cloned the template and want to rename it:

```bash
./rename_project.sh YourAppName --bundle-id com.yourcompany.yourapp --display-name "Your App"
```

After creating your project:
- Update the app icon and launch screen
- Update `DemoContent.swift` with your app's copy (navigation titles, section headers, placeholder text)

## Step 3: Understand the Build Configurations

The template ships with three build configurations, each using a different xcconfig file:

| Configuration | Scheme | Firebase | RevenueCat | Purpose |
|--------------|--------|----------|------------|---------|
| **Mock** | Forge - Mock | None (local stubs) | None (mock) | Rapid development, no credentials |
| **Dev** | Forge - Dev | Real (dev project) | Sandbox | Full integration, test credentials |
| **Production** | Forge | Real (prod project) | Production | App Store releases |

Configuration files live in `Forge/Configurations/`:
- `Mock.xcconfig` — no API keys, points to local stubs
- `Development.xcconfig` — includes `Secrets.xcconfig.local` (gitignored)
- `Production.xcconfig` — includes `Secrets.xcconfig.local` (gitignored)

**To set up Dev/Production credentials:**
```bash
cp Forge/Configurations/Secrets.xcconfig.local.example Forge/Configurations/Secrets.xcconfig.local
# Edit the .local file and add your real API keys
```

## Step 4: Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app with your bundle ID
3. Download `GoogleService-Info.plist` and add it to the `Forge/` group in Xcode
4. In Firebase console, enable these products:
   - **Authentication** (Apple Sign-In, Google Sign-In)
   - **Firestore** (database)
   - **Analytics** (usage tracking)
   - **Crashlytics** (crash reporting)
5. For Apple Sign-In: add your Apple Team ID and Service ID in Firebase Auth settings
6. For Google Sign-In: copy the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` into your URL Schemes in Xcode

> **Dev vs Production Firebase:** Use separate Firebase projects for Dev and Production. Place each project's `GoogleService-Info.plist` in the correct xcconfig target or use build phase scripts to swap them.

## Step 5: Configure RevenueCat

1. Create a RevenueCat account at [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new project and add your iOS app
3. Copy your **API key** and add it to `Secrets.xcconfig.local`:
   ```
   REVENUECAT_API_KEY = appl_your_key_here
   ```
4. In `Forge/Managers/Purchases/EntitlementOption.swift`, replace the placeholder product IDs with your App Store Connect product IDs:
   ```swift
   case .monthly:  return "com.yourcompany.yourapp.monthly"
   case .annual:   return "com.yourcompany.yourapp.annual"
   case .lifetime: return "com.yourcompany.yourapp.lifetime"
   ```
5. Delete any `EntitlementOption` cases you don't use (e.g., remove `.lifetime` if you're subscription-only)

## First Run Checklist

Before submitting to the App Store:

- [ ] Bundle ID updated (`rename_project.sh` done)
- [ ] App icon replaced (`Forge/SupportingFiles/Assets.xcassets/AppIcon`)
- [ ] `DemoContent.swift` updated with your app's copy
- [ ] `FeatureFlags.swift` configured (enable/disable auth, purchases, push notifications)
- [ ] Firebase project created and `GoogleService-Info.plist` added
- [ ] RevenueCat project created, API key added, product IDs updated
- [ ] Push notification entitlements configured in Xcode (for push notifications)
- [ ] Apple Sign-In capability added in Xcode Signing & Capabilities
- [ ] `CleanTheme.swift` brand color updated (look for "START HERE" comment)
- [ ] Onboarding copy updated (`OnboardingStep.swift` headline/subtitle strings)
- [ ] Privacy policy and terms of service URLs added to `DemoContent.Auth`
