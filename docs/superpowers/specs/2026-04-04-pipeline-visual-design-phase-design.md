# Pipeline Improvement: Visual Design Phase + Architecture Rewrite

## Context

The Forge v2 pipeline (Planner → Generator → Judge) was tested on Kova (personal finance app, 2026-04-04). Three screens were built (Pulse, Onboarding, Paywall). All passed architecture checks. All were technically correct. All looked like garbage — generic, template-y, zero personality.

**Root causes identified:**
1. No visual references gathered — the spec said "forge-browse is killed" and references were "optional"
2. DESIGN.md blueprints were anatomy, not intent — "Icon 60pt, DSSpacing.xl gap" produces correct but dead output
3. No visual design step between spec and code — text blueprint → code, with no visual mockup phase
4. Judge checked compliance, not quality — caught `Font.system(size:)` but not "this looks like a wireframe"
5. Parallel builds caused DerivedData lock conflicts — three subagents building the same Xcode project

**Design audit summary:** "Technically flawless and emotionally empty." All screens felt assembled by different people following a spec checklist. No visual cohesion, no personality, no craft.

Full post-mortem: `docs/superpowers/specs/2026-04-04-pipeline-visual-design-phase.md`

---

## Architecture: 4 Skills + 1 Contract

### Current (v2, broken)
```
forge-app (Planner) → DESIGN.md → forge-build (Generator, does everything) → forge-judge (Judge)
3 skills, Generator owns build/screenshot/verification
```

### New (v3)
```
forge-app (Orchestrator) → forge-design (Visual Design) → DESIGN.md → forge-build (Generator, code only) → forge-judge (Judge)
4 skills, Orchestrator owns build/screenshot/verification
```

### Skill Responsibilities

| Skill | Role | What It Does | What It Does NOT Do |
|-------|------|-------------|-------------------|
| `forge-app` (Orchestrator) | Coordination | Spec conversation, DESIGN.md generation, sprint loop, centralized build/screenshot/verification, human gates, session handoff | Write feature code, evaluate quality |
| `forge-design` | Visual Design | Mobbin reference gathering (Playwright), Stitch mockup generation, visual direction review with human | Generate DESIGN.md, build code, run builds |
| `forge-build` (Generator) | Code Generation | Read DESIGN.md + mockup → write View/ViewModel/Manager code, return file list | Build, screenshot, floor checks, commit, self-evaluate |
| `forge-judge` (Judge) | Quality Evaluation | Grade screenshot + code against DESIGN.md + mockup on 7 criteria | Fix code, write code, run builds |

### Why This Split

**Generator writes code only (ios-implementer pattern).** The fragile, environment-sensitive steps (xcodebuild, simulator control, screenshots) are centralized in the Orchestrator. One owner for build verification means one implementation, one place for logs, one place to fix infra issues. Generators can run in parallel with zero DerivedData contention because they never touch build tools.

**forge-design is a separate skill.** The visual design phase has its own tools (Playwright, Stitch MCP), its own human gate (mockup direction approval), and its own output (approved mockups + design DNA). It's a distinct concern that doesn't belong in the Orchestrator's already-large coordination file.

**Agent teams designed in.** Three integration points for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`:
1. Visual design phase — parallel reference researchers
2. Sprint loop — parallel Generator dispatches for independent features
3. Future: Generator ↔ Judge direct communication for repair cycles

---

## Pipeline Phases

### Phase 1: Spec Conversation (unchanged from v2)

5 adaptive questions → spec.json. No changes needed.

### Phase 2: Visual Design (NEW — forge-design skill)

This phase is REQUIRED. The pipeline does not produce DESIGN.md until visual references are gathered, mockups are generated, and the human picks a direction.

#### 2a: Visual Reference Gathering (Playwright, REQUIRED)

**Tool:** Playwright browser automation → Mobbin.com

**Process:**
1. For each reference app named in spec conversation, browse Mobbin
2. Capture 8-12 in-app screenshots at full resolution
3. Save to `.forge/design-references/` with `index.md`
4. Extract design DNA: spacing patterns, typography hierarchy, surface treatment, color usage

**Agent teams:** Dispatch 2-3 researchers in parallel, each focused on a different reference app or design angle:
- Primary reference app
- Competitors in the same domain
- Wildcard inspiration outside the domain

**Rules:**
- DO NOT screenshot App Store pages — tiny thumbnails, useless
- DO NOT screenshot marketing websites or landing pages
- ONLY screenshot actual in-app UI at readable resolution
- Mobbin has pre-captured in-app screenshots organized by screen type — use it
- If Mobbin doesn't have the app, search for "{app name} iOS UI screenshots" on design blogs

#### 2b: Mockup Generation (Stitch MCP, REQUIRED)

**Tools:** Stitch MCP server

**Process:**
1. `extract_design_context` from the best reference screenshots
2. `create_design_system` from extracted DNA
3. `generate_screen_from_text` for each key screen (dashboard/hero, onboarding, paywall at minimum)
4. `generate_variants` — 2-3 variants per key screen
5. `apply_design_context` for cross-screen consistency
6. Save all mockups to `.forge/design-mockups/`

#### 2c: Visual Direction Review (Human Gate)

**Process:**
1. Present mockup variants to human with clear labels (A/B/C per screen)
2. Human picks a direction — they are the decision-maker
3. If none work: iterate with Stitch using human's feedback
4. Max 2 iteration rounds, then proceed with best available
5. Mark approved mockups in `.forge/design-mockups/` (e.g., `{screen}-approved.png`)

#### 2d: DESIGN.md Generation (back in Orchestrator)

forge-design hands back to the Orchestrator. The Orchestrator generates DESIGN.md informed by:
- Spec conversation context (Phase 1)
- Approved mockups and design DNA (Phase 2a-2c)
- Design intent and craft moments derived from what the human approved

DESIGN.md generation stays in the Orchestrator because it needs the full spec conversation context.

### Phase 3: Sprint Loop (rewritten for centralized verification)

#### Feature Sprint

For each batch of independent features:

```
1. DISPATCH — Generators in parallel (agent team) → code only
   Each Generator receives: AGENTS.md, DESIGN.md, spec.json feature, mockup image path
   Each returns: files created, files modified, handoff summary

2. COLLECT — Orchestrator gathers results

3. For each completed Generator:

   a. FLOOR CHECKS (grep-based, instant)
      - Architecture: DSScreen, .toast(, .onAppear, @Observable, etc.
      - Banned patterns: Font.system(size:, Color(red:, AsyncImage, etc.
      - DESIGN.md Don'ts: grep each banned pattern from Section 6

   b. BUILD (xcodebuildmcp CLI)
      xcodebuildmcp simulator build-sim \
        --scheme "{App} - Mock" \
        --project-path ./{App}.xcodeproj \
        --simulator-name "iPhone 17 Pro"

   c. If build fails → dispatch repair Generator with error log → rebuild (max 2)

   d. SCREENSHOT (xcodebuildmcp CLI)
      xcodebuildmcp simulator build-run-sim --scheme ... --simulator-name ...
      sleep 3
      xcodebuildmcp ui-automation snapshot-ui --simulator-id {id}
      # navigate to target screen via nav_path from spec.json
      xcodebuildmcp ui-automation tap --simulator-id {id} --x {x} --y {y}
      sleep 1
      xcodebuildmcp ui-automation screenshot --simulator-id {id} --return-format path

   e. EVALUATE — dispatch Judge with screenshot + mockup + files
      Judge grades on 7 criteria (see Judge section)

   f. If Judge fails → dispatch repair Generator with fix list → rebuild → re-judge (max 2)

   g. HUMAN GATE — show screenshot to user, get approval
      If feedback → dispatch repair Generator → rebuild → re-judge (max 2 human rounds)

   h. COMMIT — Orchestrator commits after verification passes
      git add {files} && git commit -m "feat: build {feature_name} screen"

4. Mark features done in spec.json
5. Move to next batch (dependent features now unlocked)
```

**Parallelization:** Independent features (`depends_on: []`) dispatch as parallel team members. Each Generator writes code for its own feature — no file conflicts because each feature has its own directory (`{App}/Features/{Feature}/`). Orchestrator runs verification sequentially (one build queue). Dependent features wait for their dependencies to complete.

### Phase 4: Finalization (unchanged from v2)

Cross-screen consistency check (Judge), navigation wiring verification, final build, completion report.

---

## Generator (forge-build) — Code-Only Rewrite

### What It Does

1. Read AGENTS.md (relevant sections: ViewModel Rules, Loading & States, Patterns, DS Component Reference, Post-Build Checks)
2. Read `.forge/DESIGN.md` — the full design contract
3. Read `.forge/spec.json` — the specific feature being built
4. Read the approved mockup image for this screen (path from dispatch prompt)
5. Scaffold View + ViewModel + Manager (if `has_manager: true`)
6. Implement the DESIGN.md blueprint — component rules, typography, color, layout, copy
7. Use the mockup as a visual target — aim to match the feel, not pixel-perfect
8. Return: files created, files modified, short handoff summary

### What It Does NOT Do

- No `xcodebuildmcp` — no builds, no launches, no screenshots
- No floor checks — Orchestrator runs those centrally
- No commits — Orchestrator commits after verification passes
- No self-evaluation — Judge handles that
- No navigation wiring verification — Orchestrator handles post-build

### Repair Mode

When dispatched for a repair (build failure or Judge feedback), the Generator receives:
- The specific error log or Judge fix list
- The files it previously created
- Instruction: "Fix ONLY the listed issues. Don't rebuild from scratch."

Returns updated file list.

### Key Rules

- Blueprint design intent is non-negotiable
- DS tokens only — never hardcode values that exist as tokens
- Never use raw SwiftUI when DS equivalents exist
- No self-evaluation — build and report
- Never invent copy — DESIGN.md Section 8 has all strings
- Never add animations/decorations not in the contract
- Read the mockup image — use it as a visual target alongside DESIGN.md

---

## Judge (forge-judge) — Craft + Intent Upgrade

### Inputs

- `.forge/DESIGN.md` — the grading rubric
- Screenshot of the built screen (from Orchestrator's verification step)
- Approved mockup image (from forge-design phase)
- View and ViewModel files created by the Generator

### 7 Grading Criteria

All must PASS for an overall PASS. Any single FAIL makes the overall verdict FAIL.

#### 1. Design Quality (PASS/FAIL) — DESIGN.md Sections 1, 2, 3

- Does the mood come through? Compare screenshot against Section 1 mood statement.
- Are colors from Section 2 actually used? Flag system defaults that should be custom tokens.
- Does typography hierarchy match Section 3 tokens?
- Is there one dominant element per screen?

#### 2. iOS-Native (PASS/FAIL) — always, regardless of DESIGN.md

- No hamburger menus, floating action buttons, top-aligned tabs
- No custom navigation bars that fight the system
- No web-style box shadows, non-SF-Pro fonts
- System controls for system behaviors

#### 3. Originality (PASS/FAIL) — DESIGN.md Section 6 Don'ts

- Grep each Don't pattern against the View file
- Flag template sins: uniform padding, same card everywhere, generic empty states

#### 4. Craft (PASS/FAIL) — DESIGN.md Sections 4, 5, 7, 8

- Component rules (KEEP/COMPOSE/CREATE/SKIP) followed correctly
- Spacing varies between sections (not uniform padding)
- Screen blueprint structure matches
- Copy matches Section 8 exactly

#### 5. Craft Intent (NEW) (PASS/FAIL) — DESIGN.md Section 7 (Design Intent + Craft Moment)

- Does the screen have a clear visual entry point?
- Does the blueprint's "Craft Moment" actually land? (The signature detail is present and noticeable)
- Does typography create interest, not just correctness?
- Are there decisions that went BEYOND the minimum spec?

#### 6. Visual Target Match (NEW) (PASS/FAIL) — mockup vs screenshot

- Does the built screen match the approved mockup's feel? (Not pixel-perfect — feel, weight, density)
- Same visual hierarchy? (Hero prominence, section rhythm, whitespace distribution)
- Same surface treatment? (Card depth, border usage, background treatment)
- If it feels like a different app than the mockup, FAIL

#### 7. Architecture (PASS/FAIL) — AGENTS.md Post-Build Checks

- View MUST contain: `DSScreen`, `.toast(`, `.onAppear`, `AppServices.self`
- View MUST NOT contain: `AsyncImage`, `@StateObject`
- ViewModel MUST contain: `@Observable`, `hasLoaded`, `LoggableEvent`, `var toast: Toast?`
- Manager pattern correct (if applicable): protocol + mock, skeleton loading, empty state

### Verdict Format

```
JUDGE VERDICT: {PASS|FAIL}

1. Design Quality: {PASS|FAIL}
   {observations referencing DESIGN.md section numbers}

2. iOS-Native: {PASS|FAIL}
   {any platform anti-patterns found}

3. Originality: {PASS|FAIL}
   {observations with file:line for violations}

4. Craft: {PASS|FAIL}
   {observations referencing DESIGN.md section numbers}

5. Craft Intent: {PASS|FAIL}
   {observations — does the craft moment land? visual entry point clear?}

6. Visual Target Match: {PASS|FAIL}
   {observations — mockup vs screenshot comparison}

7. Architecture: {PASS|FAIL}
   {observations with file:line for violations}

FIXES REQUIRED:
1. {file_path:line — what to change, referencing DESIGN.md section}
```

---

## DESIGN.md Format Updates

### New Fields in Section 7 (Screen Blueprints)

Three new fields added to every screen blueprint:

```markdown
### [ScreenName]

**Design Intent:** [WHY this screen exists — what job it does for the user, what emotion it should create]

**Craft Moment:** [The ONE signature detail that makes this screen memorable — not a list, one thing]

**Visual Reference:** [Path to approved mockup: .forge/design-mockups/{screen}-approved.png]

**Hero element:** [unchanged]

**Sections (top to bottom):**
1. [unchanged]

**Empty state:** [unchanged]

**Entrance animation:** [unchanged]

**Don't:**
- [unchanged]
```

**Why these fields:**
- **Design Intent** prevents "anatomy without purpose" — the Generator knows WHY each element exists
- **Craft Moment** focuses creative energy — one thing per screen gets love, not everything equally
- **Visual Reference** gives Generator and Judge a shared target image

### Validation Checklist Additions

```
- [ ] Every Screen Blueprint has a Design Intent (not just anatomy)
- [ ] Every Screen Blueprint has exactly ONE Craft Moment (not a list)
- [ ] Every Screen Blueprint has a Visual Reference path
- [ ] Design Intent describes purpose/emotion, not layout
- [ ] Craft Moment is specific enough to verify in a screenshot
```

### No Changes to Sections 1-6 or Section 8

The format is already solid. The gap was in blueprints being anatomy-only.

---

## Session Handoff: `/forge:continue`

### The Problem

The user starts in the Forge template repo. The Orchestrator creates a new project (e.g., `~/Documents/Developer/Apps/Kova`). All building needs to happen in that new repo's context. The spec conversation and visual design phases happen in one session; the sprint loop happens in another.

### The Solution

**Phase 1-2 (Forge template repo):** Orchestrator runs spec conversation + visual design. After Phase 2 completes and DESIGN.md is generated, the Orchestrator:
1. Runs `scripts/new-app.sh` to create the project
2. Copies `.forge/` contents (spec.json, DESIGN.md, design-references/, design-mockups/) to the new project
3. Generates `.forge/handoff.md` in the new project
4. Tells the user: "Project created at `{path}`. Open a new session there and run `/forge:continue`."

**Phase 3-4 (New app repo):** User opens a new Claude session in the app repo, runs `/forge:continue`. The Orchestrator:
1. Detects `.forge/handoff.md`
2. Reports what was planned: app name, screens, visual direction summary
3. Asks user to confirm before building
4. Jumps directly to Phase 3 (Sprint Loop)

### handoff.md Contents

```markdown
# Forge Handoff

## Source
- Template session: {Forge template repo path}
- Created: {timestamp}

## Phases Completed
- [x] Phase 1: Spec Conversation
- [x] Phase 2: Visual Design (forge-design)
- [ ] Phase 3: Sprint Loop
- [ ] Phase 4: Finalization

## Next Phase
Phase 3: Sprint Loop

## App Context
- Name: {app_name}
- Pitch: {one-line pitch}
- Target: {target audience}
- Monetization: {model}
- Reference apps: {list with what to take from each}

## Visual Direction Summary
- Approved mockup style: {description of what the human picked}
- Key design decisions from review: {list}
- Mood: {mood statement from DESIGN.md Section 1}

## Agent Teams Config
- Parallel features: {list of feature IDs with depends_on: []}
- Sequential features: {list of feature IDs with dependencies}
- Recommended batch order: {ordered list of batches}

## Files Present
- .forge/spec.json — {N} features, {N} models
- .forge/DESIGN.md — all 8 sections populated
- .forge/design-references/ — {N} reference screenshots + index.md
- .forge/design-mockups/ — {N} approved mockups
```

### `/forge:continue` Implementation

Added as a command in the forge-app skill (or as a new micro-skill in forge-feature):

1. Check for `.forge/handoff.md` — if missing, error: "No handoff found. Run `/forge:app` in the Forge template repo first."
2. Read handoff.md — parse completed phases, next phase, app context
3. Read `.forge/spec.json` and `.forge/DESIGN.md` — verify they exist and are valid
4. Report to user:
   > "Resuming {app_name}: {pitch}. {N} features to build. Visual direction: {summary}. Ready to start the sprint loop?"
5. On user confirmation → enter Phase 3 (Sprint Loop)

---

## Files to Modify

All source files in: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/`

### 1. Pipeline Redesign Spec (this repo)
`docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md`

Changes:
- Update architecture diagram: 3 skills → 4 skills
- Rename "Planner" → "Orchestrator" throughout
- Reverse decision #3 ("forge-browse is killed") — visual references are REQUIRED
- Move Playwright/Stitch from "Optional Enhancements" to Phase 2 (forge-design)
- Add Phase 2a-2d description
- Update Generator section: code-only, no build tools
- Update Judge section: add Craft Intent + Visual Target Match criteria
- Add centralized verification section
- Add agent teams integration points
- Add session handoff section
- Add `/forge:continue` command

### 2. DESIGN.md Format Spec (forge-marketplace)
`.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md`

Changes:
- Section 7 (Screen Blueprints): add Design Intent, Craft Moment, Visual Reference fields
- Validation Checklist: add checks for new fields
- Update "Who reads this file" to include forge-design

### 3. Orchestrator Skill (forge-marketplace)
`.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

Changes:
- Rename "Planner" → "Orchestrator" in all text
- Phase 2: replace optional visual references with REQUIRED forge-design dispatch
- Phase 3: rewrite sprint loop for centralized verification (Orchestrator builds/screenshots)
- Add verification recipe using xcodebuildmcp CLI
- Add agent teams integration for parallel Generator dispatches
- Add repair loop (build failure → repair Generator → rebuild)
- Add `/forge:continue` detection and resume logic
- Add session handoff generation after Phase 2
- Update Optional Enhancements: remove Playwright/Stitch (now core), keep marketing/impeccable/code-review

### 4. Generator Agent (forge-marketplace)
`.claude-plugin/plugins/forge-feature/agents/forge-build.md`

Changes:
- Strip ALL build/screenshot/check logic (Steps 4, 4b, 5)
- Add mockup image reading in Step 1 (context)
- Update Step 6 (return): file list + handoff summary only, no screenshot, no commit
- Remove xcodebuildmcp commands entirely
- Add repair mode documentation
- Update Key Rules: remove all build-related rules, add "never touch xcodebuildmcp"

### 5. Judge Agent (forge-marketplace)
`.claude-plugin/plugins/forge-feature/agents/forge-judge.md`

Changes:
- Add mockup image as input (alongside screenshot)
- Add criterion 5: Craft Intent
- Add criterion 6: Visual Target Match
- Update verdict format to include all 6 criteria (was 4 + iOS-Native)
- Update Step 2: compare screenshot against mockup, not just describe

### 6. New Skill: forge-design (forge-marketplace)
`.claude-plugin/plugins/forge-design/skills/forge-design/SKILL.md`

New file. Contents:
- Phase 2a: Visual Reference Gathering (Playwright + Mobbin)
- Phase 2b: Mockup Generation (Stitch MCP)
- Phase 2c: Visual Direction Review (human gate)
- Agent teams integration for parallel reference research
- Output: approved mockups + design DNA in `.forge/`

### 7. forge-feature Skill (forge-marketplace)
`.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`

Changes:
- Add `/forge:continue` as a command or mode
- Update Full Mode Pipeline to reflect centralized verification
- Update Generator/Judge dispatch descriptions

### 8. marketplace.json (forge-marketplace)
`marketplace.json`

Changes:
- Add forge-design plugin entry

---

## Success Criteria

1. A new Forge app build produces screens that look DESIGNED, not ASSEMBLED
2. Visual references are gathered before any DESIGN.md is written
3. The human sees and approves visual mockups before code is written
4. The Generator has visual targets (mockup images), not just text blueprints
5. The Judge catches "this is generic" not just "this violates the spec"
6. Parallel Generator dispatches work without DerivedData lock conflicts (code-only agents)
7. Session handoff from Forge template repo to app repo is seamless via `/forge:continue`
8. Agent teams are used for parallel reference research and parallel feature generation
