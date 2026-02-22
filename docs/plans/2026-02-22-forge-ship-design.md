# Design: forge-ship — App Store Submission Skill

**Date:** 2026-02-22
**Status:** Approved

---

## Problem

After forge-app builds the app and forge-wire connects the backend, the developer needs to submit to the App Store. This involves a long checklist: privacy manifests, accessibility compliance, test coverage, metadata, code signing, export compliance, age ratings. Missing any of these causes rejection. Today this is manual trial-and-error.

## Solution

A pre-flight audit skill (`/forge:ship`) that scans the app, identifies gaps, fixes what it can, and tells the developer what needs manual action. Integrates with Axiom audit agents for deep compliance scanning (accessibility, security, performance).

---

## How It Works

### Phase 1: Pre-Flight Audit

Scan the project for submission readiness across these categories:

**1. Privacy Compliance**
- [ ] `PrivacyInfo.xcprivacy` exists with correct required reason APIs
- [ ] NSPrivacyTracking declared if using ATT
- [ ] NSPrivacyCollectedDataTypes populated
- [ ] Privacy Nutrition Labels match actual data collection
- [ ] Required reason APIs documented (UserDefaults, file timestamp, etc.)

**2. Accessibility**
- [ ] VoiceOver labels on interactive elements
- [ ] Dynamic Type supported (no hardcoded font sizes)
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 large text)
- [ ] Touch targets minimum 44x44pt
- [ ] Reduce Motion respected

**3. Security**
- [ ] No hardcoded API keys in source code
- [ ] Secrets in .xcconfig files, not committed to git
- [ ] Keychain used for tokens, not UserDefaults
- [ ] ATS enabled (no arbitrary loads)

**4. Testing**
- [ ] Unit tests exist for ViewModels
- [ ] Unit tests exist for Managers
- [ ] Tests pass on CI/simulator
- [ ] Minimum meaningful coverage (not just boilerplate)

**5. App Store Metadata**
- [ ] Display name set (not "Forge")
- [ ] Bundle ID configured (not placeholder)
- [ ] Version and build number set
- [ ] App icon provided (all sizes)
- [ ] Launch screen configured

**6. Build Configuration**
- [ ] Production scheme configured
- [ ] Release build compiles
- [ ] Code signing configured (or guidance provided)
- [ ] Bitcode/dSYM settings correct

**7. Legal/Compliance**
- [ ] Age rating appropriate for content
- [ ] Export compliance (encryption usage)
- [ ] Terms of service URL if needed
- [ ] EULA if subscriptions

### Phase 2: Axiom Deep Scan

Invoke Axiom audit agents for comprehensive scanning:

| Axiom Agent | What it checks |
|------------|----------------|
| `axiom:accessibility-auditor` | VoiceOver, Dynamic Type, color contrast, touch targets, WCAG compliance |
| `axiom:security-privacy-scanner` | API keys, insecure storage, Privacy Manifests, ATS |
| `axiom:memory-auditor` | Retain cycles, timer leaks, observer leaks |
| `axiom:concurrency-auditor` | Swift 6 strict concurrency, data race potential |
| `axiom:energy-auditor` | Battery drain patterns, timer abuse, polling |
| `axiom:testing-auditor` | Test quality, flaky patterns, missing assertions |

Each agent produces findings. forge-ship aggregates them into a single report.

### Phase 3: Auto-Fix

For issues that can be automatically fixed, forge-ship fixes them:

**Auto-fixable:**
- Generate `PrivacyInfo.xcprivacy` with detected required reason APIs
- Add missing VoiceOver labels to DS components
- Add `.dynamicTypeSize()` modifier where missing
- Scaffold unit test files for untested ViewModels/Managers
- Update `Info.plist` with missing keys
- Set version/build numbers
- Configure export compliance in Info.plist

**Requires manual action (guidance provided):**
- App icon design and export
- Code signing certificate and provisioning profile
- App Store Connect account and app record creation
- Screenshot capture and upload
- App description, keywords, categories
- Review notes for App Review team
- Age rating questionnaire answers

### Phase 4: Submission Checklist

After fixes, present a final checklist with status:

```
## App Store Readiness: [App Name]

### Automated Checks
| Check | Status | Action |
|-------|--------|--------|
| Privacy Manifest | ✅ Generated | Auto-fixed |
| Accessibility | ⚠️ 3 issues | Fixed 2, 1 needs manual review |
| Security | ✅ No issues | — |
| Unit Tests | ✅ 12 tests | Scaffolded for 4 ViewModels |
| Build Config | ✅ Production compiles | — |
| Memory | ✅ No leaks detected | — |
| Concurrency | ⚠️ 1 warning | Fixed |

### Manual Steps Required
1. ☐ Create App Store Connect record
2. ☐ Add app icon (1024x1024 PNG)
3. ☐ Configure code signing in Xcode
4. ☐ Capture screenshots (6.7", 6.1", iPad if universal)
5. ☐ Write app description and keywords
6. ☐ Set age rating in App Store Connect
7. ☐ Archive and upload via Xcode Organizer or `xcodebuild archive`

### Metadata Draft
**Suggested description:** [AI-generated based on app pitch]
**Suggested keywords:** [comma-separated based on app domain]
**Suggested category:** [primary and secondary]
```

---

## Axiom Integration Details

forge-ship checks if Axiom agents are available and invokes them when present. If Axiom is not installed, forge-ship runs its own lightweight checks:

| Check | With Axiom | Without Axiom |
|-------|-----------|---------------|
| Accessibility | Full WCAG audit with 50+ rules | Basic check: VoiceOver labels, font sizes, touch targets |
| Security | Deep scan: keys, storage, manifests, ATS | Grep for API keys, check xcconfig, check Privacy Manifest exists |
| Memory | Retain cycle detection, leak patterns | Check for `[weak self]` in closures, timer invalidation |
| Concurrency | Swift 6 strict compliance scan | Check for `@MainActor`, `Sendable`, obvious races |
| Energy | 8 anti-pattern categories | Check for Timer usage, continuous location, polling |
| Testing | Quality, flakiness, migration readiness | Check test files exist, basic assertion count |

---

## Token Cost

| Scope | Estimated Tokens | Cost |
|-------|-----------------|------|
| Pre-flight audit only | 100K-200K | ~$0.40-0.80 |
| Audit + Axiom deep scan | 300K-600K | ~$1.20-2.40 |
| Audit + Axiom + auto-fix | 400K-800K | ~$1.60-3.20 |
| Full (audit + fix + metadata draft) | 500K-1.0M | ~$2.00-4.00 |

---

## File Structure

```
forge-ship/
├── claude-code.json
└── skills/
    └── forge-ship/
        ├── SKILL.md              # Main orchestrator
        └── references/
            ├── checklist.md      # Full pre-flight checklist with all items
            └── axiom-agents.md   # Which Axiom agents to invoke and how to aggregate findings
```

---

## Trigger Phrases

- `/forge:ship`
- "Prepare for App Store"
- "Is my app ready to submit?"
- "Pre-flight check"
- "Get ready for App Review"

---

## Success Criteria

1. Developer goes from "built app" to "ready to archive" in one session
2. Zero preventable App Store rejections (privacy, accessibility, metadata)
3. Privacy Manifest auto-generated correctly
4. Test scaffolds actually test meaningful behavior (not empty tests)
5. Axiom agents invoked when available for deep compliance
6. Clear manual step list for things the skill can't automate
7. Works without Axiom installed (degraded but functional)
