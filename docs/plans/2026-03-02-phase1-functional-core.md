# Phase 1: Functional Core — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Forge pipeline output from "beautiful shell with mock arrays" to "functional app with backend-agnostic data layer, proper loading/error states, and wired services."

**Architecture:** Stay MVVM. Add LoadPhase utility to the template. Update builder/orchestrator prompts to create feature managers and use state tiers. No backend choice — mock implementations only, forge-wire swaps later.

**Tech Stack:** SwiftUI, Swift 6, @Observable, AppServices DI, Manager Pattern (protocol + Mock)

---

### Task 1: Add LoadPhase enum to the Forge template

**Files:**
- Create: `Forge/Utilities/LoadPhase.swift`

**Step 1: Create the LoadPhase utility file**

```swift
//
//  LoadPhase.swift
//  Forge
//
//  Lightweight phase tracking for screens that fetch data asynchronously.
//  Use alongside a separate data property — phase tracks lifecycle,
//  data persists across phase transitions (e.g., refresh doesn't nuke the list).
//
//  Usage in ViewModel:
//    var phase: LoadPhase = .idle
//    var items: [Item] = []
//    var isEmpty: Bool { phase != .loading && items.isEmpty }
//

import Foundation

enum LoadPhase: Equatable {
    case idle
    case loading
    case refreshing
    case error(String)

    var isLoading: Bool {
        self == .loading || self == .refreshing
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }

    static func == (lhs: LoadPhase, rhs: LoadPhase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.refreshing, .refreshing):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
```

**Step 2: Verify it compiles**

```bash
xcodebuildmcp simulator build-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj
```

Expected: Build Succeeded

**Step 3: Commit**

```bash
git add Forge/Utilities/LoadPhase.swift
git commit -m "feat: add LoadPhase enum for async screen state management"
```

---

### Task 2: Update AGENTS.md with state management patterns and feature manager rules

**Files:**
- Modify: `AGENTS.md` (ViewModel Rules section + Patterns section)

**Step 1: Add ViewModel State Management section after the existing ViewModel Rules**

Insert after line 62 (after the ViewModel Rules closing `---`), before the `## Patterns` section:

```markdown
### ViewModel State Tiers

Choose the tier based on the screen's data source. Feature spec drives state requirements — when no spec exists, use these defaults.

**Tier 1 — Local data (SwiftData, in-memory, UserDefaults):**
No LoadPhase needed. Data is always available.
```swift
@Observable class HabitListViewModel {
    var habits: [Habit] = []
    var isEmpty: Bool { habits.isEmpty }
}
```

**Tier 2 — API-fetched / async data:**
Use `LoadPhase` + separate data array. Data survives refresh.
```swift
@Observable class FeedViewModel {
    var phase: LoadPhase = .idle
    var posts: [Post] = []
    var isEmpty: Bool { phase != .loading && posts.isEmpty }

    func load(services: AppServices) async {
        phase = .loading
        do {
            posts = try await services.feedManager.fetchAll()
            phase = .idle
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func refresh(services: AppServices) async {
        phase = .refreshing  // keeps posts visible
        do {
            posts = try await services.feedManager.fetchAll()
            phase = .idle
        } catch {
            phase = .error(error.localizedDescription)
        }
    }
}
```
View pattern: content always visible, loading/error/empty as overlays.
```swift
List(viewModel.posts) { post in ... }
    .overlay { if viewModel.phase == .loading { ProgressView() } }
    .overlay { if viewModel.isEmpty { ContentUnavailableView("No posts", systemImage: "tray") } }
    .overlay { if let msg = viewModel.phase.errorMessage { ErrorBanner(msg) } }
    .refreshable { await viewModel.refresh(services: services) }
    .task { await viewModel.load(services: services) }
```

**Tier 3 — Static/computed:**
Just properties. No state machine, no LoadPhase.
```swift
@Observable class AboutViewModel {
    let appVersion = Bundle.main.appVersion
}
```

**Default tier by screen type:**
| Screen type | Default tier |
|------------|-------------|
| List/collection with domain data | Tier 1 (local) or Tier 2 (API) based on manager |
| Dashboard/summary | Tier 1 or 2 based on data source |
| Detail (passed from parent) | Tier 3 (data already loaded) |
| Form/input | Tier 1 (save locally) |
| Settings, About, Onboarding, Paywall | Tier 3 |

### Loading Patterns

- Use `.redacted(reason: .placeholder)` for skeleton loading — not full-screen spinners
- Use `ContentUnavailableView` for empty states (Apple's built-in)
- Use `.refreshable { }` for pull-to-refresh
- Use `.task { }` for initial data load
- Use `.task(id: value)` for reactive reloads when a dependency changes
```

**Step 2: Add feature manager creation rules to the Patterns section**

In the existing `### Adding a Feature` pattern (line 67), add a new step between scaffolding and navigation wiring:

```markdown
### Adding a Feature Manager

When a feature reads/writes domain data, create a manager BEFORE the ViewModel:

1. Create protocol: `{App}/Managers/{Feature}/{Feature}Manager.swift`
2. Create mock: `{App}/Managers/{Feature}/Mock{Feature}Manager.swift`
3. Register in `AppServices` — add protocol property and mock initializer
4. ViewModel accesses via `services.{feature}Manager`

```swift
// {App}/Managers/Habits/HabitManager.swift
protocol HabitManagerProtocol: Sendable {
    func fetchAll() async throws -> [Habit]
    func create(_ habit: Habit) async throws
    func update(_ habit: Habit) async throws
    func delete(_ id: String) async throws
}

// {App}/Managers/Habits/MockHabitManager.swift
final class MockHabitManager: HabitManagerProtocol, @unchecked Sendable {
    // SAFETY: Only mutated from @MainActor callers via async methods
    private var habits: [Habit] = Habit.mockList

    func fetchAll() async throws -> [Habit] { habits }
    func create(_ habit: Habit) async throws { habits.append(habit) }
    func update(_ habit: Habit) async throws {
        if let i = habits.firstIndex(where: { $0.id == habit.id }) { habits[i] = habit }
    }
    func delete(_ id: String) async throws {
        habits.removeAll { $0.id == id }
    }
}
```

**Which screens get managers:**
- Screens that list/create/edit/delete domain objects → YES
- Settings, About, Onboarding, Paywall → NO (static content)
- Dashboard aggregating from existing managers → uses existing managers, no new one

**Mock data rules:**
- List screens: 5-8 items with realistic, varied content
- Include edge cases: long strings, zero values, past/future dates
- Add static `mockList` and `mockSingle` to the Model for easy access
```

**Step 3: Verify AGENTS.md is valid markdown**

Read the file back and confirm the new sections are properly formatted and don't break existing content.

**Step 4: Commit**

```bash
git add AGENTS.md
git commit -m "feat: add state management tiers, LoadPhase docs, feature manager pattern to AGENTS.md"
```

---

### Task 3: Update forge-builder agent — add manager creation and state tier selection

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md`

**Step 1: Add a new Step 3b between Step 3 (Scaffold) and Step 4 (Build)**

Insert after the existing Step 3 (Scaffold):

```markdown
### Step 3b: Create feature manager (if this screen has domain data)

Determine if this screen reads/writes domain data (habits, transactions, posts, etc.):
- Does the blueprint describe this screen listing, creating, editing, or deleting objects? → YES
- Is this Settings, About, Onboarding, or Paywall? → NO (skip to Step 4)
- Is this a detail view that receives data from a parent? → NO (data already loaded)

If YES, create a feature manager following AGENTS.md "Adding a Feature Manager":

1. **Create protocol** at `{App}/Managers/{Feature}/{Feature}Manager.swift`
   - CRUD methods matching this screen's needs (don't add methods you won't use)
   - Conform to `Sendable`

2. **Create mock implementation** at `{App}/Managers/{Feature}/Mock{Feature}Manager.swift`
   - In-memory array with realistic mock data (5-8 items for lists)
   - Include edge cases: one very long name, one with empty optional fields, varied dates
   - Add `static let mockList: [Model]` and `static let mockSingle: Model` to the Model file

3. **Register in AppServices**
   - Add `let {feature}Manager: any {Feature}ManagerProtocol` to AppServices
   - Initialize with `Mock{Feature}Manager()` in the mock initializer

4. **Report:** List the manager protocol, mock, and AppServices registration in your output.
```

**Step 2: Update Step 4 (Build) to use state tiers and managers**

Find the existing Step 4 section and add at the beginning, before the current build instructions:

```markdown
**Determine the ViewModel tier** (see AGENTS.md "ViewModel State Tiers"):
- If you created a manager in Step 3b that calls an API → Tier 2 (LoadPhase + separate data)
- If you created a manager in Step 3b that's local-only → Tier 1 (properties, no LoadPhase)
- If no manager (static screen) → Tier 3 (plain properties)

**Wire the manager to the ViewModel:**
- Store `services` reference from `onAppear(services:session:)`
- Call manager methods via `services.{feature}Manager`
- Never hardcode mock data arrays in the ViewModel — always go through the manager

**Implement appropriate states:**
- Check the feature spec (`.forge/feature-specs/{screen_name}.md`) for defined states
- If no feature spec, use AGENTS.md "Default tier by screen type" table
- Tier 2 screens MUST implement: `.task { }` for initial load, `.refreshable { }` for refresh,
  loading overlay, error overlay (use `ErrorStateView` or error banner), empty state overlay
  (use `ContentUnavailableView` with voice-guide copy)
- Tier 1 screens MUST implement: empty state (use `ContentUnavailableView`)
- Tier 3 screens: no state management needed
```

**Step 3: Update the REQUIRED OUTPUT FORMAT**

Add after the existing output items:

```markdown
   7. MANAGER CREATED: [protocol name + mock name, or "N/A — static screen"]
   8. STATE TIER: [Tier 1/2/3 — with justification]
   9. STATES IMPLEMENTED: [list: populated, empty, loading, error, refreshing — which ones]
```

**Step 4: Sync to cache**

```bash
cp ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md \
   ~/.claude/plugins/cache/forge-marketplace/forge-feature/1.0.0/agents/forge-builder.md
```

**Step 5: Commit marketplace**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-builder.md
git commit -m "feat: forge-builder creates feature managers, uses state tiers"
```

---

### Task 4: Update forge-app orchestrator — Build Agent prompt with data layer instructions

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**Step 1: Update the Build Agent Task prompt (around line 663)**

Find the Build Agent prompt that starts with `Task(subagent_type: "general-purpose", description: "Build {screen_name} screen")`.

In the instruction body, after the line about reading `.forge/` files and before `Follow AGENTS.md MVVM conventions`, add:

```markdown
   FEATURE MANAGER — Before implementing the ViewModel:
   Determine if this screen reads/writes domain data. If yes:
   1. Create manager protocol at {AppName}/Managers/{Feature}/{Feature}Manager.swift
   2. Create MockManager with 5-8 realistic items (see AGENTS.md "Adding a Feature Manager")
   3. Register in AppServices
   4. ViewModel calls services.{feature}Manager — NEVER hardcode mock arrays in ViewModel

   STATE MANAGEMENT — Choose the ViewModel tier (see AGENTS.md "ViewModel State Tiers"):
   - API data → Tier 2: use LoadPhase enum, implement .task/.refreshable/overlays
   - Local data → Tier 1: direct properties, implement empty state
   - Static screen → Tier 3: plain properties, no state management
   If a feature spec exists for this screen, it defines which states to implement.
   If no feature spec, use the default tier table in AGENTS.md.
```

**Step 2: Update the Build Agent REQUIRED OUTPUT FORMAT**

Add to the existing output format list:

```markdown
   7. MANAGER CREATED: [protocol + mock names, or "N/A"]
   8. STATE TIER: [1/2/3]
   9. STATES IMPLEMENTED: [populated/empty/loading/error/refreshing — which ones]
```

**Step 3: Update the Orchestrator verification after Build Agent**

In the section "Orchestrator verification after Build Agent completes", add:

```markdown
- Does MANAGER CREATED list a protocol and mock? (Skip check for static screens like Settings/About)
- Does STATE TIER match the screen type? (Tier 2 for API screens, Tier 1 for local data, Tier 3 for static)
- Does STATES IMPLEMENTED include at least "populated" and "empty" for data screens?
```

**Step 4: Update the Polish Agent REQUIRED OUTPUT FORMAT**

Add to the existing polish output format:

```markdown
   12. LOADING/ERROR UX: [For Tier 2 screens: does the loading state use skeleton/redacted instead of full-screen spinner? Does error show a banner/toast, not replace content?]
```

**Step 5: Sync to cache**

```bash
cp ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md \
   ~/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app/SKILL.md
```

**Step 6: Commit marketplace**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: forge-app Build Agent creates managers, selects state tiers"
```

---

### Task 5: Update forge-app Step 5 (Data Models) to include mock data helpers

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**Step 1: Update the Step 5 Data Models Task prompt**

Find the existing Step 5 Data Models section. Update the Task prompt to include mock data generation:

```markdown
   Create Swift model files at {AppName}/Models/ for each model in the blueprint.
   Rules:
   - Conform to StringIdentifiable, Codable, Sendable
   - Use snake_case for CodingKeys raw values
   - Include id: String as first field, createdAt: Date as last
   - Create enums in the same file if the model has enum fields
   - Add static mock data helpers for each model:
     ```swift
     extension Habit {
         static let mockSingle = Habit(id: "1", name: "Morning Run", ...)
         static let mockList: [Habit] = [
             Habit(id: "1", name: "Morning Run", ...),
             Habit(id: "2", name: "Read for 30 minutes", ...),
             // 5-8 items with varied content, realistic data
             // Include: one long name, one with nil optional fields, varied dates
         ]
     }
     ```
   This mock data is consumed by MockManagers in Step 6.
```

**Step 2: Sync to cache**

```bash
cp ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md \
   ~/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app/SKILL.md
```

**Step 3: Commit marketplace**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: Step 5 Data Models generates static mock data helpers"
```

---

### Task 6: Verify the full pipeline integration

**Step 1: Read all modified files and verify cross-references**

Verify that:
- AGENTS.md references `LoadPhase` (which exists at `Forge/Utilities/LoadPhase.swift`)
- forge-builder references AGENTS.md sections by name ("ViewModel State Tiers", "Adding a Feature Manager")
- forge-app Build Agent prompt references the same section names
- Output format items are numbered consistently (no duplicate numbers)
- forge-app polish output includes the new loading/error UX check

**Step 2: Verify AGENTS.md, forge-builder, and forge-app are internally consistent**

Check:
- Manager pattern description matches in all three files
- State tier definitions match in all three files
- Default tier table matches in AGENTS.md and forge-builder

**Step 3: Run `/forge-publish` to sync and push both repos**

```bash
/forge-publish
```

This syncs marketplace → cache, commits both repos, and pushes.

---

### Task 7: Update MEMORY.md and design doc status

**Files:**
- Modify: `~/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md`
- Modify: `docs/plans/2026-03-02-pipeline-quality-upgrade-design.md`

**Step 1: Update MEMORY.md**

Add to the Pipeline Enforcement section:

```markdown
- **Phase 1 Functional Core (2026-03-02)** — builders create backend-agnostic feature managers (protocol + mock), use 3-tier ViewModel state management (local/API/static), implement LoadPhase for async screens. Template has LoadPhase.swift utility. Mock data helpers on Models via static properties.
```

**Step 2: Mark Phase 1 as implemented in the design doc**

Add at the top of the design doc:

```markdown
## Status
- [x] Phase 1: Functional Core — implemented 2026-03-02
- [ ] Phase 2: Robustness
- [ ] Phase 3: App Store Pipeline
- [ ] Phase 4: Speed & Quality
```

**Step 3: Commit**

```bash
git add docs/plans/2026-03-02-pipeline-quality-upgrade-design.md
git commit -m "docs: mark Phase 1 as implemented, update memory"
```
