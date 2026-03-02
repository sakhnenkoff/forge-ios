# Forge Pipeline Quality Upgrade — Design Document

## Status
- [x] Phase 1: Functional Core — implemented 2026-03-02
- [ ] Phase 2: Robustness
- [ ] Phase 3: App Store Pipeline
- [ ] Phase 4: Speed & Quality

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the Forge pipeline from producing "beautiful shell with mock data" to producing functional, robust, App Store-ready apps.

**Key insight:** The Forge template already has a Manager Pattern (protocol + Mock/Prod) documented in AGENTS.md, plus `AppServices` environment injection. But builders ignore it — they create ViewModels with hardcoded mock arrays instead of creating feature managers. The existing `DocumentManagerSync` is Firestore-specific (user profile sync) and NOT what we use for domain data. We need simple, backend-agnostic manager protocols per feature.

---

## Current State Assessment

### What the template already provides
- Manager Pattern (protocol + Mock/Prod) documented in AGENTS.md lines 77-93
- `AppServices` environment injection with scheme-based implementation selection
- `DocumentManagerSync` — Firestore-specific user profile sync (NOT for domain data)
- `ErrorStateView`, `EmptyStateView`, `ToastView` UI components
- Mock/Dev/Prod build configurations

### What the pipeline does NOT use
- Builders create `@Observable class ViewModel` with `var items: [Item] = [mockItem1, mockItem2]`
- No manager protocol is created per feature — the pattern exists in AGENTS.md but builders don't follow it
- No `LoadPhase` or loading states
- No error handling (happy path only)
- No tests
- ViewModels are self-contained islands with no connection to services

### The gap
The template documents the Manager Pattern. The builder prompts don't tell agents to follow it for domain data. `DocumentManagerSync` is a Firestore sync tool — it's NOT the pattern to generalize. We need simple, backend-agnostic manager protocols per feature.

---

## Phase 1: Functional Core

### 1A. ViewModel State Management (3 tiers)

Based on research (IceCubesApp patterns, Thomas Ricouard's architecture, community consensus):

**Tier 1 — Local data (SwiftData, UserDefaults):**
No loading phase needed. Data always available from disk.
```swift
@Observable class HabitListViewModel {
    var habits: [Habit] = []
    var isEmpty: Bool { habits.isEmpty }
}
```
Applies to: habit trackers, journals, calculators, local-only lists.

**Tier 2 — API-fetched (URLSession, remote data):**
Hybrid pattern — LoadPhase enum + separate data array. Data survives refresh.
```swift
enum LoadPhase { case idle, loading, refreshing, error(Error) }

@Observable class FeedViewModel {
    var phase: LoadPhase = .idle
    var posts: [Post] = []
    var isEmpty: Bool { phase != .loading && posts.isEmpty }
}
```
View uses overlays: content always visible, loading/error/empty as overlays on top.
Applies to: API feeds, dashboards with server data, search results.

**Tier 3 — Static/computed:**
Just properties, no state machine.
```swift
@Observable class AboutViewModel {
    let appVersion: String
}
```
Applies to: settings, about, onboarding steps, paywall.

**Builder decides tier based on data source** — not universal. Feature spec drives state requirements. When no feature spec exists, default based on screen type.

**Optimistic updates** (from IceCubesApp pattern) for quick user actions:
Set expected state immediately, API call in background, revert on failure. No spinner for toggle/like/pin/delete actions. Applies when forge-wire connects a backend.

### 1B. Feature Managers (Backend-Agnostic)

For each screen that reads/writes domain data, the builder creates a manager following the existing AGENTS.md Manager Pattern:

```swift
// Protocol — backend-agnostic contract
protocol HabitManagerProtocol: Sendable {
    func fetchAll() async throws -> [Habit]
    func create(_ habit: Habit) async throws
    func update(_ habit: Habit) async throws
    func delete(_ habit: Habit) async throws
}

// Mock — in-memory, no persistence, works immediately
final class MockHabitManager: HabitManagerProtocol {
    private var habits: [Habit] = Habit.mockList  // realistic mock data

    func fetchAll() async throws -> [Habit] { habits }
    func create(_ habit: Habit) async throws { habits.append(habit) }
    // ...
}
```

Wire to `AppServices`, ViewModel calls `services.habitManager.fetchAll()` instead of holding `var habits = [mockHabit1]`.

**What this enables:**
- Mock scheme works immediately with realistic in-memory data
- forge-wire later swaps `MockHabitManager` for `SwiftDataHabitManager`, `FirestoreHabitManager`, `RESTHabitManager`, etc. — no ViewModel changes
- The app's data contract is defined once, backend choice is deferred

**What the builder does NOT do:**
- Does NOT choose SwiftData vs Firestore vs REST — that's forge-wire's job
- Does NOT use `DocumentManagerSync` — that's Firestore-specific user profile sync
- Does NOT create persistence layer — mock is in-memory only

**Which screens get managers:**
- Screens that list/create/edit/delete domain objects → YES (create manager)
- Settings, About, Onboarding, Paywall → NO (static content, no domain data)
- Dashboard aggregating data from other managers → uses existing managers, no new one

### 1C. Loading Patterns (from Dimillian's skill)

- `.redacted(reason: .placeholder)` for skeleton loading (not full-screen spinners)
- `ContentUnavailableView` for empty states
- `.refreshable { }` for pull-to-refresh
- `.task { }` for initial data load
- `.task(id:)` for reactive reloads

### 1D. State Requirements per Screen Type

Not every screen needs all states. The builder checks the feature spec first, then falls back to defaults:

| Screen data source | Default states |
|-------------------|----------------|
| Local query (SwiftData) | populated, empty |
| API fetch | populated, empty, loading, error |
| Static content | populated only |
| User input (form) | default, saving, validation error |
| Computed/aggregated | populated, empty |

---

## Phase 2: Robustness

### 2A. ViewModel Unit Tests

For every ViewModel that has logic (not passthrough), generate a test file:
- Test initial state
- Test data loading (mock manager injection)
- Test error handling
- Test user actions (add, delete, toggle)

### 2B. Edge Case Mock Data

Builder creates realistic mock data with edge cases:
- Very long strings (tests text truncation)
- Empty/nil optional fields
- Dates in past/future/today
- Zero and negative numbers
- Large datasets (20+ items for scroll performance)

Only for data-driven screens. Static screens skip this.

### 2C. Error Handling Patterns

Standardize error handling in ViewModels:
- Network errors → `phase = .error(error)` + toast
- Validation errors → inline field errors
- Save failures → toast with retry
- Auth expiry → redirect to login

---

## Phase 3: App Store Pipeline (Manual Trigger)

No changes to when forge-ship and forge-storefront run — they remain manually invoked by the user after testing.

### Improvements to forge-ship:
- Auto-scan code for API usage patterns → generate PrivacyInfo.xcprivacy
- Auto-detect tracking SDKs → populate tracking domains

### Improvements to forge-storefront:
- Auto-capture marketing screenshots via forge-eye (tap through key screens at App Store dimensions)
- Generate screenshot descriptions from mood + screen content

---

## Phase 4: Speed & Quality

### 4A. Parallel Screen Building
Classify screens during blueprint:
- **Independent** (Settings, Profile, About) → can build in parallel
- **Dependent** (Detail pushed from List) → build sequentially

### 4B. Curated Reference Fallback
When Playwright fails to browse real apps (login walls, geo-blocks), fall back to `.forge/design-references/fallback/` library organized by screen type and mood.

### 4C. Independent Quality Verification
After polisher reports "Serves the mood," orchestrator takes its OWN screenshot and does a brief independent check: "does this look like a unique app or template output?"

### 4D. E2E Flow Testing
After all screens built, launch the app and tap through the main user flow (onboarding → home → core action → result). Screenshot each step. Verify the flow works end-to-end.

---

## Files to Modify

### Phase 1 (Functional Core)
| File | Change |
|------|--------|
| `forge-feature/agents/forge-builder.md` | Update build instructions: create feature managers (protocol + mock), wire to AppServices, use LoadPhase for API screens, implement appropriate states per tier |
| `forge-app/skills/forge-app/SKILL.md` | Update Build Agent prompt: create managers, state tiers, loading patterns |
| `AGENTS.md` | Add ViewModel state management tiers, LoadPhase pattern, feature manager creation rules |

### Phase 2 (Robustness)
| File | Change |
|------|--------|
| `forge-feature/agents/forge-builder.md` | Add test generation step after build |
| `forge-app/skills/forge-app/SKILL.md` | Add test verification to orchestrator |
| Template: `{App}Tests/` | Add test scaffolding patterns |

### Phase 3 (App Store Pipeline)
| File | Change |
|------|--------|
| `forge-ship/skills/forge-ship/SKILL.md` | Add auto-scan for privacy manifest |
| `forge-storefront/skills/forge-storefront/SKILL.md` | Add auto-screenshot capture |

### Phase 4 (Speed & Quality)
| File | Change |
|------|--------|
| `forge-app/skills/forge-app/SKILL.md` | Add parallel screen building logic, E2E flow test step |
| `forge-craft/skills/forge-eye/SKILL.md` | Add E2E flow testing protocol |

---

## Architecture Decisions

1. **Stay MVVM** — The template is built on it, AGENTS.md documents it, all agent prompts reference it. Migrating to MV (no ViewModel) would require rewriting everything for marginal benefit. Cherry-pick Ricouard's best patterns (`.task`, `.redacted`, `ContentUnavailableView`, overlay pattern) into MVVM structure.

2. **Backend-agnostic manager protocols** — Builders create simple CRUD protocols per feature with mock implementations. `DocumentManagerSync` is Firestore-specific user sync — NOT for domain data. Backend choice (SwiftData, Firestore, REST, etc.) is deferred to forge-wire.

3. **State tiers, not universal pattern** — Different screens need different state management. Feature spec drives requirements, with sensible defaults per screen type.

4. **LoadPhase + separate data** — For API-fetched screens, keep phase and data separate so refresh doesn't nuke visible content. Inspired by IceCubesApp's `TimelineViewModel` pattern.

5. **Tests for logic, not views** — Unit test ViewModels and managers. Use screenshots for visual testing. Don't test SwiftUI views directly.

---

## Research Sources

- [IceCubesApp](https://github.com/Dimillian/IceCubesApp) — Thomas Ricouard's open-source Mastodon client
- [Migrating to Observation framework](https://dimillian.medium.com/migrating-ice-cubes-to-the-swiftui-observation-framework-821f90deebee)
- [SwiftUI in 2025: Forget MVVM](https://dimillian.medium.com/) — Ricouard's MV advocacy (assessed, decided to stay MVVM)
- [Dimillian/Skills](https://github.com/Dimillian/Skills) — SwiftUI UI patterns, loading placeholders, MV patterns
- [View State Management: Enum vs Properties](https://medium.com/policiano/view-state-management-b71813f500a1)
- [Handling loading states in SwiftUI](https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/)
- [SwiftUI loading states with a twist](https://www.swiftindepth.com/articles/swiftui-loading-states-with-mutation/)
- Axiom skills: `axiom-storage`, `axiom-swiftui-architecture`, `axiom-ios-data`
