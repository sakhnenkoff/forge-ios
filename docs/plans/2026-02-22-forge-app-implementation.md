# forge-app Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a `forge-app` whole-app orchestrator skill that takes a developer from "I have an app idea" to a fully built, polished, running iOS app by chaining forge-feature calls via a conversational blueprint.

**Architecture:** A new plugin in the forge-marketplace containing a SKILL.md orchestrator that: (1) builds a blueprint through conversation, (2) detects workspace setup status, (3) executes the blueprint by calling forge-feature with adaptive mode per screen, (4) delivers a running app on Mock scheme. Optional integration with superpowers for creative direction and final review.

**Tech Stack:** Claude Code plugin system, SKILL.md format, forge-marketplace Git repo

---

### Task 1: Create the forge-app plugin scaffold

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/claude-code.json`
- Create directories: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/`

**Step 1: Create directory structure**

```bash
mkdir -p /Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references
```

**Step 2: Create claude-code.json**

Write this file to `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/claude-code.json`:

```json
{
  "name": "forge-app",
  "version": "1.0.0",
  "description": "Build an entire iOS app from an idea — conversational blueprint, then screen-by-screen execution with forge-feature",
  "author": "Matvii Sakhnenko",
  "license": "MIT",
  "skills": [
    {
      "name": "forge-app",
      "description": "Build a complete iOS app from a description. Asks questions to build a blueprint (screens, data models, navigation, design direction), then executes screen-by-screen via forge-feature. Use when the user says 'build me an app', 'I want to create an app for X', 'build an app that does X', or '/forge:app'."
    }
  ]
}
```

**Step 3: Commit**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/claude-code.json
git commit -m "feat: add forge-app plugin scaffold"
```

---

### Task 2: Write the main SKILL.md orchestrator

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

This is the core skill file. It must be complete — no abbreviations, no placeholders. The SKILL.md must contain all of the following sections, fully fleshed out.

**Step 1: Write SKILL.md**

Write the complete file to the path above. The file must follow this exact structure:

**Frontmatter:**
```yaml
---
name: forge-app
description: >
  Build a complete iOS app from an idea. Conversational spec-building produces
  a blueprint (screens, data models, navigation, design direction), then
  screen-by-screen execution via forge-feature delivers a polished, running app.
  Detects workspace setup status and optional enhancements automatically.
license: MIT
---
```

**Section 1 — Overview:**
- This skill takes a developer from "I have an app idea" to a running, polished iOS app
- It works in two phases: blueprint (conversation) and execution (forge-feature calls)
- Default: high autonomy — builds everything without stopping unless the developer requests checkpoints
- Works with zero third-party plugins. Superpowers enhance creative direction and final review when available
- Part of the Forge ecosystem: `forge-workspace` (setup) → `forge-app` (build) → future: `forge-wire` (connect) → `forge-ship` (submit)

**Section 2 — Prerequisites Check:**
Same pattern as forge-feature:
```
[ ] *.xcodeproj exists in working directory
[ ] AGENTS.md exists in working directory
[ ] Packages/core-packages/DesignSystem/ exists
```
Detect app name from xcodeproj filename. Check whether `forge-feature` skill is available (required — this skill depends on it). If forge-feature is not available, tell the user to install it: `claude plugin install forge-feature@forge-marketplace`.

**Section 3 — Optional Enhancement Detection:**
Same detection pattern as forge-feature. Check available skills list for:
- `superpowers:brainstorming` — creative direction delegation
- `superpowers:requesting-code-review` — final whole-app review
- `superpowers:verification-before-completion` — final verification
- `forge-workspace:forge-workspace` — workspace setup if needed

Log which are available.

**Section 4 — Phase 1: Conversational Spec-Building:**

The orchestrator asks adaptive questions to understand the app. NOT a rigid questionnaire — adapt based on answers. Ask ONE question at a time.

**Structural questions (forge-app handles directly):**

1. **Pitch:** "What does your app do? Give me the one-sentence pitch."
   - From the answer, infer likely screens, data models, and user flows

2. **Target user:** "Who is this for?" (helps inform design decisions — pro users want density, casual users want simplicity)

3. **Core screens:** Propose screens based on the pitch. Example:
   > "Based on your pitch, I'm thinking these screens:
   > 1. Dashboard (Tab) — [brief description]
   > 2. Detail View (Push) — [brief description]
   > 3. Add/Edit (Sheet) — [brief description]
   > 4. Stats (Tab) — [brief description]
   > 5. Onboarding — customize for your domain
   > 6. Paywall — configure for your monetization
   > 7. Settings — already exists
   >
   > Add, remove, or adjust?"

4. **Data models:** "What data does the app track? I'm thinking: [propose models based on pitch]. Adjust?"

5. **User flows:** "What's the core daily loop? User opens the app and..." (establishes navigation priorities)

6. **Monetization:** "How does this app make money?" (maps to paywall configuration)
   - Free (no paywall)
   - Freemium (paywall with limits)
   - Subscription (paywall with tiers)

**Creative direction:**

If `superpowers:brainstorming` is available:
- Invoke it with: "Help me define the creative direction for [app pitch]. What should make this app stand out visually? What reference apps capture the feel? What brand color fits?"
- Take the output and integrate into the blueprint

If NOT available, ask inline:
7. **Brand color:** "What brand color fits this app?" (suggest based on domain — blue for productivity, green for health, etc.)
8. **Reference apps:** "Name 1-2 apps whose feel you want to match." (or suggest based on domain)

**Section 5 — Blueprint Generation:**

After the conversation, generate a structured blueprint. This is the contract — present it to the developer for approval before ANY execution.

Blueprint format:
```
## Blueprint: [App Name]

**Pitch:** [one sentence]
**Target user:** [brief]
**Brand color:** [color]
**Reference apps:** [1-2 apps]
**Monetization:** [free/freemium/subscription]

### Screens

| # | Complexity | Screen | Type | Description |
|---|-----------|--------|------|-------------|
| 1 | complex | Dashboard | Tab: Home | [description] |
| 2 | simple | Detail | Push from Dashboard | [description] |
| 3 | simple | Add Item | Sheet from Dashboard | [description] |
| ... | ... | ... | ... | ... |

### Data Models

- **ModelName:** field1 (Type), field2 (Type), ...
- **ModelName:** field1 (Type), field2 (Type), ...

### Navigation Map

- **Tabs:** [list]
- **Pushes:** [from → to]
- **Sheets:** [from → to]

### Checkpoint preferences

[Ask the developer: "Any screens you want to review before I continue? Or should I build everything and show you the final result?"]
```

**Complexity tagging rules:**
- `[complex]` — screens with charts, custom layouts, multi-component interactions, real-time data, filtering/sorting
- `[simple]` — standard list/detail/form screens, onboarding slides, paywall configuration
- `[skip]` — screens that already exist and just need minor config (Settings, Auth)

Wait for developer approval. If they request changes, update the blueprint and re-present. Do NOT proceed to execution until the blueprint is explicitly approved.

**Section 6 — Phase 2: Execution Engine:**

After blueprint approval, execute in this order:

**Step 1 — Smart workspace detection:**
- Check if the xcodeproj name matches the app name from the blueprint
- Check if bundle ID has been configured (not still `com.forge.app`)
- If workspace is NOT set up AND `forge-workspace:forge-workspace` is available:
  - Invoke `forge-workspace` with the app name, brand color, and domain from the blueprint
  - Wait for it to complete before proceeding
- If workspace is NOT set up AND `forge-workspace` is NOT available:
  - Tell the developer: "The template hasn't been set up yet. Install forge-workspace (`claude plugin install forge-workspace@forge-marketplace`) and run 'Set up Forge for [app name]' first, then re-run /forge:app."
  - Stop execution.
- If workspace IS already set up: proceed to step 2

**Step 2 — Data model creation:**
- Create SwiftData `@Model` classes for each data model in the blueprint
- Place them in `{App}/Models/` directory
- Follow AGENTS.md patterns: `@MainActor`, strict concurrency, `StringIdentifiable` protocol
- These must exist before screens are built (screens depend on them)
- Build to verify models compile: `xcodebuild -project *.xcodeproj -scheme "[AppName] - Mock" -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build`
- Commit: `git commit -m "feat: add data models for [app name]"`

**Step 3 — Screen-by-screen execution:**

For each screen in the blueprint (in order):

If `[skip]`:
- Make minor configuration changes only (e.g., update Settings rows, customize onboarding text)
- No forge-feature invocation needed
- Commit changes

If `[simple]`:
- Invoke `forge-feature` in quick mode
- Pass this context: "Build [screen name]: [description from blueprint]. Data models available: [list]. Navigation: [type] from [source]. Follow the app's design direction inspired by [reference apps]. Brand color: [color]."
- forge-feature handles: scaffold → build → polish → verify

If `[complex]`:
- Invoke `forge-feature` in full mode
- Pass the same context as simple, plus: "This is a complex screen. Use full mode with planning and review."
- forge-feature handles: brainstorm → plan → scaffold → build → polish → verify → review

**Between screens:**
- Report brief progress: "Built [screen name]. [N] of [total] complete."
- If the developer set checkpoint preferences in the blueprint: pause at specified screens
- If the developer interrupts with "stop", "wait", or "let me review": pause and present current state
- Otherwise: continue to the next screen

**Step 4 — Tab/Navigation wiring:**

After all screens are built, verify the tab structure matches the blueprint:
- Check `AppTab` enum has the right tabs
- Check `AppRoute` has routes for all push destinations
- Check `AppSheet` has sheets for all sheet presentations
- Fix any missing wiring

**Step 5 — Final verification:**

- Full `xcodebuild` on Mock scheme
- If `superpowers:requesting-code-review` is available: invoke for a whole-app architecture review
- If `superpowers:verification-before-completion` is available: invoke for final verification
- If neither is available, run inline:
  - Build passes
  - All screens exist and are navigable
  - DS components used throughout
  - Analytics events in ViewModels
  - No compilation warnings from app code

**Section 7 — Completion Report:**

After everything passes, present the final report:

```
## App Built: [App Name]

**Screens created:** [N]
**Data models:** [list]
**Navigation:** [tabs] tabs, [pushes] push routes, [sheets] sheets

### What was built
[Table of screens with status]

### Next steps
- **Add real data:** Replace mock data with real backend (future: /forge:wire)
- **Prepare for submission:** App Store metadata, privacy manifest (future: /forge:ship)
- **Test on device:** Run on physical device to verify feel and performance

### Files created/modified
[list all files]
```

**Section 8 — Token Optimization Notes:**

```html
<!-- Model hints for token optimization:
- Spec conversation: Use current model (creative judgment, understanding intent)
- Blueprint generation: Use current model (structured output from conversation)
- Data model creation: Can use sonnet (templated SwiftData code)
- Per-screen forge-feature: Handled by forge-feature's own optimization
- Final verification: Can use haiku (mechanical build check)
- Completion report: Can use haiku (summarization)

Context management:
- The spec conversation and blueprint are the most context-intensive phases
- Execution phase can offload per-screen work to forge-feature subagents
- Each forge-feature call runs in its own context when invoked as a skill
- Pass only the relevant blueprint section to each forge-feature call, not the full blueprint
-->
```

**Section 9 — Skill Boundaries:**

| Domain | forge-app handles | Defers to |
|--------|-------------------|-----------|
| App ideation | Structural questions (screens, data, flows) | `superpowers:brainstorming` for creative direction when available |
| Workspace setup | Detection of setup status | `forge-workspace` for actual setup |
| Per-screen building | Orchestration and context passing | `forge-feature` for scaffold, build, polish, verify |
| Design polish | Nothing — fully delegated | `swiftui-craft` (via forge-feature) |
| Screen scaffolding | Nothing — fully delegated | `forge-screens` (via forge-feature) |
| Backend wiring | Not in scope | Future: `forge-wire` |
| App Store submission | Not in scope | Future: `forge-ship` |
| Code review | Final whole-app review | `superpowers:requesting-code-review` when available |

**Step 2: Commit SKILL.md**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: add forge-app orchestrator skill"
```

---

### Task 3: Write blueprint.md reference

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/blueprint.md`

**Step 1: Write blueprint.md**

This reference contains:
- The full blueprint format with all fields
- Two complete examples (different app domains) showing what a good blueprint looks like
- Complexity tagging guidelines with examples
- Common app archetypes and their typical screen sets (to help propose screens from a pitch)

Example archetypes to include:

| Archetype | Typical Screens |
|-----------|----------------|
| Tracker (habits, expenses, workouts) | Dashboard, Detail, Add/Edit, Stats, History |
| Social/Feed (posts, photos) | Feed, Profile, Create Post, Detail, Search |
| Utility (converter, calculator, timer) | Main, Settings, History |
| Education (courses, flashcards) | Library, Lesson, Progress, Quiz |
| E-commerce (products, cart) | Browse, Product Detail, Cart, Checkout |
| Journal/Notes (diary, notes) | List, Editor, Tags, Search |

These help the orchestrator propose sensible screens from a one-sentence pitch.

**Step 2: Commit**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/references/blueprint.md
git commit -m "docs: add blueprint reference with examples and archetypes"
```

---

### Task 4: Write execution.md reference

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/execution.md`

**Step 1: Write execution.md**

This reference contains:
- Execution order rules (workspace → data models → screens → wiring → verification)
- Mode selection table (complexity tag → forge-feature mode)
- Checkpoint system rules (default autonomy, how interrupts work, how to set checkpoints)
- Context passing format — exactly what to pass to forge-feature for each screen:

```
Context template for forge-feature invocation:

Screen: [name]
Type: [Tab/Push/Sheet] from [source]
Description: [description from blueprint]
Data models: [list relevant models with fields]
Navigation: [what routes/sheets this screen triggers]
Design direction: Brand color [color], inspired by [reference apps]
Mode: [quick/full based on complexity tag]
```

- Error recovery rules:
  - If forge-feature fails on a screen (build error): fix and retry that screen, don't skip
  - If a screen reveals missing data model fields: add them, rebuild previous screens that might be affected
  - If the developer rejects a screen at checkpoint: take feedback, re-run forge-feature for that screen
- Token budget guidance:
  - Small app (3-4 screens): ~600K-900K tokens
  - Medium app (5-7 screens): ~1.0M-1.7M tokens
  - Large app (8+ screens): multi-session via GSD auto-escalation in forge-feature

**Step 2: Commit**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/references/execution.md
git commit -m "docs: add execution engine reference for forge-app"
```

---

### Task 5: Register forge-app in marketplace.json and push

**Files:**
- Modify: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/marketplace.json`

**Step 1: Add forge-app to the plugins array**

Add this entry to the `plugins` array in marketplace.json (after the forge-feature entry):

```json
{
  "name": "forge-app",
  "version": "1.0.0",
  "source": "./.claude-plugin/plugins/forge-app",
  "description": "Build an entire iOS app from an idea — conversational blueprint, then screen-by-screen execution with forge-feature",
  "author": {
    "name": "Matvii Sakhnenko"
  }
}
```

**Step 2: Validate JSON**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('Valid JSON')"
```
Expected: `Valid JSON`

**Step 3: Commit**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/marketplace.json
git commit -m "feat: register forge-app in marketplace"
```

**Step 4: Push all forge-marketplace changes**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git push origin main
```

**Step 5: Update marketplace and install**

```bash
claude plugin marketplace update forge-marketplace
claude plugin install forge-app@forge-marketplace
```

---

### Task 6: Update AGENTS.md in Forge template

**Files:**
- Modify: `/Users/matvii/Documents/Developer/Templates/forge/AGENTS.md`

**Step 1: Update "How to Build Features" section**

Add forge-app as the top-level entry point above the existing forge-feature guidance. The updated section should read:

```markdown
### How to Build Features

**Build an entire app:** `/forge:app` — describe your idea, get a running app
```bash
claude plugin install forge-app@forge-marketplace
```

**Build individual features:** Use the `forge-feature` pipeline:

- **Most features:** `/forge:quick` — scaffold, build, polish, verify (default)
- **Major features:** `/forge:feature` — full pipeline with brainstorming, planning, and review
- **Multi-session work:** Automatically escalates to GSD when complexity warrants it

Or build features manually with individual skills:
...
```

**Step 2: Update "Available Skills" table**

Add `forge-app` as the first row in the skills table:

```markdown
| `forge-app` | Build a complete app from an idea — blueprint + execution | `/forge:app` |
```

**Step 3: Update "Setting Up a New Project" section**

Add `forge-app` to the list of available skills, and mention it as the recommended way to build a whole app after workspace setup.

**Step 4: Commit**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git add AGENTS.md
git commit -m "docs: add forge-app to AGENTS.md workflow and skills table"
```

---

### Task 7: Update README.md in Forge template

**Files:**
- Modify: `/Users/matvii/Documents/Developer/Templates/forge/README.md`

**Step 1: Update skills count and table**

Change "Four AI-powered skills" to "Five AI-powered skills". Add forge-app as the first row:

```markdown
| `forge-app` | `claude plugin install forge-app@forge-marketplace` | Build an entire app from an idea |
```

**Step 2: Update workflow line**

```markdown
**Workflow**: `forge-workspace` (setup) → `forge-app` (build entire app) → or use `forge-feature` / `forge-screens` + `swiftui-craft` individually
```

**Step 3: Commit**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git add README.md
git commit -m "docs: add forge-app to README skills section"
```

---

### Task 8: Create symlink, push, and verify

**Step 1: Create symlink in .agents/skills**

```bash
ln -s /Users/matvii/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app /Users/matvii/.agents/skills/forge-app
```

**Step 2: Push Forge template changes**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git push origin main
```

**Step 3: Verify license**

Check that SKILL.md has `license: MIT` in frontmatter:
```bash
head -10 /Users/matvii/.claude/plugins/cache/forge-marketplace/forge-app/1.0.0/skills/forge-app/SKILL.md
```
Expected: `license: MIT` on line 8 or similar

**Step 4: Verify no bundled third-party code**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
grep -r "superpowers\|gsd\|ralph" .claude-plugin/plugins/forge-app/ | grep -v "invoke\|detect\|check\|available\|installed\|when\|if\|not"
```
Expected: no results (only detection/invocation references)

**Step 5: Verify the skill loads**

Restart Claude Code and verify `/forge:app` appears in the available skills list.
