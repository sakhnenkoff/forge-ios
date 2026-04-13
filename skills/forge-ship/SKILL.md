---
name: forge-ship
description: >
  Prepare a Forge app for App Store submission. Runs pre-flight audit across
  seven categories (privacy, accessibility, security, testing, metadata, build
  config, legal), invokes Axiom audit agents for deep scanning when available,
  auto-fixes what it can, and produces a final submission checklist with manual
  steps remaining. Prevents common App Store rejections for privacy manifest,
  accessibility, metadata, and security issues.
license: MIT
---

# Forge Ship

This skill prepares a Forge app for App Store submission. It runs a comprehensive pre-flight audit, invokes Axiom deep-scan agents when installed, auto-fixes everything it safely can, and produces a categorized submission checklist with the remaining manual steps.

The goal: reduce App Store rejections to zero by catching every known rejection reason before you submit.

**Part of the Forge ecosystem:**

```
forge-workspace -> forge-app -> forge-wire -> forge-ship
   (setup)          (build)      (connect)     (submit)
```

Each skill is independent and invocable separately. They chain naturally: forge-workspace sets up the project, forge-app builds screens, forge-wire connects backends, and forge-ship prepares for submission. But any skill can be used alone — a developer who already has a running app can jump straight to forge-ship.

**Axiom integration:** When Axiom audit agents are installed, forge-ship invokes them for deep scanning across accessibility, security, memory, concurrency, energy, and testing. When Axiom is not available, forge-ship runs lightweight inline checks for each category. No capability is lost — only scan depth.

---

## 1. Prerequisites Check

Before starting, verify the project is a valid Forge workspace ready for submission analysis.

```
[ ] *.xcodeproj exists in working directory
[ ] AGENTS.md exists in working directory
[ ] App name, bundle ID, and version detected
[ ] Build configurations detected (Mock, Dev, Production)
```

Run these checks:

1. `ls *.xcodeproj` — must find exactly one. Extract the app name from the filename (e.g., `MyApp.xcodeproj` means the app name is `MyApp`).
2. `ls AGENTS.md` — must exist. Read it to understand the project's architecture, DS components, and conventions.
3. Detect app identity:
   - **App name:** Extract from the xcodeproj filename.
   - **Bundle ID:** Read from build settings or Info.plist. Run:
     ```bash
     xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | head -1
     ```
   - **Current version:** Read from build settings:
     ```bash
     xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep MARKETING_VERSION | head -1
     ```
   - **Build number:** Read from build settings:
     ```bash
     xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep CURRENT_PROJECT_VERSION | head -1
     ```
4. Detect build configurations:
   - Check for schemes: `xcodebuild -project *.xcodeproj -list 2>/dev/null`
   - Look for Mock, Dev/Development, Production/Release scheme names.
   - Check if a Production or Release scheme exists — this is required for App Store submission.
5. Read AGENTS.md to extract the app pitch (used later for suggested App Store metadata).

If the xcodeproj or AGENTS.md is missing, stop and tell the user what is wrong. If no Production scheme exists, flag it as a P0 issue but continue the audit.

Report the detected state:

> "Found {AppName} ({bundleID}) version {version} build {buildNumber}.
> Schemes: {list of schemes}.
> Starting pre-flight audit."

---

## 2. Phase 1: Pre-Flight Audit

Scan the project for submission readiness across seven categories. For each individual check, report one of three statuses:

- **Pass** — meets App Store requirements
- **Warning** — may cause issues or is a best practice violation
- **Fail** — will cause App Store rejection or critical issue

Run all seven categories sequentially. Collect every finding into a structured audit report.

### Category 1: Privacy Compliance

Privacy is the number one rejection reason. Apple requires a privacy manifest (PrivacyInfo.xcprivacy) for all apps and any SDK that uses Required Reason APIs.

**Check 1.1 — PrivacyInfo.xcprivacy exists:**

Search for the privacy manifest:

```bash
find . -name "PrivacyInfo.xcprivacy" -not -path "*/.*" -not -path "*/DerivedData/*"
```

- **Pass:** File exists in the app target directory.
- **Fail (P0):** File does not exist. Will be auto-fixed in Phase 3.

**Check 1.2 — Required Reason API usage:**

Scan all Swift files for APIs that require privacy declarations. Search for each of these patterns:

| API Category | Search patterns | Privacy type |
|-------------|----------------|--------------|
| File timestamp APIs | `fileModificationDate`, `creationDate`, `contentModificationDateKey`, `NSFileModificationDate` | `NSPrivacyAccessedAPICategoryFileTimestamp` |
| System boot time | `systemUptime`, `ProcessInfo`, `mach_absolute_time` | `NSPrivacyAccessedAPICategorySystemBootTime` |
| Disk space APIs | `volumeAvailableCapacityKey`, `volumeTotalCapacityKey`, `systemFreeSize`, `systemSize`, `statfs` | `NSPrivacyAccessedAPICategoryDiskSpace` |
| User defaults | `UserDefaults`, `NSUserDefaults`, `@AppStorage` | `NSPrivacyAccessedAPICategoryUserDefaults` |
| Active keyboards | `activeInputModes` | `NSPrivacyAccessedAPICategoryActiveKeyboards` |

For each API found, grep the source files:

```bash
grep -rl "UserDefaults\|NSUserDefaults\|@AppStorage" --include="*.swift" . | grep -v DerivedData | grep -v ".build"
```

Repeat for each API category.

- **Pass:** All detected Required Reason APIs are declared in PrivacyInfo.xcprivacy with valid reasons.
- **Fail (P0):** APIs found but not declared in privacy manifest. Will be auto-fixed.
- **Pass (trivially):** No Required Reason APIs detected.

**Check 1.3 — Tracking declaration:**

Read PrivacyInfo.xcprivacy (if it exists) and check:
- `NSPrivacyTracking` — is it set to `true` or `false`?
- If `true`, check that the app uses AppTrackingTransparency framework (`ATTrackingManager`).

Search for tracking-related imports:

```bash
grep -rl "ATTrackingManager\|AppTrackingTransparency\|AdSupport\|ASIdentifierManager" --include="*.swift" .
```

- **Pass:** No tracking, `NSPrivacyTracking` is `false` or absent.
- **Warning:** Tracking frameworks imported but `NSPrivacyTracking` not set to `true`.
- **Fail (P0):** `NSPrivacyTracking` is `true` but no ATT prompt implementation found.

**Check 1.4 — Collected data types:**

Check `NSPrivacyCollectedDataTypes` in PrivacyInfo.xcprivacy. If the app collects any user data (analytics, auth, purchases), the privacy manifest must declare what is collected.

- **Warning:** App uses analytics or auth but `NSPrivacyCollectedDataTypes` is empty or missing.
- **Pass:** Collected data types are declared and match detected usage.

### Category 2: Accessibility

Apple increasingly reviews accessibility. Poor accessibility causes rejections and limits your audience.

**Check 2.1 — VoiceOver labels on interactive elements:**

Scan all SwiftUI view files for interactive elements without accessibility labels:

```bash
grep -n "DSButton\|DSIconButton\|Button\|NavigationLink\|Toggle\|Slider\|Stepper" --include="*.swift" -r .
```

Then check if those files also contain `.accessibilityLabel`:

```bash
grep -c "accessibilityLabel\|accessibilityValue\|accessibilityHint" --include="*.swift" -r . | grep ":0$"
```

Files with interactive elements but zero accessibility modifiers are flagged.

- **Pass:** All view files with interactive elements have accessibility labels.
- **Warning (P1):** View files with interactive elements but no accessibility labels found.

**Check 2.2 — Hardcoded font sizes (Dynamic Type):**

Search for hardcoded font sizes that bypass Dynamic Type:

```bash
grep -rn "\.font(.system(size:" --include="*.swift" .
grep -rn "UIFont(name:.*size:" --include="*.swift" .
grep -rn "\.font(.custom(" --include="*.swift" .
```

- **Pass:** No hardcoded font sizes, or all fonts use DS typography tokens (`.bodyMedium()`, `.titleLarge()`, etc.).
- **Warning (P2):** Hardcoded font sizes found — should use DS typography for Dynamic Type support.

**Check 2.3 — Touch target sizes:**

Search for frames smaller than 44x44pt on interactive elements:

```bash
grep -rn "\.frame(width:\s*[0-3][0-9]\b\|\.frame(height:\s*[0-3][0-9]\b" --include="*.swift" .
```

Also check for icon buttons without adequate padding.

- **Pass:** All interactive elements meet minimum 44x44pt.
- **Warning (P2):** Elements found with frames smaller than 44pt.

**Check 2.4 — Accessibility identifiers for UI testing:**

Check if view files include `.accessibilityIdentifier()` for testability:

```bash
grep -c "accessibilityIdentifier" --include="*.swift" -r . | grep -v ":0$" | wc -l
```

- **Pass:** Accessibility identifiers found across view files.
- **Warning (P2):** Few or no accessibility identifiers — limits UI test capabilities.

### Category 3: Security

Security issues cause rejections and put users at risk.

**Check 3.1 — Hardcoded secrets in source:**

Search for patterns that indicate hardcoded API keys, secrets, or passwords:

```bash
grep -rn "apiKey\s*=\s*\"[A-Za-z0-9]" --include="*.swift" .
grep -rn "secret\s*=\s*\"[A-Za-z0-9]" --include="*.swift" .
grep -rn "password\s*=\s*\"[A-Za-z0-9]" --include="*.swift" .
grep -rn "token\s*=\s*\"[A-Za-z0-9]" --include="*.swift" .
grep -rn "AIza[A-Za-z0-9_-]{35}" --include="*.swift" .  # Google API keys
grep -rn "sk-[A-Za-z0-9]{20,}" --include="*.swift" .  # OpenAI keys
grep -rn "ghp_[A-Za-z0-9]{36}" --include="*.swift" .  # GitHub tokens
```

Exclude test files, mock data, and example comments from results.

- **Pass:** No hardcoded secrets found in source code.
- **Fail (P0):** Hardcoded secrets detected. List each occurrence with file and line number.

**Check 3.2 — Secrets config in .gitignore:**

Check that sensitive config files are gitignored:

```bash
grep -q "Secrets.xcconfig.local" .gitignore && echo "FOUND" || echo "MISSING"
grep -q "GoogleService-Info.plist" .gitignore && echo "FOUND" || echo "MISSING"
```

- **Pass:** Sensitive config files are in .gitignore.
- **Warning (P1):** Sensitive config files not gitignored — risk of credential exposure.

**Check 3.3 — Keychain usage for sensitive tokens:**

Search for tokens or sensitive data stored in UserDefaults or @AppStorage instead of Keychain:

```bash
grep -rn "UserDefaults.*token\|UserDefaults.*auth\|UserDefaults.*session\|@AppStorage.*token\|@AppStorage.*auth" --include="*.swift" .
```

Also check for Keychain usage:

```bash
grep -rl "SecItem\|KeychainManager\|keychain" --include="*.swift" .
```

- **Pass:** Sensitive tokens use Keychain, not UserDefaults.
- **Warning (P1):** Tokens appear to be stored in UserDefaults — should use Keychain.

**Check 3.4 — App Transport Security:**

Check Info.plist for ATS exceptions:

```bash
grep -A 5 "NSAppTransportSecurity" */Info.plist 2>/dev/null
```

- **Pass:** No ATS exceptions, or only specific domain exceptions with justification.
- **Warning (P1):** `NSAllowsArbitraryLoads` is `true` — Apple may reject without justification.
- **Pass (trivially):** No NSAppTransportSecurity key — ATS is enforced by default.

### Category 4: Testing

Adequate test coverage reduces crashes and improves review outcomes.

**Check 4.1 — Unit test count:**

Count existing test files and test methods:

```bash
find . -name "*Tests.swift" -not -path "*/DerivedData/*" | wc -l
grep -r "@Test\|func test" --include="*.swift" . | grep -v DerivedData | wc -l
```

- **Pass:** 10+ test methods found.
- **Warning (P2):** Fewer than 10 test methods — consider adding tests for critical paths.
- **Fail (P1):** Zero test methods found.

**Check 4.2 — Untested ViewModels and Managers:**

List all ViewModels and Managers, then check which have corresponding test files:

```bash
find . -name "*ViewModel.swift" -not -path "*/DerivedData/*" | sed 's/.*\///' | sed 's/.swift//'
find . -name "*Manager.swift" -not -path "*/DerivedData/*" | sed 's/.*\///' | sed 's/.swift//'
```

Compare against test files:

```bash
find . -name "*Tests.swift" -not -path "*/DerivedData/*" | sed 's/.*\///' | sed 's/Tests.swift//'
```

- **Pass:** All ViewModels and Managers have corresponding test files.
- **Warning (P2):** Some ViewModels/Managers lack test files. List which ones are untested. Can be partially auto-fixed (scaffold test files).

**Check 4.3 — Tests pass:**

Run the test suite:

```bash
xcodebuild -project *.xcodeproj -scheme "{AppName} - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' test 2>&1 | tail -30
```

- **Pass:** All tests pass.
- **Fail (P1):** Tests fail. List failing test names and errors.
- **Warning:** Test target does not exist or cannot be built.

### Category 5: App Store Metadata

Missing or default metadata causes rejection.

**Check 5.1 — Display name:**

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep "PRODUCT_NAME\|INFOPLIST_KEY_CFBundleDisplayName"
```

- **Pass:** Display name is set and not "Forge" (template default).
- **Fail (P0):** Display name is still "Forge" or empty.

**Check 5.2 — Bundle ID:**

Read from build settings (already detected in prerequisites).

- **Pass:** Bundle ID is set and not a placeholder (`com.forge.app`, `com.example.app`).
- **Fail (P0):** Bundle ID is a placeholder.

**Check 5.3 — Version and build number:**

Already detected in prerequisites.

- **Pass:** Version is set (not "1.0" or "0.0.1" — these are okay for first submission).
- **Warning (P2):** Version is still at default "1.0". Consider whether this is intentional.

**Check 5.4 — App icon:**

Search for the app icon asset:

```bash
find . -name "AppIcon.appiconset" -not -path "*/DerivedData/*"
```

If found, check if it contains actual image files (not just the Contents.json):

```bash
ls {path_to_AppIcon.appiconset}/ | grep -v Contents.json
```

- **Pass:** AppIcon asset exists and contains image files.
- **Fail (P0):** AppIcon asset is missing or empty. Requires manual action (design).

**Check 5.5 — Launch screen:**

Check for a launch screen configuration:

```bash
grep -r "UILaunchScreen\|UILaunchStoryboardName\|launch_screen" --include="*.plist" .
grep -r "LaunchScreen" --include="*.storyboard" .
```

- **Pass:** Launch screen is configured.
- **Warning (P1):** No launch screen configured — Apple requires one.

### Category 6: Build Configuration

The app must build and archive successfully for submission.

**Check 6.1 — Production/Release scheme exists:**

Already detected in prerequisites. Check for a scheme name containing "Production", "Release", or the app name without "Mock" or "Dev".

- **Pass:** Production or Release scheme exists.
- **Fail (P0):** No production scheme. Provide guidance on creating one.

**Check 6.2 — Production build succeeds:**

If a Production/Release scheme exists, attempt a build:

```bash
xcodebuild -project *.xcodeproj -scheme "{ProductionScheme}" -destination 'generic/platform=iOS' build 2>&1 | tail -30
```

- **Pass:** Production build succeeds with zero errors and zero warnings from app code.
- **Fail (P0):** Build fails. List errors.
- **Warning (P1):** Build succeeds but has warnings from app code.

**Check 6.3 — Code signing:**

Check code signing configuration:

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep "CODE_SIGN_IDENTITY\|DEVELOPMENT_TEAM\|CODE_SIGN_STYLE\|PROVISIONING_PROFILE"
```

- **Pass:** Code signing identity and development team are set. Automatic signing is enabled or valid profiles are configured.
- **Fail (P0):** No development team set — cannot archive without it.
- **Warning (P1):** Manual signing selected but no provisioning profile specified.

### Category 7: Legal and Compliance

**Check 7.1 — Encryption usage (export compliance):**

Search for encryption-related imports and usage:

```bash
grep -rl "CryptoKit\|CommonCrypto\|Security.framework\|SecKey\|AES\|RSA\|CryptoSwift" --include="*.swift" .
```

Also check Info.plist for the export compliance key:

```bash
grep "ITSAppUsesNonExemptEncryption" */Info.plist 2>/dev/null
```

- **Pass:** No custom encryption, or `ITSAppUsesNonExemptEncryption` is set to `false`.
- **Warning (P1):** Encryption APIs used but `ITSAppUsesNonExemptEncryption` not set. Apple will ask during submission — set it now to streamline.
- **Pass (with note):** HTTPS-only usage (standard) does not require export compliance declaration.

**Check 7.2 — Third-party SDK licenses:**

Check for SPM dependencies and their license compliance:

```bash
find . -name "Package.resolved" -not -path "*/DerivedData/*" | head -1
```

Read Package.resolved to list all third-party dependencies.

- **Pass:** All dependencies are well-known open-source packages with compatible licenses.
- **Warning (P2):** Some dependencies detected — verify their licenses allow App Store distribution.

**Check 7.3 — In-app purchase configuration:**

Check if the app uses StoreKit or RevenueCat:

```bash
grep -rl "StoreKit\|RevenueCat\|Product\|EntitlementOption\|PurchaseManager" --include="*.swift" .
```

If purchase-related code is found:
- Check for a StoreKit configuration file: `find . -name "*.storekit" -not -path "*/DerivedData/*"`
- Check that product IDs are not placeholders

- **Pass:** Purchase code found with valid StoreKit configuration or configured RevenueCat.
- **Warning (P1):** Purchase code found but StoreKit configuration may have placeholder product IDs.
- **Pass (trivially):** No purchase code found — skip this check.

### Audit Summary

After all seven categories are checked, present a summary table:

```
## Pre-Flight Audit Summary

| # | Category | Pass | Warn | Fail | Status |
|---|----------|------|------|------|--------|
| 1 | Privacy Compliance | {n} | {n} | {n} | {best/worst status} |
| 2 | Accessibility | {n} | {n} | {n} | {status} |
| 3 | Security | {n} | {n} | {n} | {status} |
| 4 | Testing | {n} | {n} | {n} | {status} |
| 5 | App Store Metadata | {n} | {n} | {n} | {status} |
| 6 | Build Configuration | {n} | {n} | {n} | {status} |
| 7 | Legal/Compliance | {n} | {n} | {n} | {status} |

Total: {passes} passed, {warnings} warnings, {failures} failures
```

Proceed to Phase 2 regardless of results — Axiom agents may find additional issues.

---

## 3. Phase 2: Axiom Deep Scan

Axiom is a suite of specialized audit agents that perform deep analysis beyond what grep-based checks can catch. Each Axiom agent focuses on a specific quality dimension and runs sophisticated analysis — AST inspection, control flow analysis, memory graph traversal, and more.

**Check which Axiom agents are available** by scanning the current session's skill list for these skill names:

| Agent | Skill name | Focus |
|-------|-----------|-------|
| Accessibility Auditor | `axiom:accessibility-auditor` | WCAG compliance, Dynamic Type, VoiceOver, color contrast, motion sensitivity |
| Security & Privacy Scanner | `axiom:security-privacy-scanner` | Secrets detection, data flow, ATS, certificate pinning, Keychain usage |
| Memory Auditor | `axiom:memory-auditor` | Retain cycles, closure captures, delegate patterns, memory leaks |
| Concurrency Auditor | `axiom:concurrency-auditor` | Swift 6 compliance, data races, actor isolation, Sendable conformance |
| Energy Auditor | `axiom:energy-auditor` | Battery drain patterns, background task efficiency, network usage, timer abuse |
| Testing Auditor | `axiom:testing-auditor` | Test quality, coverage gaps, flaky test detection, assertion quality |

Log detection results:

> "Axiom agents detected: [list]. Not available: [list] (using inline fallback checks)."

### Invoking Available Agents

For each available Axiom agent, invoke it with the project context:

**Accessibility Auditor:**

> "Run a full accessibility audit on {AppName}. Project root: {cwd}. Check WCAG 2.1 AA compliance, Dynamic Type support, VoiceOver labels and hints, color contrast ratios, motion sensitivity, and touch target sizes across all view files."

**Security & Privacy Scanner:**

> "Run a deep security and privacy scan on {AppName}. Project root: {cwd}. Check for hardcoded secrets, insecure data storage, ATS configuration, certificate pinning, privacy manifest completeness, and data flow analysis for PII."

**Memory Auditor:**

> "Run a memory audit on {AppName}. Project root: {cwd}. Check for retain cycles in closures, delegate patterns without weak references, NotificationCenter observer leaks, Timer retain cycles, and ViewModel-View strong reference cycles."

**Concurrency Auditor:**

> "Run a concurrency audit on {AppName}. Project root: {cwd}. Check Swift 6 strict concurrency compliance, data race potential, actor isolation correctness, Sendable conformance, and @MainActor annotation completeness."

**Energy Auditor:**

> "Run an energy audit on {AppName}. Project root: {cwd}. Check for battery drain patterns: excessive timers, unnecessary background tasks, unthrottled network polling, inefficient animations, location tracking precision, and Bluetooth/sensor usage."

**Testing Auditor:**

> "Run a test quality audit on {AppName}. Project root: {cwd}. Analyze test coverage gaps, assertion quality, test isolation, mock usage patterns, flaky test indicators, and test naming conventions."

Wait for each agent to return findings before proceeding to the next.

### Fallback Inline Checks

For each Axiom agent that is NOT available, run these lightweight inline alternatives:

**Accessibility fallback (if `axiom:accessibility-auditor` not available):**

Already covered by Category 2 in Phase 1. Note:

> "Install Axiom for deeper accessibility scanning including WCAG contrast ratios, VoiceOver flow analysis, and motion sensitivity checks."

**Security fallback (if `axiom:security-privacy-scanner` not available):**

Already covered by Category 3 in Phase 1. Note:

> "Install Axiom for deeper security scanning including data flow analysis, certificate pinning checks, and PII tracking."

**Memory fallback (if `axiom:memory-auditor` not available):**

Run basic retain cycle checks:

```bash
grep -rn "\[self\]" --include="*.swift" . | grep -v "weak self\|unowned self"
grep -rn "\.sink\|\.store" --include="*.swift" . | head -20
grep -rn "delegate\s*:" --include="*.swift" . | grep -v "weak"
grep -rn "Timer.scheduledTimer\|Timer.publish" --include="*.swift" .
```

- Closures capturing `self` without `[weak self]` are potential retain cycles.
- Combine `.sink` without proper cancellable management can leak.
- Delegates without `weak` create retain cycles.
- Timers without invalidation in deinit create retain cycles.

> "Install Axiom for deeper memory scanning including AST-based retain cycle detection, memory graph analysis, and closure capture inspection."

**Concurrency fallback (if `axiom:concurrency-auditor` not available):**

Run basic concurrency checks:

```bash
grep -rn "@unchecked Sendable\|nonisolated(unsafe)" --include="*.swift" .
grep -rn "DispatchQueue.main.async" --include="*.swift" . | head -10
grep -rn "Task \{" --include="*.swift" . | head -10
```

- `@unchecked Sendable` and `nonisolated(unsafe)` are concurrency escape hatches — flag for review.
- `DispatchQueue.main.async` in a `@MainActor` context is redundant.
- Unstructured `Task {}` without proper cancellation can cause issues.

> "Install Axiom for deeper concurrency scanning including data race detection, actor isolation analysis, and Swift 6 migration guidance."

**Energy fallback (if `axiom:energy-auditor` not available):**

Run basic energy checks:

```bash
grep -rn "Timer.scheduledTimer\|Timer.publish" --include="*.swift" .
grep -rn "CLLocationManager\|startUpdatingLocation" --include="*.swift" .
grep -rn "UIApplication.shared.beginBackgroundTask" --include="*.swift" .
grep -rn "withAnimation.*repeatForever\|animation.*repeatForever" --include="*.swift" .
```

- Repeating timers with intervals under 1 second drain battery.
- Continuous location updates (`startUpdatingLocation`) vs. significant location changes.
- Background tasks that run longer than needed.
- Infinite repeat animations drain GPU.

> "Install Axiom for deeper energy scanning including Instruments-level analysis, network efficiency, and background activity profiling."

**Testing fallback (if `axiom:testing-auditor` not available):**

Already covered by Category 4 in Phase 1. Note:

> "Install Axiom for deeper test quality analysis including coverage gap identification, assertion quality scoring, and flaky test detection."

### Aggregating Axiom Findings

After all available agents (and fallback checks) have run, aggregate findings:

1. **Deduplicate:** If an Axiom agent found the same issue as Phase 1 (e.g., both found hardcoded secrets), keep the Axiom finding (more detailed) and remove the Phase 1 duplicate.
2. **Categorize by severity:**
   - **P0 (will cause rejection):** Privacy manifest missing, hardcoded secrets, broken build, missing app icon
   - **P1 (may cause rejection):** Accessibility gaps, security warnings, test failures, missing launch screen
   - **P2 (best practice):** Test coverage, energy efficiency, code quality, Dynamic Type
3. **Categorize by fixability:**
   - **Auto-fixable:** Can be resolved by forge-ship in Phase 3
   - **Manual required:** Needs developer action (design, certificates, console setup)
4. **Merge into unified report** with Phase 1 findings for the final audit view.

Present the aggregated Axiom scan summary:

```
## Axiom Deep Scan Results

| Agent | Status | Findings |
|-------|--------|----------|
| Accessibility | {invoked/fallback/skipped} | {n} issues ({p0} P0, {p1} P1, {p2} P2) |
| Security | {status} | {n} issues |
| Memory | {status} | {n} issues |
| Concurrency | {status} | {n} issues |
| Energy | {status} | {n} issues |
| Testing | {status} | {n} issues |

New issues found by Axiom: {n} (beyond Phase 1 pre-flight)
```

---

## 4. Phase 3: Auto-Fix

Fix what can be fixed automatically. For each auto-fix, apply the change, verify it compiles, and commit.

**Critical rule:** Only auto-fix items that are safe to fix automatically. When in doubt, add to the manual checklist instead.

### Auto-Fixable Items

**Fix 1 — Generate PrivacyInfo.xcprivacy:**

If the privacy manifest is missing, generate one based on the detected Required Reason API usage from Check 1.2.

Create the file at `{AppName}/PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <!-- Add entries for each detected Required Reason API -->
    </array>
</dict>
</plist>
```

For each detected Required Reason API category, add an entry:

```xml
<dict>
    <key>NSPrivacyAccessedAPIType</key>
    <string>{API category identifier}</string>
    <key>NSPrivacyAccessedAPITypeReasons</key>
    <array>
        <string>{reason code}</string>
    </array>
</dict>
```

Common reason codes:
- **UserDefaults:** `CA92.1` (app-specific data) — most common for Forge apps
- **File timestamp:** `DDA9.1` (display to user) or `C617.1` (internal logic)
- **Disk space:** `E174.1` (prevent full disk writes)
- **System boot time:** `35F9.1` (elapsed time measurement)

**Auto-detect tracking domains and collected data:**

Scan for analytics/tracking SDKs and populate the manifest:

```bash
# Detect analytics SDKs
grep -rl "FirebaseAnalytics\|MixpanelService\|Mixpanel\|Amplitude" --include="*.swift" . | head -5
# Detect auth SDKs (user data collection)
grep -rl "FirebaseAuth\|GoogleSignIn\|ASAuthorizationApple" --include="*.swift" . | head -5
# Detect payment SDKs
grep -rl "RevenueCat\|Purchases\|StoreKit" --include="*.swift" . | head -5
```

Based on detected SDKs, auto-populate `NSPrivacyCollectedDataTypes`:
- **Analytics detected** → add `NSPrivacyCollectedDataTypeIdentifiers` (device ID), `NSPrivacyCollectedDataTypeCrashData`
- **Auth detected** → add `NSPrivacyCollectedDataTypeEmailAddress`, `NSPrivacyCollectedDataTypeUserID`
- **Purchases detected** → add `NSPrivacyCollectedDataTypePurchaseHistory`

Set `NSPrivacyCollectedDataTypePurposes` to `Analytics` or `AppFunctionality` as appropriate.
Mark `NSPrivacyCollectedDataTypeLinked` as `true` for auth data, `false` for analytics.

After generating, verify the file is valid XML:

```bash
plutil -lint {AppName}/PrivacyInfo.xcprivacy
```

Build to verify:

```bash
xcodebuild -project *.xcodeproj -scheme "{AppName} - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build 2>&1 | tail -20
```

Commit:

```bash
git add {AppName}/PrivacyInfo.xcprivacy
git commit -m "feat: add PrivacyInfo.xcprivacy with required reason API declarations"
```

**Fix 2 — Add missing accessibility labels to DS components:**

For each DS component usage found without an accessibility label in Check 2.1, add `.accessibilityLabel()` with a descriptive label.

Scan each flagged file. For `DSButton` and `DSIconButton` instances, add labels based on the button's title or icon:

```swift
// Before:
DSIconButton(icon: "plus", style: .primary) { viewModel.addItem() }

// After:
DSIconButton(icon: "plus", style: .primary) { viewModel.addItem() }
    .accessibilityLabel("Add item")
```

For buttons with text titles, the label is often redundant (SwiftUI infers it), but add `.accessibilityHint()` for context:

```swift
DSButton("Save", style: .primary) { viewModel.save() }
    .accessibilityHint("Saves your changes")
```

Build after each file modification to ensure no syntax errors.

Commit all accessibility fixes together:

```bash
git add -A
git commit -m "fix: add missing accessibility labels to interactive elements"
```

**Fix 3 — Scaffold unit test files:**

For each untested ViewModel and Manager found in Check 4.2, create a test file scaffold using Swift Testing framework.

Create files at `{AppName}Tests/{ClassName}Tests.swift`:

```swift
import Testing
@testable import {AppName}

@MainActor
struct {ClassName}Tests {

    @Test
    func initialization() async throws {
        let sut = {ClassName}()
        // TODO: Add initialization assertions
    }

    // TODO: Add tests for each public method
}
```

For ViewModels, scaffold tests for observable state:

```swift
import Testing
@testable import {AppName}

@MainActor
struct {ViewModel}Tests {

    @Test
    func initialState() async throws {
        let sut = {ViewModel}()
        // TODO: Verify initial state values
    }

    @Test
    func onAppear() async throws {
        let sut = {ViewModel}()
        // TODO: Test onAppear behavior
    }
}
```

Build the test target to verify scaffolds compile:

```bash
xcodebuild -project *.xcodeproj -scheme "{AppName} - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build-for-testing 2>&1 | tail -20
```

Commit:

```bash
git add {AppName}Tests/
git commit -m "test: scaffold unit test files for untested ViewModels and Managers"
```

**Fix 4 — Set version and build number if still at defaults:**

If version is empty or unset, set it to "1.0.0". If build number is empty or unset, set it to "1".

This is done via build settings — modify the project.pbxproj or use xcconfig:

```bash
# Check current values first (already detected in prerequisites)
# Only modify if truly empty or unset
```

If modification is needed, update the build settings file directly.

Commit:

```bash
git add *.xcodeproj
git commit -m "chore: set version to 1.0.0 and build number to 1"
```

**Fix 5 — Add NSAppTransportSecurity if needed:**

If Check 3.4 found `NSAllowsArbitraryLoads = true` without justification, or if the app makes HTTP (not HTTPS) requests without an ATS exception, fix it.

For most Forge apps, ATS should be enforced (HTTPS only). If arbitrary loads were enabled for development convenience, remove the exception for production:

This is a configuration change in Info.plist. Only auto-fix if the setting is clearly a development leftover. If the app legitimately needs HTTP access (e.g., local network, specific domain), add it to the manual checklist instead.

Commit if fixed:

```bash
git add */Info.plist
git commit -m "fix: enforce App Transport Security for production"
```

**Fix 6 — Apply concurrency fixes from Axiom:**

If the Axiom Concurrency Auditor found auto-fixable Swift 6 concurrency warnings (missing `@Sendable`, incorrect actor isolation, etc.), apply the suggested fixes.

Review each fix before applying — some concurrency changes can alter behavior. Only apply fixes that are clearly correct:

- Adding `@Sendable` to closure types in protocols
- Adding `@MainActor` to types that access UI from the main thread
- Replacing `DispatchQueue.main.async` with `MainActor.run` in async contexts
- Adding `nonisolated` to properties that are safe to access from any isolation

Do NOT auto-fix:
- Adding `@unchecked Sendable` (escape hatch)
- Changing actor isolation of existing types (may break callers)
- Removing `@MainActor` annotations (may introduce races)

Build after each fix. Commit:

```bash
git add -A
git commit -m "fix: resolve Swift 6 concurrency warnings"
```

### Items Requiring Manual Action

For each issue that cannot be auto-fixed, add clear guidance to the submission checklist (Phase 4). These include:

| Item | Why Manual | Guidance |
|------|----------|----------|
| **App icon design** | Requires visual design work | Need 1024x1024 icon. Use Xcode Asset Catalog or tools like Figma/Sketch. Apple guidelines: simple, recognizable, no text, no screenshots. |
| **Code signing certificates** | Requires Apple Developer account | Enroll at developer.apple.com ($99/year). Create certificates in Xcode: Preferences > Accounts > Manage Certificates. Enable Automatic Signing. |
| **Provisioning profiles** | Requires Apple Developer account | Automatic signing handles this. If manual: create profiles in developer.apple.com/account/resources/profiles. |
| **App Store Connect setup** | Requires web portal access | Create app record at appstoreconnect.apple.com. Enter name, bundle ID, SKU, primary language. |
| **Screenshots** | Requires running app on simulator | Capture screenshots on 6.7" and 5.5" simulators. Use Xcode Simulator > File > Screenshot or `xcrun simctl io screenshot`. |
| **App description and keywords** | Requires copywriting | Write 4000-char description. Choose keywords (100 chars max). Set subtitle (30 chars max). |
| **Age rating** | Requires questionnaire answers | Answer content rating questions in App Store Connect. Most utility apps: 4+. |
| **Export compliance** | Requires legal assessment | If using HTTPS only (standard): answer "No" to encryption questions. If using custom encryption: may need CCATS filing. |
| **Privacy policy URL** | Requires hosting | Required for all apps. Host a privacy policy at a stable URL. |
| **Support URL** | Requires hosting | Required. Can be a simple webpage, GitHub repo, or social media profile. |

---

## 5. Phase 4: Submission Checklist

Present the final comprehensive report with all findings, fixes, and remaining steps.

### Final Report Format

```
## Ship Report: {AppName}

**Version:** {version} ({buildNumber})
**Bundle ID:** {bundleID}
**Date:** {today's date}

---

### Audit Results

| # | Check | Category | Priority | Status | Notes |
|---|-------|----------|----------|--------|-------|
| 1.1 | PrivacyInfo.xcprivacy exists | Privacy | P0 | {status} | {notes} |
| 1.2 | Required Reason APIs declared | Privacy | P0 | {status} | {notes} |
| 1.3 | Tracking declaration | Privacy | P0 | {status} | {notes} |
| 1.4 | Collected data types | Privacy | P1 | {status} | {notes} |
| 2.1 | VoiceOver labels | Accessibility | P1 | {status} | {notes} |
| 2.2 | Dynamic Type | Accessibility | P2 | {status} | {notes} |
| 2.3 | Touch targets 44pt | Accessibility | P2 | {status} | {notes} |
| 2.4 | Accessibility identifiers | Accessibility | P2 | {status} | {notes} |
| 3.1 | No hardcoded secrets | Security | P0 | {status} | {notes} |
| 3.2 | Secrets in .gitignore | Security | P1 | {status} | {notes} |
| 3.3 | Keychain for tokens | Security | P1 | {status} | {notes} |
| 3.4 | App Transport Security | Security | P1 | {status} | {notes} |
| 4.1 | Unit test count | Testing | P2 | {status} | {notes} |
| 4.2 | Untested ViewModels/Managers | Testing | P2 | {status} | {notes} |
| 4.3 | Tests pass | Testing | P1 | {status} | {notes} |
| 5.1 | Display name set | Metadata | P0 | {status} | {notes} |
| 5.2 | Bundle ID configured | Metadata | P0 | {status} | {notes} |
| 5.3 | Version number | Metadata | P2 | {status} | {notes} |
| 5.4 | App icon present | Metadata | P0 | {status} | {notes} |
| 5.5 | Launch screen | Metadata | P1 | {status} | {notes} |
| 6.1 | Production scheme exists | Build | P0 | {status} | {notes} |
| 6.2 | Production build succeeds | Build | P0 | {status} | {notes} |
| 6.3 | Code signing configured | Build | P0 | {status} | {notes} |
| 7.1 | Export compliance | Legal | P1 | {status} | {notes} |
| 7.2 | SDK licenses | Legal | P2 | {status} | {notes} |
| 7.3 | IAP configuration | Legal | P1 | {status} | {notes} |
```

### Auto-Fixed Items

```
### What Was Auto-Fixed

| Fix | What changed | Commit |
|-----|-------------|--------|
| PrivacyInfo.xcprivacy | Generated with {n} required reason API declarations | {hash} |
| Accessibility labels | Added labels to {n} interactive elements in {n} files | {hash} |
| Test scaffolds | Created {n} test files for untested ViewModels/Managers | {hash} |
| Version/build | Set to {version} ({build}) | {hash} |
| ATS enforcement | Removed NSAllowsArbitraryLoads | {hash} |
| Concurrency fixes | Resolved {n} Swift 6 warnings | {hash} |
```

Only list fixes that were actually applied. Skip rows for items that were already passing or were not auto-fixable.

### Manual Steps Remaining

Present a numbered checklist of everything the developer still needs to do manually, ordered by priority:

```
### Manual Steps Required

**P0 — Will cause rejection if not done:**

1. [ ] **App icon:** Add a 1024x1024 app icon to Assets.xcassets/AppIcon.appiconset. Must be PNG, no alpha channel, no rounded corners (iOS applies them automatically).

2. [ ] **Code signing:** Set your development team in Xcode project settings. Go to target > Signing & Capabilities > Team. Enable Automatic Signing.

3. [ ] **App Store Connect:** Create an app record at appstoreconnect.apple.com. Enter: app name, primary language, bundle ID ({bundleID}), SKU.

**P1 — May cause rejection or should be done:**

4. [ ] **Screenshots:** Capture screenshots on these simulator sizes:
   - 6.7" display (iPhone 15 Pro Max): `xcrun simctl io booted screenshot screenshot-6.7.png`
   - 5.5" display (iPhone 8 Plus): Required if you support older devices
   - iPad Pro 12.9" (3rd gen): Required if your app runs on iPad

5. [ ] **App description:** Write your App Store description (up to 4000 characters). Include:
   - What the app does (first 3 lines are visible before "Read More")
   - Key features as bullet points
   - What makes it different

6. [ ] **Keywords:** Choose up to 100 characters of comma-separated keywords. Focus on terms users search for, not your app name.

7. [ ] **Privacy policy:** Host a privacy policy at a public URL. Required for all apps. Include what data you collect, how you use it, and how users can request deletion.

8. [ ] **Support URL:** Provide a support URL (website, email contact page, or social profile).

9. [ ] **Age rating:** Answer the content rating questionnaire in App Store Connect. Common ratings:
   - 4+: No objectionable content
   - 12+: Infrequent mild language, simulated gambling
   - 17+: Frequent intense content

10. [ ] **Export compliance:** When prompted during submission, answer encryption questions:
    - HTTPS only (standard networking): Answer "No" — exempt
    - Custom encryption (CryptoKit, AES, etc.): May need to file CCATS

**P2 — Best practices for a polished submission:**

11. [ ] **What's New text:** Write release notes for version {version}. First release can say "Initial release of {AppName}."

12. [ ] **Promotional text:** Optional 170-character text above description. Can be updated without a new version.

13. [ ] **Subtitle:** Optional 30-character subtitle shown under app name in search results.

14. [ ] **Preview video:** Optional but significantly increases conversion. 15-30 second app preview.
```

### Suggested App Store Metadata

Based on the app pitch from AGENTS.md, suggest metadata:

```
### Suggested Metadata

Based on your app's purpose, here are metadata suggestions you can adapt:

**Suggested category:** {primary category based on app domain}
**Suggested subtitle:** "{30-char subtitle suggestion}"
**Suggested keywords:** "{keyword1}, {keyword2}, {keyword3}, ... (up to 100 chars)"

**Suggested description (first paragraph):**
> "{2-3 sentence description based on the app pitch from AGENTS.md}"
```

### Archive Command

Provide the command to create the final archive:

```
### Ready to Archive

When all manual steps are complete, create the archive:

xcodebuild archive \
  -project {AppName}.xcodeproj \
  -scheme "{ProductionScheme}" \
  -archivePath ./build/{AppName}.xcarchive \
  -destination 'generic/platform=iOS'

Then open the archive in Xcode Organizer to upload:

open ./build/{AppName}.xcarchive

Or export and upload via command line:

xcodebuild -exportArchive \
  -archivePath ./build/{AppName}.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ExportOptions.plist

xcrun altool --upload-app \
  -f ./build/export/{AppName}.ipa \
  -t ios \
  -u "your@apple.id" \
  -p "@keychain:AC_PASSWORD"
```

---

## 6. Token Optimization Notes

<!-- Model hints for token optimization:
- Prerequisites check (Section 1): Can use haiku model (mechanical file detection)
- Phase 1 pre-flight audit (Section 2): Can use sonnet model for grep-based checks (templated patterns). Use current model for analyzing results and determining severity.
- Phase 2 Axiom deep scan (Section 3): Axiom agents run in their own context, so token cost scales with number of agents invoked. The forge-ship orchestrator only needs to send invocation prompts and receive findings — minimal token usage in the main context.
- Phase 3 auto-fix (Section 4): Use current model for code modifications (privacy manifest generation, accessibility labels, test scaffolds need context awareness). Can use sonnet for mechanical fixes (version number, ATS config).
- Phase 4 submission checklist (Section 5): Can use sonnet model (structured report generation from collected data).

Context management:
- Phase 1 audit findings must persist through all phases — they feed into Phase 3 auto-fix and Phase 4 checklist
- Phase 2 Axiom findings are additive — merge into Phase 1 findings
- Phase 3 auto-fix only needs the failing items from Phase 1+2, not the passing ones
- Phase 4 checklist generation needs all findings (pass/warn/fail) plus auto-fix results
- The Axiom agent invocations are independent — they can theoretically run in parallel
- After Phase 4 report is generated, no further context from earlier phases is needed
-->

---

## 7. Skill Boundaries

| Domain | forge-ship Handles | Defers To |
|--------|-------------------|-----------|
| Privacy audit | PrivacyInfo.xcprivacy detection, Required Reason API scanning, tracking declaration checks | `axiom:security-privacy-scanner` for deep data flow analysis when available |
| Privacy auto-fix | Generating PrivacyInfo.xcprivacy with detected required reason APIs | Developer for tracking implementation decisions |
| Accessibility audit | VoiceOver label detection, Dynamic Type check, touch target analysis | `axiom:accessibility-auditor` for WCAG compliance, contrast ratios when available |
| Accessibility auto-fix | Adding `.accessibilityLabel()` to DS components | Developer for VoiceOver flow design, custom accessibility actions |
| Security audit | Hardcoded secrets grep, .gitignore check, Keychain vs UserDefaults analysis, ATS check | `axiom:security-privacy-scanner` for deep security scan when available |
| Security auto-fix | ATS enforcement | Developer for credential management, certificate setup |
| Testing audit | Test count, untested ViewModel/Manager detection, test execution | `axiom:testing-auditor` for test quality analysis when available |
| Testing auto-fix | Scaffolding test files with Swift Testing framework | Developer for writing actual test assertions |
| Metadata audit | Display name, bundle ID, version, app icon, launch screen checks | Developer for app icon design, screenshots, description copywriting |
| Build verification | Production scheme detection, build check, code signing verification | Developer for Apple Developer account, certificates, provisioning |
| Legal compliance | Encryption detection, SDK license listing, IAP configuration check | Developer for export compliance filing, privacy policy hosting |
| Memory audit | Basic retain cycle grep (closures, delegates, timers) | `axiom:memory-auditor` for deep memory graph analysis when available |
| Concurrency audit | Basic Swift 6 escape hatch detection | `axiom:concurrency-auditor` for data race detection when available |
| Concurrency auto-fix | Safe Swift 6 warning fixes from Axiom findings | Developer for architectural concurrency decisions |
| Energy audit | Basic timer and location usage check | `axiom:energy-auditor` for battery profiling when available |
| Submission checklist | Full categorized checklist with priority levels and guidance | Developer for executing manual steps |
| App Store metadata | Suggesting category, keywords, description based on app pitch | Developer for final copywriting and selection |
| Archive creation | Providing archive command | Developer for uploading via Xcode Organizer or altool |
| Screen building | -- | `forge-app` / `forge-feature` for UI and screen creation |
| Backend wiring | -- | `forge-wire` for connecting real services |
| Project setup | -- | `forge-workspace` for initial template configuration |
| Design polish | -- | `forge-craft` for mood-driven UI design |
