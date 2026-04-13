# Axiom Agent Integration Reference

Complete reference for integrating Axiom audit agents into the forge-ship pre-flight pipeline. Covers invocation order, finding aggregation, fallback inline checks, and combined report presentation.

---

## Overview

Axiom is a suite of specialized audit agents designed for deep iOS/SwiftUI code analysis. Each agent focuses on a specific quality dimension and performs analysis beyond what pattern matching (grep) can achieve — including AST inspection, control flow analysis, memory graph traversal, and concurrency modeling.

forge-ship integrates with Axiom in Phase 2 (Deep Scan) after the Phase 1 grep-based pre-flight audit. When Axiom agents are available, they provide deeper findings. When not available, forge-ship runs lightweight inline fallback checks.

**Key principle:** forge-ship always produces a complete audit report. Axiom adds depth, not breadth. Every check category is covered regardless of Axiom availability.

---

## Agent Inventory

| Agent | Skill Name | Focus Area | Phase 1 Overlap |
|-------|-----------|------------|-----------------|
| Accessibility Auditor | `axiom:accessibility-auditor` | WCAG compliance, Dynamic Type, VoiceOver, color contrast, motion sensitivity | Category 2 (Accessibility) |
| Security & Privacy Scanner | `axiom:security-privacy-scanner` | Secrets detection, data flow, ATS, certificate pinning, Keychain, PII tracking | Category 3 (Security) + Category 1 (Privacy) |
| Memory Auditor | `axiom:memory-auditor` | Retain cycles, closure captures, delegate patterns, memory leaks, Combine lifecycle | None (new dimension) |
| Concurrency Auditor | `axiom:concurrency-auditor` | Swift 6 compliance, data races, actor isolation, Sendable conformance | None (new dimension) |
| Energy Auditor | `axiom:energy-auditor` | Battery drain, background tasks, network polling, animation efficiency, sensor usage | None (new dimension) |
| Testing Auditor | `axiom:testing-auditor` | Test quality, coverage gaps, flaky tests, assertion quality, mock patterns | Category 4 (Testing) |

---

## Detection

At the start of Phase 2, check which Axiom agents are available by scanning the current session's skill list.

**How to detect:** Check the list of available skills visible in the current session. Simply note which skill names appear from the agent inventory table above. Do NOT attempt to import, invoke, or test them — just check if they are listed as available.

**Log detection results:**

```
Axiom agents detected: [list of available agent names]
Not available: [list of unavailable agent names] (using inline fallback checks)
```

Example outputs:

```
Axiom agents detected: accessibility-auditor, security-privacy-scanner, concurrency-auditor.
Not available: memory-auditor, energy-auditor, testing-auditor (using inline fallback checks).
```

```
Axiom agents detected: none.
All categories will use inline fallback checks. Install Axiom for deeper analysis.
```

---

## Invocation Order

Invoke available agents in this specific order. The order is optimized for dependency (some agents benefit from earlier agents' findings) and for fail-fast (critical issues surface first):

### Order 1: Security & Privacy Scanner

**Why first:** Security issues are P0 rejections. Finding them early avoids wasted time on other checks if there are showstoppers.

**Invocation prompt:**

> "Run a deep security and privacy scan on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - Hardcoded secrets, API keys, tokens, passwords in all Swift files
> - Data flow analysis for PII (personally identifiable information)
> - Privacy manifest completeness (cross-reference detected APIs with PrivacyInfo.xcprivacy declarations)
> - App Transport Security configuration and HTTP endpoint inventory
> - Certificate pinning implementation (if networking code exists)
> - Keychain usage patterns vs insecure storage (UserDefaults for credentials)
> - Third-party SDK privacy implications
>
> Phase 1 already detected these security items: {list Phase 1 Category 3 findings}.
> Report only NEW findings not already covered by Phase 1."

**Expected output:** List of findings with severity (P0/P1/P2), file locations, and remediation guidance.

### Order 2: Accessibility Auditor

**Why second:** Accessibility is an increasingly common rejection reason and impacts the largest user population.

**Invocation prompt:**

> "Run a full accessibility audit on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - WCAG 2.1 Level AA compliance across all view files
> - VoiceOver label and hint completeness on interactive elements
> - VoiceOver navigation flow and reading order
> - Dynamic Type support (font scaling, layout adaptation)
> - Color contrast ratios (4.5:1 for body text, 3:1 for large text)
> - Motion sensitivity (respect Reduce Motion setting)
> - Touch target sizes (minimum 44x44pt)
> - Accessibility traits and actions on custom controls
>
> Phase 1 already detected these accessibility items: {list Phase 1 Category 2 findings}.
> Report only NEW findings not already covered by Phase 1."

**Expected output:** List of findings with WCAG criteria references, severity, and specific code locations.

### Order 3: Concurrency Auditor

**Why third:** Concurrency issues cause crashes that are hard to reproduce during testing but surface in production. Swift 6 strict concurrency compliance is increasingly important.

**Invocation prompt:**

> "Run a concurrency audit on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - Swift 6 strict concurrency compliance (the project uses `complete` checking with `MainActor` default)
> - Data race potential in shared mutable state
> - Actor isolation correctness (@MainActor annotations, nonisolated access)
> - Sendable conformance completeness
> - Task cancellation handling
> - Structured vs unstructured concurrency usage
> - @unchecked Sendable and nonisolated(unsafe) escape hatch audit
> - DispatchQueue usage in async/await context
>
> The project's concurrency baseline from AGENTS.md:
> - App target uses strict concurrency (complete) and defaults to MainActor isolation
> - Upcoming features enabled: NonisolatedNonsendingByDefault, InferIsolatedConformances
> - Package targets (Packages/core-packages) do NOT default to MainActor
>
> Flag auto-fixable issues separately from issues requiring architectural changes."

**Expected output:** List of findings with auto-fix suggestions where applicable.

### Order 4: Memory Auditor

**Why fourth:** Memory leaks cause crashes over time and degrade user experience. They are hard to detect without tooling.

**Invocation prompt:**

> "Run a memory audit on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - Retain cycles in closures (missing [weak self] in escaping closures)
> - Delegate patterns without weak references
> - NotificationCenter observer registration without corresponding removal
> - Timer retain cycles (scheduledTimer retains target)
> - Combine sink without proper cancellable storage
> - ViewModel-View strong reference cycles
> - Closure captures in navigation closures (router, sheet presentations)
> - Persistent strong references in singletons and environment objects
>
> Report each finding with the specific code location and the retain cycle chain."

**Expected output:** List of potential retain cycles with file locations and fix suggestions.

### Order 5: Energy Auditor

**Why fifth:** Energy issues affect user experience and can appear in App Store reviews (battery complaints). Not a rejection reason but impacts ratings.

**Invocation prompt:**

> "Run an energy audit on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - Timer usage: intervals, invalidation in deinit, necessity
> - Background task efficiency: duration, work performed, completion handlers
> - Network polling: frequency, alternatives (push notifications, WebSocket)
> - Animation efficiency: unnecessary animations, repeating animations, off-screen animations
> - Location tracking: precision level, update frequency, when-in-use vs always
> - Bluetooth/sensor usage: scanning intervals, unnecessary wake-ups
> - Image loading: caching strategy, resize before display, memory pressure
> - Startup time impact: heavy initialization in app launch path
>
> Categorize findings by energy impact: High (continuous drain), Medium (periodic drain), Low (minor optimization)."

**Expected output:** List of energy-impacting patterns with impact level and optimization suggestions.

### Order 6: Testing Auditor

**Why last:** Testing quality is a P2 issue — important for app quality but not a rejection reason. Running it last allows earlier agents to surface issues that should be tested.

**Invocation prompt:**

> "Run a test quality audit on {AppName}. Project root: {cwd}.
>
> Focus areas:
> - Test coverage gaps: ViewModels and Managers without test files
> - Assertion quality: tests with no assertions, tests with only #expect(true)
> - Test isolation: tests that depend on external state, shared mutable state between tests
> - Mock usage: consistent mock patterns, mock coverage for external dependencies
> - Test naming: descriptive names following methodName_condition_expectedBehavior
> - Flaky test indicators: timing dependencies, network calls, file system access
> - Error path testing: tests for error scenarios, not just happy paths
> - Edge case coverage: empty arrays, nil values, boundary conditions
>
> Phase 1 already detected these testing items: {list Phase 1 Category 4 findings}.
> Report only NEW findings not already covered by Phase 1."

**Expected output:** List of test quality findings with specific test file references and improvement suggestions.

---

## Fallback Inline Checks

For each Axiom agent that is NOT available, run these lightweight inline checks. These provide basic coverage of the agent's focus area using grep-based pattern matching.

### Accessibility Fallback

When `axiom:accessibility-auditor` is not available:

Phase 1 Category 2 checks already cover the basics. Add these supplementary checks:

```bash
# Check for color-only information (accessibility anti-pattern)
grep -rn "\.foregroundColor\|\.tint\|\.accentColor" --include="*.swift" . | grep -v DerivedData | head -20

# Check for Reduce Motion respect
grep -rl "accessibilityReduceMotion\|UIAccessibility.isReduceMotionEnabled\|ReduceMotion" --include="*.swift" . | grep -v DerivedData

# Check for large content viewer support
grep -rl "accessibilityShowsLargeContentViewer\|showsLargeContentViewer" --include="*.swift" . | grep -v DerivedData
```

Report:
- If Reduce Motion is not referenced and the app has custom animations, flag as P2.
- Note that color contrast analysis requires Axiom (cannot be done via grep).

> "Inline accessibility check complete. Install Axiom (`axiom:accessibility-auditor`) for deeper analysis including WCAG contrast ratios, VoiceOver flow analysis, and motion sensitivity compliance."

### Security & Privacy Fallback

When `axiom:security-privacy-scanner` is not available:

Phase 1 Categories 1 and 3 already cover the basics. Add these supplementary checks:

```bash
# Check for certificate pinning (if networking code exists)
grep -rl "URLSessionDelegate\|urlSession.*didReceive.*challenge\|ServerTrustPolicy\|TrustKit\|certificatePinning" --include="*.swift" . | grep -v DerivedData

# Check for biometric authentication for sensitive actions
grep -rl "LAContext\|canEvaluatePolicy\|evaluatePolicy\|biometricType" --include="*.swift" . | grep -v DerivedData

# Check for clipboard data exposure
grep -rn "UIPasteboard\|pasteboard\|\.copy\|NSPasteboard" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Check for logging sensitive data
grep -rn 'print.*token\|print.*password\|print.*secret\|NSLog.*token\|NSLog.*password' --include="*.swift" . | grep -v DerivedData | grep -v Tests | grep -v Mock
```

Report:
- If no certificate pinning exists and the app makes API calls, flag as P2 recommendation.
- If sensitive data appears in print statements, flag as P1.

> "Inline security check complete. Install Axiom (`axiom:security-privacy-scanner`) for deeper analysis including data flow tracing, PII detection, and comprehensive secret scanning."

### Memory Fallback

When `axiom:memory-auditor` is not available:

No Phase 1 coverage — these checks are the only analysis:

```bash
# Closures capturing self without [weak self]
grep -rn "\[self\]" --include="*.swift" . | grep -v DerivedData | grep -v "weak self\|unowned self" | grep -v Tests | head -20

# Strong delegate properties (should be weak)
grep -rn "var delegate:" --include="*.swift" . | grep -v "weak" | grep -v DerivedData | grep -v Tests

# Combine sinks without cancellable storage
grep -B 3 "\.sink\b" --include="*.swift" -r . | grep -v "store\|cancellable\|AnyCancellable\|DerivedData" | head -20

# Timers without invalidation
grep -rn "Timer.scheduledTimer\|Timer.publish" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Check for deinit with cleanup
grep -rl "deinit" --include="*.swift" . | grep -v DerivedData | grep -v Tests | wc -l

# NotificationCenter observers without removal
grep -rn "NotificationCenter.default.addObserver" --include="*.swift" . | grep -v DerivedData | grep -v Tests
grep -rn "NotificationCenter.default.removeObserver" --include="*.swift" . | grep -v DerivedData | grep -v Tests
```

Analysis:
- Closures with `[self]` instead of `[weak self]` in escaping contexts are potential retain cycles.
- Non-weak delegate properties create retain cycles between parent and child.
- `.sink` without `.store(in: &cancellables)` leaks the subscription.
- Timers without `invalidate()` in `deinit` retain their target indefinitely.
- NotificationCenter observers without corresponding `removeObserver` leak.

Report each finding with file location and severity:
- Strong self in escaping closure: P1 (memory leak)
- Non-weak delegate: P1 (retain cycle)
- Timer without invalidation: P2 (may leak)
- Missing observer removal: P2 (minor leak)

> "Inline memory check complete. Install Axiom (`axiom:memory-auditor`) for deeper analysis including AST-based retain cycle detection, memory graph traversal, and closure capture chain analysis."

### Concurrency Fallback

When `axiom:concurrency-auditor` is not available:

No Phase 1 coverage — these checks are the only analysis:

```bash
# Concurrency escape hatches (should be minimized)
grep -rn "@unchecked Sendable" --include="*.swift" . | grep -v DerivedData | grep -v Tests
grep -rn "nonisolated(unsafe)" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Legacy GCD usage in async context
grep -rn "DispatchQueue.main.async\|DispatchQueue.global" --include="*.swift" . | grep -v DerivedData | grep -v Tests | head -15

# Unstructured Tasks without cancellation
grep -rn "Task \{" --include="*.swift" . | grep -v DerivedData | grep -v Tests | head -15
grep -rn "Task\.detached" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Global actors in incorrect context
grep -rn "@MainActor" --include="*.swift" . | grep -v DerivedData | grep -v Tests | wc -l

# Data race indicators: mutable state without isolation
grep -rn "var.*=.*\[\]$\|var.*=.*\[:\]$" --include="*.swift" . | grep -v DerivedData | grep -v Tests | grep -v "@MainActor\|@Observable\|actor " | head -10

# Checking for SAFETY: comments (indicating known unsafe patterns)
grep -rn "SAFETY:" --include="*.swift" . | grep -v DerivedData
```

Analysis:
- `@unchecked Sendable` bypasses compile-time race checks — each use should have a SAFETY comment.
- `nonisolated(unsafe)` disables isolation checking — requires justification.
- `DispatchQueue.main.async` in `@MainActor` context is redundant.
- `Task.detached` loses actor context — should have explicit isolation.
- Unstructured `Task {}` without stored handle cannot be cancelled.

Report each finding with severity:
- `@unchecked Sendable` without SAFETY comment: P1
- `nonisolated(unsafe)` without justification: P1
- Redundant DispatchQueue in async context: P2
- Unstructured Task without cancellation: P2
- `Task.detached` usage: P2 (review needed)

> "Inline concurrency check complete. Install Axiom (`axiom:concurrency-auditor`) for deeper analysis including data race detection, actor isolation graph analysis, and Swift 6 migration guidance."

### Energy Fallback

When `axiom:energy-auditor` is not available:

No Phase 1 coverage — these checks are the only analysis:

```bash
# Repeating timers (battery drain)
grep -rn "Timer.scheduledTimer\|Timer.publish" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Continuous location updates (vs significant change)
grep -rn "startUpdatingLocation\|startMonitoringSignificantLocationChanges\|CLLocationManager" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Background tasks
grep -rn "beginBackgroundTask\|BGTaskScheduler\|BGAppRefreshTaskRequest" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Infinite repeat animations
grep -rn "repeatForever\|\.repeatForever\|Animation.*repeat" --include="*.swift" . | grep -v DerivedData | grep -v Tests

# Large image loading without downsampling
grep -rn "UIImage(named:\|UIImage(contentsOfFile:\|Image(" --include="*.swift" . | grep -v DerivedData | grep -v Tests | head -15

# Network polling patterns
grep -B 5 "Timer\|DispatchQueue.*asyncAfter" --include="*.swift" -r . | grep -i "fetch\|load\|refresh\|poll\|sync" | grep -v DerivedData | head -10
```

Analysis:
- Repeating timers with intervals under 1 second drain battery significantly.
- `startUpdatingLocation` uses GPS continuously — use `startMonitoringSignificantLocationChanges` when possible.
- `repeatForever` animations keep the GPU active even when the view is off-screen.
- Network polling on timers should use push notifications or server-sent events instead.

Report each finding with energy impact level:
- Continuous location tracking: High
- Sub-second timer intervals: High
- Infinite animations: Medium
- Network polling on timer: Medium
- Large image without downsampling: Low

> "Inline energy check complete. Install Axiom (`axiom:energy-auditor`) for deeper analysis including Instruments-level profiling, background activity analysis, and network efficiency scoring."

### Testing Fallback

When `axiom:testing-auditor` is not available:

Phase 1 Category 4 checks already cover test count and coverage. Add these supplementary checks:

```bash
# Tests with no assertions (empty or print-only tests)
grep -A 10 "@Test\|func test[A-Z]" --include="*.swift" -r . | grep -v DerivedData | grep -B 10 "^--$\|^}" | grep -L "#expect\|XCTAssert\|XCTEqual\|XCTNotNil\|XCTFail"

# Tests accessing network (flaky test indicator)
grep -rn "URLSession\|URL(string:\|\.data(for:" --include="*Tests.swift" . | grep -v DerivedData | grep -v Mock

# Tests using sleep/delay (flaky test indicator)
grep -rn "Task.sleep\|Thread.sleep\|usleep\|XCTestExpectation.*timeout" --include="*Tests.swift" . | grep -v DerivedData

# Test naming quality
grep -rn "func test[A-Z]" --include="*Tests.swift" . | grep -v DerivedData | head -20
# Good: testSaveItem_validInput_returnsSuccess
# Bad: testSave, test1, testThing
```

Analysis:
- Tests without assertions provide no verification — they only test that code does not crash.
- Tests accessing the network are flaky (depend on connectivity and server state).
- Tests using sleep are timing-dependent and may fail intermittently.
- Short/vague test names make it hard to understand what is being tested.

Report each finding with severity:
- Tests without assertions: P2
- Network-dependent tests: P2
- Sleep-dependent tests: P2
- Poor test naming: P2 (informational)

> "Inline testing check complete. Install Axiom (`axiom:testing-auditor`) for deeper analysis including code coverage gap identification, assertion quality scoring, and flaky test detection."

---

## Finding Aggregation

After all agents (and fallback checks) complete, aggregate their findings with Phase 1 results into a unified report.

### Step 1: Collect All Findings

Create a combined findings list from three sources:
1. Phase 1 pre-flight audit findings (Categories 1-7)
2. Axiom agent findings (for available agents)
3. Inline fallback findings (for unavailable agents)

### Step 2: Deduplicate

When both Phase 1 and an Axiom agent flag the same issue:
- **Keep the Axiom finding** (it has more detail — specific code paths, deeper analysis)
- **Remove the Phase 1 finding** (to avoid double-counting)
- **Note the deduplication** in the report

Common duplicates:
- Phase 1 Check 3.1 (hardcoded secrets) vs Axiom Security Scanner (same secrets, deeper context)
- Phase 1 Check 2.1 (VoiceOver labels) vs Axiom Accessibility Auditor (same gaps, plus contrast ratios)
- Phase 1 Check 4.2 (untested ViewModels) vs Axiom Testing Auditor (same gaps, plus coverage metrics)

### Step 3: Categorize by Severity

Assign each finding to a priority level:

**P0 — Will cause rejection:**
- Privacy manifest missing or incomplete
- Hardcoded secrets in source code
- Build failures on production scheme
- Missing app icon
- Missing display name or placeholder bundle ID
- Missing code signing

**P1 — May cause rejection:**
- Accessibility gaps (no VoiceOver labels on interactive elements)
- Security weaknesses (tokens in UserDefaults, ATS disabled)
- Test failures
- Missing launch screen
- Export compliance not declared
- IAP configuration issues
- Retain cycles causing crashes (from Memory Auditor)
- Data races causing crashes (from Concurrency Auditor)

**P2 — Best practice:**
- Dynamic Type not supported
- Low test coverage
- Energy inefficiencies
- Test quality issues
- Accessibility identifiers missing
- SDK license compliance
- Touch target sizes below recommended minimum

### Step 4: Categorize by Fixability

For each finding, determine if forge-ship can auto-fix it:

**Auto-fixable by forge-ship:**
- Generate PrivacyInfo.xcprivacy with detected APIs
- Add `.accessibilityLabel()` to DS components
- Scaffold test files for untested ViewModels/Managers
- Set default version/build number
- Add `ITSAppUsesNonExemptEncryption` to Info.plist
- Apply safe concurrency fixes (from Axiom Concurrency Auditor)
- Remove `NSAllowsArbitraryLoads` when no HTTP endpoints exist

**Requires manual action:**
- App icon design and creation
- Code signing certificate/profile setup
- App Store Connect account and app record creation
- Screenshot capture on required device sizes
- App description, keywords, subtitle copywriting
- Privacy policy URL hosting
- Support URL
- Age rating questionnaire answers
- Export compliance filing (if custom encryption)
- Fixing retain cycles (requires understanding of intended ownership)
- Resolving data races (requires architectural decisions)
- Writing actual test assertions (scaffolds are empty)

### Step 5: Build Unified Report

Merge all findings into the Phase 4 submission checklist format. The report should present:

1. **Summary table:** All checks with Pass/Warning/Fail status
2. **Auto-fixed items:** What forge-ship fixed automatically in Phase 3
3. **Manual steps:** Numbered checklist ordered by priority
4. **Axiom insights:** Any deeper findings from Axiom that require attention

---

## Combined Findings Presentation

### Deduplication Example

Phase 1 found: "Check 3.1 — Hardcoded API key in `NetworkManager.swift:42`"
Axiom found: "Hardcoded API key in `NetworkManager.swift:42` — this key is passed to `URLRequest` headers and transmitted over the network. Data flow: `NetworkManager.apiKey` -> `makeRequest()` -> `URLSession.data(for:)`. The key appears to be a production Firebase API key (AIza prefix)."

Combined report uses Axiom version (more context), removes Phase 1 duplicate.

### Severity Escalation

When an Axiom agent provides context that changes the severity of a Phase 1 finding:

- Phase 1 flagged a timer as P2 (energy best practice)
- Axiom Energy Auditor determines the timer runs at 0.1s interval in a background view — escalate to P1 (significant battery drain)

Always use the higher severity when findings overlap.

### Report Format

The unified report in Phase 4 should distinguish finding sources:

```
| # | Check | Source | Priority | Status | Notes |
|---|-------|--------|----------|--------|-------|
| 1.1 | PrivacyInfo.xcprivacy | Pre-flight | P0 | Auto-fixed | Generated with 2 API declarations |
| 1.2 | Required Reason APIs | Pre-flight + Axiom | P0 | Auto-fixed | UserDefaults + FileTimestamp detected |
| 2.1 | VoiceOver labels | Axiom | P1 | Partial fix | 8/12 labels added, 4 need manual review |
| M.1 | Retain cycle | Axiom Memory | P1 | Manual | HomeViewModel → closure → self cycle |
| C.1 | Data race | Axiom Concurrency | P1 | Auto-fixed | Added @MainActor to SharedState |
| E.1 | Timer battery drain | Axiom Energy | P1 | Manual | 0.1s timer in BackgroundSync |
```

Note: "M.1", "C.1", "E.1" prefixes indicate findings from Axiom agents not covered by the standard 7-category checklist. These are additional findings that enhance the audit.

---

## Axiom Installation Guidance

When presenting findings from fallback checks, always include installation guidance for the relevant Axiom agent:

```
To unlock deeper {category} analysis, install the Axiom {agent name}:

    claude plugin install axiom-{agent}@axiom-marketplace

Axiom agents run in their own context, so they do not consume tokens from the main
forge-ship invocation. Each agent typically uses 50-100K tokens for a full project scan.
```

When multiple agents are missing, consolidate the guidance:

```
For deeper analysis, consider installing these Axiom agents:

    claude plugin marketplace add https://github.com/axiom-ios/axiom-marketplace
    claude plugin install axiom-accessibility@axiom-marketplace
    claude plugin install axiom-security@axiom-marketplace
    claude plugin install axiom-memory@axiom-marketplace
    claude plugin install axiom-concurrency@axiom-marketplace
    claude plugin install axiom-energy@axiom-marketplace
    claude plugin install axiom-testing@axiom-marketplace

Each agent runs independently. Install only the ones relevant to your app's needs.
```

---

## Token Cost Considerations

Axiom agents run in their own context when invoked as skills. This means:

- **forge-ship main context:** Sends invocation prompt (~200-500 tokens per agent) and receives findings (~1000-5000 tokens per agent). Total Axiom overhead in main context: ~3000-15000 tokens for all 6 agents.
- **Axiom agent contexts:** Each agent runs its own full analysis. Typical costs:
  - Accessibility Auditor: 50-100K tokens (reads all view files)
  - Security Scanner: 30-80K tokens (reads all Swift files, analyzes data flow)
  - Memory Auditor: 30-60K tokens (reads all classes, analyzes reference chains)
  - Concurrency Auditor: 40-80K tokens (reads all async code, models isolation)
  - Energy Auditor: 20-40K tokens (reads timers, networking, animations)
  - Testing Auditor: 20-50K tokens (reads all test files, analyzes quality)

**Recommendation:** For a first-time audit, run all available agents. For subsequent audits (after fixing issues), run only the agents whose categories had failures.

---

## Integration Checklist

Before invoking Axiom agents, verify:

```
[ ] Phase 1 pre-flight audit is complete
[ ] Phase 1 findings are collected and categorized
[ ] Available Axiom agents are detected
[ ] Invocation prompts include Phase 1 context (to avoid duplicate work)
[ ] Each agent receives the project root path
[ ] Each agent receives relevant AGENTS.md context (concurrency baseline, architecture)
```

After all agents complete, verify:

```
[ ] All available agents returned findings
[ ] Findings are deduplicated against Phase 1
[ ] Findings are categorized by severity (P0/P1/P2)
[ ] Findings are categorized by fixability (auto-fix/manual)
[ ] Severity escalations from Axiom context are applied
[ ] Unified report is ready for Phase 3 (auto-fix) and Phase 4 (checklist)
```
