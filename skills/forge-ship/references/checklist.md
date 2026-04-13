# Pre-Flight Checklist Reference

Complete reference for every check in the forge-ship pre-flight audit. Each item includes detection method, fix guidance, and priority level.

Priority levels:
- **P0 — Will cause rejection:** Apple will reject the app during review if this is not addressed.
- **P1 — May cause rejection:** Apple may reject depending on reviewer, or this is a significant quality issue.
- **P2 — Best practice:** Will not cause rejection but improves app quality, user experience, or review speed.

---

## Category 1: Privacy Compliance

### 1.1 PrivacyInfo.xcprivacy Exists

**Priority:** P0

**What:** Every app submitted to the App Store must include a privacy manifest file (`PrivacyInfo.xcprivacy`). This file declares what privacy-sensitive APIs the app uses and why.

**Detection:**

```bash
find . -name "PrivacyInfo.xcprivacy" -not -path "*/.*" -not -path "*/DerivedData/*" -not -path "*/.build/*"
```

**Pass criteria:** File exists in the app target directory (e.g., `{AppName}/PrivacyInfo.xcprivacy`).

**Auto-fix:** Generate the file with detected Required Reason API declarations. Template:

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
        <!-- Entries added based on detected API usage -->
    </array>
</dict>
</plist>
```

After generation, validate with: `plutil -lint {path}/PrivacyInfo.xcprivacy`

**Manual fix (if auto-fix fails):** Create the file manually in Xcode: File > New > File > App Privacy. Xcode provides a visual editor for the privacy manifest.

---

### 1.2 Required Reason API Declarations

**Priority:** P0

**What:** Apple requires apps to declare why they use certain APIs. If the app uses any of these APIs, they must be listed in `NSPrivacyAccessedAPITypes` with valid reason codes.

**Detection — UserDefaults:**

```bash
grep -rn "UserDefaults\|NSUserDefaults\|@AppStorage" --include="*.swift" . | grep -v DerivedData | grep -v ".build" | grep -v "Tests"
```

API category: `NSPrivacyAccessedAPICategoryUserDefaults`
Common reason: `CA92.1` — Access UserDefaults to read and write data specific to the app.

**Detection — File Timestamp APIs:**

```bash
grep -rn "fileModificationDate\|creationDate\|contentModificationDateKey\|NSFileModificationDate\|URLResourceKey\.contentModificationDateKey\|URLResourceKey\.creationDateKey" --include="*.swift" . | grep -v DerivedData
```

API category: `NSPrivacyAccessedAPICategoryFileTimestamp`
Common reasons:
- `DDA9.1` — Display file timestamps to the user
- `C617.1` — Access timestamps for files in the app's container
- `3B52.1` — Access timestamps for files accessed via user-granted file picker

**Detection — Disk Space APIs:**

```bash
grep -rn "volumeAvailableCapacityKey\|volumeTotalCapacityKey\|systemFreeSize\|systemSize\|statfs\|statvfs\|fstatfs\|URLResourceKey\.volumeAvailableCapacity" --include="*.swift" . | grep -v DerivedData
```

API category: `NSPrivacyAccessedAPICategoryDiskSpace`
Common reason: `E174.1` — Check available disk space to prevent errors when writing data.

**Detection — System Boot Time:**

```bash
grep -rn "systemUptime\|ProcessInfo.*systemUptime\|mach_absolute_time\|mach_continuous_time\|kern\.boottime" --include="*.swift" . | grep -v DerivedData
```

API category: `NSPrivacyAccessedAPICategorySystemBootTime`
Common reason: `35F9.1` — Measure elapsed time between events in the app.

**Detection — Active Keyboards:**

```bash
grep -rn "activeInputModes\|UITextInputMode" --include="*.swift" . | grep -v DerivedData
```

API category: `NSPrivacyAccessedAPICategoryActiveKeyboards`
Common reason: `54BD.1` — Customize behavior based on active keyboard.

**Auto-fix:** For each detected API category, add an entry to `NSPrivacyAccessedAPITypes` in PrivacyInfo.xcprivacy:

```xml
<dict>
    <key>NSPrivacyAccessedAPIType</key>
    <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
    <key>NSPrivacyAccessedAPITypeReasons</key>
    <array>
        <string>CA92.1</string>
    </array>
</dict>
```

**Manual fix:** If the auto-assigned reason code is wrong, open PrivacyInfo.xcprivacy in Xcode and select the correct reason from the dropdown. Apple's documentation lists all valid reasons per category: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files

---

### 1.3 Tracking Declaration

**Priority:** P0

**What:** If the app tracks users (sends data linked to device identifiers for advertising or shares with data brokers), `NSPrivacyTracking` must be `true` and the app must use AppTrackingTransparency (ATT) to request permission.

**Detection — Tracking frameworks:**

```bash
grep -rn "ATTrackingManager\|AppTrackingTransparency\|requestTrackingAuthorization" --include="*.swift" . | grep -v DerivedData
grep -rn "AdSupport\|ASIdentifierManager\|advertisingIdentifier" --include="*.swift" . | grep -v DerivedData
grep -rn "FBSDKCoreKit\|FacebookCore\|FBAdView" --include="*.swift" . | grep -v DerivedData
```

**Detection — Privacy manifest tracking flag:**

```bash
# If PrivacyInfo.xcprivacy exists:
grep -A 1 "NSPrivacyTracking" {path}/PrivacyInfo.xcprivacy
```

**Pass criteria:**
- No tracking: `NSPrivacyTracking` is `false` or absent, and no tracking framework imports.
- With tracking: `NSPrivacyTracking` is `true`, ATT implementation exists, and `NSPrivacyTrackingDomains` lists domains.

**Manual fix:**
- If you DO track users: Set `NSPrivacyTracking` to `true`, implement ATT prompt, list tracking domains.
- If you do NOT track users: Ensure `NSPrivacyTracking` is `false`, remove any advertising SDK imports.

---

### 1.4 Collected Data Types

**Priority:** P1

**What:** `NSPrivacyCollectedDataTypes` in the privacy manifest should declare what user data the app collects. This must match what you declare in App Store Connect's privacy nutrition label.

**Detection:**

Check for data collection indicators:
```bash
# Analytics events (collects usage data)
grep -rl "trackEvent\|logEvent\|Analytics.logEvent\|Mixpanel\|PostHog" --include="*.swift" . | grep -v DerivedData | head -5

# Auth (collects email, name)
grep -rl "signIn\|signUp\|email\|password\|displayName" --include="*.swift" . | grep -v DerivedData | head -5

# Purchases (collects purchase history)
grep -rl "PurchaseManager\|RevenueCat\|StoreKit\|purchase" --include="*.swift" . | grep -v DerivedData | head -5

# Location
grep -rl "CLLocationManager\|CoreLocation" --include="*.swift" . | grep -v DerivedData | head -5
```

**Pass criteria:** If analytics, auth, or purchases are used, `NSPrivacyCollectedDataTypes` should have entries describing what data is collected, why (app functionality, analytics, etc.), and whether it is linked to the user.

**Manual fix:** Open PrivacyInfo.xcprivacy in Xcode. Add collected data type entries. Each entry needs:
- Data type (e.g., email address, usage data, purchase history)
- Whether it is linked to the user's identity
- Whether it is used for tracking
- Collection purpose (app functionality, analytics, etc.)

Align these declarations with your App Store Connect privacy nutrition label answers.

---

## Category 2: Accessibility

### 2.1 VoiceOver Labels on Interactive Elements

**Priority:** P1

**What:** All interactive elements (buttons, toggles, sliders, links) must have VoiceOver labels so blind and visually impaired users can navigate the app.

**Detection:**

Step 1 — Find all view files with interactive elements:
```bash
grep -rln "DSButton\|DSIconButton\|Button\|NavigationLink\|Toggle\|Slider\|Stepper\|onTapGesture" --include="*.swift" . | grep -v DerivedData | grep -v Tests | grep -v "Components/"
```

Step 2 — For each file, check for accessibility modifiers:
```bash
# For each file from step 1:
grep -c "accessibilityLabel\|accessibilityValue\|accessibilityHint\|accessibilityAction" {file}
```

Files with interactive elements but zero accessibility modifiers are flagged.

**Auto-fix:** For DSButton and DSIconButton, add `.accessibilityLabel()` with labels inferred from the button's title or icon name:

```swift
// DSIconButton with system image "plus" → .accessibilityLabel("Add")
// DSIconButton with system image "trash" → .accessibilityLabel("Delete")
// DSIconButton with system image "gear" → .accessibilityLabel("Settings")
// DSButton("Save", ...) → already has implicit label, add .accessibilityHint("Saves your changes")
```

**Manual fix:** For custom interactive elements, add appropriate labels describing the element's purpose, not its appearance. Example: `.accessibilityLabel("Add new habit")` not `.accessibilityLabel("Plus button")`.

---

### 2.2 Dynamic Type Support (No Hardcoded Font Sizes)

**Priority:** P2

**What:** Fonts should use Dynamic Type so text scales with the user's accessibility settings. Hardcoded font sizes do not scale.

**Detection:**

```bash
# Hardcoded system fonts with fixed sizes
grep -rn "\.font(.system(size:" --include="*.swift" . | grep -v DerivedData | grep -v "DesignSystem"

# Custom fonts with fixed sizes
grep -rn "\.font(.custom(" --include="*.swift" . | grep -v DerivedData | grep -v "DesignSystem"

# UIKit font with fixed size
grep -rn "UIFont(name:.*size:" --include="*.swift" . | grep -v DerivedData | grep -v "DesignSystem"

# Fixed-size Text initializers
grep -rn "Font\.system(size:" --include="*.swift" . | grep -v DerivedData | grep -v "DesignSystem"
```

Exclude DesignSystem directory because DS tokens handle Dynamic Type scaling internally.

**Pass criteria:** No hardcoded font sizes in app code (outside DesignSystem). All fonts use DS typography tokens (`.bodyMedium()`, `.titleLarge()`, etc.) or SwiftUI's built-in text styles (`.body`, `.title`, etc.).

**Manual fix:** Replace hardcoded sizes with DS typography tokens:

| Instead of | Use |
|-----------|-----|
| `.font(.system(size: 34, weight: .bold))` | `.font(.display())` |
| `.font(.system(size: 28, weight: .semibold))` | `.font(.titleLarge())` |
| `.font(.system(size: 17))` | `.font(.bodyLarge())` |
| `.font(.system(size: 15))` | `.font(.bodyMedium())` |
| `.font(.system(size: 13))` | `.font(.bodySmall())` |
| `.font(.system(size: 11))` | `.font(.captionLarge())` |

---

### 2.3 Touch Target Minimum Size (44x44pt)

**Priority:** P2

**What:** Apple's Human Interface Guidelines require interactive elements to have a minimum touch target of 44x44 points. Small targets cause usability issues and can trigger rejection.

**Detection:**

```bash
# Frames with width or height below 44 on interactive elements
grep -B 2 -A 2 "\.frame(width:\s*[0-3][0-9]\b" --include="*.swift" -r . | grep -v DerivedData
grep -B 2 -A 2 "\.frame(height:\s*[0-3][0-9]\b" --include="*.swift" -r . | grep -v DerivedData

# Small icon buttons without padding
grep -B 3 "\.frame(width:\s*[12][0-9]," --include="*.swift" -r . | grep -i "button\|tap\|onTap" | grep -v DerivedData
```

**Pass criteria:** No interactive element has a frame smaller than 44x44pt. Note: DS components (`DSButton`, `DSIconButton`) already enforce minimum sizes.

**Manual fix:** Add padding to small interactive elements:
```swift
// Before:
Image(systemName: "xmark")
    .frame(width: 20, height: 20)
    .onTapGesture { dismiss() }

// After:
Image(systemName: "xmark")
    .frame(width: 20, height: 20)
    .padding(12) // Total touch target: 44x44
    .contentShape(Rectangle()) // Ensures tap area includes padding
    .onTapGesture { dismiss() }
```

---

### 2.4 Accessibility Identifiers for UI Testing

**Priority:** P2

**What:** `.accessibilityIdentifier()` on key UI elements enables UI testing (XCUITest). While not required for submission, it enables automated testing which improves quality.

**Detection:**

```bash
# Count files with accessibility identifiers
grep -rl "accessibilityIdentifier" --include="*.swift" . | grep -v DerivedData | grep -v Tests | wc -l

# Count total view files
find . -name "*View.swift" -not -path "*/DerivedData/*" -not -path "*Tests*" | wc -l
```

**Pass criteria:** At least 50% of view files have accessibility identifiers on key elements.

**Manual fix:** Add identifiers to key interactive and display elements:
```swift
DSButton("Save", style: .primary) { viewModel.save() }
    .accessibilityIdentifier("save-button")

Text(viewModel.title)
    .accessibilityIdentifier("item-title")
```

Use kebab-case for identifiers. Name them by purpose: `"add-habit-button"`, `"habit-name-field"`, `"streak-count-label"`.

---

## Category 3: Security

### 3.1 No Hardcoded Secrets in Source Code

**Priority:** P0

**What:** API keys, tokens, passwords, and other secrets must never be hardcoded in source code. They will be visible in the compiled binary and in version control history.

**Detection:**

```bash
# Generic secret patterns
grep -rn 'apiKey\s*[:=]\s*"[A-Za-z0-9_\-]{8,}"' --include="*.swift" . | grep -v DerivedData | grep -v Mock | grep -v Tests | grep -v "\.example"
grep -rn 'secret\s*[:=]\s*"[A-Za-z0-9_\-]{8,}"' --include="*.swift" . | grep -v DerivedData | grep -v Mock | grep -v Tests
grep -rn 'password\s*[:=]\s*"[A-Za-z0-9_\-]{4,}"' --include="*.swift" . | grep -v DerivedData | grep -v Mock | grep -v Tests
grep -rn 'token\s*[:=]\s*"[A-Za-z0-9_\-]{8,}"' --include="*.swift" . | grep -v DerivedData | grep -v Mock | grep -v Tests

# Google API keys (AIza prefix)
grep -rn "AIza[A-Za-z0-9_\-]\{35\}" --include="*.swift" . | grep -v DerivedData

# OpenAI keys (sk- prefix)
grep -rn "sk-[A-Za-z0-9]\{20,\}" --include="*.swift" . | grep -v DerivedData

# GitHub tokens (ghp_ prefix)
grep -rn "ghp_[A-Za-z0-9]\{36\}" --include="*.swift" . | grep -v DerivedData

# AWS keys
grep -rn "AKIA[A-Z0-9]\{16\}" --include="*.swift" . | grep -v DerivedData

# Supabase/JWT tokens (eyJ prefix)
grep -rn 'eyJ[A-Za-z0-9_\-]\{20,\}' --include="*.swift" . | grep -v DerivedData | grep -v Tests | grep -v Mock

# Firebase config values that should be in GoogleService-Info.plist, not source
grep -rn '"[0-9]\{1,\}:ios:[a-f0-9]\{32\}"' --include="*.swift" . | grep -v DerivedData
```

**Pass criteria:** Zero matches after excluding test files, mock data, and example comments.

**Manual fix:** Move secrets to:
1. **xcconfig files:** `Secrets.xcconfig.local` (added to .gitignore)
2. **Keychain:** For runtime tokens
3. **Environment variables:** For CI/CD pipelines

Access via a `Configuration` struct that reads from xcconfig at build time:
```swift
enum Configuration {
    static let apiKey: String = {
        guard let value = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("API_KEY not set in build configuration")
        }
        return value
    }()
}
```

---

### 3.2 Secrets Configuration in .gitignore

**Priority:** P1

**What:** Files containing secrets (API keys, Firebase config, xcconfig with credentials) must be in `.gitignore` to prevent accidental commits.

**Detection:**

```bash
# Check .gitignore exists
test -f .gitignore && echo "EXISTS" || echo "MISSING"

# Check for common secret file patterns in .gitignore
grep -q "Secrets.xcconfig" .gitignore 2>/dev/null && echo "Secrets.xcconfig: IGNORED" || echo "Secrets.xcconfig: NOT IGNORED"
grep -q "GoogleService-Info" .gitignore 2>/dev/null && echo "GoogleService-Info.plist: IGNORED" || echo "GoogleService-Info.plist: NOT IGNORED"
grep -q "\.xcconfig\.local" .gitignore 2>/dev/null && echo "*.xcconfig.local: IGNORED" || echo "*.xcconfig.local: NOT IGNORED"

# Check if any secret files are tracked by git
git ls-files | grep -i "secret\|credential\|\.env"
```

**Pass criteria:** `.gitignore` exists and includes patterns for secret files. No secret files are tracked by git.

**Manual fix:** Add to `.gitignore`:
```
# Secrets
Secrets.xcconfig.local
*.xcconfig.local
.env
.env.*

# Firebase (if containing real project config)
# GoogleService-Info.plist  # Uncomment if your plist contains production secrets
```

If a secret file is already tracked, remove it from git tracking:
```bash
git rm --cached Secrets.xcconfig.local
git commit -m "chore: remove tracked secret file"
```

---

### 3.3 Keychain Usage for Sensitive Tokens

**Priority:** P1

**What:** Authentication tokens, session tokens, and other sensitive credentials must be stored in the Keychain, not in UserDefaults or @AppStorage. UserDefaults is not encrypted and is accessible to other apps on jailbroken devices.

**Detection:**

```bash
# Tokens in UserDefaults (bad)
grep -rn "UserDefaults.*token\|UserDefaults.*auth\|UserDefaults.*session\|UserDefaults.*credential\|UserDefaults.*password" --include="*.swift" . | grep -v DerivedData | grep -v Tests | grep -v Mock
grep -rn '@AppStorage.*".*token\|@AppStorage.*".*auth\|@AppStorage.*".*session' --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Keychain usage (good)
grep -rl "SecItemAdd\|SecItemCopyMatching\|SecItemUpdate\|SecItemDelete\|KeychainManager\|KeychainWrapper\|KeychainAccess\|keychain" --include="*.swift" . | grep -v DerivedData | wc -l
```

**Pass criteria:** No sensitive tokens stored in UserDefaults. Keychain usage detected for credential storage.

**Manual fix:** Create a `KeychainManager` helper:

```swift
import Security

enum KeychainManager {
    static func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
    }

    static func load(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

---

### 3.4 App Transport Security (ATS)

**Priority:** P1

**What:** ATS enforces HTTPS for all network connections. Disabling ATS with `NSAllowsArbitraryLoads = true` weakens security and Apple may reject without justification.

**Detection:**

```bash
# Check Info.plist for ATS configuration
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep -l "NSAppTransportSecurity" {} \;

# Check for arbitrary loads
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep -A 3 "NSAllowsArbitraryLoads" {} \;

# Check for exception domains (legitimate)
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep -A 5 "NSExceptionDomains" {} \;
```

**Pass criteria:**
- No `NSAppTransportSecurity` key (ATS enforced by default) — best case
- `NSAllowsArbitraryLoads` is `false` — explicit enforcement
- Only specific `NSExceptionDomains` with justification — acceptable

**Fail criteria:**
- `NSAllowsArbitraryLoads` is `true` without exception domains — Apple may reject

**Auto-fix:** Remove `NSAllowsArbitraryLoads = true` if no legitimate HTTP endpoints exist. If the app needs HTTP access to specific domains, convert to exception domains:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>specific-domain.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
        </dict>
    </dict>
</dict>
```

**Manual fix:** If you need HTTP for local development:
1. Remove `NSAllowsArbitraryLoads` from Production/Release config
2. Keep it only in Debug/Dev configurations using preprocessor flags or separate Info.plist files

---

## Category 4: Testing

### 4.1 Unit Test Count

**Priority:** P2 (P1 if zero tests)

**What:** Apps should have unit tests covering critical business logic. While Apple does not enforce a minimum test count, having tests demonstrates quality and catches regressions.

**Detection:**

```bash
# Count test files
find . -name "*Tests.swift" -not -path "*/DerivedData/*" -not -path "*/.build/*" | wc -l

# Count test methods (Swift Testing @Test + XCTest func test)
grep -r "@Test\b" --include="*.swift" . | grep -v DerivedData | wc -l
grep -r "func test[A-Z]" --include="*.swift" . | grep -v DerivedData | wc -l
```

**Pass criteria:** 10+ test methods across test files.

**Manual fix:** Focus testing on:
1. ViewModels — test state changes, computed properties, and action methods
2. Managers — test CRUD operations with mock dependencies
3. Data models — test encoding/decoding, validation logic
4. Utilities — test helper functions, formatters, extensions

---

### 4.2 Untested ViewModels and Managers

**Priority:** P2

**What:** Every ViewModel and Manager should have a corresponding test file. These contain business logic that is critical to app correctness.

**Detection:**

```bash
# List all ViewModels
find . -name "*ViewModel.swift" -not -path "*/DerivedData/*" -not -path "*Tests*" | while read f; do
    basename "$f" .swift
done | sort

# List all Managers
find . -name "*Manager.swift" -not -path "*/DerivedData/*" -not -path "*Tests*" -not -path "*/Packages/*" | while read f; do
    basename "$f" .swift
done | sort

# List test files
find . -name "*Tests.swift" -not -path "*/DerivedData/*" | while read f; do
    basename "$f" Tests.swift
done | sort

# Diff to find untested classes
comm -23 <(find . \( -name "*ViewModel.swift" -o -name "*Manager.swift" \) -not -path "*/DerivedData/*" -not -path "*Tests*" | while read f; do basename "$f" .swift; done | sort) <(find . -name "*Tests.swift" -not -path "*/DerivedData/*" | while read f; do basename "$f" Tests.swift; done | sort)
```

**Auto-fix:** Scaffold test files for each untested class. Use Swift Testing framework:

```swift
import Testing
@testable import {AppName}

@MainActor
struct {ClassName}Tests {

    @Test
    func initialization() async throws {
        // Arrange & Act
        let sut = {ClassName}()

        // Assert — verify initial state
        // TODO: Add assertions for initial property values
    }

    // TODO: Add @Test methods for each public method
    // Naming convention: methodName_condition_expectedBehavior
}
```

**Manual fix:** Write meaningful test assertions. For ViewModels:

```swift
@Test
func loadData_success_updatesItems() async throws {
    let sut = HomeViewModel()
    await sut.loadData()
    #expect(!sut.items.isEmpty)
    #expect(sut.isLoading == false)
}

@Test
func deleteItem_existingItem_removesFromList() async throws {
    let sut = HomeViewModel()
    await sut.loadData()
    let initialCount = sut.items.count
    sut.deleteItem(sut.items[0])
    #expect(sut.items.count == initialCount - 1)
}
```

---

### 4.3 Tests Pass

**Priority:** P1

**What:** All existing tests must pass. Failing tests indicate regressions or broken functionality.

**Detection:**

```bash
xcodebuild -project *.xcodeproj \
    -scheme "{AppName} - Mock" \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
    test 2>&1 | tail -40
```

Check the output for:
- `** TEST SUCCEEDED **` — all tests passed
- `** TEST FAILED **` — some tests failed, parse for specific failures
- Build failure — test target cannot compile

**Pass criteria:** All tests pass.

**Manual fix:** For each failing test:
1. Read the failure message and assertion
2. Determine if the test is wrong (outdated assertion) or the code is wrong (regression)
3. Fix the appropriate side
4. Re-run the test to verify

---

## Category 5: App Store Metadata

### 5.1 Display Name Set

**Priority:** P0

**What:** The app's display name (shown under the icon on the home screen) must be set to the actual app name, not the template default "Forge".

**Detection:**

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep -E "PRODUCT_NAME|INFOPLIST_KEY_CFBundleDisplayName|MARKETING_VERSION" | head -5

# Also check Info.plist directly
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep -A 1 "CFBundleDisplayName\|CFBundleName" {} \;
```

**Pass criteria:** Display name is set and is NOT "Forge" (template default).

**Manual fix:** Set in Xcode: Target > General > Display Name. Or set `INFOPLIST_KEY_CFBundleDisplayName` in build settings.

---

### 5.2 Bundle ID Configured

**Priority:** P0

**What:** The bundle identifier must be unique and follow reverse-DNS format (e.g., `com.yourcompany.yourapp`). Placeholder bundle IDs will be rejected.

**Detection:**

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | head -1
```

**Pass criteria:** Bundle ID is set, follows reverse-DNS format, and is NOT a placeholder:
- `com.forge.app` (template default)
- `com.example.*`
- `com.yourcompany.*`
- Empty or unset

**Manual fix:** Set in Xcode: Target > Signing & Capabilities > Bundle Identifier. Must match your App Store Connect app record.

---

### 5.3 Version and Build Number

**Priority:** P2

**What:** Version (`MARKETING_VERSION`) and build number (`CURRENT_PROJECT_VERSION`) must be set. Each submission to the App Store must have a unique version+build combination.

**Detection:**

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION" | head -2
```

**Pass criteria:** Version is set (any valid semver like "1.0.0" is fine for first submission). Build number is set (any positive integer like "1" is fine).

**Auto-fix:** If empty, set version to "1.0.0" and build number to "1".

**Manual fix:** Set in Xcode: Target > General > Version and Build.

---

### 5.4 App Icon Present

**Priority:** P0

**What:** Every app must have an app icon. The icon must be a 1024x1024 PNG without alpha channel and without rounded corners (iOS applies them automatically).

**Detection:**

```bash
# Find AppIcon asset
find . -name "AppIcon.appiconset" -not -path "*/DerivedData/*"

# Check if it has actual image files
find . -name "AppIcon.appiconset" -not -path "*/DerivedData/*" -exec ls {} \; | grep -v Contents.json | head -5

# Check Contents.json for image references
find . -name "AppIcon.appiconset" -not -path "*/DerivedData/*" -exec cat {}/Contents.json \; 2>/dev/null | grep filename
```

**Pass criteria:** AppIcon.appiconset exists and contains at least one image file referenced in Contents.json.

**Manual fix:** Design a 1024x1024 app icon and add it to the asset catalog:
1. In Xcode, open Assets.xcassets
2. Select AppIcon
3. Drag your 1024x1024 PNG onto the "App Store" slot (or all slots for device-specific icons)
4. Requirements: PNG format, no transparency/alpha channel, no rounded corners, sRGB color space

Design guidelines:
- Simple, recognizable shape
- No text (too small to read at icon size)
- No screenshots of the app
- Use the app's brand color as the primary color
- Test at multiple sizes (small sizes must still be recognizable)

---

### 5.5 Launch Screen Configured

**Priority:** P1

**What:** Apple requires a launch screen. Without one, the app may show a black screen during launch, which causes poor first impressions and potential rejection.

**Detection:**

```bash
# Check for launch screen in Info.plist
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep -l "UILaunchScreen\|UILaunchStoryboardName" {} \;

# Check for launch screen storyboard
find . -name "LaunchScreen.storyboard" -not -path "*/DerivedData/*"

# Check build settings
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep -i "launch"
```

**Pass criteria:** A launch screen configuration exists (either Info.plist key `UILaunchScreen` with background color, or a LaunchScreen.storyboard file).

**Manual fix:** Add `UILaunchScreen` to Info.plist for a simple solid-color launch screen:
```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>LaunchScreenBackground</string>
</dict>
```

Or create a LaunchScreen.storyboard in Xcode for a custom design.

---

## Category 6: Build Configuration

### 6.1 Production/Release Scheme Exists

**Priority:** P0

**What:** A Production or Release build scheme is required to create an App Store archive. The Mock scheme includes debug flags and mock data that should not ship.

**Detection:**

```bash
xcodebuild -project *.xcodeproj -list 2>/dev/null | grep -i "production\|release" | grep -v "Debug\|Mock\|Dev"
```

Also check for scheme files:
```bash
find . -name "*.xcscheme" -not -path "*/DerivedData/*" | while read f; do basename "$f" .xcscheme; done
```

**Pass criteria:** At least one scheme exists with "Production", "Release", or the app name without "Mock"/"Dev" qualifier.

**Manual fix:** Create a Production scheme in Xcode:
1. Product > Scheme > Manage Schemes
2. Duplicate an existing scheme
3. Rename to "{AppName} - Production" or "{AppName}"
4. Edit scheme: set Build Configuration to "Release" for Archive action
5. Remove any mock-related build flags

---

### 6.2 Production Build Succeeds

**Priority:** P0

**What:** The app must compile successfully on the Production/Release scheme with zero errors. The production build may differ from Mock (no mock data, different feature flags, different code signing).

**Detection:**

```bash
xcodebuild -project *.xcodeproj \
    -scheme "{ProductionScheme}" \
    -destination 'generic/platform=iOS' \
    build 2>&1 | tail -40
```

Check output for:
- `** BUILD SUCCEEDED **` — pass
- `** BUILD FAILED **` — fail, parse errors
- Warnings from app code — warning (should fix)

**Pass criteria:** Build succeeds with zero errors. Zero warnings from app code (package warnings acceptable).

**Manual fix:** Common production build failures:
1. Missing `#if DEBUG` guards on mock-only code
2. Feature flag differences exposing compilation errors
3. Code signing issues (development vs distribution)
4. Missing production configuration in xcconfig

---

### 6.3 Code Signing Configured

**Priority:** P0

**What:** Valid code signing is required to archive and submit to the App Store. The development team and signing identity must be set.

**Detection:**

```bash
xcodebuild -project *.xcodeproj -showBuildSettings 2>/dev/null | grep -E "CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM|CODE_SIGN_STYLE|PROVISIONING_PROFILE_SPECIFIER" | head -10
```

**Pass criteria:**
- `DEVELOPMENT_TEAM` is set (not empty)
- `CODE_SIGN_STYLE` is "Automatic" (recommended) or valid manual profiles exist
- `CODE_SIGN_IDENTITY` is "Apple Distribution" or "iPhone Distribution" for release

**Manual fix:**
1. In Xcode, select the app target
2. Go to Signing & Capabilities
3. Check "Automatically manage signing"
4. Select your development team from the dropdown
5. If no team appears: Xcode > Preferences > Accounts > Add Apple ID

For distribution:
1. Ensure you have an Apple Developer Program membership ($99/year)
2. Xcode will create distribution certificates and profiles automatically

---

## Category 7: Legal and Compliance

### 7.1 Export Compliance (Encryption)

**Priority:** P1

**What:** Apps that use encryption beyond standard HTTPS must declare it for export compliance. Apple asks about this during submission — having `ITSAppUsesNonExemptEncryption` in Info.plist streamlines the process.

**Detection:**

```bash
# Check for encryption framework usage
grep -rl "CryptoKit\|CommonCrypto\|Security/SecKey\|CCCrypt\|AES\|RSA\|CryptoSwift\|Sodium\|OpenSSL" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Check Info.plist for export compliance declaration
find . -name "Info.plist" -not -path "*/DerivedData/*" -exec grep "ITSAppUsesNonExemptEncryption" {} \;
```

**Pass criteria:**
- No custom encryption: Set `ITSAppUsesNonExemptEncryption` to `false` to skip App Store Connect encryption questions
- Custom encryption with exemption: Set to `false` with documentation
- Custom encryption without exemption: Set to `true` and file CCATS

**Auto-fix:** If no custom encryption detected, add to Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**Manual fix:** If your app uses encryption beyond HTTPS:
1. Determine if it qualifies for an exemption (most apps do)
2. Apple's exemptions: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations
3. If exempt: set `ITSAppUsesNonExemptEncryption` to `false`
4. If not exempt: set to `true` and file for CCATS approval at bis.gov

---

### 7.2 Third-Party SDK Licenses

**Priority:** P2

**What:** All third-party SDKs used in the app must have licenses compatible with App Store distribution. Most popular open-source SDKs (MIT, Apache 2.0, BSD) are compatible.

**Detection:**

```bash
# Find Package.resolved for SPM dependencies
find . -name "Package.resolved" -not -path "*/DerivedData/*" -exec cat {} \;

# List unique packages
find . -name "Package.resolved" -not -path "*/DerivedData/*" -exec cat {} \; | grep -o '"identity"[^,]*' | sort -u
```

**Pass criteria:** All dependencies use App Store-compatible licenses (MIT, Apache 2.0, BSD, ISC, Zlib).

**Manual fix:** For each dependency:
1. Check its LICENSE file in the repository
2. Verify it allows redistribution in compiled form
3. Some licenses (GPL, LGPL) have restrictions — consult legal advice
4. Include attribution if the license requires it (e.g., Apache 2.0 requires NOTICE file)

---

### 7.3 In-App Purchase Configuration

**Priority:** P1 (if applicable)

**What:** If the app uses in-app purchases, the StoreKit configuration must have valid product IDs that match App Store Connect, and the purchase flow must work correctly.

**Detection:**

```bash
# Check for purchase-related code
grep -rl "StoreKit\|RevenueCat\|Product\|purchase\|subscription\|EntitlementOption\|PurchaseManager" --include="*.swift" . | grep -v DerivedData | grep -v Tests | head -10

# Check for StoreKit configuration file
find . -name "*.storekit" -not -path "*/DerivedData/*"

# Check for placeholder product IDs
grep -rn "com.example\|com.forge\|placeholder\|TODO.*product" --include="*.swift" . | grep -vi "bundle" | grep -v DerivedData | grep -v Tests
grep -rn "com.example\|com.forge\|placeholder" --include="*.storekit" . | grep -v DerivedData
```

**Pass criteria:**
- No purchase code: Check is skipped entirely.
- Purchase code exists: StoreKit configuration has non-placeholder product IDs. Products are configured in App Store Connect or RevenueCat dashboard.

**Manual fix:**
1. In App Store Connect, go to In-App Purchases
2. Create products matching your StoreKit configuration
3. Update product IDs in code to match App Store Connect
4. Test purchases in sandbox mode before submission
5. If using RevenueCat: configure products in the RevenueCat dashboard

---

## Quick Reference: All Checks by Priority

### P0 — Will Cause Rejection

| Check | Category | Auto-fixable |
|-------|----------|-------------|
| 1.1 PrivacyInfo.xcprivacy exists | Privacy | Yes |
| 1.2 Required Reason APIs declared | Privacy | Yes |
| 1.3 Tracking declaration correct | Privacy | Partial |
| 3.1 No hardcoded secrets | Security | No |
| 5.1 Display name set | Metadata | No |
| 5.2 Bundle ID configured | Metadata | No |
| 5.4 App icon present | Metadata | No |
| 6.1 Production scheme exists | Build | No |
| 6.2 Production build succeeds | Build | Partial |
| 6.3 Code signing configured | Build | No |

### P1 — May Cause Rejection

| Check | Category | Auto-fixable |
|-------|----------|-------------|
| 1.4 Collected data types | Privacy | No |
| 2.1 VoiceOver labels | Accessibility | Partial |
| 3.2 Secrets in .gitignore | Security | Yes |
| 3.3 Keychain for tokens | Security | No |
| 3.4 App Transport Security | Security | Yes |
| 4.3 Tests pass | Testing | No |
| 5.5 Launch screen | Metadata | No |
| 7.1 Export compliance | Legal | Yes |
| 7.3 IAP configuration | Legal | No |

### P2 — Best Practice

| Check | Category | Auto-fixable |
|-------|----------|-------------|
| 2.2 Dynamic Type | Accessibility | No |
| 2.3 Touch targets 44pt | Accessibility | No |
| 2.4 Accessibility identifiers | Accessibility | No |
| 4.1 Unit test count | Testing | Partial (scaffold) |
| 4.2 Untested ViewModels/Managers | Testing | Yes (scaffold) |
| 5.3 Version number | Metadata | Yes |
| 7.2 SDK licenses | Legal | No |
