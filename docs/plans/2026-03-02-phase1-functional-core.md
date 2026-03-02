# Phase 1: Functional Core — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Forge pipeline output from "beautiful shell with mock arrays" to "functional app with backend-agnostic data layer, skeleton loading, and wired services."

**Architecture:** Stay MVVM. Update builder/orchestrator prompts to create feature managers and use skeleton loading with `.redacted`. No backend choice — mock implementations only, forge-wire swaps later.

**Tech Stack:** SwiftUI, Swift 6, @Observable, AppServices DI, Manager Pattern (protocol + Mock)

---

### Task 1: Update AGENTS.md — feature manager pattern and loading rules

**Files:**
- Modify: `AGENTS.md`

**Step 1: Add feature manager rules to the Patterns section**

After the existing `### Adding a Feature` pattern, add:

```markdown
### Adding a Feature Manager

When a feature reads/writes domain data, create a manager BEFORE the ViewModel:

1. Create protocol: `{App}/Managers/{Feature}/{Feature}Manager.swift`
2. Create mock: in the same file or `Mock{Feature}Manager.swift`
3. Register in `AppServices` — add protocol property and mock initializer
4. ViewModel accesses via `services.{feature}Manager`

```swift
// Protocol — backend-agnostic contract
protocol HabitManagerProtocol: Sendable {
    func fetchAll() async throws -> [Habit]
    func create(_ habit: Habit) async throws
    func update(_ habit: Habit) async throws
    func delete(_ id: String) async throws
}

// Mock — in-memory, works immediately
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
- Detail view receiving data from parent → NO (data already loaded)
```

**Step 2: Add loading and state rules to ViewModel Rules section**

After the existing ViewModel Rules, add:

```markdown
### Loading & States

**Skeleton loading (screens with data):**
ViewModels with loadable data initialize with placeholder items. The View renders
the same layout in both loading and loaded states — `.redacted(reason: .placeholder)`
toggles the skeleton appearance. No full-screen spinners.

```swift
// ViewModel
@Observable class HabitListViewModel {
    var habits: [Habit] = Habit.placeholders  // placeholder data for skeleton
    var isLoading = true
    var isEmpty: Bool { !isLoading && habits.isEmpty }

    func load(services: AppServices) async {
        do {
            habits = try await services.habitManager.fetchAll()
        } catch {
            toast = .error(error.localizedDescription)
        }
        isLoading = false
    }
}

// View
List(viewModel.habits) { habit in
    HabitRow(habit: habit)
}
.redacted(reason: viewModel.isLoading ? .placeholder : [])
.overlay { if viewModel.isEmpty { ContentUnavailableView("No habits", systemImage: "tray") } }
.refreshable { await viewModel.load(services: services) }
.task { await viewModel.load(services: services) }
```

**Empty states:** Use `ContentUnavailableView` with voice-guide copy.
**Errors:** Use `Toast.error()` — don't replace content with an error screen.
**Refresh:** `.refreshable { }` — existing content stays visible during refresh.
**Static screens** (Settings, About, Onboarding, Paywall): No loading, no states — just properties.

### Mock Data on Models

Every model used by a manager must have static placeholder and mock data:

```swift
extension Habit {
    static let placeholders: [Habit] = (0..<4).map {
        Habit(id: "\($0)", name: "Placeholder", streak: 0, createdAt: .now)
    }
    static let mockList: [Habit] = [
        Habit(id: "1", name: "Morning Run", streak: 12, createdAt: ...),
        Habit(id: "2", name: "Read for 30 minutes before bed", streak: 5, ...),
        // 5-8 items, varied content, realistic data
        // Include: one long name, one with nil optional fields, varied dates
    ]
    static let mockSingle: Habit = mockList[0]
}
```

`placeholders` — used for skeleton loading (same shape, dummy content).
`mockList` — used by MockManager (realistic data for development).
```

**Step 3: Commit**

```bash
git add AGENTS.md
git commit -m "feat: add feature manager pattern, skeleton loading, mock data rules to AGENTS.md"
```

---

### Task 2: Update forge-builder — manager creation and skeleton loading

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md`

**Step 1: Add Step 3b — Create feature manager**

Insert after Step 3 (Scaffold):

```markdown
### Step 3b: Create feature manager (if this screen has domain data)

Does the blueprint describe this screen listing, creating, editing, or deleting domain objects?
- YES → create a feature manager following AGENTS.md "Adding a Feature Manager"
- NO (Settings, About, Onboarding, Paywall, detail view receiving data) → skip to Step 4

If YES:
1. Create manager protocol at `{App}/Managers/{Feature}/{Feature}Manager.swift`
   - Only methods this screen actually needs (don't add unused CRUD methods)
   - Conform to `Sendable`
2. Create mock implementation in the same file
   - Uses `Model.mockList` for initial data (created in Step 5 Data Models)
3. Register in `AppServices` — add protocol property, initialize with mock
```

**Step 2: Update Step 4 (Build) — wire manager and implement skeleton loading**

Add at the beginning of Step 4:

```markdown
**Wire the manager** (if created in Step 3b):
- ViewModel calls `services.{feature}Manager` — NEVER hardcode mock arrays in ViewModel
- Initialize ViewModel data with `Model.placeholders` for skeleton loading
- Add `var isLoading = true` and set to `false` after first load completes

**Loading pattern** (screens with data):
- View renders the SAME list/content in both loading and loaded states
- Use `.redacted(reason: viewModel.isLoading ? .placeholder : [])` for skeleton shimmer
- Use `ContentUnavailableView` with voice-guide copy for empty state
- Use `Toast.error()` for errors — don't replace content
- Use `.refreshable { }` for pull-to-refresh
- Use `.task { }` for initial data load

**Static screens** (no manager): skip all loading/state logic — just render content.
```

**Step 3: Update REQUIRED OUTPUT FORMAT**

Add:

```markdown
   7. MANAGER CREATED: [protocol name + mock, or "N/A — static screen"]
   8. LOADING PATTERN: [skeleton/none — which approach and why]
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
git commit -m "feat: forge-builder creates feature managers, uses skeleton loading"
```

---

### Task 3: Update forge-app orchestrator — Build Agent prompt

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**Step 1: Update Build Agent Task prompt**

Find the Build Agent prompt (around line 663). After the `.forge/` reading instructions and before `Follow AGENTS.md MVVM conventions`, add:

```markdown
   FEATURE MANAGER — Before implementing the ViewModel:
   Does this screen list/create/edit/delete domain objects? If yes:
   1. Create manager protocol + mock at {AppName}/Managers/{Feature}/
   2. Register in AppServices
   3. ViewModel calls services.{feature}Manager — NEVER hardcode mock arrays
   If no (Settings, About, Onboarding, Paywall, detail receiving data): skip.

   LOADING — Screens with data use skeleton loading:
   - Initialize ViewModel data with Model.placeholders
   - View uses .redacted(reason: viewModel.isLoading ? .placeholder : [])
   - Empty state: ContentUnavailableView with voice-guide copy
   - Errors: Toast.error(), don't replace content
   - Static screens: no loading logic needed
```

**Step 2: Update Build Agent REQUIRED OUTPUT FORMAT**

Add:

```markdown
   7. MANAGER CREATED: [protocol + mock names, or "N/A"]
   8. LOADING PATTERN: [skeleton/none]
```

**Step 3: Update Orchestrator verification after Build Agent**

Add to verification checks:

```markdown
- Does MANAGER CREATED list a protocol and mock? (Skip for static screens)
- Does LOADING PATTERN say "skeleton" for data screens? If it says "none" for a list screen, flag it.
```

**Step 4: Update Polish Agent REQUIRED OUTPUT FORMAT**

Add:

```markdown
   12. LOADING UX: [Does loading use skeleton shimmer, not full-screen spinner? Does empty state use ContentUnavailableView?]
```

**Step 5: Sync to cache and commit marketplace**

```bash
cp ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md \
   ~/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app/SKILL.md

cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: forge-app Build Agent creates managers, skeleton loading"
```

---

### Task 4: Update forge-app Step 5 (Data Models) — mock + placeholder data

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**Step 1: Update Step 5 Data Models Task prompt**

Find existing Step 5. Add to the rules list:

```markdown
   - Add static mock and placeholder data for each model:
     ```swift
     extension Habit {
         /// Placeholder items for skeleton loading — same shape, dummy content
         static let placeholders: [Habit] = (0..<4).map {
             Habit(id: "\($0)", name: "Placeholder", streak: 0, createdAt: .now)
         }
         /// Realistic mock data for MockManagers in Step 6
         static let mockList: [Habit] = [
             Habit(id: "1", name: "Morning Run", streak: 12, ...),
             Habit(id: "2", name: "Read for 30 minutes before bed", streak: 5, ...),
             // 5-8 items with varied content
             // Include: one long name, one with nil optional fields, varied dates
         ]
         static let mockSingle: Habit = mockList[0]
     }
     ```
   Placeholders are consumed by ViewModels for skeleton loading.
   mockList is consumed by MockManagers for development data.
```

**Step 2: Sync to cache and commit marketplace**

```bash
cp ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md \
   ~/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app/SKILL.md

cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: Step 5 Data Models generates placeholders + mock data"
```

---

### Task 5: Verify cross-references and publish

**Step 1: Verify all files reference the same patterns**

Read all modified files and check:
- AGENTS.md "Adding a Feature Manager" matches what forge-builder Step 3b describes
- AGENTS.md "Loading & States" matches what forge-builder Step 4 describes
- forge-app Build Agent prompt matches forge-builder instructions
- Output format numbering is consistent (no duplicates, no gaps)
- Polish Agent checks skeleton loading, not spinner

**Step 2: Run `/forge-publish`**

Syncs marketplace → cache, commits both repos, pushes both.

---

### Task 6: Update MEMORY.md and design doc

**Files:**
- Modify: `~/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md`
- Modify: `docs/plans/2026-03-02-pipeline-quality-upgrade-design.md`

**Step 1: Update MEMORY.md**

Add to Pipeline Enforcement section:

```markdown
- **Phase 1 Functional Core (2026-03-02)** — builders create backend-agnostic feature managers (protocol + mock), use skeleton loading (.redacted + placeholders) instead of spinners, ContentUnavailableView for empty states, Toast for errors. Models have static placeholders + mockList. No LoadPhase enum — just isLoading bool + data array.
```

**Step 2: Add status tracker to design doc**

Insert after the title:

```markdown
## Status
- [x] Phase 1: Functional Core — implemented 2026-03-02
- [ ] Phase 2: Robustness
- [ ] Phase 3: App Store Pipeline
- [ ] Phase 4: Speed & Quality
```

**Step 3: Commit forge repo**

```bash
git add docs/plans/2026-03-02-pipeline-quality-upgrade-design.md
git commit -m "docs: mark Phase 1 as implemented, update memory"
```
