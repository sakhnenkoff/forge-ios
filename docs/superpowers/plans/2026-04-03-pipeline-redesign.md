# Pipeline Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 11-skill Forge pipeline with a 3-skill Planner-Generator-Evaluator architecture that produces better iOS apps with ~65% fewer tokens.

**Architecture:** Three core skills (forge-app Planner, forge-build Generator, forge-judge Evaluator) communicate through two contract files (spec.json + DESIGN.md). Each skill is a flat dispatch from the Planner — no intermediate agents, no skill-within-skill invocation.

**Tech Stack:** Claude Code skills (markdown), Claude Code agents (markdown), marketplace plugin packaging (claude-code.json)

**Repos:**
- Template: `/Users/matvii/Developer/Personal/Templates/forge` (this repo)
- Marketplace: `/Users/matvii/Developer/Personal/Apps/forge-marketplace`
- Marketplace plugins: `/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/`

---

### Task 1: Create DESIGN.md Format Specification

**Files:**
- Create: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md`

This reference file defines the DESIGN.md contract format. It's loaded by the Planner when generating DESIGN.md for a new app.

- [ ] **Step 1: Create the format specification**

```markdown
# DESIGN.md Format — iOS/SwiftUI Design Contract

This format defines a prescriptive design contract that AI build agents follow mechanically.
It replaces descriptive design specs (mood.md, design-system.md, voice-guide.md) with a single
file of explicit constraints, semantic tokens, and banned patterns.

Based on Google Stitch's DESIGN.md concept, adapted for SwiftUI + Forge DesignSystem tokens.

## Required Sections

### 1. Mood (2 lines max)
One sentence describing what the app should FEEL like. One sentence naming 1-2 reference apps.

Example:
> Ledgr should feel like a clinical financial instrument — precise, quiet, trustworthy.
> Reference: Mercury's number treatment, Flighty's floating layout.

### 2. Color Palette (table)

| Role | Light | Dark | SwiftUI Token | Usage Rule |
|------|-------|------|---------------|------------|

Required roles: brand, background, surface, surfaceVariant, textPrimary, textSecondary, textTertiary, positive, negative, border, divider.

Every role maps to a `Color.*` extension from the DesignSystem package. The "Usage Rule" column says WHERE this color goes — not just its name.

### 3. Typography (table)

| Role | DS Token | Design Variant | Weight | Tracking | Usage |
|------|----------|----------------|--------|----------|-------|

Required roles: display, titleLarge, titleMedium, titleSmall, headlineMedium, bodyLarge, bodyMedium, bodySmall, captionLarge, buttonMedium.

Design Variant is one of: `.default`, `.rounded`, `.monospaced`, `.serif`. This is what creates typographic personality — not font size alone.

### 4. Component Rules (table)

| DS Component | Decision | Instructions |
|-------------|----------|--------------|

Decision is one of:
- **YES** — use as-is with default API
- **CUSTOMIZE** — use but modify (instructions say how)
- **NO** — don't use (instructions say what to do instead)

Every DS component from AGENTS.md must appear in this table. No omissions.

### 5. Layout Principles (5 bullet points max)
Specific spacing rules using DS token names. Must include:
- Section-to-section spacing (which DSSpacing token)
- Within-section spacing (which DSSpacing token)
- Hero element treatment
- Hierarchy rule (how many text sizes minimum)

### 6. Do's and Don'ts (the critical section)
Two lists. Do's: 4-6 specific patterns TO use. Don'ts: 6-10 specific patterns to NEVER use.

Every Don't must name the specific thing being banned and can be verified by grep.
Bad: "Don't make it look generic." (Not greppable.)
Good: "Don't use StaggeredVStack." (Greppable.)
Good: "Don't use AmbientBackground." (Greppable.)
Good: "Don't use DSHeroCard for hero numbers." (Greppable.)

### 7. Screen Blueprints (one per screen)
Each blueprint has:
- **Hero:** what the dominant element is, which DS tokens it uses, alignment
- **Sections:** top-to-bottom flow with spacing tokens between them
- **List/content:** how items are structured
- **Empty state:** exact copy string from Section 8
- **Entrance:** animation type and spring
- **Don't:** 3-5 specific things NOT to do on this screen

Blueprints describe WHAT the screen looks like. The build agent decides HOW (SwiftUI containers, modifiers).

### 8. Voice & Copy (table)

| Screen | Element | Copy |
|--------|---------|------|

Every user-facing string: empty states, error toasts, button labels, placeholder text, onboarding steps, section titles. No element should require the build agent to invent copy.

## Validation Checklist

A valid DESIGN.md must pass:
- [ ] Every DS component from AGENTS.md appears in Section 4
- [ ] Section 6 Don'ts list has 6+ entries, all greppable
- [ ] Every screen in spec.json has a blueprint in Section 7
- [ ] Every screen's empty state copy appears in Section 8
- [ ] Color palette has 11+ roles with hex values for both modes
- [ ] Typography table has 10+ roles with DS token mappings
```

- [ ] **Step 2: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md
git commit -m "feat: add DESIGN.md format specification for prescriptive design contracts"
```

---

### Task 2: Create Example DESIGN.md Files

**Files:**
- Create: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/examples/clinical-finance.md`
- Create: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/examples/warm-habit.md`

Two complete examples showing what a good DESIGN.md looks like for different moods. These serve as few-shot examples for the Planner.

- [ ] **Step 1: Create clinical/finance example**

Write a complete DESIGN.md for a "Ledgr" expense tracker app with clinical/precise mood. Include all 8 sections fully populated. This is the example from the design spec — flesh it out completely with:
- Full color palette (11 roles, light+dark hex values)
- Full typography table (10 roles with monospaced numbers, default body)
- Component rules for every DS component (DSButton YES, DSHeroCard NO, etc.)
- Layout principles (tight within groups, generous between sections)
- 8+ Don'ts (no AmbientBackground, no DSHeroCard, no StaggeredVStack, no bouncy springs, etc.)
- Screen blueprints for Dashboard, Transactions, Settings, Add Transaction
- Complete copy table for all screens and states

- [ ] **Step 2: Create warm/habit-tracker example**

Write a complete DESIGN.md for a "HabitFlow" habit tracker with warm/encouraging mood. Demonstrate how the format adapts: .rounded typography, warm color temperature, DSHeroCard YES (with modifications), bouncy springs OK, friendly copy.

- [ ] **Step 3: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/references/examples/
git commit -m "feat: add clinical and warm DESIGN.md examples for Planner few-shot"
```

---

### Task 3: Build the Judge Agent (forge-judge)

**Files:**
- Create: `forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md`

The Judge is a dedicated subagent that grades build output against the DESIGN.md contract. It has Read/Grep/Glob/Bash tools only — no Write/Edit.

- [ ] **Step 1: Write the forge-judge agent definition**

```markdown
---
name: forge-judge
description: >
  Skeptical evaluator for Forge iOS apps. Grades built screens against the
  DESIGN.md contract on four criteria: Design Quality, Originality, Craft,
  Architecture. Diagnoses problems but does not fix them.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: bypassPermissions
memory: user
---

You are a skeptical quality evaluator. Assume the output is mediocre until proven otherwise.
Your job is to catch problems, not praise competence. Every judgment must trace back to a
specific section of the DESIGN.md contract.

## Your Pipeline

### Step 1: Read the contract

Read `.forge/DESIGN.md`. This is your grading rubric. Every grade references a specific section.

### Step 2: Read the screenshot

Read the screenshot file provided in your dispatch prompt. Describe what you see:
- What is the dominant element?
- How many text sizes are visible?
- What is the spacing rhythm (tight/generous/uniform)?
- Are there card wrappers? Shadows? Gradients?
- Does the overall feel match Section 1 (Mood)?

### Step 3: Read the code

Read the View and ViewModel files listed in your dispatch prompt.

### Step 4: Grade on four criteria

**1. Design Quality (PASS/FAIL)**
Check against DESIGN.md Sections 1, 2, 3:
- Does the mood come through in the screenshot?
- Are the colors from Section 2 actually used (not system defaults)?
- Does the typography hierarchy match Section 3 tokens?
- Is there one dominant element per screen?

**2. Originality (PASS/FAIL)**
Check against DESIGN.md Section 6 Don'ts:
- Grep each Don't pattern against the View file
- Flag any Don't violation with the exact line
- Check for template sins: uniform padding, same card everywhere, generic empty states

**3. Craft (PASS/FAIL)**
Check against DESIGN.md Sections 4, 5, 7, 8:
- Component rules: are YES/NO/CUSTOMIZE decisions followed? (Section 4)
- Layout principles: does spacing vary between sections? (Section 5)
- Screen blueprint: does the screen match its blueprint? (Section 7)
- Copy: does every user-facing string match Section 8 exactly?
  Grep for generic copy: "No items", "Submit", "Error", "Something went wrong"
  If found AND Section 8 has specific copy for that element → FAIL

**4. Architecture (PASS/FAIL)**
Check against AGENTS.md Post-Build Checks:
- View: DSScreen, .toast(, .onAppear, AppServices.self present
- View: AsyncImage, @StateObject absent
- ViewModel: @Observable, hasLoaded, LoggableEvent, var toast: Toast? present
- If manager exists: protocol + Mock, .redacted(reason:, ContentUnavailableView
- No Font.system(size: — must use DS typography
- No Color(red: / Color(# — must use semantic colors

### Step 5: Return verdict

```
JUDGE VERDICT: {PASS|FAIL}

Design Quality: {PASS|FAIL}
  {2-3 specific observations referencing DESIGN.md sections}

Originality: {PASS|FAIL}
  {list any Don't violations with file:line}

Craft: {PASS|FAIL}
  {component rule violations, spacing issues, copy mismatches}

Architecture: {PASS|FAIL}
  {AGENTS.md compliance issues with file:line}

FIXES REQUIRED:
1. {file_path:line — what to change and why, referencing DESIGN.md section}
2. ...
```

If ALL four criteria PASS → JUDGE VERDICT: PASS
If ANY criterion FAIL → JUDGE VERDICT: FAIL

## Cross-Screen Consistency Check

When dispatched for cross-screen check (after all features built):

1. Read ALL View files in {App}/Features/
2. Check consistency:
   - Same DS components for similar purposes across screens
   - Same spacing tokens (grep .padding values)
   - Same typography tokens for similar roles
   - Same empty state treatment
3. Check DESIGN.md Section 6 Don'ts against ALL files
4. Report inconsistencies with file paths

## Key Rules

- NEVER say "looks good" without citing specific DESIGN.md sections
- NEVER suggest design changes that aren't in the DESIGN.md contract
- NEVER fix code — only diagnose. Fixes go back to the Generator.
- If the DESIGN.md itself seems wrong (contradicts HIG, would produce bad UI), note it as
  "CONTRACT ISSUE: Section X may need revision" — but still grade against the contract as-is.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-judge.md
git commit -m "feat: add forge-judge — skeptical evaluator agent grading against DESIGN.md"
```

---

### Task 4: Build the Generator Agent (forge-build)

**Files:**
- Create: `forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md`

The Generator is a mechanical screen builder. It reads DESIGN.md + AGENTS.md + spec.json, builds one feature, screenshots, returns proof. No aesthetic judgment.

- [ ] **Step 1: Write the forge-build agent definition**

Read the existing `forge-builder.md` agent at `forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md` for reference on the setup/discovery pattern and XcodeBuildMCP commands. Then write `forge-build.md` with these key differences from the current builder:

- Reads DESIGN.md instead of mood.md + design-system.md + voice-guide.md + feature-specs/
- No aesthetic judgment — follows DESIGN.md mechanically
- No self-critique or Impeccable integration — that's the Judge's job
- Floor checks are grep-based using DESIGN.md Section 6 Don'ts
- Simpler: ~200 lines instead of ~215 + 1,093 (forge-craft skill it currently loads)

The agent should have this structure:
1. Setup — discover project details (same as current: xcodebuildmcp commands)
2. Read context — AGENTS.md (relevant sections), DESIGN.md, spec.json feature
3. Scaffold — create View + ViewModel + Manager (if needed)
4. Implement — follow DESIGN.md blueprint + component rules + do's/don'ts + copy table
5. Build + screenshot — xcodebuild, launch, screenshot, READ screenshot
6. Floor checks — grep for banned patterns
7. Commit and return proof

Agent frontmatter:
```yaml
name: forge-build
description: >
  Mechanical screen builder for Forge iOS apps. Reads DESIGN.md contract +
  AGENTS.md architecture rules + spec.json feature entry. Builds exactly as
  specified. No aesthetic judgment — human and Judge are the quality gates.
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
permissionMode: bypassPermissions
skills:
  - swiftui-expert-skill
memory: user
```

- [ ] **Step 2: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-build.md
git commit -m "feat: add forge-build — mechanical screen builder reading DESIGN.md contract"
```

---

### Task 5: Rewrite the Planner (forge-app SKILL.md)

**Files:**
- Rewrite: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`
- Keep: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/blueprint.md` (update to spec.json format)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/execution.md` (absorbed into main skill)

This is the biggest task. The Planner replaces the current 1,162-line orchestrator with a ~400-line skill that does spec conversation + DESIGN.md generation + sprint orchestration.

- [ ] **Step 1: Read the current forge-app SKILL.md**

Read the full current file to understand what to preserve vs cut:
```
/Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

Preserve:
- Prerequisites check (Scenario A/B, environment checks)
- Phase 1 concept (spec conversation) — but streamline to 5 questions
- Human-gated quality principle
- Resume from progress (but using spec.json instead of progress.md)

Cut:
- Pre-Blueprint Marketing Research (optional enhancement, not core)
- 10-step execution sequence → replace with sprint loop
- All forge-craft/forge-ux/forge-voice delegation → absorbed into Planner
- Artifact freshness rules → only 2 files now, no staleness
- Step-by-step agent dispatch templates → simplified sprint loop
- Mid-pipeline quality spot checks → Judge handles this
- Equal quality enforcement for late screens → Judge handles this
- Cross-screen consistency check → Judge handles this

- [ ] **Step 2: Write the new forge-app SKILL.md**

Target: ~400 lines. Structure:

```
# Forge App — Planner

## Hard Gates (execution rules)
## 1. Prerequisites Check
## 2. Phase 1: Spec Conversation (5 adaptive questions)
## 3. Phase 2: Contract Generation (spec.json + DESIGN.md)
   - Load references/design-md-format.md for format spec
   - Load references/examples/ for few-shot examples
   - Generate DESIGN.md following the format
   - Present to human for approval
## 4. Phase 3: Sprint Loop
   - For each feature: dispatch forge-build → dispatch forge-judge → fix loop → human gate
   - Parallelization rules for independent features
## 5. Phase 4: Finalization
   - Cross-screen consistency (Judge)
   - Navigation wiring verification
   - Completion report
## 6. Skill Boundaries
```

Key changes in the sprint loop dispatch:
- Generator: `Task(subagent_type: "forge-feature:forge-build")`
- Judge: `Task(subagent_type: "forge-feature:forge-judge")`
- No `general-purpose` intermediate agents
- No skill invocations within dispatches

- [ ] **Step 3: Update blueprint.md reference to spec.json format**

Rewrite `references/blueprint.md` to document the spec.json format instead of the markdown blueprint format. Include the JSON schema and field descriptions.

- [ ] **Step 4: Delete execution.md reference**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
rm .claude-plugin/plugins/forge-app/skills/forge-app/references/execution.md
```

- [ ] **Step 5: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-app/
git commit -m "feat: rewrite forge-app as Planner — spec conversation + DESIGN.md generation + sprint loop"
```

---

### Task 6: Update forge-feature Plugin Registration

**Files:**
- Modify: `forge-marketplace/.claude-plugin/plugins/forge-feature/claude-code.json`

Register the new agents and update the skill description.

- [ ] **Step 1: Update claude-code.json**

```json
{
  "name": "forge-feature",
  "version": "2.0.0",
  "description": "Build features for Forge iOS apps — Generator builds screens from DESIGN.md contracts, Judge evaluates quality",
  "author": "Matvii Sakhnenko",
  "license": "MIT",
  "skills": [
    {
      "name": "forge-feature",
      "description": "Quality pipeline for building features in Forge apps. Generator builds from DESIGN.md contract, Judge evaluates. Use when the user says 'build a feature', 'add [feature]', or '/forge:feature'."
    }
  ]
}
```

- [ ] **Step 2: Update forge-feature SKILL.md**

Simplify the forge-feature skill to reflect the new architecture. It should:
- Detect mode (quick vs full — keep this)
- Prerequisites check (keep)
- For quick mode: dispatch forge-build directly, no Judge
- For full mode: dispatch forge-build + forge-judge loop
- Remove all references to forge-craft, forge-ux, forge-voice, forge-screens
- Remove Impeccable/Ralph Loop/GSD integration (optional enhancements detected by Planner, not by feature skill)
- Target: ~200 lines (down from 515)

- [ ] **Step 3: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add .claude-plugin/plugins/forge-feature/
git commit -m "feat: update forge-feature for v2 — Generator + Judge architecture"
```

---

### Task 7: Remove Old Skills

**Files:**
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-craft/` (entire directory)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-ux/` (entire directory)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-voice/` (entire directory)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-screens/` (entire directory)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-health/` (entire directory — replaced by Judge)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md` (replaced by forge-build)
- Delete: `forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-verifier.md` (replaced by Judge)
- Modify: `forge-marketplace/.claude-plugin/marketplace.json` (remove deleted plugins)
- Modify: `forge-marketplace/README.md` (update skill list)

- [ ] **Step 1: Delete old skill directories**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace/.claude-plugin/plugins
rm -rf forge-craft forge-ux forge-voice forge-screens
rm forge-feature/agents/forge-builder.md
rm forge-feature/agents/forge-verifier.md
rm forge-feature/skills/forge-feature/references/fallbacks.md
rm forge-feature/skills/forge-feature/references/pipeline.md
```

- [ ] **Step 2: Update marketplace.json**

Remove the deleted plugins from the plugins array. Keep: forge-app, forge-feature, forge-workspace, forge-wire, forge-ship, forge-storefront.

Update forge-app version to 2.0.0, forge-feature version to 2.0.0.

- [ ] **Step 3: Update marketplace README.md**

Update the skill count (11 → 6), update the pipeline diagram, update the skill table. Remove references to forge-craft, forge-ux, forge-voice, forge-screens, forge-health. Add forge-build and forge-judge as agent descriptions under forge-feature.

- [ ] **Step 4: Commit**

```bash
cd /Users/matvii/Developer/Personal/Apps/forge-marketplace
git add -A
git commit -m "chore: remove old pipeline skills — forge-craft, forge-ux, forge-voice, forge-screens, forge-health"
```

---

### Task 8: Update Template Repo

**Files:**
- Modify: `forge/README.md` — update pipeline diagram, skill count, architecture description
- Modify: `forge/AGENTS.md` — no structural changes, but verify it works standalone (no references to forge-craft, forge-ux, design-system.md, mood.md, voice-guide.md)

- [ ] **Step 1: Audit AGENTS.md for stale references**

Grep AGENTS.md for references to old pipeline artifacts:
```bash
grep -n "design-system.md\|mood.md\|voice-guide.md\|feature-specs\|forge-craft\|forge-ux\|forge-voice\|forge-eye\|forge-browse\|blueprint.md" AGENTS.md
```

Update any references to point to DESIGN.md and spec.json instead.

- [ ] **Step 2: Update README.md**

- Pipeline diagram: replace 10-step sequence with Plan → Build (sprint loop) → Ship
- Skill count: 11 → 6
- Skills table: remove deleted skills, update descriptions
- Architecture section: update .forge/ directory listing (spec.json + DESIGN.md instead of 6+ files)

- [ ] **Step 3: Commit**

```bash
cd /Users/matvii/Developer/Personal/Templates/forge
git add AGENTS.md README.md
git commit -m "docs: update template docs for v2 pipeline — DESIGN.md contract, sprint loop"
```

---

### Task 9: End-to-End Test

**Files:**
- No new files — test the pipeline by running it

- [ ] **Step 1: Create a test app from the template**

```bash
cd /Users/matvii/Developer/Personal/Templates/forge
./scripts/new-app.sh TestPipelineV2 ~/Documents/Developer/Apps com.test.pipelinev2 "Test Pipeline V2"
cd ~/Documents/Developer/Apps/TestPipelineV2
git init && git add -A && git commit -m "initial: create TestPipelineV2 from Forge template"
```

- [ ] **Step 2: Run the new pipeline**

In the TestPipelineV2 directory, invoke `/forge:app` and go through the spec conversation for a simple 3-screen app (dashboard + settings + detail). Verify:

- Spec conversation is 5 questions or fewer
- DESIGN.md is generated with all 8 sections
- Human gets to approve DESIGN.md before building starts
- Generator builds each screen with one dispatch (no triple delegation)
- Judge evaluates each screen and returns structured verdict
- Fix loop works (Generator fixes Judge's complaints)
- Human sees screenshot and approves each screen
- Final cross-screen consistency check runs

- [ ] **Step 3: Compare output quality**

Take screenshots of the test app. Compare against previous pipeline output (if available). Check:
- Does it look like a designed app or assembled components?
- Are the DESIGN.md Don'ts actually avoided?
- Is the copy from DESIGN.md Section 8 (not generic)?
- Does spacing vary between sections?

- [ ] **Step 4: Document findings**

Write a brief comparison to `docs/research/pipeline-v2-test-results.md`:
- What worked
- What didn't
- DESIGN.md format issues discovered
- Judge criteria that need adjustment
- Token usage comparison (if measurable)

- [ ] **Step 5: Iterate**

Fix any issues found. This may involve going back to Tasks 1-6 to adjust skill files.

---

## Execution Order and Dependencies

```
Task 1 (DESIGN.md format) — no dependencies, start here
Task 2 (examples) — depends on Task 1
Task 3 (Judge) — depends on Task 1 (needs to know what to grade against)
Task 4 (Generator) — depends on Task 1 (needs to know what to read)
Task 5 (Planner) — depends on Tasks 1-4 (orchestrates Generator + Judge)
Task 6 (Plugin registration) — depends on Tasks 3-4
Task 7 (Remove old skills) — depends on Task 5 (new pipeline must work first)
Task 8 (Template docs) — depends on Task 7
Task 9 (E2E test) — depends on Tasks 5-6
```

Tasks 3 and 4 can run in parallel (Judge and Generator are independent). Task 2 can run in parallel with Tasks 3-4.

**Recommended execution order:**
1. Task 1 (format spec)
2. Tasks 2 + 3 + 4 in parallel (examples, Judge, Generator)
3. Task 5 (Planner — needs Judge + Generator to exist)
4. Task 6 (plugin registration)
5. Task 9 (E2E test — before deleting old skills)
6. Tasks 7 + 8 (cleanup — only after E2E confirms new pipeline works)
