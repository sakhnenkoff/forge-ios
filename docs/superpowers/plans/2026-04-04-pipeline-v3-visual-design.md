# Pipeline V3: Visual Design Phase + Architecture Rewrite — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the Forge pipeline from 3 skills (Planner/Generator/Judge) to 4 skills (Orchestrator/Visual Design/Generator/Judge) with required visual design phases, code-only Generator, 7-criteria Judge, centralized build verification, agent teams, and session handoff.

**Architecture:** All changes are to markdown skill/agent files in two repos: the Forge template repo (specs) and the forge-marketplace repo (skills/agents). The Generator becomes code-only (ios-implementer pattern), the Orchestrator takes over build/screenshot/verification via xcodebuildmcp CLI, a new forge-design skill handles visual reference gathering and mockup generation, and the Judge gets craft intent + visual target match criteria.

**Tech Stack:** Claude Code plugins (markdown skill files), xcodebuildmcp CLI, Playwright MCP, Stitch MCP, agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)

**Repos:**
- Forge template: `/Users/matvii/.superset/worktrees/forge/obsidian-sound/` (specs only)
- forge-marketplace source: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/` (skills/agents)
- forge-marketplace cache: `/Users/matvii/.claude/plugins/cache/forge-marketplace/` (read-only reference, DO NOT edit)

**Design spec:** `docs/superpowers/specs/2026-04-04-pipeline-visual-design-phase-design.md`

---

## File Map

### forge-marketplace repo (`/Users/matvii/Developer/Personal/Apps/forge-marketplace/`)

| File | Action | Responsibility |
|------|--------|---------------|
| `.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md` | Modify | Add Design Intent, Craft Moment, Visual Reference to Section 7; update validation checklist |
| `.claude-plugin/plugins/forge-feature/agents/forge-build.md` | Rewrite | Code-only Generator — strip all build/screenshot/check logic |
| `.claude-plugin/plugins/forge-feature/agents/forge-judge.md` | Modify | Add criteria 5 (Craft Intent), 6 (Visual Target Match), 7 (Architecture); accept mockup input |
| `.claude-plugin/plugins/forge-design/skills/forge-design/SKILL.md` | Create | New skill: visual reference gathering, mockup generation, direction review |
| `.claude-plugin/plugins/forge-design/claude-code.json` | Create | Plugin manifest for forge-design |
| `.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md` | Rewrite | Orchestrator: rename, visual design dispatch, centralized verification, session handoff, /forge:continue |
| `.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md` | Modify | Update for centralized verification, add /forge:continue reference |
| `marketplace.json` | Modify | Add forge-design plugin entry |

### Forge template repo (current working directory)

| File | Action | Responsibility |
|------|--------|---------------|
| `docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md` | Modify | Update to reflect v3 architecture (4 skills, Orchestrator rename, visual phases required) |

---

## Task Dependency Graph

```
Task 1 (DESIGN.md format) ──┐
Task 2 (Generator rewrite) ──┤── independent, can run in parallel
Task 3 (Judge update) ───────┤
Task 4 (forge-design skill) ─┘
                              │
                              ▼
Task 5 (Orchestrator rewrite) ── depends on Tasks 1-4 (references their interfaces)
                              │
                              ▼
Task 6 (forge-feature update) ── depends on Task 5
Task 7 (marketplace.json) ───── depends on Task 4
Task 8 (pipeline spec update) ── depends on all above
```

**Parallel batch 1:** Tasks 1, 2, 3, 4
**Sequential:** Task 5 → Task 6, Task 7 → Task 8

---

### Task 1: Update DESIGN.md Format Spec

**Files:**
- Modify: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md`

This is foundational — the Generator, Judge, and Orchestrator all reference this format. Update it first.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md
```

Confirm the file has 8 sections. Note the current Section 7 (Screen Blueprints) format and the Validation Checklist structure.

- [ ] **Step 2: Update "Who reads this file" header**

At the top of the file, update the reader list to include forge-design:

```markdown
**Who reads this file:**
- **Orchestrator (forge-app)** — generates a DESIGN.md during Phase 2d
- **Visual Design (forge-design)** — informs mockup generation and design DNA extraction
- **Generator (forge-build)** — reads DESIGN.md before writing every screen
- **Judge (forge-judge)** — grades output against DESIGN.md rules
```

- [ ] **Step 3: Update Section 7 format template**

In Section 7 (Screen Blueprints), replace the format block with the new format that includes Design Intent, Craft Moment, and Visual Reference. Find the block starting with `**Format (one subsection per screen):**` and replace:

```markdown
**Format (one subsection per screen):**

\`\`\`markdown
## Screen Blueprints

### [ScreenName]

**Design Intent:** [WHY this screen exists — what job it does for the user, what emotion it should create. Not anatomy — purpose.]

**Craft Moment:** [The ONE signature detail that makes this screen memorable. Not a list — one specific thing. Must be verifiable in a screenshot.]

**Visual Reference:** [Path to approved mockup: .forge/design-mockups/{screen}-approved.png]

**Hero element:** [The single most prominent element on this screen — what the eye hits first]

**Sections (top to bottom):**
1. [Section name] — [what it contains, which DS component, layout details]
2. [Section name] — [what it contains, which DS component, layout details]
3. [Section name] — [what it contains, which DS component, layout details]

**Empty state:** "[Exact copy from Section 8]" + [CTA button label]

**Entrance animation:** [Specific animation — e.g., ".opacity with 0.3s delay per section" or "none"]

**Don't:**
- [Screen-specific ban — something the generator might try that would be wrong for THIS screen]
\`\`\`
```

- [ ] **Step 4: Update Section 7 rules**

Add to the existing rules list under Section 7:

```markdown
- Design Intent is required for every screen — it describes purpose and emotion, not layout structure
- Craft Moment must be exactly ONE thing — not a list of 3-4 details. It must be specific enough to verify in a screenshot ("monospaced hero counter with .contentTransition(.numericText())" not "make it feel premium")
- Visual Reference path is required when mockups were generated (Phase 2b). If no mockup exists for this screen, use "None — derived from {closest screen} mockup"
```

- [ ] **Step 5: Update Section 7 example**

Replace the existing Dashboard example with one that includes the new fields:

```markdown
**Example:**

\`\`\`markdown
### Dashboard

**Design Intent:** This is the app's confidence moment — the user opens and instantly knows their financial position. It should feel like a calm, authoritative summary, not a cluttered data dump.

**Craft Moment:** The hero number uses .contentTransition(.numericText()) so it animates smoothly when the period changes — the one detail that says "this app was made with care."

**Visual Reference:** .forge/design-mockups/dashboard-approved.png

**Hero element:** Today's completion count — standalone 48pt .display() .monospaced number, left-aligned

**Sections (top to bottom):**
1. Hero stat — Raw number + .captionLarge() subtitle below, DSSpacing.xs (4) gap
2. Today's habits — Vertical list of DSListRow, each with checkbox toggle and habit name
3. Weekly spark — Inline 7-day bar chart (Swift Charts), 80pt tall, no axes, brand color fill

**Empty state:** "Your first habit starts here" + "Add Habit" button

**Entrance animation:** .opacity per section, 0.15s stagger delay

**Don't:**
- Don't wrap the hero number in any card or container
- Don't use a progress ring — this app uses raw numbers, not circular progress
\`\`\`
```

- [ ] **Step 6: Update Validation Checklist — Completeness section**

Add these lines to the `### Completeness` section of the Validation Checklist, after the existing Screen Blueprints checks:

```markdown
- [ ] **Screen Blueprints** every blueprint has a Design Intent (describes purpose/emotion, not layout)
- [ ] **Screen Blueprints** every blueprint has exactly ONE Craft Moment (not a list of details)
- [ ] **Screen Blueprints** every blueprint has a Visual Reference path (or "None — derived from {screen}")
- [ ] **Screen Blueprints** Craft Moments are specific enough to verify in a screenshot
```

- [ ] **Step 7: Update Validation Checklist — Consistency section**

Add this line to the `### Consistency` section:

```markdown
- [ ] Visual Reference paths in Section 7 point to files that exist in .forge/design-mockups/
```

- [ ] **Step 8: Verify no stale references**

```bash
grep -n "Planner" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md
```

If any "Planner" references remain, update them to "Orchestrator."

- [ ] **Step 9: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md
git commit -m "feat: add Design Intent, Craft Moment, Visual Reference to DESIGN.md blueprint format"
```

---

### Task 2: Rewrite Generator Agent (Code-Only)

**Files:**
- Rewrite: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md`

Strip all build/screenshot/check logic. The Generator writes code and returns a file list. Nothing else.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md
```

Note the current structure: Setup, Step 1 (context), Step 2 (scaffold), Step 2b (manager), Step 3 (implement), Step 4 (build+screenshot), Step 4b (navigate), Step 5 (floor checks), Step 6 (return). Steps 4, 4b, and 5 must be removed entirely.

- [ ] **Step 2: Rewrite the file**

Replace the entire file contents with:

```markdown
---
name: forge-build
description: >
  Code-only screen builder for Forge iOS apps. Reads DESIGN.md contract +
  AGENTS.md architecture rules + spec.json feature entry + approved mockup.
  Writes code and returns file list. No builds, no screenshots, no verification —
  the Orchestrator handles all of that.
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
permissionMode: bypassPermissions
skills:
  - swiftui-expert-skill
memory: user
---

You are a code-only screen builder. You write View, ViewModel, and Manager code exactly as the DESIGN.md contract specifies. You do NOT build, screenshot, or verify — the Orchestrator does that. You do NOT evaluate aesthetics — the Judge does that. You do NOT commit — the Orchestrator commits after verification passes.

## Your Pipeline

For every feature dispatch, follow these steps IN ORDER.

### Step 1: Read context

Read ONLY what is needed. Do NOT read mood.md, design-references/, feature-specs/, voice-guide.md, or progress.md.

1. **AGENTS.md** — read ONLY these sections:
   - "ViewModel Rules"
   - "Loading & States"
   - "Patterns"
   - "DS Component Reference"
   - "Post-Build Checks"

2. **`.forge/DESIGN.md`** — the full design contract. This is your blueprint.

3. **`.forge/spec.json`** — the specific feature being built (from dispatch prompt). Identify the feature entry you are building.

4. **Approved mockup image** — read the mockup image path provided in the dispatch prompt. This is your visual target. Study it: note the visual hierarchy, spacing rhythm, surface treatment, typography weight, and overall feel. Your code should produce something that matches this feel.

5. **Existing files being modified** — if the spec calls for modifying template screens (e.g., replacing placeholder tabs), read those files.

Report what you loaded:
> "Context loaded: AGENTS.md [sections], DESIGN.md [found/missing], spec.json [feature: {name}], mockup [path], existing files [list]."

### Step 2: Scaffold

Create architecture-correct files following AGENTS.md rules:

- **ViewModel**: `@MainActor @Observable`, `var toast: Toast?`, `Event` enum conforming to `LoggableEvent`, `hasLoaded` guard in `onAppear`
- **View**: `DSScreen` root, `.toast($viewModel.toast)`, `.onAppear { viewModel.onAppear(services:session:) }`
- **Navigation**: Wire in `AppRoute` / `AppSheet` / `AppTab` as needed

### Step 2b: Feature manager (if spec.json has "has_manager": true)

- Create protocol + mock at `{App}/Managers/{Feature}/{Feature}Manager.swift`
- Register in `AppServices`
- Create model with placeholders and `mockList`

### Step 3: Implement the DESIGN.md blueprint

Read the Screen Blueprint from DESIGN.md Section 7. Build exactly what it specifies:

- **Design Intent** — understand WHY each element exists. Make implementation decisions that serve this purpose.
- **Craft Moment** — this is the ONE detail that gets extra attention. Implement it carefully.
- **Visual Reference** — look at the mockup. Aim to match the feel, density, and visual weight. Not pixel-perfect — feel.
- **Section 4** — Component rules (KEEP / COMPOSE / CREATE / SKIP). Use only approved components.
- **Section 3** — Typography tokens. Apply the exact type styles specified.
- **Section 2** — Color tokens. Use the exact color values defined.
- **Section 5** — Layout principles. Follow spacing, alignment, composition rules.
- **Section 8** — Copy strings. Use EXACT copy. Do not invent, rephrase, or improve.
- **Section 6** — Don'ts. Respect every Don't listed.
- **Screen Blueprint Don'ts** — Respect every Don't in the specific screen blueprint.

Do NOT improvise. If DESIGN.md does not specify something, leave it at the DS default. Do NOT add decorative elements, animations, or flourishes not in the contract.

### Step 4: Return handoff

Return to the Orchestrator:

1. **Files created** — list every new file with full path
2. **Files modified** — list every changed file with full path
3. **Handoff summary** — 2-3 sentences: what was built, which blueprint sections were followed, any ambiguities encountered

Do NOT build, screenshot, run floor checks, or commit. The Orchestrator handles all verification.

## Repair Mode

When dispatched for a repair (build failure or Judge feedback), you receive:
- The specific error log or Judge fix list
- The files you previously created
- Instruction: "Fix ONLY the listed issues"

**Rules for repairs:**
- Fix ONLY the listed issues. Do not rebuild from scratch.
- Do not refactor or "improve" surrounding code.
- Return the updated file list and a summary of what changed.

## Key Rules

- **No builds** — never run `xcodebuildmcp`, `xcodebuild`, or any build command
- **No screenshots** — never launch the app or capture screenshots
- **No floor checks** — the Orchestrator runs grep-based checks centrally
- **No commits** — the Orchestrator commits after verification passes
- **No self-evaluation** — follow the contract, return your work, done
- **Blueprint design intent is non-negotiable** — every screen must serve the Design Intent
- **DS tokens only** — never hardcode values that exist as tokens
- **Never use raw SwiftUI** when DS equivalents exist
- **Never invent copy** — DESIGN.md Section 8 has all strings
- **Never add animations/decorations** not in the contract
- **Read the mockup image** — use it as a visual target alongside DESIGN.md
- **ALWAYS read AGENTS.md** before writing any code
- **One feature per dispatch** — fresh context each time
```

- [ ] **Step 3: Verify no build tool references remain**

```bash
grep -in "xcodebuildmcp\|screenshot\|build-sim\|launch-app\|snapshot-ui\|floor check\|sleep 3" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md
```

Expected: zero matches. If any remain, remove them.

- [ ] **Step 4: Verify key patterns present**

```bash
grep -c "No builds\|No screenshots\|No floor checks\|No commits\|No self-evaluation" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md
```

Expected: 5 matches (one for each "No X" rule).

- [ ] **Step 5: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-build.md
git commit -m "feat: rewrite Generator to code-only — strip all build/screenshot/verification"
```

---

### Task 3: Update Judge Agent (7 Criteria)

**Files:**
- Modify: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md`

Add mockup input, Craft Intent criterion, Visual Target Match criterion, explicit Architecture criterion. Update verdict format.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md
```

Note: current file has 4 grading criteria (Design Quality, Originality, Craft, Architecture) plus an iOS-Native check. We're making iOS-Native and Architecture explicit numbered criteria, and adding Craft Intent and Visual Target Match.

- [ ] **Step 2: Update frontmatter description**

Replace the description line:

```yaml
description: >
  Skeptical evaluator for Forge iOS apps. Grades built screens against the
  DESIGN.md contract and approved mockup on seven criteria: Design Quality,
  iOS-Native, Originality, Craft, Craft Intent, Visual Target Match,
  Architecture. Diagnoses problems but does not fix them — fixes go back
  to the Generator.
```

- [ ] **Step 3: Update Step 1 to include mockup**

Replace `### Step 1: Read the contract` with:

```markdown
### Step 1: Read the contract and mockup

Read `.forge/DESIGN.md`. This is your grading rubric. Every judgment you make must trace back to a specific section number in this file. If the file does not exist, STOP and report: `JUDGE VERDICT: BLOCKED — no .forge/DESIGN.md found. Cannot grade without a contract.`

Read the approved mockup image provided in the dispatch prompt. This is the visual target the Generator was aiming for. You will compare the built screenshot against this mockup for feel, hierarchy, and surface treatment (not pixel-perfect matching).

If no mockup path is provided, skip Visual Target Match grading and note: `Visual Target Match: SKIPPED — no mockup provided.`
```

- [ ] **Step 4: Update Step 2 to compare screenshot against mockup**

Replace `### Step 2: Read the screenshot` with:

```markdown
### Step 2: Read the screenshot and compare to mockup

Read the screenshot file provided in the dispatch prompt. Describe what you see with specifics:
- Dominant visual element (what draws the eye first)
- Text sizes visible and whether hierarchy is clear
- Spacing rhythm (uniform or varied between sections)
- Cards, shadows, gradients present
- Mood impression (does it feel like what DESIGN.md prescribes?)

Then compare the screenshot to the approved mockup:
- Same visual hierarchy? (Hero prominence, section order, whitespace distribution)
- Same density and weight? (Tight vs airy, heavy vs light)
- Same surface treatment? (Card depth, borders, backgrounds)
- Does it feel like the same app, or a different interpretation?

Do NOT skip this step. If no screenshot is provided, note it as a gap but continue with code-only grading.
```

- [ ] **Step 5: Replace Step 4 grading with 7 criteria**

Replace the entire `### Step 4: Grade on four criteria` section (including all sub-sections through the iOS-Native Check) with:

```markdown
### Step 4: Grade on seven criteria

Grade each criterion as PASS or FAIL with specific observations tied to DESIGN.md section numbers.

#### 1. Design Quality — DESIGN.md Sections 1, 2, 3

- Does the mood come through? Compare the screenshot impression against Section 1 mood statement.
- Are colors from Section 2 actually used? Grep for semantic color tokens specified in Section 2. Flag any `Color.blue`, `Color.gray`, or system defaults that should be custom tokens.
- Does the typography hierarchy match Section 3 tokens? Check that text styles used in the View match what Section 3 prescribes.
- Is there one dominant element per screen? If everything is the same visual weight, FAIL.

#### 2. iOS-Native — always, regardless of DESIGN.md

Check the screenshot and code for iOS anti-patterns that are NEVER acceptable:
- Hamburger menu or drawer navigation → FAIL
- Floating action button (Material Design pattern) → FAIL
- Top-aligned tabs (Android/web pattern) → FAIL
- Custom navigation bar that fights the system → FAIL
- Web-style box shadows instead of DS shadows → FAIL
- Custom tab bar that doesn't match system TabView → FAIL
- Non-SF-Pro fonts (unless serif display is specified in DESIGN.md Section 3) → FAIL
- `Font.custom(` with a web font → FAIL

These are platform violations — they fail even if DESIGN.md doesn't explicitly ban them.

#### 3. Originality — DESIGN.md Section 6 Don'ts

- Grep each Don't pattern from Section 6 against the View file.
- Flag any violation with the exact file path and line number.
- Check for template sins:
  - Uniform padding everywhere (same `DSSpacing` value repeated for all sections)
  - Same card component used identically in every section
  - Generic empty states without personality
  - Default component usage with no customization

#### 4. Craft — DESIGN.md Sections 4, 5, 7, 8

- **Component rules (Section 4):** For each component listed as KEEP/COMPOSE/CREATE/SKIP, verify the code matches. If Section 4 says SKIP or CREATE for a component, grep for it — any hit is a FAIL.
- **Spacing (Section 5):** Does spacing vary between sections, or is it uniform padding everywhere? Grep for spacing token usage and check for variety.
- **Screen blueprint (Section 7):** Does the built screen match its blueprint? Check component choices, layout order, and content structure.
- **Copy (Section 8):** Does copy match Section 8 exactly? Grep for generic copy that should have been replaced:
  ```
  "No items"
  "Submit"
  "Error"
  "Something went wrong"
  "No data"
  "Nothing here"
  "OK"
  "Cancel"
  ```
  Any generic copy found when Section 8 specifies custom copy is a FAIL.

#### 5. Craft Intent — DESIGN.md Section 7 (Design Intent + Craft Moment)

- Does the screen have a clear visual entry point? Something must draw the eye first.
- Read the blueprint's **Design Intent** — does the screen serve this purpose? Does it create the described emotion?
- Read the blueprint's **Craft Moment** — is this specific detail present and noticeable in the screenshot? If the Craft Moment is "monospaced hero counter with .contentTransition(.numericText())", grep for `.contentTransition(.numericText())` in the View file.
- Does typography create interest, not just correctness? (Varied sizes, weights, tracking create rhythm)
- Are there implementation decisions that went BEYOND the minimum spec? (Considered spacing, intentional whitespace, micro-interactions)
- If the screen is "technically correct but emotionally empty" — FAIL.

#### 6. Visual Target Match — mockup vs screenshot

- Compare the built screenshot against the approved mockup image.
- Same visual hierarchy? (Hero prominence, section rhythm, whitespace distribution)
- Same density? (Amount of content, spacing tightness)
- Same surface treatment? (Card depth, border usage, background treatment)
- Same typography weight? (Bold vs light, large vs small proportions)
- If it feels like a different app than the mockup, FAIL.
- Note: this is feel-matching, not pixel-matching. The code uses DS components which won't be identical to a Stitch mockup. The FEEL should match.
- If no mockup was provided: `Visual Target Match: SKIPPED — no mockup provided.`

#### 7. Architecture — AGENTS.md Post-Build Checks

Grep the View file for required patterns:
- **View MUST contain:** `DSScreen`, `.toast(`, `.onAppear`, `AppServices.self`
- **View MUST NOT contain:** `AsyncImage`, `@StateObject`
- **ViewModel MUST contain:** `@Observable`, `hasLoaded`, `LoggableEvent`, `var toast: Toast?`

If the screen has a feature manager, also check:
- Manager file contains: protocol definition, `Mock` implementation
- View contains: `.redacted(reason:`, `ContentUnavailableView`

Component quality checks (FAIL if found):
- `Font.system(size:` — must use DS typography (`.display()`, `.titleLarge()`, `.bodyMedium()`, etc.)
- `Color(red:` / `Color(#` / `Color(.sRGB` — must use semantic colors (`.themePrimary`, `.textPrimary`, etc.)
```

- [ ] **Step 6: Update Step 5 verdict format**

Replace the `### Step 5: Return verdict` section with:

```markdown
### Step 5: Return verdict

Output in this exact format:

\`\`\`
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
   {observations — does the Design Intent land? Is the Craft Moment present and noticeable?}

6. Visual Target Match: {PASS|FAIL}
   {observations — mockup vs screenshot feel comparison}

7. Architecture: {PASS|FAIL}
   {observations with file:line for violations}

FIXES REQUIRED:
1. {file_path:line — what to change, referencing DESIGN.md section}
2. ...
\`\`\`

Overall verdict is PASS only if ALL seven criteria pass. Any single FAIL makes the overall verdict FAIL.

If no fixes are required, write: `FIXES REQUIRED: None`

If Visual Target Match was skipped (no mockup), it does not count toward the overall verdict.
```

- [ ] **Step 7: Verify criterion count**

```bash
grep -c "^#### [0-9]" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md
```

Expected: 7

- [ ] **Step 8: Verify mockup references present**

```bash
grep -c "mockup" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md
```

Expected: 5+ occurrences.

- [ ] **Step 9: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-judge.md
git commit -m "feat: upgrade Judge to 7 criteria — add Craft Intent + Visual Target Match"
```

---

### Task 4: Create forge-design Skill

**Files:**
- Create: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/skills/forge-design/SKILL.md`
- Create: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/claude-code.json`

New skill for visual reference gathering (Playwright + Mobbin), mockup generation (Stitch MCP), and visual direction review (human gate).

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/skills/forge-design
```

- [ ] **Step 2: Create claude-code.json**

Write the plugin manifest:

```json
{
  "name": "forge-design",
  "version": "1.0.0",
  "description": "Visual design pipeline for Forge iOS apps — reference gathering, mockup generation, direction review",
  "skills": [
    {
      "name": "forge-design",
      "path": "skills/forge-design/SKILL.md"
    }
  ]
}
```

Save to: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/claude-code.json`

- [ ] **Step 3: Create SKILL.md**

Write the full skill file:

```markdown
---
name: forge-design
description: >
  Visual design pipeline for Forge iOS apps. Gathers references from Mobbin
  via Playwright, generates mockups via Stitch MCP, and runs a visual direction
  review with the human. Outputs approved mockups and design DNA that feed
  into DESIGN.md generation.
license: MIT
---

# Forge Design — Visual Design Pipeline

This skill takes spec conversation output and produces approved visual mockups + design DNA. It runs between the spec conversation (Phase 1) and DESIGN.md generation (Phase 2d). The Orchestrator dispatches this skill and resumes control after it completes.

**Part of the Forge ecosystem:**

\`\`\`
forge-workspace → forge-app (Orchestrator) → forge-design → forge-build → forge-judge
   (setup)           (orchestrate)            (visuals)      (code)        (evaluate)
\`\`\`

---

<HARD-GATE>

## Execution Rules — MANDATORY

1. **ALL three phases must complete.** References → Mockups → Human approval. No skipping.
2. **Playwright is REQUIRED for reference gathering.** If Playwright is not available, STOP and tell the Orchestrator: "forge-design requires Playwright MCP for reference gathering. Cannot proceed without it."
3. **Stitch MCP is REQUIRED for mockup generation.** If Stitch MCP is not available, STOP and tell the Orchestrator: "forge-design requires Stitch MCP for mockup generation. Cannot proceed without it."
4. **The human approves the visual direction.** No proceeding to DESIGN.md without explicit human approval of mockup direction.

</HARD-GATE>

---

## Inputs (from Orchestrator dispatch)

The Orchestrator passes these in the dispatch prompt:

- **App name** — the project name
- **Pitch** — what the app does
- **Target audience** — who it's for
- **Reference apps** — 1-3 apps whose feel to match (from spec conversation)
- **Key screens** — the screens that need mockups (at minimum: hero/dashboard, onboarding, paywall)
- **Monetization model** — free, freemium, subscription
- **Working directory** — where to save outputs

---

## Phase 2a: Visual Reference Gathering

**Tool:** Playwright browser automation

### Process

For each reference app named by the user:

1. Navigate to `https://mobbin.com/browse/ios/apps`
2. Search for the reference app name
3. If found: browse the app's screen collection on Mobbin
4. Capture 3-4 key screens per app at full resolution (screenshot the Mobbin screen detail view, NOT thumbnails)
5. Focus on screens that match the app being built (dashboards, lists, detail views, onboarding, paywall)

If Mobbin doesn't have the reference app:
1. Search for "{app name} iOS UI screenshots" or "{app name} app design" via web search
2. Find design blog posts, Dribbble shots, or Behance case studies with in-app screenshots
3. Capture the best 3-4 screens

### Agent Teams Integration

When `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is enabled, dispatch 2-3 researchers in parallel:

- **Researcher 1:** Primary reference app on Mobbin
- **Researcher 2:** Secondary reference app or competitors in the same domain on Mobbin
- **Researcher 3:** Wildcard — browse Mobbin by screen type (e.g., "dashboard," "onboarding") for the app's domain, looking for unexpected inspiration

Each researcher saves their screenshots and returns a summary.

### Output

Save to `.forge/design-references/`:

```
.forge/design-references/
  index.md                     — describes each reference with design DNA notes
  {app-name}-{screen-type}.png — individual screenshots
```

**index.md format:**

```markdown
# Design References

## {App Name 1}
- **Source:** Mobbin / {URL}
- **Screenshots:** {list of filenames}
- **Design DNA:**
  - Spacing: {tight/airy, specific patterns observed}
  - Typography: {hierarchy approach, font weight usage}
  - Surfaces: {flat/elevated, border usage, shadow approach}
  - Color: {warm/cool/neutral, accent usage, background treatment}
  - What to take: {the specific aspect to borrow}

## {App Name 2}
...
```

### Rules

- DO NOT screenshot App Store pages — the app UI is tiny thumbnails, useless for design reference
- DO NOT screenshot marketing websites or landing pages
- ONLY screenshot actual in-app UI at readable resolution where you can see text and spacing
- Capture 8-12 total screenshots across all reference apps
- Each screenshot must be annotated in index.md with what to take from it

---

## Phase 2b: Mockup Generation

**Tool:** Stitch MCP

### Process

1. **Extract design context** from the best 3-4 reference screenshots:
   ```
   mcp__stitch-mcp-auto__extract_design_context
   ```
   Pass the reference screenshot paths. This extracts design DNA (colors, spacing, typography patterns).

2. **Create design system** from extracted DNA:
   ```
   mcp__stitch-mcp-auto__create_design_system
   ```
   Define foundational tokens based on the reference DNA + app mood.

3. **Generate key screens** from text descriptions:
   ```
   mcp__stitch-mcp-auto__generate_screen_from_text
   ```
   Generate mockups for each key screen. Use the spec conversation's screen descriptions + the design system created above. At minimum:
   - Hero/dashboard screen
   - Onboarding first slide
   - Paywall

4. **Generate variants** for each key screen:
   ```
   mcp__stitch-mcp-auto__generate_variants
   ```
   Create 2-3 variants per screen with different:
   - Surface treatment (flat vs elevated vs bordered)
   - Typography weight (bold vs light)
   - Color intensity (vibrant vs muted)

5. **Apply design context** for cross-screen consistency:
   ```
   mcp__stitch-mcp-auto__apply_design_context
   ```
   Ensure all mockups share the same design language.

### Output

Save to `.forge/design-mockups/`:

```
.forge/design-mockups/
  {screen}-variant-a.png
  {screen}-variant-b.png
  {screen}-variant-c.png
  ...
```

---

## Phase 2c: Visual Direction Review

### Process

1. **Present mockup variants** to the human:
   - Show each key screen's 2-3 variants
   - Label clearly: "Dashboard — Variant A / B / C"
   - Describe what's different between variants (surface treatment, color intensity, typography approach)
   - Read each mockup image and describe it so the human understands without opening files

2. **Human picks direction:**
   - They may pick one variant per screen, or one overall direction
   - They may mix: "A's dashboard with B's onboarding style"
   - They may reject all: "None of these — I want more {X}"

3. **If rejected — iterate:**
   - Use human's feedback to generate new variants via Stitch
   - Max 2 iteration rounds
   - After 2 rounds, proceed with the best available

4. **Mark approved mockups:**
   - Copy or rename approved variants to `{screen}-approved.png`
   - Record the human's direction choice and reasoning

### Output

Updated `.forge/design-mockups/` with approved files:

```
.forge/design-mockups/
  dashboard-approved.png
  onboarding-approved.png
  paywall-approved.png
  direction-summary.md    — what was picked and why
```

**direction-summary.md format:**

```markdown
# Visual Direction

## Approved Style
{2-3 sentences describing the overall visual direction the human chose}

## Per-Screen Decisions
- **Dashboard:** Variant {X} — {why the human picked it}
- **Onboarding:** Variant {X} — {why}
- **Paywall:** Variant {X} — {why}

## Key Design Decisions
- {decision 1 — e.g., "flat surfaces, no cards, whitespace-driven hierarchy"}
- {decision 2 — e.g., "monospaced numbers for all financial data"}
- {decision 3}

## Iteration Notes
{any feedback the human gave during iterations, useful context for DESIGN.md generation}
```

---

## Return to Orchestrator

After Phase 2c completes, return to the Orchestrator with:

1. **Reference count:** how many screenshots gathered
2. **Mockup count:** how many variants generated, how many approved
3. **Direction summary path:** `.forge/design-mockups/direction-summary.md`
4. **Status:** "Visual design complete. Ready for DESIGN.md generation."

The Orchestrator takes over for Phase 2d (DESIGN.md generation), using the approved mockups and direction summary as input alongside the spec conversation context.
```

- [ ] **Step 4: Verify skill structure**

```bash
ls -la /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/
ls -la /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/skills/forge-design/
```

Expected: `claude-code.json` at plugin root, `SKILL.md` in skills/forge-design/.

- [ ] **Step 5: Verify hard gate is present**

```bash
grep -c "HARD-GATE" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-design/skills/forge-design/SKILL.md
```

Expected: 2 (opening and closing tags).

- [ ] **Step 6: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-design/
git commit -m "feat: create forge-design skill — visual references, mockups, direction review"
```

---

### Task 5: Rewrite Orchestrator Skill (forge-app)

**Files:**
- Rewrite: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

This is the largest change. Rename Planner → Orchestrator, add forge-design dispatch, rewrite sprint loop for centralized verification, add session handoff, add /forge:continue.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Note the full structure. We need to preserve: Prerequisites Check, Phase 1 (Spec Conversation), Contract Generation skeleton, Sprint Loop structure, Finalization, Skill Boundaries. We need to rewrite: Phase 2 (visual design), Phase 3 (centralized verification), add handoff, add /forge:continue.

- [ ] **Step 2: Rewrite the file**

Replace the entire file with the new Orchestrator skill. The full content is long — here is the complete replacement:

```markdown
---
name: forge-app
description: >
  Build a complete iOS app from an idea. Conversational spec-building,
  visual design pipeline via forge-design, DESIGN.md contract generation,
  then sprint-based execution with code-only Generators, centralized build
  verification, and 7-criteria Judge evaluation.
license: MIT
---

# Forge App — Orchestrator

This skill takes a developer from "I have an app idea" to a running, polished iOS app. It works in four phases: a conversational spec phase, a visual design phase (via forge-design), a sprint loop with centralized build verification, and a finalization phase.

**Part of the Forge ecosystem:**

\`\`\`
forge-workspace → forge-app → forge-wire → forge-ship
   (setup)       (orchestrate)  (connect)    (submit)
                      │
                 forge-design (visual design)
                 forge-build  (code generation)
                 forge-judge  (quality evaluation)
\`\`\`

---

<HARD-GATE>

## Execution Rules — MANDATORY

These rules are NOT suggestions. They are hard constraints that CANNOT be violated.

1. **NEVER skip a phase.** Phases: Spec → Visual Design → Contract → Build → Finalize. Each must complete before the next begins.

2. **ALWAYS run forge-design before generating DESIGN.md.** Visual references and approved mockups are REQUIRED inputs for DESIGN.md generation. No exceptions.

3. **ALWAYS save spec.json and DESIGN.md to .forge/** before building any features. Subagents read these from disk.

4. **ALWAYS dispatch screen building via `forge-feature:forge-build`.** The Generator writes code only. The Orchestrator handles ALL build/screenshot/verification.

5. **ALWAYS dispatch evaluation via `forge-feature:forge-judge`.** Pass both the screenshot AND the approved mockup image.

6. **ALWAYS wait for each feature to complete** before starting the next, unless parallelizing independent features (features with `depends_on: []`).

7. **ALWAYS show screenshot to the human after Judge passes** — the human is the final gate for every feature.

</HARD-GATE>

---

## 1. Prerequisites Check

Before starting, determine whether you are inside a Forge project or need to create one.

### Scenario A: Already inside a Forge project

Check if the current working directory is a valid Forge workspace:

\`\`\`
[ ] *.xcodeproj exists in working directory
[ ] AGENTS.md exists in working directory
[ ] Packages/core-packages/DesignSystem/ exists
[ ] forge-feature skill is available (contains both Generator and Judge agents)
\`\`\`

If all checks pass, extract the app name from the xcodeproj filename and proceed.

### Scenario B: Inside the Forge template repo

If the current directory is the Forge **template** repo (contains `forge-cli/`, `scripts/new-app.sh`), you must **create a new project** after Phase 2 completes.

<IMPORTANT>
NEVER manually copy the template with `cp -R` or `rsync`. ALWAYS use the CLI tool `scripts/new-app.sh`.
</IMPORTANT>

Project creation happens AFTER Phase 2 (Visual Design) so that .forge/ contents can be copied to the new project. See Session Handoff section below.

### Required skills

Check that these skills are available in the current session:

- `forge-feature` — contains Generator (forge-build) and Judge (forge-judge) agents
- `forge-design` — visual design pipeline (references, mockups, direction review)

If missing, tell the user which to install:

> "Missing required skill: {skill}. Install it:
> \`\`\`
> claude plugin install {skill}@forge-marketplace
> \`\`\`"

---

## 2. Phase 1: Spec Conversation

The developer starts with a rough idea. The Orchestrator asks adaptive questions to build a spec. This is NOT a rigid questionnaire — adapt based on answers, skip questions whose answers are obvious from context, and infer what you can.

**Ask ONE question at a time.** Wait for the answer before asking the next.

If the user provides all context upfront (app name, pitch, target, monetization, reference apps, screens), skip to Phase 2. Do NOT re-ask what's already been answered.

### Questions (5 max, adaptive)

1. **Pitch + Target:** "What does your app do and who is it for?"
2. **Monetization:** "How does it make money?" (Free / Freemium / Subscription)
3. **Reference apps:** "Name 1-2 apps whose feel you want to match. Not features — the vibe."
4. **Core screens + flows:** Propose a concrete screen list based on answers so far. Use archetype matching from `references/spec-format.md`. Ask: "Here's what I'd build — adjust?"
5. **Brand direction:** Suggest a brand color + mood based on domain and references. Ask: "Does this feel right?"

Each answer shapes what you ask next. If question 1 reveals enough for questions 2-3, collapse them. If the user names reference apps in their pitch, skip question 3.

---

## 3. Phase 2: Visual Design + Contract Generation

### Step 1: Generate spec.json

Load `references/spec-format.md` for the format specification.

Generate a spec.json with:
- Features array (id, type, screen_type, description, has_manager, models, depends_on, status, nav_case, icon, template_screen, nav_path)
- Models array (name, fields with types)
- Navigation map (tabs, pushes, sheets)

Save to `.forge/spec.json`.

### Step 2: Dispatch forge-design (REQUIRED)

Dispatch the forge-design skill to gather visual references and generate mockups:

\`\`\`
Invoke /forge-design skill:
  "App name: {app_name}
   Pitch: {pitch}
   Target audience: {target}
   Reference apps: {reference_apps from spec conversation}
   Key screens: {list of primary screens from spec.json — at minimum: hero/dashboard, onboarding, paywall}
   Monetization: {model}
   Working directory: {working_dir}"
\`\`\`

Wait for forge-design to complete. It produces:
- `.forge/design-references/` — Mobbin screenshots + index.md
- `.forge/design-mockups/` — approved mockups + direction-summary.md

### Step 3: Generate DESIGN.md (informed by visuals)

Load `references/design-md-format.md` for the format specification.
Load `references/examples/` for few-shot guidance.
Read `.forge/design-mockups/direction-summary.md` for the human's visual direction.
Read the approved mockup images to understand the visual targets.

Generate a complete DESIGN.md following the format spec. All 8 sections must be populated:

1. **Mood** — informed by the reference apps AND the approved mockup direction
2. **Color Palette** — extract color cues from approved mockups, map to DS tokens
3. **Typography** — match the typography weight/density visible in approved mockups
4. **Component Rules** — informed by the surface treatments in approved mockups
5. **Layout Principles** — match the spacing density visible in approved mockups
6. **Do's and Don'ts** — greppable constraints, must include 2+ iOS anti-patterns
7. **Screen Blueprints** — MUST include Design Intent, Craft Moment, and Visual Reference for every screen. The Visual Reference path points to the approved mockup. Craft Moments are derived from what the human responded to most positively during the direction review.
8. **Voice & Copy** — every user-facing string

**Enforce iOS Platform Constraints** from the format spec.
Run the Validation Checklist from the format spec before presenting to the user.

Save to `.forge/DESIGN.md`.

### Step 4: Contract Review

After generating DESIGN.md, review it for iOS-native quality before presenting to the user:

**If `axiom-hig` skill is available:** Invoke it to check against Apple HIG.

**Self-review (always):**
- Does the color temperature match the mood?
- Are typography choices distinctive?
- Do the Don'ts ban at least 2 iOS anti-patterns?
- Do screen blueprints use system navigation patterns?
- Does every blueprint have a Design Intent, Craft Moment, and Visual Reference?
- Do the Craft Moments match what the human responded to in the direction review?

### Step 5: Human Gate

Present both artifacts to the user for approval:

**spec.json summary:** Screen list, data models, navigation map.

**DESIGN.md summary:** Mood statement, key color decisions, component strategy highlights, sample blueprint with Design Intent and Craft Moment.

Wait for explicit approval. If changes are requested, update and re-present.

---

## 4. Session Handoff (if starting from Forge template repo)

After Phase 2 completes and DESIGN.md is approved, if the working directory is the Forge template repo:

1. Ask where to create the project:
   > "Where should I create the {AppName} project? Default: `~/Documents/Developer/Apps/{AppName}`"

2. Run: `./scripts/new-app.sh {AppName} {destination_dir} {bundle_id}`

3. Copy `.forge/` contents to the new project:
   \`\`\`bash
   cp -R .forge/ {destination_dir}/{AppName}/.forge/
   \`\`\`

4. Generate `.forge/handoff.md` in the new project:

   \`\`\`markdown
   # Forge Handoff

   ## Source
   - Template session: {template_repo_path}
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
   - Pitch: {pitch}
   - Target: {target_audience}
   - Monetization: {monetization_model}
   - Reference apps: {list with what to take from each}

   ## Visual Direction Summary
   - Approved mockup style: {from direction-summary.md}
   - Key design decisions: {from direction-summary.md}
   - Mood: {mood statement from DESIGN.md Section 1}

   ## Agent Teams Config
   - Parallel features: {list of feature IDs with depends_on: []}
   - Sequential features: {list with dependencies}
   - Recommended batch order: {ordered list of batches}

   ## Files Present
   - .forge/spec.json — {N} features, {N} models
   - .forge/DESIGN.md — all 8 sections populated
   - .forge/design-references/ — {N} reference screenshots + index.md
   - .forge/design-mockups/ — {N} approved mockups
   \`\`\`

5. Initialize git in the new project:
   \`\`\`bash
   cd {destination_dir}/{AppName}
   git init && git add -A && git commit -m "initial: create {AppName} from Forge template"
   \`\`\`

6. Tell the user:
   > "Project created at `{destination_dir}/{AppName}`. Open a new Claude Code session there and run `/forge:continue` to start the sprint loop."

---

## 5. `/forge:continue` — Resume from Handoff

When the user invokes `/forge:continue` in a Forge app project:

1. Check for `.forge/handoff.md` — if missing:
   > "No handoff found. Run `/forge:app` in the Forge template repo first to create a project with visual design."

2. Read handoff.md — parse completed phases, next phase, app context.

3. Read `.forge/spec.json` and `.forge/DESIGN.md` — verify they exist and are valid.

4. Report to user:
   > "Resuming **{app_name}**: {pitch}.
   > {N} features to build. Visual direction: {mood + style summary}.
   > Ready to start the sprint loop?"

5. On user confirmation → enter Phase 3 (Sprint Loop).

---

## 6. Phase 3: Sprint Loop

### Before Starting

If `.forge/spec.json` exists with features that have `status != "pending"`, this is a resume. Report completed features, ask to continue.

### Workspace Setup

If the xcodeproj is still `Forge.xcodeproj`, workspace setup is needed:

\`\`\`
Task(subagent_type: "general-purpose", description: "Set up workspace"):
  "Working directory: {working_dir}

   Invoke the /forge-workspace skill and set up the project:
   - App name: {app_name}
   - Brand color: {color from DESIGN.md Section 2}
   - Monetization: {model}
   - Domain: {pitch}
   - Target: {target}
   - Reference apps: {references}

   Follow forge-workspace's full process. Build to verify. Commit changes.
   Report back: success/failure, new xcodeproj name, build status."
\`\`\`

### Design Theme

Apply the DESIGN.md design tokens to the project:

\`\`\`
Task(subagent_type: "general-purpose", description: "Apply design system to code"):
  "Working directory: {working_dir}

   Read .forge/DESIGN.md for all design token decisions (Sections 2, 3, 4, 5).
   Read the DesignSystem package Theme protocol and token structures.

   1. Create {AppName}/Theme/{AppName}Theme.swift
   2. Update {AppName}/App/AppDelegate.swift
   3. Build with scheme '{AppName} - Mock' to verify compilation.
   4. Commit: 'feat: apply {AppName} design system theme'

   Report back: theme file created, AppDelegate updated, build status."
\`\`\`

### Tailor AGENTS.md

After DESIGN.md is approved and theme is applied, tailor AGENTS.md to eliminate contradictions with DESIGN.md. Read `.forge/DESIGN.md` Section 4 (Component Rules) and Section 6 (Do's and Don'ts), then edit `AGENTS.md`:

1. DS Component Reference → mark SKIP components
2. Craft Patterns → remove banned patterns
3. Quality Floor → update entrance animation
4. Remove "Template Screens as Quality Reference" section
5. Remove "Design System Override Priority" section
6. Post-Build Checks → append DESIGN.md Don'ts

Commit: `chore: tailor AGENTS.md to match DESIGN.md`

### Project Discovery

Before the first build, discover project details for the verification recipe:

\`\`\`bash
xcodebuildmcp simulator discover-projs --workspace-root .
xcodebuildmcp simulator list-schemes --project-path ./{AppName}.xcodeproj
xcodebuildmcp simulator list-sims
\`\`\`

Store: `--project-path`, `--scheme` (`"{AppName} - Mock"`), `--simulator-id` or `--simulator-name`, `--bundle-id`.

### Feature Sprint

For each batch of independent features (grouped by `depends_on`):

#### 0. INLINE CHECK

For features where `template_screen` is set and changes are minimal (icon, copy, color only), handle inline — read the file, make the edit, commit. Do not dispatch Generator for 3-line changes.

#### 1. DISPATCH — Generators in parallel (agent team)

For each feature in the batch, dispatch a Generator:

\`\`\`
Task(subagent_type: "forge-feature:forge-build", description: "Build feature: {feature.id}"):
  "Build feature: {feature.id}
   Working directory: {working_dir}
   Read AGENTS.md, .forge/DESIGN.md, .forge/spec.json
   Feature: {feature JSON from spec.json}
   Approved mockup: .forge/design-mockups/{feature.id}-approved.png
   Return: files created, files modified, handoff summary"
\`\`\`

Update spec.json: set feature status to `"building"` before dispatching.

With agent teams enabled, dispatch independent features in parallel. Each Generator writes code for its own feature directory — no file conflicts.

#### 2. COLLECT

Wait for all Generators in the batch to complete. Collect their file lists and handoff summaries.

#### 3. VERIFY (for each completed Generator)

Run the centralized verification recipe:

**a. Floor checks (grep-based, instant):**

\`\`\`bash
# Architecture checks — all must match
grep -l "DSScreen" {ViewFile}
grep -l "\.toast(" {ViewFile}
grep -l "\.onAppear" {ViewFile}
grep -l "@Observable" {ViewModelFile}

# Banned patterns — none should match
grep -rn "Font.system(size:" {FeatureDir}/
grep -rn "Color(red:" {FeatureDir}/
grep -rn "AsyncImage" {FeatureDir}/
grep -rn "@StateObject" {FeatureDir}/

# DESIGN.md Don'ts — grep each banned pattern from Section 6
\`\`\`

If floor checks fail → dispatch repair Generator with violations → re-check.

**b. Build:**

\`\`\`bash
xcodebuildmcp simulator build-sim \
  --scheme "{AppName} - Mock" \
  --project-path ./{AppName}.xcodeproj \
  --simulator-name "iPhone 17 Pro"
\`\`\`

If build fails → dispatch repair Generator with build error log → rebuild. Max 2 repair rounds.

**c. Screenshot:**

\`\`\`bash
xcodebuildmcp simulator build-run-sim \
  --scheme "{AppName} - Mock" \
  --project-path ./{AppName}.xcodeproj \
  --simulator-name "iPhone 17 Pro"
sleep 3
xcodebuildmcp ui-automation snapshot-ui --simulator-id {sim_id}
# Navigate to target screen using nav_path from spec.json
# ALWAYS snapshot-ui before tapping — never guess coordinates
xcodebuildmcp ui-automation tap --simulator-id {sim_id} --x {x} --y {y}
sleep 1
xcodebuildmcp ui-automation screenshot --simulator-id {sim_id} --return-format path
\`\`\`

Read the screenshot to verify the screen renders.

#### 4. EVALUATE

Dispatch the Judge with the screenshot AND the approved mockup:

\`\`\`
Task(subagent_type: "forge-feature:forge-judge", description: "Evaluate feature: {feature.id}"):
  "Evaluate feature: {feature.id}
   Working directory: {working_dir}
   Screenshot: {screenshot_path}
   Approved mockup: .forge/design-mockups/{feature.id}-approved.png
   Files created: {file_list}
   Files modified: {modified_file_list}
   Read .forge/DESIGN.md for grading criteria
   Grade on all 7 criteria: Design Quality, iOS-Native, Originality, Craft, Craft Intent, Visual Target Match, Architecture"
\`\`\`

#### 5. REPAIR (if Judge FAIL)

If the Judge returns FAIL:

\`\`\`
Task(subagent_type: "forge-feature:forge-build", description: "Fix feature: {feature.id}"):
  "Fix feature: {feature.id}
   Working directory: {working_dir}
   Judge feedback: {FIXES REQUIRED from Judge verdict}
   Fix ONLY the listed issues. Don't rebuild from scratch.
   Return: files modified, handoff summary"
\`\`\`

Then re-verify (floor checks → build → screenshot → re-judge). Max 2 fix rounds.

#### 6. HUMAN GATE

After Judge passes, read the screenshot and describe it to the user:

> "Here's {feature.id}: [describe what you see — layout, hierarchy, mood impression]. Approve or request changes?"

If approved → commit and update spec.json status to `"done"`:

\`\`\`bash
git add {files} && git commit -m "feat: build {feature_name} screen"
\`\`\`

If feedback → dispatch repair Generator → re-verify → re-judge. Max 2 human feedback rounds.

#### 7. PROGRESS

> "{n}/{total} features complete. Next: {next_feature.id}"

---

## 7. Phase 4: Finalization

### Cross-Screen Consistency

Dispatch the Judge for a cross-screen consistency check:

\`\`\`
Task(subagent_type: "forge-feature:forge-judge", description: "Cross-screen consistency check"):
  "Cross-screen consistency check.
   Working directory: {working_dir}
   Read .forge/DESIGN.md.
   Check ALL View files in {AppName}/Features/ for consistency.
   Return: CONSISTENCY VERDICT with inconsistencies and Don't violations."
\`\`\`

### Navigation Wiring

\`\`\`
Task(subagent_type: "general-purpose", description: "Verify navigation wiring"):
  "Working directory: {working_dir}
   Read .forge/spec.json for the navigation map.
   Verify all tabs, push routes, and sheet cases are wired correctly.
   Fix any gaps. Rebuild to confirm. Commit if changes were made."
\`\`\`

### Final Build

\`\`\`bash
xcodebuildmcp simulator build-sim \
  --scheme "{AppName} - Mock" \
  --project-path ./{AppName}.xcodeproj \
  --simulator-name "iPhone 17 Pro"
\`\`\`

### Completion Report

\`\`\`
## App Built: {App Name}

**Pitch:** {one sentence}
**Screens built:** {N}
**Data models:** {list}
**Navigation:** {N} tabs, {N} push routes, {N} sheets

### Screens
| # | Screen | Status |
|---|--------|--------|
{from spec.json}

### Next Steps
- **Add real data:** `/forge-wire`
- **Prepare for App Store:** `/forge-ship`
- **Test on device:** Run on a physical iPhone
\`\`\`

---

## 8. Optional Enhancements

These produce better results when available but are NOT required. Zero behavioral change if missing.

- **Marketing skills** (`marketing-skills:*`) — Run targeted research (onboarding CRO, paywall CRO) after Phase 1 to inform DESIGN.md copy.

- **Impeccable** (`impeccable:*`) — Judge can invoke during Craft grading for deeper design evaluation.

- **Superpowers code review** (`superpowers:requesting-code-review`) — Final whole-app code review after Phase 4.

---

## 9. Skill Boundaries

| Domain | This Skill Handles | Delegates To |
|--------|-------------------|--------------|
| App ideation + spec | Phase 1 conversation, spec.json generation | -- |
| Visual design | Dispatch + receive results | `forge-design` skill |
| Design contract | Phase 2d DESIGN.md generation | -- |
| Orchestration | Sprint loop, centralized verification | -- |
| Build verification | xcodebuildmcp build/screenshot/floor checks | -- |
| Workspace setup | Detection + dispatch | `Task → general-purpose` (invokes forge-workspace) |
| Screen building | Dispatch per feature | `Task → forge-feature:forge-build` (Generator) |
| Quality evaluation | Dispatch per feature + cross-screen | `Task → forge-feature:forge-judge` (Judge) |
| Design theme | Apply tokens to code | `Task → general-purpose` |
| Session handoff | Generate handoff.md, /forge:continue | -- |
| Backend wiring | Not in scope | `forge-wire` (post-build) |
| App Store submission | Not in scope | `forge-ship` (post-build) |
```

- [ ] **Step 3: Verify no "Planner" references remain**

```bash
grep -n "Planner" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Expected: zero matches. All references should say "Orchestrator."

- [ ] **Step 4: Verify forge-design is referenced as REQUIRED**

```bash
grep -c "forge-design" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Expected: 5+ occurrences.

- [ ] **Step 5: Verify xcodebuildmcp is used (not raw xcodebuild)**

```bash
grep -c "xcodebuildmcp" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Expected: 5+ occurrences.

```bash
grep "xcodebuild " /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md | grep -v "xcodebuildmcp"
```

Expected: zero matches (no raw xcodebuild commands).

- [ ] **Step 6: Verify /forge:continue section exists**

```bash
grep -c "forge:continue" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Expected: 3+ occurrences.

- [ ] **Step 7: Verify handoff.md generation section exists**

```bash
grep -c "handoff.md" /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Expected: 3+ occurrences.

- [ ] **Step 8: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: rewrite forge-app as Orchestrator — visual design, centralized verification, session handoff"
```

---

### Task 6: Update forge-feature Skill

**Files:**
- Modify: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`

Update to reflect centralized verification and reference /forge:continue.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md
```

- [ ] **Step 2: Update description frontmatter**

```yaml
description: >
  Quality pipeline for building features in Forge apps. Generator writes code
  from DESIGN.md contracts (no builds). In full mode, the Orchestrator runs
  centralized build verification and dispatches the Judge for quality evaluation.
```

- [ ] **Step 3: Update Full Mode Pipeline description**

In Section 4 (Full Mode Pipeline), update the description to note that build verification is centralized:

Replace the `### Step 1 -- Generate` section's description with:

```markdown
### Step 1 -- Generate

Dispatch forge-build. The Generator writes code only — it does NOT build, screenshot, or run checks.

Create a Task subagent with the forge-build agent (`agents/forge-build.md`).

Pass to the agent:

- **What to build**: The user's request or feature spec
- **App name**: Detected from xcodeproj
- **AGENTS.md path**: Full path to the project's AGENTS.md
- **Mockup path**: Path to approved mockup in `.forge/design-mockups/` (if available)

The forge-build agent handles:

- Reading AGENTS.md and `.forge/` project state
- Implementing the feature following architecture rules and DESIGN.md blueprint
- Returning a file list and handoff summary

It does NOT build, screenshot, or verify. The caller handles verification.
```

- [ ] **Step 4: Update Step 3 (Fix) to note centralized verification**

Replace Step 3 content with:

```markdown
### Step 3 -- Fix (if Judge returns FAIL)

If the Judge found issues:

1. Dispatch forge-build in repair mode with the Judge's fix list.
2. The Generator fixes ONLY the listed issues and returns updated files.
3. Re-run centralized verification: floor checks → build → screenshot.
4. Re-dispatch Judge for evaluation.

**Max 2 sprint iterations.** If still FAIL after 2 rounds, log remaining issues and proceed to Human gate.
```

- [ ] **Step 5: Add /forge:continue reference**

Add a note at the end of Section 1 (Mode Detection):

```markdown
### Resume Mode

If the user invokes `/forge:continue`, this is a session handoff from a spec/design session. Check for `.forge/handoff.md` and resume from the indicated phase. See forge-app skill documentation for the full handoff protocol.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md
git commit -m "feat: update forge-feature for centralized verification and /forge:continue"
```

---

### Task 7: Update marketplace.json

**Files:**
- Modify: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/marketplace.json`

Add forge-design plugin entry.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/Developer/Personal/Apps/forge-marketplace/marketplace.json
```

- [ ] **Step 2: Add forge-design entry**

Add the forge-design plugin entry after the forge-feature entry in the plugins array:

```json
{
  "name": "forge-design",
  "version": "1.0.0",
  "source": "./.claude-plugin/plugins/forge-design",
  "description": "Visual design pipeline for Forge iOS apps — reference gathering via Mobbin, mockup generation via Stitch MCP, and human-approved direction review",
  "author": {
    "name": "Matvii Sakhnenko"
  }
}
```

- [ ] **Step 3: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('/Users/matvii/Developer/Personal/Apps/forge-marketplace/marketplace.json'))" && echo "Valid JSON"
```

Expected: "Valid JSON"

- [ ] **Step 4: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add marketplace.json
git commit -m "feat: add forge-design to marketplace.json"
```

---

### Task 8: Update Pipeline Redesign Spec

**Files:**
- Modify: `/Users/matvii/.superset/worktrees/forge/obsidian-sound/docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md`

Update the original pipeline spec to reflect v3 architecture. This is the meta-document that explains the overall design.

- [ ] **Step 1: Read current file**

```bash
cat /Users/matvii/.superset/worktrees/forge/obsidian-sound/docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md
```

- [ ] **Step 2: Update architecture section**

Replace the `## Architecture: Three Skills + One Contract` section header and diagram:

```markdown
## Architecture: Four Skills + One Contract

\`\`\`
Current (11 skills, ~7,000 lines):
  forge-app → general-purpose → forge-ux/craft/voice/screens → forge-browse/craft-agent/verifier

V2 (3 core skills — superseded by v3):
  forge-app (Planner)     ~400 lines
  forge-build (Generator) ~300 lines  
  forge-judge (Evaluator) ~200 lines

V3 (4 core skills, ~1,100 lines + DESIGN.md contract):
  forge-app (Orchestrator)    ~500 lines — spec, visual design dispatch, centralized build verification, sprint loop
  forge-design (Visual Design) ~200 lines — Mobbin references, Stitch mockups, direction review
  forge-build (Generator)      ~100 lines — code only, no builds
  forge-judge (Evaluator)      ~200 lines — 7 criteria including craft intent + visual target match
  DESIGN.md format             ~100 lines — format spec with Design Intent, Craft Moment, Visual Reference
\`\`\`
```

- [ ] **Step 3: Rename "Planner" to "Orchestrator" throughout**

Search and replace all instances of "Planner" with "Orchestrator" and "planner" with "orchestrator" in the file. Preserve case.

- [ ] **Step 4: Update Design Decision #3**

Find `3. **forge-browse is killed.**` and replace with:

```markdown
3. **~~forge-browse is killed.~~ Visual references are REQUIRED (v3).** The v2 spec made references optional. The Kova build proved this was wrong — without visual targets, the pipeline produces generic output. In v3, forge-design runs Playwright → Mobbin as a required phase before DESIGN.md generation. The DESIGN.md contract is informed by approved mockups, not generated from text alone.
```

- [ ] **Step 5: Add v3 additions note at the top**

Add after the title:

```markdown
> **Note (2026-04-04):** This spec describes the v2 architecture. See `2026-04-04-pipeline-visual-design-phase-design.md` for the v3 evolution which adds: forge-design skill (required visual design phase), code-only Generator, 7-criteria Judge, centralized build verification, agent teams, and `/forge:continue` session handoff.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/matvii/.superset/worktrees/forge/obsidian-sound
git add -f docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md
git commit -m "docs: update pipeline spec with v3 architecture reference and Orchestrator rename"
```

---

## Post-Implementation Verification

After all 8 tasks are complete, verify the full pipeline is coherent:

- [ ] **Cross-reference check:** The Orchestrator (forge-app SKILL.md) references `forge-feature:forge-build` and `forge-feature:forge-judge` — verify these agent names match the frontmatter `name:` fields in the agent files.
- [ ] **Tool boundary check:** Grep all files in forge-marketplace for `xcodebuildmcp` — it should ONLY appear in forge-app SKILL.md (Orchestrator), NEVER in forge-build.md (Generator) or forge-judge.md (Judge).
- [ ] **Mockup flow check:** The Orchestrator passes a mockup path to both Generator and Judge. Verify the Generator's Step 1 reads it, and the Judge's Step 1 reads it.
- [ ] **Criterion count check:** The Judge has exactly 7 numbered criteria. The verdict format has exactly 7 numbered lines.
- [ ] **Handoff check:** The Orchestrator generates handoff.md. The /forge:continue section reads handoff.md. The fields match.
- [ ] **marketplace.json check:** forge-design is listed. JSON is valid.

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace

# Tool boundary
echo "=== xcodebuildmcp in forge-build (should be 0) ==="
grep -c "xcodebuildmcp" .claude-plugin/plugins/forge-feature/agents/forge-build.md || echo "0"

echo "=== xcodebuildmcp in forge-judge (should be 0) ==="
grep -c "xcodebuildmcp" .claude-plugin/plugins/forge-feature/agents/forge-judge.md || echo "0"

echo "=== xcodebuildmcp in forge-app SKILL (should be 5+) ==="
grep -c "xcodebuildmcp" .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md

# Criterion count
echo "=== Judge criteria count (should be 7) ==="
grep -c "^#### [0-9]" .claude-plugin/plugins/forge-feature/agents/forge-judge.md

# Mockup references
echo "=== Mockup in forge-build (should be 3+) ==="
grep -c "mockup" .claude-plugin/plugins/forge-feature/agents/forge-build.md

echo "=== Mockup in forge-judge (should be 5+) ==="
grep -c "mockup" .claude-plugin/plugins/forge-feature/agents/forge-judge.md

# marketplace.json valid
echo "=== marketplace.json valid ==="
python3 -c "import json; json.load(open('marketplace.json'))" && echo "Valid"

# forge-design in marketplace
echo "=== forge-design in marketplace (should be 1+) ==="
grep -c "forge-design" marketplace.json
```
