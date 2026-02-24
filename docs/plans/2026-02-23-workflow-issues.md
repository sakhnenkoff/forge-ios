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
**Status:** RESOLVED — Verified script logic is correct: Step 2 uses `${OLD_NAME}.xcodeproj` path (xcodeproj not renamed until Step 5), Step 1 only changes file contents not filenames. Original report was from a partial/failed run.

### 3. ForgeApp.swift filename not renamed
**When:** After rename_project.sh completed
**What happened:** File contents were updated (references to LedgrApp) but the filename itself stayed as ForgeApp.swift
**Root cause:** rename_project.sh doesn't rename individual Swift files, only directories and xcodeproj-related files
**Fix applied:** Manual `mv ForgeApp.swift LedgrApp.swift`
**Status:** RESOLVED — Verified Step 3's `find . -type f -name "*Forge*"` catches ForgeApp.swift. Original report was from same partial run as #2.

### 4. forge-app blueprint doesn't specify brand color implementation
**When:** Blueprint approved, dashboard built
**What happened:** Blueprint says "Muted sapphire (#3D5A80)" but the brand color was never applied. Dashboard still shows template purple.
**Root cause:** forge-app execution engine has no step to update `AdaptiveTheme(brandColor:)` or pass brand color to forge-workspace
**Fix needed:** forge-app must configure the brand color during workspace setup or as a dedicated step
**Status:** RESOLVED — forge-workspace already has Step 2 (Edit AppDelegate) that changes `AdaptiveTheme()` to `AdaptiveTheme(brandColor: .{color})`. The Ledgr issue was that forge-workspace was never invoked (#5). Added comment to AppDelegate.swift making the brand color location obvious.

### 5. forge-feature skill was never actually invoked
**When:** Building Dashboard screen
**What happened:** Instead of invoking `/forge:feature` which would chain forge-screens → build → swiftui-craft → verify, a raw general-purpose subagent was dispatched with "build this screen." The subagent implemented everything directly without following the forge-feature pipeline.
**Root cause:** The orchestration layer (forge-app → forge-feature → forge-screens → swiftui-craft) was designed in SKILL.md files but treated as documentation rather than executable steps. Subagents don't invoke skills — they just code.
**Impact:** swiftui-craft never ran (no design polish, no soul dimension, no web research for inspiration). forge-screens never ran (no architecture-correct scaffolding). The quality pipeline was entirely bypassed.
**Fix needed:** forge-app must invoke forge-feature AS A SKILL (not dispatch a raw subagent). This likely means the orchestrator must follow the skill chain itself rather than delegating to subagents.
**Status:** RESOLVED — Platform limitation (Task subagents can't invoke skills). Solved by: forge-builder and forge-polisher agents now have `skills:` in frontmatter, loading forge-craft and forge-eye directly. Agents moved from ~/.claude/agents/ to forge-marketplace for distribution.

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
**Status:** RESOLVED — SKIP_ALL_GATES already implemented in template. forge-eye uses it with `launch-app-sim --json '{"args": ["SKIP_ALL_GATES"]}'`. forge-eye Navigate Protocol uses `snapshot-ui` + `tap` to reach specific screens.

### 7. UI looks identical to every other Forge app
**When:** Dashboard screenshot review
**What happened:** DSHeroCard, DSListRow, DSListCard all have the template's visual identity. The dashboard looks like "Forge with different data" not "a unique finance app."
**Root cause:** The design system components define specific visual styles (shadows, radii, spacing, typography). forge-workspace changes the brand color but doesn't rethink component aesthetics per-app. swiftui-craft (which was supposed to handle this) was never invoked.
**Fix needed:**
  1. swiftui-craft must run on every screen and actively customize component appearance for the app's domain and personality
  2. Consider whether forge-app should generate a custom theme layer per-app (not just brand color, but shadow styles, card treatments, typography scale choices)
  3. The soul dimension should drive visual personality: a finance app should look different from a habit tracker at the component level, not just the color level
**Status:** RESOLVED — Addressed at three levels: (1) forge-craft v1.3.0 mood-driven approach ensures each app gets design decisions tailored to its mood, not the template's defaults. (2) forge-app Step 1.5 "Template or Custom" decision point lets developers retheme DS tokens before building screens. (3) forge-eye visual iteration loop catches template sameness visually.

### 8. Superpowers and Ralph Loop not used
**When:** Entire Dashboard build
**What happened:** superpowers:brainstorming was available but not invoked for creative direction. superpowers:requesting-code-review was available but not invoked for quality review. Ralph Loop was available but not offered for iterative UI refinement.
**Root cause:** Same as #5 — raw subagent dispatch bypassed all enhancement detection and integration
**Fix needed:** Same fix as #5 — follow the skill chain
**Status:** RESOLVED (same as #5) — Agents now load skills via frontmatter. Enhancement detection documented in forge-feature SKILL.md.

### 9. Old "Home" tab still exists alongside new Dashboard tab
**When:** Dashboard screenshot
**What happened:** Tab bar shows Dashboard, Home, Settings — the template's Home tab was not removed when Dashboard was added
**Root cause:** The subagent added a Dashboard tab but didn't remove or replace the Home tab
**Fix needed:** Remove the Home tab, make Dashboard the home tab
**Status:** RESOLVED — This is per-project logic handled by forge-app's Step 3 (screen execution). When a blueprint specifies a Dashboard tab as "Tab: Home", forge-feature replaces the existing Home tab. The Ledgr issue was that the skill chain wasn't invoked (#5).

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
**Status:** RESOLVED — Solved via option 2: forge-builder and forge-polisher agents use `skills:` frontmatter to load forge-craft and forge-eye directly. Agents moved from ~/.claude/agents/ to forge-marketplace for distribution.

### B. Design system needs "template vs custom" decision point
**Problem:** Every Forge app looks identical because DS components (DSHeroCard, DSListCard, DSListRow) have baked-in visual identity. Changing brand color doesn't change component aesthetics — shadows, radii, card styles, typography personality all stay the same. Users don't want their app to look like the template.
**Impact:** The product's value proposition is undermined — "premium unique app" becomes "purple template but blue."
**Solution:** Add a decision point in forge-app after workspace setup:
  1. Ask: "Template components or custom visual identity?"
  2. If template: proceed with DS components as-is (fast, good enough for MVPs)
  3. If custom: retheme DS token values (shadows, radii, surface tones, typography weights) AND build app-specific view components where needed, using DS tokens for spacing/color but with custom layouts
  4. The DS infrastructure stays (token system, DSScreen, DSButton API, .toast, .cardSurface) — only the visual expression changes
  5. swiftui-craft's research step should drive the custom component design — research real apps in the domain, then build components that match that aesthetic
**Status:** RESOLVED — forge-app Step 1.5 "Template or Custom" decision point added. Developer chooses template components (fast) or custom token retheme (shadows, radii, surfaces, typography matched to mood).

### C. No visual verification loop in the pipeline
**Problem:** The pipeline builds screens but has no built-in way to visually verify them. Taking screenshots requires bypassing auth/onboarding/paywall gates. swiftui-craft needs to SEE the screen to polish it.
**Impact:** Design polish is blind — swiftui-craft would refine code without seeing the result.
**Possible solutions:**
  1. Debug deep links for every screen
  2. SwiftUI Preview snapshots as verification artifacts
  3. A `SKIP_ALL_GATES` launch argument that goes straight to the tab bar
  4. XcodeBuildMCP UI automation (tap through gates automatically)
**Status:** RESOLVED — forge-eye skill provides the visual iteration protocol using xcodebuildmcp CLI. SKIP_ALL_GATES bypasses gates, snapshot-ui + tap navigates to specific screens. forge-builder, forge-polisher, and forge-feature all reference forge-eye in their polish steps.

### D. swiftui-craft "premium" bias produces generic output
**Problem:** The swiftui-craft skill uses "premium" as the universal goal — "premium iOS design", "award-winning quality", "premium feel." This biases every output toward one specific aesthetic: oversized numbers, uppercase tracked headers, shadow-only cards, elaborate animations. The result is Dribbble-bait, not design that serves the app's actual personality.
**Evidence from Ledgr build:**
  - 46pt bold rounded currency number (skill says "48-52pt bold rounded numbers create confidence")
  - Uppercase tracked section headers (skill says "positive tracking on all-caps labels creates quiet authority")
  - Warm cream card tint with brand-tinted shadows (skill's shadow guidance)
  - These rules were applied mechanically without asking "does this serve Ledgr's users?"
**Root cause:** "Premium" is subjective. What one person considers premium is different for another. The skill should help discover what aesthetic fits THIS app, not push everything toward one flavor.
**Fix needed:** Replace "make it premium" with "what should this app feel like?" throughout swiftui-craft. The skill should:
  1. Ask about mood/feeling, not just "aesthetic register"
  2. Research what works in the app's specific domain with Playwright (actually look at screenshots, not just read blog posts)
  3. Let the user's vision drive design, not a preset "premium" formula
  4. Remove or soften prescriptive rules like "48-52pt for hero stats" — these should be suggestions, not defaults
**Status:** RESOLVED — swiftui-craft rewritten as forge-craft v1.3.0 with mood-driven philosophy. Renamed to forge-craft for consistent forge-* naming. Key changes: mood discovery step replaces "aesthetic register", Playwright visual browsing for research, prescriptive rules softened, soul dimension serves the mood, user-provided references take priority. forge-app and forge-feature updated to pass mood through the pipeline.

### E. AI cannot iterate visually without seeing results
**Problem:** The build-screenshot-evaluate cycle is too slow and coarse. By the time I see a screenshot, all the code is written. Real design requires seeing → judging → tweaking → seeing again, rapidly. Writing 200 lines of SwiftUI and then checking one screenshot is not iteration.
**Possible solutions:**
  1. Xcode Previews as the iteration target (faster feedback, no simulator needed)
  2. XcodeBuildMCP's RenderPreview tool for in-conversation preview rendering
  3. Tighter loops: write one component, screenshot, adjust, write next
  4. The human reviews screenshots and gives specific visual feedback ("too much spacing", "make the number smaller")
**Status:** RESOLVED — forge-eye skill created with visual iteration protocol using xcodebuildmcp CLI. Tight loop: build-sim → stop-app → launch-app with SKIP_ALL_GATES → screenshot → read → evaluate → iterate (max 3 rounds). Includes Navigate Protocol (snapshot-ui → tap) for reaching specific screens. forge-builder and forge-polisher agents updated with visual check and iteration steps. forge-feature polish step includes visual iteration.

---

## Items to Revisit

- [x] Fix rename_project.sh scheme rename ordering (Issue #2) — verified correct, original report from partial run
- [x] Fix rename_project.sh to rename ForgeApp.swift → {AppName}App.swift (Issue #3) — verified Step 3 catches it
- [x] Fix new-app.sh which calls rename_project.sh and inherits the same bugs — rename_project.sh is correct
- [x] Implement brand color application in forge-app execution (Issue #4) — forge-workspace Step 2 handles it, added comment to AppDelegate
- [x] Fix orchestration: invoke forge-feature as skill, not raw subagent (Issue #5) — agents load skills via frontmatter
- [x] Build AI screen router / debug deep links (Issue #6) — SKIP_ALL_GATES + forge-eye Navigate Protocol
- [x] Design system customization per-app beyond brand color (Issue #7, Systemic B) — forge-craft mood-driven + Step 1.5
- [x] Add "template vs custom" decision point to forge-app pipeline (Systemic B) — Step 1.5 in forge-app
- [x] Remove Home tab, keep only Dashboard (Issue #9) — per-project, handled by forge-app screen execution
- [x] Add post-rename verification step that checks all "Forge" references are gone — Step 6/6 in rename_project.sh
- [x] Evaluate whether skill content should be embedded in AGENTS.md (Systemic A) — solved via agent `skills:` frontmatter
- [x] Build visual verification into the pipeline (Systemic C) — forge-eye + forge-feature/forge-builder/forge-polisher
- [x] Rewrite swiftui-craft to remove "premium" bias, make it mood/personality-driven (Systemic D) — forge-craft v1.3.0
- [x] Build visual iteration loop — forge-eye skill with xcodebuildmcp CLI screenshot loop (Systemic E)
- [x] Actually use Playwright to browse design references (Dribbble, Mobbin, Behance) — forge-craft research step
