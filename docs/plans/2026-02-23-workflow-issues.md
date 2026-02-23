# Forge Workflow Issues & Improvements Log

**Date:** 2026-02-23
**Purpose:** Track issues encountered during real app building (Ledgr) to optimize the pipeline later.

---

## Issues Found

### 1. Manual copy instead of CLI tool
**When:** First attempt to create Ledgr project
**What happened:** Claude used `cp -R` to copy the template instead of `scripts/new-app.sh`
**Root cause:** forge-app SKILL.md didn't handle the "invoked from template repo" scenario
**Fix applied:** Updated forge-app SKILL.md prerequisites, added `<IMPORTANT>` warnings to AGENTS.md, README.md, getting-started.md, marketplace README
**Status:** Fixed

### 2. rename_project.sh bug — scheme rename fails
**When:** Running `scripts/new-app.sh` and `rename_project.sh` for Ledgr
**What happened:** Step 1 (content update) replaces "Forge" with "Ledgr" in pbxproj, but Step 2 tries to `mv` scheme files using the old `Forge.xcodeproj` path. The xcodeproj directory hasn't been renamed yet at that point, so `mv` fails with "No such file or directory."
**Root cause:** The script renames file contents before renaming directories. Step 2 should use the OLD directory path since it hasn't been renamed yet, but the scheme filenames inside have already been updated by Step 1.
**Fix applied:** Manual directory/file renames after script failure. Script needs a proper fix.
**Status:** OPEN — needs fix in rename_project.sh

### 3. ForgeApp.swift filename not renamed
**When:** After rename_project.sh completed
**What happened:** File contents were updated (references to LedgrApp) but the filename itself stayed as ForgeApp.swift
**Root cause:** rename_project.sh doesn't rename individual Swift files, only directories and xcodeproj-related files
**Fix applied:** Manual `mv ForgeApp.swift LedgrApp.swift`
**Status:** OPEN — needs fix in rename_project.sh

### 4. forge-app blueprint doesn't specify brand color implementation
**When:** Blueprint approved, dashboard built
**What happened:** Blueprint says "Muted sapphire (#3D5A80)" but the brand color was never applied. Dashboard still shows template purple.
**Root cause:** forge-app execution engine has no step to update `AdaptiveTheme(brandColor:)` or pass brand color to forge-workspace
**Fix needed:** forge-app must configure the brand color during workspace setup or as a dedicated step
**Status:** OPEN

### 5. forge-feature skill was never actually invoked
**When:** Building Dashboard screen
**What happened:** Instead of invoking `/forge:feature` which would chain forge-screens → build → swiftui-craft → verify, a raw general-purpose subagent was dispatched with "build this screen." The subagent implemented everything directly without following the forge-feature pipeline.
**Root cause:** The orchestration layer (forge-app → forge-feature → forge-screens → swiftui-craft) was designed in SKILL.md files but treated as documentation rather than executable steps. Subagents don't invoke skills — they just code.
**Impact:** swiftui-craft never ran (no design polish, no soul dimension, no web research for inspiration). forge-screens never ran (no architecture-correct scaffolding). The quality pipeline was entirely bypassed.
**Fix needed:** forge-app must invoke forge-feature AS A SKILL (not dispatch a raw subagent). This likely means the orchestrator must follow the skill chain itself rather than delegating to subagents.
**Status:** CRITICAL — this defeats the entire pipeline purpose

### 6. No way to navigate directly to a specific screen for visual verification
**When:** Trying to screenshot the Dashboard
**What happened:** Had to disable auth (FeatureFlags), then disable paywall (FeatureFlags), then set onboarding UserDefaults — 3 separate hacks just to see the Dashboard.
**Root cause:** The template's auth → onboarding → paywall → main app flow blocks access to screens during development
**Fix needed:** AI-accessible screen router — a debug mechanism that lets Claude (or a developer) jump directly to any screen for visual verification and design polish
**Potential approaches:**
  - Deep link scheme: `ledgr://screen/dashboard` that bypasses auth/onboarding/paywall
  - Debug launch argument: `SKIP_ALL_GATES` that goes straight to tabs
  - Xcode Preview-based verification instead of simulator
  - SwiftUI Preview snapshots for swiftui-craft to analyze
**Status:** OPEN — high priority for the polish workflow

### 7. UI looks identical to every other Forge app
**When:** Dashboard screenshot review
**What happened:** DSHeroCard, DSListRow, DSListCard all have the template's visual identity. The dashboard looks like "Forge with different data" not "a unique finance app."
**Root cause:** The design system components define specific visual styles (shadows, radii, spacing, typography). forge-workspace changes the brand color but doesn't rethink component aesthetics per-app. swiftui-craft (which was supposed to handle this) was never invoked.
**Fix needed:**
  1. swiftui-craft must run on every screen and actively customize component appearance for the app's domain and personality
  2. Consider whether forge-app should generate a custom theme layer per-app (not just brand color, but shadow styles, card treatments, typography scale choices)
  3. The soul dimension should drive visual personality: a finance app should look different from a habit tracker at the component level, not just the color level
**Status:** OPEN — fundamental to the product value proposition

### 8. Superpowers and Ralph Loop not used
**When:** Entire Dashboard build
**What happened:** superpowers:brainstorming was available but not invoked for creative direction. superpowers:requesting-code-review was available but not invoked for quality review. Ralph Loop was available but not offered for iterative UI refinement.
**Root cause:** Same as #5 — raw subagent dispatch bypassed all enhancement detection and integration
**Fix needed:** Same fix as #5 — follow the skill chain
**Status:** Blocked by #5

### 9. Old "Home" tab still exists alongside new Dashboard tab
**When:** Dashboard screenshot
**What happened:** Tab bar shows Dashboard, Home, Settings — the template's Home tab was not removed when Dashboard was added
**Root cause:** The subagent added a Dashboard tab but didn't remove or replace the Home tab
**Fix needed:** Remove the Home tab, make Dashboard the home tab
**Status:** OPEN — quick fix

---

## Systemic Issues

### A. Subagents cannot invoke skills
**Problem:** The Task tool dispatches general-purpose subagents that write code. They don't have access to the skill system — they can't invoke forge-feature, swiftui-craft, or any other skill. This means the entire orchestration layer (forge-app → forge-feature → forge-screens → swiftui-craft) breaks down when implemented via subagents.
**Impact:** The pipeline design is sound but unexecutable with the current approach.
**Possible solutions:**
  1. The orchestrator (this session) must invoke skills directly, not delegate to subagents
  2. Subagents receive skill content as context (paste the SKILL.md into the subagent prompt) so they follow the same process
  3. Accept that the orchestrator session is the only place skills chain, and manage context accordingly
  4. Build the skill logic into AGENTS.md so it's always available regardless of skill invocation

### B. No visual verification loop in the pipeline
**Problem:** The pipeline builds screens but has no built-in way to visually verify them. Taking screenshots requires bypassing auth/onboarding/paywall gates. swiftui-craft needs to SEE the screen to polish it.
**Impact:** Design polish is blind — swiftui-craft would refine code without seeing the result.
**Possible solutions:**
  1. Debug deep links for every screen
  2. SwiftUI Preview snapshots as verification artifacts
  3. A `SKIP_ALL_GATES` launch argument that goes straight to the tab bar
  4. XcodeBuildMCP UI automation (tap through gates automatically)

---

## Items to Revisit

- [ ] Fix rename_project.sh scheme rename ordering (Issue #2)
- [ ] Fix rename_project.sh to rename ForgeApp.swift → {AppName}App.swift (Issue #3)
- [ ] Fix new-app.sh which calls rename_project.sh and inherits the same bugs
- [ ] Implement brand color application in forge-app execution (Issue #4)
- [ ] Fix orchestration: invoke forge-feature as skill, not raw subagent (Issue #5) — CRITICAL
- [ ] Build AI screen router / debug deep links (Issue #6)
- [ ] Design system customization per-app beyond brand color (Issue #7)
- [ ] Remove Home tab, keep only Dashboard (Issue #9)
- [ ] Add post-rename verification step that checks all "Forge" references are gone
- [ ] Evaluate whether skill content should be embedded in AGENTS.md (Systemic A)
- [ ] Build visual verification into the pipeline (Systemic B)
