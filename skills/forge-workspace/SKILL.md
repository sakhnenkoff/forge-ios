---
name: forge-workspace
description: >
  Set up a Forge template project for a new app. Use when the user says
  "set up Forge for [app]", "I want to build [app]", "initialize project",
  "start new app", "customize template", or wants to transform the Forge
  template into their own branded app. Gathers app name, domain, brand color,
  feature flags, and monetization model, then renames the project, configures
  the theme, rewrites onboarding/dashboard/paywall content, and updates AGENTS.md.
license: MIT
---

# Forge Workspace Setup

This skill transforms a Forge template clone into a fully configured, renamed, branded app project. It operates in four phases: gather context, generate plan, execute, and verify.

---

## Prerequisites Check

Before starting, verify ALL of the following exist. If any are missing, stop and tell the user what's wrong.

```
[ ] *.xcodeproj exists in working directory (Forge.xcodeproj or already renamed)
[ ] rename_project.sh exists in working directory
[ ] AGENTS.md exists in working directory
[ ] Packages/core-packages/DesignSystem/ directory exists
```

Run these checks:
1. `ls *.xcodeproj` — must find exactly one
2. `ls rename_project.sh` — must exist and be executable
3. `ls AGENTS.md` — must exist
4. `ls Packages/core-packages/DesignSystem/` — must exist

If the project has already been renamed (no `Forge.xcodeproj` but another `.xcodeproj` exists), skip the rename step in Phase 3.

---

## Phase 1 — Gather Context

Ask the user these questions using the AskUserQuestion tool. Ask all questions in a single call when possible.

### Question 1: App Name + Bundle ID

**Question**: "What's your app name? I'll suggest a bundle ID based on it."

After the user answers, suggest a bundle ID like `com.{company}.{appname}` (lowercase, no spaces). Let them confirm or override.

### Question 2: What the App Does

**Question**: "What does your app do? (e.g., 'habit tracking', 'meditation timer', 'recipe organizer', 'workout logger')"

This determines:
- Onboarding step content (icons, headlines, subtitles)
- Dashboard content (what stats/lists to show)
- Paywall value propositions
- Goal options for the onboarding goals step

### Question 3: Brand Color

**Question**: "Pick a brand color for your app."

**Options** (present as choices):
- Plum (default Forge purple)
- Blue
- Green
- Orange
- Red
- Teal
- Indigo
- Pink
- Custom hex (let user type)

Map to the `AdaptiveTheme` initializer color. The brand color is set via:
```swift
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .{color}))
```

Available colors: `.plum` (default), `.blue`, `.green`, `.orange`, `.red`, `.teal`, `.indigo`, `.pink`, or `Color(hex: "XXXXXX")` for custom.

### Question 4: Features to Enable

**Question**: "Which features do you want enabled?" (multi-select)

**Options**:
- Authentication (sign-in flow) — `enableAuth`
- In-App Purchases (RevenueCat) — `enablePurchases`
- Push Notifications (Firebase) — `enablePushNotifications`
- Analytics (Mixpanel) — `enableMixpanel`
- Firebase Analytics — `enableFirebaseAnalytics`
- Crash Reporting (Crashlytics) — `enableCrashlytics`
- A/B Testing (Remote Config) — `enableABTesting`

Default: all enabled. Note dependency: Crashlytics, Push, and A/B Testing require Firebase Analytics.

### Question 5: Monetization (only if purchases enabled)

**Question**: "What's your monetization model?"

**Options**:
- Monthly + Annual subscriptions
- Monthly + Annual + Lifetime
- Lifetime only
- Free (disable purchases)

This determines which `EntitlementOption` cases to keep and what product IDs to suggest.

---

## Phase 2 — Generate Setup Plan

After gathering context, produce a concrete plan. Present it to the user for review before executing.

The plan must cover ALL of the following:

### 1. Rename Command
```bash
./rename_project.sh {AppName} --bundle-id {bundle.id}
```

### 2. Theme Configuration
In `{App}/App/AppDelegate.swift`, update:
```swift
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .{color}))
```

### 3. Feature Flags
In `{App}/Utilities/FeatureFlags.swift`, set each flag to `true` or `false` based on user selections.

If Firebase Analytics is disabled, also disable Crashlytics, Push Notifications, and A/B Testing (they depend on it).

### 4. Onboarding Steps
Rewrite `{App}/Features/Onboarding/OnboardingStep.swift`:
- Keep the enum structure (cases, computed properties)
- Replace finance-themed content with domain-appropriate content
- Map intro screens to the app's value propositions
- Map goals to domain-relevant choices
- Update icons to match the domain

Rewrite `{App}/Features/Onboarding/OnboardingController.swift`:
- Update the `steps` array if adding/removing steps
- Update `selectedGoals` type if needed

### 5. Dashboard
Describe changes to `{App}/Features/Home/HomeView.swift`:
- Replace hero stat card content (what's the primary metric?)
- Replace quick stats pills (what secondary stats?)
- Replace activity list items (what recent items look like?)
- Keep the Components gallery tab — it's a DS reference

Describe changes to `{App}/Features/Home/HomeViewModel.swift`:
- Update greeting if needed
- Add domain-specific data properties
- Update analytics events

### 6. Product IDs
In `{App}/Managers/Purchases/EntitlementOption.swift`:
- Update product ID strings to `{bundle.id}.monthly`, `{bundle.id}.annual`, `{bundle.id}.lifetime`
- Remove unused cases based on monetization model

### 7. Paywall Value Props
In `{App}/Features/Paywall/PaywallView.swift`:
- Update the `heroCard` title (e.g., "{AppName} Pro")
- Update the description text
- Replace `featureBullet` entries with domain-relevant premium features
- Update any "Forge Pro" text references

### 8. Constants
In `{App}/Utilities/Constants.swift`:
- Update `privacyPolicyUrlString` placeholder
- Update `termsOfServiceUrlString` placeholder

### 9. AGENTS.md Rewrite
Full rewrite following the strategy in the AGENTS.md Rewrite section below.

Present the plan and wait for user approval before proceeding to Phase 3.

---

## Phase 3 — Execute

After user approves the plan, execute each step in order. Use the Write/Edit tools for file changes.

### Checkpoint & Recovery Protocol

Phase 3 has 11 sequential steps. If a step fails mid-execution, the project may be in a partially configured state. Follow these rules:

1. **After each step**, verify it succeeded before proceeding:
   - Step 1 (rename): Confirm `{AppName}.xcodeproj` exists and `Forge.xcodeproj` does not
   - Steps 2-10 (file edits): Confirm the file was written without error
   - Step 11 (AGENTS.md): Confirm the file was written without error

2. **If any step fails**, STOP and report to the developer:
   > "Step {N} ({description}) failed: {error}. Steps 1-{N-1} completed successfully. The project is partially configured. To recover: {what to fix or re-run}."

3. **Do NOT skip a failed step and continue.** Each step builds on the previous. If Step 4 (OnboardingStep) fails, Steps 5-11 may reference the wrong content.

4. **Track progress** — after completing each step, mentally note it as done. If context resets mid-execution, the developer can tell you which step to resume from.

### Step 1: Run Rename Script

```bash
./rename_project.sh {AppName} --bundle-id {bundle.id}
```

After running, the project directory structure changes:
- `Forge/` → `{AppName}/`
- `Forge.xcodeproj` → `{AppName}.xcodeproj`
- All `import Forge` → `import {AppName}`

**All subsequent file paths use `{AppName}/` instead of `Forge/`.**

**Verify rename succeeded:** Confirm `{AppName}.xcodeproj` exists and `Forge.xcodeproj` does not. If the rename script failed (exit code non-zero, or `Forge.xcodeproj` still exists), STOP and report:
> "Rename script failed: {error}. Check that Forge.xcodeproj exists and the script is executable."

Do not continue with subsequent steps if the rename failed — all paths depend on the new app name.

### Step 2: Edit AppDelegate (Brand Color)

File: `{AppName}/App/AppDelegate.swift`

Change:
```swift
DesignSystem.configure(theme: AdaptiveTheme())
```
To:
```swift
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .{color}))
```

If the user chose the default plum color, leave as `AdaptiveTheme()` (plum is the default).

### Step 3: Edit FeatureFlags

File: `{AppName}/Utilities/FeatureFlags.swift`

Set each `static let enable*` to `true` or `false` based on user selections.

### Step 4: Rewrite OnboardingStep

File: `{AppName}/Features/Onboarding/OnboardingStep.swift`

Replace the entire enum body with domain-appropriate content. Keep the same structure:
- 3 intro cases (text-intro screens for value props)
- 1 goals case (user selects from domain-relevant options)
- 1 permissions case (if push enabled)
- 1 name case

Update ALL computed properties: `isTextIntro`, `analyticsId`, `title`, `icon`, `introHeadline`, `headlineLeading`, `headlineHighlight`, `headlineTrailing`, `subtitle`, `ctaTitle`.

### Step 5: Update OnboardingController

File: `{AppName}/Features/Onboarding/OnboardingController.swift`

Update the `steps` computed property if step cases changed.

### Step 6: Update HomeView

File: `{AppName}/Features/Home/HomeView.swift`

Replace the dashboard content:
- `heroStatCard` — primary metric for the domain
- `quickStatsRow` — two secondary stats
- `activityList` — recent items relevant to the domain

Keep the Components gallery tab unchanged.

### Step 7: Update HomeViewModel

File: `{AppName}/Features/Home/HomeViewModel.swift`

Update analytics event names from `Home_Appear` to `{AppName}_Home_Appear` or similar.

### Step 8: Update EntitlementOption

File: `{AppName}/Managers/Purchases/EntitlementOption.swift`

- Update product IDs to use the app's bundle ID
- Remove unused cases based on monetization model
- Remove the TODO comments

### Step 9: Update PaywallView

File: `{AppName}/Features/Paywall/PaywallView.swift`

- Replace "Forge Pro" with "{AppName} Pro" in the hero card title
- Update description text for the app's domain
- Replace feature bullets with domain-relevant premium features
- Update the DSScreen title

### Step 10: Update Constants

File: `{AppName}/Utilities/Constants.swift`

- Update URL placeholders (leave as placeholder URLs but make them descriptive)

### Step 11: Rewrite AGENTS.md

Follow the AGENTS.md Rewrite Strategy below.

---

## Phase 4 — Verify

After execution:

### 1. Build Check
Run the Mock scheme build:
```bash
xcodebuild -project {AppName}.xcodeproj -scheme "{AppName} - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build 2>&1 | tail -20
```

If the build fails, fix compile errors and rebuild.

### 2. Manual Steps Checklist
List remaining manual steps the user needs to do:

- [ ] Add your app icon to `Assets.xcassets`
- [ ] Set up Firebase project and add `GoogleService-Info-Dev.plist` / `GoogleService-Info-Prod.plist` (if Firebase enabled)
- [ ] Set up RevenueCat and update API key in `Secrets.xcconfig.local` (if purchases enabled)
- [ ] Set up Mixpanel and update token in `Secrets.xcconfig.local` (if analytics enabled)
- [ ] Create products in App Store Connect matching the product IDs in `EntitlementOption`
- [ ] Update privacy policy and terms of service URLs in `Constants.swift`
- [ ] Configure push notification certificates in Firebase Console (if push enabled)
- [ ] Review and customize onboarding goal options for your specific use case
- [ ] Replace demo dashboard data with real data sources

---

## AGENTS.md Rewrite Strategy

AGENTS.md is agent-only (158 lines). Human docs live in README.md.
It contains: Build, Architecture, View Rules, File Locations, Navigation, Data Models,
DS Component Reference, and Design System Override Priority.

### Update
- **Build section**: Change scheme from `"Forge - Mock"` to `"{AppName} - Mock"`, update xcodeproj name
- **File Locations**: Replace `{App}/` paths with `{AppName}/`
- **Architecture section**: Update if app has specific concurrency requirements

### Add
- **Project Context** at the top (after the first line):
  ```
  ## Project Context
  - **App**: {AppName} — {description}
  - **Domain**: {domain}
  - **Target**: {target user}
  - **Monetization**: {model}
  - **Features enabled**: {list}
  ```

### Keep As-Is
- **View Rules** — these are universal
- **DS Component Reference** — template defaults. The "Design System Override Priority"
  section already tells agents that `.forge/design-system.md` overrides these defaults.
- **Navigation** — patterns are the same
- **Data Models** — conventions are the same

### Do NOT Add
- Human onboarding content (belongs in README.md)
- Setup instructions (setup is done)
- "How to customize" guides (agents read .forge/design-system.md for design decisions)
- Skill installation instructions (not relevant during building)

---

## Files Modified

| File | Change |
|------|--------|
| `rename_project.sh` (executed) | Renames project, bundle IDs, imports |
| `{App}/App/AppDelegate.swift` | Brand color in `DesignSystem.configure()` |
| `{App}/Utilities/FeatureFlags.swift` | Feature toggles |
| `{App}/Features/Onboarding/OnboardingStep.swift` | Step definitions for app domain |
| `{App}/Features/Onboarding/OnboardingController.swift` | Steps array |
| `{App}/Features/Home/HomeView.swift` | Dashboard content |
| `{App}/Features/Home/HomeViewModel.swift` | Data model and analytics |
| `{App}/Managers/Purchases/EntitlementOption.swift` | Product IDs |
| `{App}/Features/Paywall/PaywallView.swift` | Value props and title |
| `{App}/Utilities/Constants.swift` | URLs, strings |
| `AGENTS.md` | Full rewrite for new app identity |

---

## Error Handling

- **Rename script fails**: Check that `Forge.xcodeproj` exists and the script is executable (`chmod +x rename_project.sh`)
- **Build fails after rename**: The rename script may miss some references. Search for remaining "Forge" strings: `grep -r "Forge" {AppName}/ --include="*.swift" -l`
- **Brand color not recognized**: Check `AdaptiveTheme` initializer accepts the color name. Fall back to `.plum` if unsure.
- **Feature flag dependencies**: If user disables Firebase Analytics but enables Crashlytics/Push/AB Testing, warn them about the dependency and disable the dependent flags.
