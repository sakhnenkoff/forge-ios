# Pipeline Quality Fix — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add mechanical floor enforcement and upstream structural constraints to prevent agents from producing screens worse than the template.

**Architecture:** Two-layer defense — upstream fixes (spec fields, contradiction removal, published check list) make good output more likely; post-build floor checks make bad output impossible to ship.

**Tech Stack:** Markdown skill/agent files, grep-based code checks in bash.

---

## Task 1: Add Post-Build Floor Checks to forge-craft-agent.md

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md` (insert after line 183, before Step 9)

**Step 1: Read the current file**

Read `forge-craft-agent.md`. Confirm Step 8b ends at line 183 and Step 9 starts at line 185.

**Step 2: Insert Step 8c**

After Step 8b (Generate ViewModel tests), before Step 9 (Return proof), insert the new Step 8c. Use the Edit tool to add after the line `Skip for static screens.` (end of Step 8b):

```markdown
### Step 8c: Floor checks

Run grep-based checks against every `.swift` file you created or modified in this screen.
Collect the list of files from your work in Steps 3-4 (View, ViewModel, Manager, Model).

**Layer 1 — Architecture (every screen, hard gate):**

Check the VIEW file for:
- `DSScreen` present (required — root container)
- `.toast(` present (required — toast modifier)
- `.onAppear` present (required — lifecycle hook)
- `AppServices.self` present (required — DI injection)
- `AsyncImage` absent (violation — use ImageLoaderView)
- `@StateObject` absent (violation — use @State)

Check the VIEWMODEL file for:
- `@Observable` present (required — not ObservableObject)
- `hasLoaded` present (required — load guard)
- `LoggableEvent` present (required — analytics events)
- `var toast: Toast?` present (required — toast property)

**Layer 2 — Data patterns (only if you created a manager in Step 3b):**

Check the MANAGER file for:
- Protocol definition exists (required)
- `Mock` implementation exists (required)

Check the MODEL file for:
- `static let placeholders` or `static var placeholders` present (required)
- `static let mockList` or `static var mockList` present (required)
- `StringIdentifiable` present (required — conformance)

Check the VIEW file for:
- `.redacted(reason:` present (required — skeleton loading)
- `ContentUnavailableView` present (required — empty state)

Check the VIEWMODEL file for:
- `toast = .error` or `Toast.error` present (required — error handling)

**Layer 3 — Component quality (every screen, warnings):**

Check ALL created `.swift` files for:
- `Font.system(size:` absent (violation — use DS typography tokens)
- `Color(red:` or `Color(#` or `Color(.sRGB` absent (violation — use semantic colors)

**How to run checks:**

For each check, grep the file. Example:
```bash
# Required pattern — must be present
grep -q 'DSScreen' {view_file} || echo "FLOOR VIOLATION: Missing DSScreen root container. Wrap view body in DSScreen(title:)."

# Violation pattern — must be absent
grep -q 'AsyncImage' {view_file} && echo "FLOOR VIOLATION: AsyncImage found. Replace with ImageLoaderView."
```

Collect all violations into a list. If any Layer 1 violations exist:
1. Fix each violation following the fix instruction
2. Rebuild: `xcodebuildmcp simulator build-sim --scheme "{scheme}" --project-path {project_path} --simulator-id {sim_id}`
3. Re-run floor checks
4. Max 2 fix rounds. After 2 rounds, report remaining violations in Step 9 output.

Layer 2 violations follow the same fix-rebuild-recheck cycle.
Layer 3 violations: fix if possible, report in output if not.
```

**Step 3: Update Step 1 (Read project context) to include Post-Build Checks**

In Step 1, the agent reads specific AGENTS.md sections. Add "Post-Build Checks" to the read list. Find the line:

```
Read AGENTS.md — ONLY these sections: "Critical Rules", "ViewModel Rules", "Loading & States",
"Patterns" (Adding a Feature, Adding a Feature Manager), "DS Component Reference", "Navigation Patterns".
```

Change to:

```
Read AGENTS.md — ONLY these sections: "ViewModel Rules", "Loading & States",
"Patterns" (Adding a Feature, Adding a Feature Manager), "DS Component Reference", "Post-Build Checks".
```

(Removed "Critical Rules" which doesn't exist in current AGENTS.md, removed "Navigation Patterns" which is just a reference, added "Post-Build Checks" which is the new section from Task 2.)

**Step 4: Verify the edit**

Read `forge-craft-agent.md` and confirm:
- Step 8c appears between Step 8b and Step 9
- Step 1 references "Post-Build Checks"
- No other steps were disrupted

**Step 5: Sync plugin caches**

```bash
# Copy marketplace to version cache
rsync -av --delete ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/ ~/.claude/plugins/cache/forge-marketplace/forge-feature/
```

Wait — the cache path may differ. Check what exists first:

```bash
ls ~/.claude/plugins/cache/ | head -20
find ~/.claude/plugins/cache/ -name "forge-craft-agent.md" -type f 2>/dev/null
```

Sync to wherever the cache copy lives. Both marketplace and cache must match.

**Step 6: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md
git commit -m "feat(forge-craft-agent): add Step 8c post-build floor checks

Three-layer grep-based verification: architecture (hard gate),
data patterns (when manager exists), component quality (warnings).
Max 2 fix rounds before reporting violations."
```

---

## Task 2: Add Post-Build Checks Section to AGENTS.md

**Files:**
- Modify: `/Users/matvii/Documents/Developer/Templates/forge/AGENTS.md` (insert between "Craft Patterns" section ending at line 328 and "Design System Override Priority" section starting at line 331)

**Step 1: Read the insertion point**

Read AGENTS.md lines 318-340 to confirm exact insertion point. The new section goes after the `---` on line 329 and before `## Design System Override Priority` on line 331.

**Step 2: Insert the Post-Build Checks section**

Use Edit to replace the `---` between Craft Patterns and Design System Override Priority (around line 329-330) with the new section:

```markdown
---

## Post-Build Checks

After building a screen, code is scanned for these patterns. Violations require fixes before the screen is accepted.

**Architecture (hard gate — every screen):**
- View MUST contain: `DSScreen`, `.toast(`, `.onAppear`, `AppServices.self`
- View MUST NOT contain: `AsyncImage`, `@StateObject`
- ViewModel MUST contain: `@Observable`, `hasLoaded`, `LoggableEvent`, `var toast: Toast?`

**Data patterns (screens with a feature manager):**
- Manager file MUST contain: protocol definition, `Mock` implementation
- Model MUST contain: `static let placeholders`, `static let mockList`, `StringIdentifiable`
- View MUST contain: `.redacted(reason:`, `ContentUnavailableView`
- ViewModel MUST contain: `toast = .error` or `Toast.error`

**Component quality (warnings):**
- No `Font.system(size:` — use DS typography (`.display()`, `.titleLarge()`, `.bodyMedium()`, etc.)
- No `Color(red:` / `Color(#` / `Color(.sRGB` — use semantic colors (`.themePrimary`, `.textPrimary`, etc.)

---
```

**Step 3: Verify**

Read AGENTS.md and confirm:
- New section appears between Craft Patterns and Design System Override Priority
- No duplicate `---` separators
- Line count increased by ~15

**Step 4: Commit**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git add AGENTS.md
git commit -m "docs(AGENTS.md): add Post-Build Checks section

Publishes the floor check list so agents know what will be verified.
Transparency about consequences, not more rules."
```

---

## Task 3: Add Implementation Contract to forge-ux Spec Template

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-ux/skills/forge-ux/SKILL.md` (two locations: the spec format template and the completeness verification)

**Step 1: Read the insertion points**

Read forge-ux SKILL.md lines 178-257 to confirm the spec template and completeness check locations.

**Step 2: Add Implementation Contract to the spec format template**

Find the section in the markdown code block that shows the spec format (around line 225-227). After `### Open questions` and before the closing triple backticks, insert:

```markdown

### Implementation contract
- DS components: [list DS components this screen will use, e.g., DSButton, DSCard, DSListRow, DSSection, DSHeroCard]
- Patterns: [list from: skeleton_loading, floating_cta, staggered_entrance, hero_stat, empty_state, error_toast]
- Data source: [manager:{ManagerName} | static | parent_injection]
- Screen type: [dashboard | list | detail | form | onboarding | settings | paywall]
```

**Step 3: Add Implementation Contract to completeness verification**

Find the completeness verification list (around lines 240-248). After item 5 (`"Screens affected"`), add:

```markdown
6. **"Implementation contract"** — lists at least 2 DS components, at least 1 pattern, specifies data source and screen type
```

Also update the existing item 6 ("File saved check") to become item 7.

**Step 4: Verify**

Read the modified section back and confirm:
- Implementation contract appears in the spec template between "Open questions" and the closing backticks
- Completeness verification now has 7 items
- No formatting issues

**Step 5: Sync plugin caches**

Same pattern as Task 1 Step 5 — sync forge-ux from marketplace to cache.

```bash
find ~/.claude/plugins/cache/ -name "forge-ux" -type d 2>/dev/null
# Then rsync marketplace → cache for forge-ux
```

**Step 6: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-ux/skills/forge-ux/SKILL.md
git commit -m "feat(forge-ux): add Implementation Contract to spec template

Structured fields (DS components, patterns, data source, screen type)
bound spec ambition and give build agents a concrete checklist.
Completeness verification now requires the contract section."
```

---

## Task 4: Add DS Code Sketch Instruction to forge-craft SKILL.md

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md` (near the Screen Blueprints section, around line 615-666)

**Step 1: Read the target area**

Read forge-craft SKILL.md lines 610-670 to see the Screen Blueprints section and the instruction about code sketches.

**Step 2: Add the DS-only instruction**

Find the line that says (around line 665-666):

```
   The sketch shows WHERE to use DS components (DSSection, DSListRow) and where to
   COMPOSE from DS tokens (hero, stats). Every value references a DS token — no
   hardcoded numbers, no raw colors, no custom fonts outside the DS scale.
```

After this paragraph, insert:

```markdown

   **DS enforcement in code sketches:** Code sketches are the primary input Build Agents
   copy. Every code sketch MUST use DS components and tokens exclusively — never
   `Font.system(size:)`, `LinearGradient` for backgrounds, raw `Button(`, or hardcoded
   `Color(`. Use `.display()`, `.titleLarge()`, `AmbientBackground`, `DSButton`, and
   semantic colors. Build Agents' post-build checks will reject code that violates these
   patterns — if the sketch violates them, the agent is set up to fail.
```

**Step 3: Fix the example code sketch contradiction**

The example code sketch at lines 630-661 uses `Font.system(size: 48, weight: .ultraLight, design: .monospaced)` on line 638. This contradicts the DS-only instruction. Change line 638 from:

```swift
               .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
```

to:

```swift
               .font(.display()).monospacedDigit()
```

This uses the DS typography token `.display()` (34pt bold rounded) instead of a hardcoded font. The `.monospacedDigit()` modifier is a standard SwiftUI modifier, not a hardcoded value.

Note: The exact typography choice depends on the mood — the agent writing the design-system.md can define a custom token in the Design Synthesis if the DS default doesn't fit. But the CODE SKETCH should use the DS token, not a raw font.

**Step 4: Verify**

Read the modified section and confirm:
- DS enforcement instruction appears after the "no hardcoded numbers" paragraph
- Example code sketch uses `.display()` instead of `Font.system(size: 48)`
- No other parts of the SKILL.md were affected

**Step 5: Sync plugin caches**

```bash
find ~/.claude/plugins/cache/ -name "forge-craft" -type d 2>/dev/null
# Sync marketplace → cache for forge-craft
```

**Step 6: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md
git commit -m "fix(forge-craft): enforce DS tokens in code sketches, fix example contradiction

Add explicit instruction that code sketches must use DS components/tokens.
Fix example sketch that used Font.system(size:) — now uses .display().
Build agents copy sketches verbatim; contradictions set them up to fail."
```

---

## Task 5: Final Verification + Publish

**Files:**
- Read: all 4 modified files
- Run: `/forge-publish` to sync marketplace, cache, commit, and push both repos

**Step 1: Read all modified files and verify changes**

Read each file and confirm changes are present:
1. `forge-craft-agent.md` — Step 8c exists, Step 1 references "Post-Build Checks"
2. `AGENTS.md` — Post-Build Checks section exists between Craft Patterns and Design System Override Priority
3. `forge-ux/SKILL.md` — Implementation contract in spec template, completeness check item 6
4. `forge-craft/SKILL.md` — DS enforcement instruction, fixed example code sketch

**Step 2: Verify no regressions**

Spot-check that existing content in each file wasn't accidentally deleted or corrupted. Specifically:
- forge-craft-agent.md: Steps 1-8b and Step 9 unchanged
- AGENTS.md: All sections before and after the new section unchanged
- forge-ux SKILL.md: Sections 1-5 and 7-8 unchanged
- forge-craft SKILL.md: All sections outside the Screen Blueprints area unchanged

**Step 3: Publish**

Run `/forge-publish` to:
- Sync marketplace to cache
- Commit all plugin changes
- Push both the forge template repo and the marketplace repo

If `/forge-publish` is not available, manually:
```bash
# Forge template repo
cd /Users/matvii/Documents/Developer/Templates/forge
git push

# Marketplace repo
cd ~/.claude/plugins/marketplaces/forge-marketplace
git push

# Sync cache
rsync -av --delete ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/ ~/.claude/plugins/cache/forge-marketplace/
```

**Step 4: Update memory**

Update `/Users/matvii/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md` to note:
- Pipeline quality fix implemented (2026-03-03)
- Post-build floor checks in forge-craft-agent Step 8c (3 layers: architecture, data patterns, component quality)
- Post-Build Checks section published in AGENTS.md
- Implementation contract added to forge-ux spec template
- DS code sketch contradiction fixed in forge-craft
