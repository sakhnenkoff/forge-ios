# Forge v4 Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Forge v4 pipeline — consolidate repos, rewrite skills for Codex-builds-Opus-judges model, add DS personality presets.

**Architecture:** Three independent phases. Phase A migrates skills into the template repo. Phase B rewrites core pipeline skills (forge-app, forge-design, forge-build, forge-judge). Phase C adds the DS preset system. Each phase is independently shippable and testable.

**Tech Stack:** Claude Code skills (markdown), Swift (DesignSystem package), xcodebuildmcp CLI, Codex plugin

**Spec:** `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md`

---

## Phase A: Repo Consolidation + Skill Migration

Migrate all skills from forge-marketplace into `skills/` in this repo. Update plugin registration. Archive the old repo.

---

### Task 1: Create skills directory and migrate unchanged skills

**Files:**
- Create: `skills/forge-workspace/SKILL.md`
- Create: `skills/forge-workspace/references/` (if any)
- Create: `skills/forge-wire/SKILL.md`
- Create: `skills/forge-wire/references/backends.md`
- Create: `skills/forge-wire/references/setup-guides.md`
- Create: `skills/forge-storefront/SKILL.md`
- Create: `skills/forge-ship/SKILL.md`
- Create: `skills/forge-ship/references/axiom-agents.md`
- Create: `skills/forge-ship/references/checklist.md`

- [ ] **Step 1: Create the skills directory structure**

```bash
mkdir -p skills/forge-workspace
mkdir -p skills/forge-wire/references
mkdir -p skills/forge-storefront
mkdir -p skills/forge-ship/references
```

- [ ] **Step 2: Copy unchanged skills from forge-marketplace**

These four skills are unchanged in v4. Copy them directly:

```bash
MARKETPLACE=~/Developer/Personal/forge-marketplace/.claude-plugin/plugins

cp "$MARKETPLACE/forge-workspace/skills/forge-workspace/SKILL.md" skills/forge-workspace/SKILL.md

cp "$MARKETPLACE/forge-wire/skills/forge-wire/SKILL.md" skills/forge-wire/SKILL.md
cp "$MARKETPLACE/forge-wire/skills/forge-wire/references/backends.md" skills/forge-wire/references/backends.md
cp "$MARKETPLACE/forge-wire/skills/forge-wire/references/setup-guides.md" skills/forge-wire/references/setup-guides.md

cp "$MARKETPLACE/forge-storefront/skills/forge-storefront/SKILL.md" skills/forge-storefront/SKILL.md

cp "$MARKETPLACE/forge-ship/skills/forge-ship/SKILL.md" skills/forge-ship/SKILL.md
cp "$MARKETPLACE/forge-ship/skills/forge-ship/references/axiom-agents.md" skills/forge-ship/references/axiom-agents.md
cp "$MARKETPLACE/forge-ship/skills/forge-ship/references/checklist.md" skills/forge-ship/references/checklist.md
```

- [ ] **Step 3: Verify files copied correctly**

```bash
find skills/ -name "*.md" | sort
```

Expected: 9 markdown files across 4 skill directories.

- [ ] **Step 4: Commit**

```bash
git add skills/forge-workspace/ skills/forge-wire/ skills/forge-storefront/ skills/forge-ship/
git commit -m "chore: migrate unchanged skills from forge-marketplace to skills/"
```

---

### Task 2: Create placeholder directories for skills to be rewritten

**Files:**
- Create: `skills/forge-app/SKILL.md` (placeholder)
- Create: `skills/forge-design/SKILL.md` (placeholder)
- Create: `skills/forge-build/PROMPT.md` (placeholder)
- Create: `skills/forge-judge/SKILL.md` (placeholder)

- [ ] **Step 1: Create directories and placeholder files**

```bash
mkdir -p skills/forge-app/references
mkdir -p skills/forge-design
mkdir -p skills/forge-build
mkdir -p skills/forge-judge
```

- [ ] **Step 2: Create placeholder SKILL.md for forge-app**

Write a minimal placeholder that notes this will be rewritten in Phase B:

```markdown
---
name: forge-app
description: "Orchestrator — spec conversation, DESIGN.md generation, sprint loop. v4 rewrite pending (Phase B)."
---

# forge-app (v4 placeholder)

This skill will be rewritten in Phase B of the v4 pipeline implementation.
See `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md` for the full spec.
```

- [ ] **Step 3: Create placeholder for forge-design, forge-build, forge-judge**

Same pattern — minimal placeholder noting Phase B rewrite. forge-build gets `PROMPT.md` instead of `SKILL.md`:

forge-design/SKILL.md:
```markdown
---
name: forge-design
description: "Reference → DESIGN.md translator. v4 rewrite pending (Phase B)."
---

# forge-design (v4 placeholder)

This skill will be rewritten in Phase B of the v4 pipeline implementation.
```

forge-build/PROMPT.md:
```markdown
# forge-build Codex Prompt Template (v4 placeholder)

This prompt template will be written in Phase B of the v4 pipeline implementation.
```

forge-judge/SKILL.md:
```markdown
---
name: forge-judge
description: "Taste-only evaluator. 5 criteria. v4 rewrite pending (Phase B)."
---

# forge-judge (v4 placeholder)

This skill will be rewritten in Phase B of the v4 pipeline implementation.
```

- [ ] **Step 4: Copy reference files that will be reused**

```bash
MARKETPLACE=~/Developer/Personal/forge-marketplace/.claude-plugin/plugins

cp "$MARKETPLACE/forge-app/skills/forge-app/references/design-md-format.md" skills/forge-app/references/design-md-format.md
cp "$MARKETPLACE/forge-app/skills/forge-app/references/spec-format.md" skills/forge-app/references/spec-format.md
cp -r "$MARKETPLACE/forge-app/skills/forge-app/references/examples" skills/forge-app/references/examples
```

- [ ] **Step 5: Commit**

```bash
git add skills/forge-app/ skills/forge-design/ skills/forge-build/ skills/forge-judge/
git commit -m "chore: create placeholder skills for v4 rewrite (forge-app, forge-design, forge-build, forge-judge)"
```

---

### Task 3: Update plugin registration and gitignore

**Files:**
- Modify: `.claude/settings.json`
- Modify: `.gitignore`

- [ ] **Step 1: Keep marketplace registration for now**

Do NOT remove the forge-marketplace plugin registration yet. The placeholder skills in `skills/` are not functional — removing marketplace registration would break the pipeline. The marketplace entry will be removed in Phase B (Task 11) after real skills are in place.

Verify current settings are unchanged:
```bash
cat .claude/settings.json
```

Expected: `"forge-storefront@forge-marketplace": true` still present.

- [ ] **Step 2: Update .gitignore for selective .forge/ tracking**

The current `.gitignore` has a blanket `.forge/` ignore. But in app projects (not the template), `.forge/spec.json`, `.forge/DESIGN.md`, and `.forge/progress.md` should be trackable as pipeline state. Update `.gitignore`:

Replace the line `.forge/` with:

```
# Forge build artifacts — track pipeline state, ignore ephemeral refs
.forge/references/
.forge/issues.md
```

This means `spec.json`, `DESIGN.md`, and `progress.md` are committable in app projects, while raw references and issues stay gitignored. In the template repo, these files don't exist yet so there's no impact.

- [ ] **Step 3: Update README install instructions**

Grep for stale marketplace references in user-facing docs:

```bash
grep -rn "forge-marketplace" README.md .claude/commands/ docs/ || echo "No stale references"
```

Update any found references to note that skills now ship with the template and no separate install is needed.

- [ ] **Step 4: Commit**

```bash
git add .gitignore README.md
git commit -m "chore: update gitignore for selective .forge/ tracking, update install docs"
```

---

### Task 4: Create design-reference docs structure

**Files:**
- Create: `docs/design-reference/README.md`
- Create: `docs/design-reference/presets.md`
- Create: `docs/design-reference/examples/` (empty, with .gitkeep)

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p docs/design-reference/examples
```

- [ ] **Step 2: Write README.md**

```markdown
# Design Reference Library

Visual references that inform how Forge apps look. Used during Phase 1 (planning) and Phase 2 (DESIGN.md generation).

## Input Sources (priority order)

1. **User-provided references** — screenshots, apps, custom DESIGN.md files
2. **awesome-design-md** — 66 curated web design systems from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md). Install with `npx getdesign@latest add <site>`.
3. **Built-in preset axes** — spacing rhythm, corner radius, typography weight, surface treatment (see `presets.md`)

## How References Flow

1. User picks references during planning (Phase 1)
2. References are saved to `.forge/references/` (gitignored by default)
3. forge-design reads references and translates web-native design language to iOS-native DS tokens
4. Output: `.forge/DESIGN.md` (8-section contract)

## Translation

awesome-design-md files use CSS values (px, rgba, rem). forge-design translates:
- CSS spacing → DS spacing tokens (xs through xxl)
- CSS typography → DS text styles + SwiftUI font modifiers
- CSS colors → DS semantic color palette
- CSS components → DS component rules
- Web patterns → iOS conventions (tab bars, not hamburgers)

## Examples

The `examples/` directory contains sample translated references for testing the pipeline.
```

- [ ] **Step 3: Write presets.md**

```markdown
# DS Personality Presets

Four axes that control how an app looks distinct from the template default.

## Axes

### Spacing Rhythm
- **tight** — Compact, dense layouts. Smaller gaps between sections. Information-rich screens. _Think: Linear, Superhuman._
- **balanced** — Default Forge spacing. Comfortable padding. _Think: Notion, Stripe._
- **airy** — Generous whitespace. Breathing room between elements. _Think: Airbnb, Apple._

### Corner Radius
- **sharp** — Small radii (xs-sm). Precise, technical feel. _Think: Linear, Vercel._
- **rounded** — Large radii (lg-xl). Friendly, approachable. _Think: Airbnb, Spotify._
- **mixed** — Small radii for controls, large for cards. _Think: Apple, Notion._

### Typography Weight
- **heavy** — Bold display type, strong heading/body contrast. _Think: Nike, Uber._
- **light** — Lighter weights, subtle hierarchy. _Think: Apple, Stripe._

### Surface Treatment
- **flat** — No shadows, minimal depth. Separation via color/spacing. _Think: Linear, Vercel._
- **elevated** — Shadow-based depth hierarchy (soft → card → lifted). _Think: Notion, Airbnb._
- **glass** — Liquid Glass / material effects where appropriate. _Think: iOS 26 native apps._

## Named Combinations

| Name | Spacing | Radius | Weight | Surface | Feel |
|------|---------|--------|--------|---------|------|
| `.linear` | tight | sharp | heavy | flat | Dense, technical, dark |
| `.airbnb` | airy | rounded | light | elevated | Warm, spacious, friendly |
| `.stripe` | balanced | mixed | light | flat | Clean, precise, editorial |
| `.apple` | airy | mixed | light | glass | Native, premium, spacious |

These are convenience shortcuts. Users can mix axes freely: "Linear's spacing but Airbnb's surface treatment."

## Token Mappings

Each axis maps to concrete DS token values. See `Packages/core-packages/DesignSystem/Theme/Presets/` for Swift implementations.
```

- [ ] **Step 4: Add .gitkeep to examples**

```bash
touch docs/design-reference/examples/.gitkeep
```

- [ ] **Step 5: Commit**

```bash
git add docs/design-reference/
git commit -m "docs: create design reference library structure with presets catalog"
```

---

### Task 5: Mark v3 artifacts as superseded

**Files:**
- Modify: `docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md`
- Modify: `docs/superpowers/plans/2026-04-03-pipeline-redesign.md`

- [ ] **Step 1: Add superseded notice to v3 spec**

Add at the top of `docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md`:

```markdown
> **ARCHIVED — Superseded by `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md` (v4). Do not execute.**
```

- [ ] **Step 2: Add superseded notice to v3 plan**

Add at the top of `docs/superpowers/plans/2026-04-03-pipeline-redesign.md`:

```markdown
> **ARCHIVED — Superseded by `docs/superpowers/plans/2026-04-12-forge-v4-pipeline.md` (v4). Do not execute.**
```

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md docs/superpowers/plans/2026-04-03-pipeline-redesign.md
git commit -m "chore: mark v3 pipeline artifacts as superseded by v4"
```

---

### Task 6: Verify Phase A — build still works, skills discoverable

- [ ] **Step 1: Verify the Xcode project still builds**

```bash
xcodebuildmcp simulator build-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj
```

Expected: Build succeeded.

- [ ] **Step 2: Verify skill files are in place**

```bash
find skills/ -name "*.md" | sort | wc -l
```

Expected: 13+ markdown files.

- [ ] **Step 3: Verify no broken references in copied skills**

Grep the migrated skills for references to old paths that no longer exist:

```bash
grep -r "forge-marketplace" skills/ || echo "No stale marketplace references"
grep -r ".claude-plugin" skills/ || echo "No stale plugin path references"
```

Expected: No matches (or fix any found).

- [ ] **Step 4: Commit any fixes**

If step 3 found stale references, fix them and commit:

```bash
git add skills/
git commit -m "fix: remove stale forge-marketplace references from migrated skills"
```

---

## Phase B: Core Skills Rewrite

Rewrite the four pipeline-critical skills for v4: forge-app (orchestrator), forge-design (translator), forge-build (Codex prompt), forge-judge (taste evaluator).

---

### Task 7: Write forge-build/PROMPT.md — Codex prompt template

This is the simplest skill and the foundation others depend on. It's a markdown template with placeholder markers that forge-app fills before sending to Codex.

**Files:**
- Modify: `skills/forge-build/PROMPT.md`

- [ ] **Step 1: Read the existing forge-build agent definition for reusable content**

```bash
cat ~/Developer/Personal/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-build.md
```

Extract the useful parts: architecture rules, file scaffolding patterns, code structure expectations.

- [ ] **Step 2: Write PROMPT.md**

The template uses `{{PLACEHOLDER}}` markers that forge-app replaces before sending to Codex. Write the full prompt template:

```markdown
# Forge Build — Codex Code Generation Prompt

You are a mechanical code generator for an iOS app built with the Forge template.
Your job: write Swift files exactly as specified. No aesthetic judgment. No build. No screenshot. Just code.

## Your Task

Build the following feature:

{{FEATURE_SPEC}}

## Design Contract (follow exactly)

{{DESIGN_BLUEPRINT}}

## Architecture Rules (follow exactly)

{{AGENTS_RULES}}

## Preset Token Values

{{PRESET_TOKENS}}

## Files to Create/Modify

For each screen, create:
1. **View** (`{App}/Features/{FeatureName}/{FeatureName}View.swift`)
   - Root container: `DSScreen`
   - Must include: `.toast(toast: $viewModel.toast)`, `.onAppear { viewModel.onAppear(services: services, session: session) }`
   - Use `@State private var viewModel = {FeatureName}ViewModel()`
   - Never use `@StateObject`, `AsyncImage`
   - Use DS components: DSButton, DSCard, DSListRow, DSScreen, DSTextField, etc.
   - Use DS typography: `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
   - Use semantic colors: `.themePrimary`, `.textPrimary`, `.textSecondary`, etc.
   - Use DS spacing: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxlg` (40), `.xxl` (52)

2. **ViewModel** (`{App}/Features/{FeatureName}/{FeatureName}ViewModel.swift`)
   - `@MainActor @Observable final class {FeatureName}ViewModel`
   - Must include: `var toast: Toast?`, `private var hasLoaded = false`
   - `onAppear(services:session:)` with `guard !hasLoaded else { return }` pattern
   - `enum Event: LoggableEvent` for analytics

3. **Manager** (only if `has_manager: true` in spec)
   - Protocol + Mock implementation
   - Register in AppServices

4. **Model** (only if models listed in spec)
   - `static let placeholders: [ModelName]`
   - `static let mockList: [ModelName]`
   - `StringIdentifiable` conformance

5. **Navigation** — add route to AppRoute/AppSheet/AppTab as specified

## Additional Skill Knowledge

{{SKILL_KNOWLEDGE}}

## Output

Write complete, compilable Swift files. Every file must be a complete implementation — no TODOs, no placeholders, no "implement later" comments.
```

- [ ] **Step 3: Commit**

```bash
git add skills/forge-build/PROMPT.md
git commit -m "feat: write forge-build Codex prompt template with placeholder markers"
```

---

### Task 8: Write forge-judge/SKILL.md — taste-only evaluator

**Files:**
- Modify: `skills/forge-judge/SKILL.md`

- [ ] **Step 1: Read the existing forge-judge agent definition**

```bash
cat ~/Developer/Personal/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md
```

Extract: grading criteria structure, DESIGN.md section references, verdict format.

- [ ] **Step 2: Write the v4 forge-judge SKILL.md**

Key changes from v3:
- Model: Opus (was Sonnet)
- Scope: 5 taste criteria only (was 7 including Architecture and iOS-Native)
- Architecture and iOS-Native checks removed (owned by floor checks + hardened-build)
- Add cross-screen consistency mode

Write the full SKILL.md with:

```markdown
---
name: forge-judge
description: "Taste-only evaluator for Forge iOS apps. Grades screens on 5 visual criteria against DESIGN.md. Diagnoses but never fixes."
model: opus
tools: [Read, Grep, Glob]
---

# forge-judge — Taste Evaluator

Skeptical grader. You evaluate whether a built screen matches the DESIGN.md contract visually. You diagnose problems but NEVER fix them — fixes go back to the Generator.

## Mode: Single Screen

### Input
- Screenshot image (from xcodebuildmcp)
- View + ViewModel source files
- DESIGN.md contract (relevant screen blueprint)

### Process
1. **Read DESIGN.md** — this is your grading rubric
2. **Read screenshot** — describe what you see: layout, colors, typography, spacing, mood impression
3. **Read code** — View + ViewModel files
4. **Grade on 5 criteria**

### Criteria

**1. Design Quality** (DESIGN.md Sections 1, 2, 3)
- Does the mood match Section 1's description?
- Are colors correct per Section 2's palette?
- Is typography hierarchy correct per Section 3?
- Is there a clear dominant element on the screen?

**2. Originality** (DESIGN.md Section 6)
- Does the screen avoid every pattern listed in Section 6 Don'ts?
- Does it avoid template sins: uniform padding everywhere, generic placeholder-style empty states, default SF Symbol usage without intent?

**3. Craft** (DESIGN.md Sections 4, 5, 7)
- Section 4: Are component rules followed? (YES/NO/CUSTOMIZE/SKIP verdicts)
- Section 5: Does spacing use the correct rhythm from the preset? Variety, not uniform.
- Section 7: Does the layout match the blueprint? Sections, list structure, data sources.
- Section 8: Are user-facing strings exact matches?

**4. Craft Intent** (DESIGN.md Section 7, Craft Moment)
- Does the screen have its "one special thing"?
- The craft moment defined in the blueprint — is it implemented?
- If no craft moment is defined, does the screen have visual interest beyond functional layout?

**5. Visual Target Match** (DESIGN.md Section 1, reference apps + .forge/references/)
- Does the screen feel like it belongs to the reference app family?
- Would a user familiar with the reference apps recognize the design language?
- If no reference was provided, evaluate against the preset axes (spacing/radius/weight/surface).

### Verdict

Return exactly one of:
- **PASS** — all 5 criteria met. Include 1-sentence summary of what works.
- **FAIL** — one or more criteria not met. For EACH failure:
  - Which criterion failed
  - What specifically is wrong (cite DESIGN.md section + line)
  - File and line in the code where the issue originates
  - What the fix should be (describe, don't implement)

### Rules
- Every observation must cite a DESIGN.md section number
- Never suggest fixes that contradict DESIGN.md
- Never fix code yourself — describe the fix for the Generator
- Grade what IS there, not what you wish was there
- A screen can PASS with minor imperfections if the overall feel is right
- A screen must FAIL if any Don't from Section 6 is violated

---

## Mode: Cross-Screen Consistency

Used in Phase 4 after all features are built.

### Input
- All screenshots from all built screens
- All View source files
- Full DESIGN.md

### Process
1. Review all screenshots together as a set
2. Check for drift across screens:
   - Consistent spacing rhythm (same preset applied everywhere?)
   - Consistent color usage (same semantic colors, same brand accent treatment?)
   - Consistent typography hierarchy (same text styles for same purposes?)
   - Consistent component treatment (same card style, same button style?)
   - Consistent animation style (same entrance animations, same transitions?)
3. Produce consistency report

### Verdict
- **CONSISTENT** — all screens feel like one app
- **DRIFT DETECTED** — list specific screens and what drifted, with fix suggestions
```

- [ ] **Step 3: Commit**

```bash
git add skills/forge-judge/SKILL.md
git commit -m "feat: write forge-judge v4 — taste-only evaluator with 5 criteria + consistency mode"
```

---

### Task 9: Write forge-design/SKILL.md — reference translator

**Files:**
- Modify: `skills/forge-design/SKILL.md`

- [ ] **Step 1: Read the existing forge-design skill and design-md-format reference**

```bash
cat ~/Developer/Personal/forge-marketplace/.claude-plugin/plugins/forge-design/skills/forge-design/SKILL.md
cat ~/Developer/Personal/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/references/design-md-format.md
```

Extract: DESIGN.md 8-section format, mapping conventions.

- [ ] **Step 2: Write the v4 forge-design SKILL.md**

Key changes from v3:
- No Mobbin browsing (removed Playwright dependency)
- No Stitch MCP mockup generation
- Reads awesome-design-md files + user refs + preset axes
- Translates web-native → iOS-native
- Outputs DESIGN.md (8 sections)

Write the full SKILL.md:

```markdown
---
name: forge-design
description: "Translates design references (awesome-design-md, user screenshots, preset axes) into an iOS-native DESIGN.md contract."
model: opus
---

# forge-design — Reference → DESIGN.md Translator

You translate design references into an iOS-native DESIGN.md contract for the Forge template.

No live browsing. No mockup generation. Pure translation from inputs already collected.

## Inputs

Read from `.forge/references/`:
- `index.md` — which references are selected, how they combine, any axis overrides
- `*.md` — awesome-design-md files (web-native DESIGN.md format, CSS values)
- `*.png` / `*.jpg` — user-provided screenshots (describe what you see)

Read from `docs/design-reference/presets.md`:
- Preset axis values selected during Phase 1

Read from `.forge/spec.json`:
- Feature list, screen types, navigation structure

## Translation Rules

### Colors (web → iOS)
- Map hex values to DS semantic roles: `.themePrimary`, `.backgroundPrimary`, `.surface`, `.textPrimary`, `.textSecondary`, `.textTertiary`, `.border`, `.divider`, `.error`
- Reference's brand/accent color → `brandColor` parameter in AdaptiveTheme
- Background surfaces → `.backgroundPrimary`, `.backgroundSecondary`, `.surface`, `.surfaceVariant`
- The DS derives most colors from `brandColor` — only specify overrides where the reference demands a color the DS can't derive

### Typography (web → iOS)
- Map font families → DS design variants: `.default` (San Francisco), `.rounded`, `.monospaced`, `.serif`
- Map font weights → DS text styles: `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
- Map font sizes → closest DS text style (don't invent new sizes)
- Weight axis from presets: heavy = use `.semibold`/`.bold` for headings; light = use `.regular`/`.medium`

### Spacing (web → iOS)
- Map CSS spacing values to closest DS spacing token: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxlg` (40), `.xxl` (52)
- Rhythm axis from presets: tight = prefer xs/sm/md; airy = prefer md/lg/xl
- Never invent spacing values — always use DS tokens

### Components (web → iOS)
- Web buttons → DSButton (sizes: .small, .medium, .large; styles: .primary, .secondary, .ghost)
- Web cards → DSCard or DSListRow (depending on content type)
- Web inputs → DSTextField
- Web navigation → AppRoute/AppSheet/AppTab (never hamburger menus)
- Web modals → .sheet() presentations
- Surface axis from presets: flat = no shadows; elevated = DSShadows.soft/card/lifted; glass = .glassEffect()

### Radius (web → iOS)
- Map CSS border-radius to DS radii: `DSRadii.xs` (8), `.sm` (12), `.md` (16), `.lg` (20), `.xl` (28), `.pill` (999)
- Radius axis from presets: sharp = prefer xs/sm; rounded = prefer lg/xl; mixed = sharp for controls, rounded for cards

## Output: DESIGN.md (8 sections)

Write to `.forge/DESIGN.md`. Follow the format in `skills/forge-app/references/design-md-format.md`.

### Section 1: Mood
- 2-sentence feel description synthesized from references
- List reference apps (with links if from awesome-design-md)
- State preset axes: `spacing: tight | radius: sharp | weight: heavy | surface: flat`

### Section 2: Color Palette
- 11+ semantic roles with DS token names
- `brandColor` hex value (the single input to AdaptiveTheme)
- Any overrides where the reference demands non-derived colors

### Section 3: Typography
- DS text style assignments per heading level
- Design variant (.default, .rounded, .monospaced, .serif)
- Weight emphasis pattern from preset

### Section 4: Component Rules
- YES/NO/CUSTOMIZE/SKIP table for every DS component
- Surface treatment details from preset

### Section 5: Layout Principles
- Spacing rules using DS token names
- Rhythm description from preset
- Preferred section patterns

### Section 6: Do's and Don'ts
- 4-6 DO patterns (derived from reference's design philosophy)
- 6-10 DON'T patterns (GREPPABLE — these become floor check inputs)
- Include iOS-native translations of web reference Don'ts

### Section 7: Screen Blueprints
- One blueprint per screen from spec.json
- For each: Design Intent, Craft Moment, layout description, data sources, entrance animation, empty/loading/error states

### Section 8: Voice & Copy
- Tone derived from reference mood
- Exhaustive table of user-facing strings

## Human Gate

After generating DESIGN.md, present it to the human for review. Do not proceed to Phase 3 until approved.
```

- [ ] **Step 3: Commit**

```bash
git add skills/forge-design/SKILL.md
git commit -m "feat: write forge-design v4 — reference translator, no live browsing"
```

---

### Task 10: Write forge-app/SKILL.md — frontmatter + Phase 1 (Planning)

**Files:**
- Modify: `skills/forge-app/SKILL.md`

- [ ] **Step 1: Read the existing forge-app skill for reusable structure**

```bash
cat ~/Developer/Personal/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
```

- [ ] **Step 2: Write the frontmatter + Phase 1 planning section**

```markdown
---
name: forge-app
description: "Build an entire iOS app from an idea — conversational spec, DESIGN.md contracts, Codex build + Opus judge sprint loop."
model: opus
tools: [Read, Write, Edit, Bash, Grep, Glob, Agent, AskUserQuestion]
---

# forge-app — Orchestrator

You are the Forge pipeline orchestrator. You plan the app, generate design contracts, dispatch builders and judges, and manage the sprint loop.

## Prerequisites

Before starting, verify:
1. This is a Forge template project: `ls Forge.xcodeproj AGENTS.md Packages/core-packages` must succeed
2. xcodebuildmcp is available: `which xcodebuildmcp` must succeed
3. Codex plugin is available: check if `codex:rescue` skill exists

Log warnings (do not block) if missing:
- hardened-build skill: "⚠ hardened-build not installed — architecture verification limited to floor checks"
- adversarial-review skill: "⚠ adversarial-review not installed — no multi-model code review in Phase 4"

## Phase 1: Planning

### Detect available planning infrastructure

Check for installed planning skills by looking for their files on disk:

```bash
# Check for Superpowers
ls ~/.claude/plugins/cache/claude-plugins-official/superpowers/*/skills/brainstorming/SKILL.md 2>/dev/null && echo "SUPERPOWERS_AVAILABLE=true"
# Check for GSD
ls ~/.claude/skills/gsd-discuss-phase/SKILL.md 2>/dev/null && echo "GSD_AVAILABLE=true"
```

If detection is unreliable, ask the user directly:
"I can use structured planning tools if you have them. Are you using Superpowers, GSD, both, or neither?"

If Superpowers is available, wrap the planning conversation in `superpowers:brainstorming`.
If GSD is available, use `gsd-discuss-phase` for adaptive questioning.
If both, use Superpowers for creative exploration, GSD for execution mechanics.
If neither, use the built-in question flow below.

### Planning questions (6-8, adaptive)

Ask one at a time. Skip questions the user has already answered.

1. **Pitch + audience**: "What does this app do, and who is it for? Give me the elevator pitch."
2. **Core screens**: "Walk me through the key screens — what does the user see and do on each one? Include all states: loading, empty, error, and loaded."
3. **User journeys**: "What are the main user flows? (e.g., onboarding → home → detail → action). What happens on bad network?"
4. **Monetization**: "How does this app make money? (Free, freemium, subscription, one-time purchase, none)"
5. **References**: "Any apps that feel like what you're building? I can pull design references from [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (66 curated styles) or you can share screenshots."
6. **Preset feel**: "Which direction feels right? Pick or mix:
   - Spacing: tight (Linear-dense) / balanced (Notion) / airy (Airbnb-spacious)
   - Corners: sharp (technical) / rounded (friendly) / mixed (Apple-like)
   - Typography: heavy (bold headlines) / light (subtle hierarchy)
   - Surface: flat (no shadows) / elevated (layered) / glass (Liquid Glass)"
7. **Brand direction**: "Any color preferences? Mood words? (e.g., 'warm and approachable', 'dark and precise')"
8. **Additional context** (if needed): "Anything else I should know — specific features, API integrations, constraints?"

### Generate spec.json

After questions are answered, generate `.forge/spec.json`:

```json
{
  "app_name": "AppName",
  "pitch": "One-sentence pitch",
  "preset": {
    "spacing": "balanced",
    "corners": "mixed",
    "weight": "light",
    "surface": "elevated"
  },
  "features": [
    {
      "id": "feature-id",
      "name": "Feature Name",
      "screen_type": "dashboard|detail|list|form|onboarding|paywall|settings",
      "description": "What this screen does",
      "required": true,
      "has_manager": false,
      "models": [],
      "depends_on": [],
      "status": "pending",
      "nav_case": "tab|push|sheet",
      "icon": "sf-symbol-name",
      "nav_path": ["tab-name", "route-name"]
    }
  ],
  "models": [
    {
      "name": "ModelName",
      "fields": [
        {"name": "fieldName", "type": "String"}
      ]
    }
  ],
  "navigation": {
    "tabs": ["tab1", "tab2"],
    "pushes": ["route1"],
    "sheets": ["sheet1"]
  }
}
```

### Fetch design references

If user selected awesome-design-md references:
```bash
mkdir -p .forge/references
cd .forge/references && npx getdesign@latest add <site-name>
```

If user provided screenshots, save them to `.forge/references/`.

Write `.forge/references/index.md` documenting which refs are selected and how they combine.

### Human gate

Present the spec.json summary to the user. Wait for approval before proceeding to Phase 2.
```

- [ ] **Step 3: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: forge-app Phase 1 — planning questions, spec.json generation, reference fetching"
```

---

### Task 10b: Write forge-app — Phase 2 (Design) + Phase 3 (Build Loop)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (append)

- [ ] **Step 1: Append Phase 2 + Phase 3 to SKILL.md**

```markdown
## Phase 2: Design Contract

Dispatch forge-design to translate references into an iOS-native DESIGN.md.

**NOTE:** Dispatch target names below (e.g., `"forge-design"`) are local skill names. The exact dispatch mechanism (Agent subagent_type, Skill tool, or direct invocation) depends on how Claude Code discovers local `skills/` — this is resolved in Task 11 during the switchover. Use whatever format works after Task 11 verification.

```
Skill("forge-design")
# OR if Agent dispatch is needed:
Agent(description: "Generate DESIGN.md", prompt: "
  You are forge-design. Read skills/forge-design/SKILL.md and follow it exactly.
  Read .forge/references/index.md for selected references.
  Read .forge/spec.json for feature list and preset axes.
  Read docs/design-reference/presets.md for preset vocabulary.
  Generate .forge/DESIGN.md following the 8-section format in skills/forge-app/references/design-md-format.md.
")
```

After forge-design returns, present DESIGN.md to the user. Wait for approval.

## Phase 3: Build Loop

For each feature in spec.json with status "pending", ordered by dependencies:

### State tracking

Track `codex_invocations` per feature (starts at 0, max 8). This is a hard ceiling regardless of which gate triggered the retry.

### Step 1: Codex Code Generation

Read `skills/forge-build/PROMPT.md`. Replace placeholders:

- `{{FEATURE_SPEC}}` — the feature entry from spec.json
- `{{DESIGN_BLUEPRINT}}` — Section 7 blueprint for this screen from DESIGN.md
- `{{AGENTS_RULES}}` — extract from AGENTS.md: "Architecture" through "Post-Build Checks" sections (~200 lines)
- `{{PRESET_TOKENS}}` — concrete token values for the selected preset from PresetConfiguration
- `{{SKILL_KNOWLEDGE}}` — if Build iOS Apps skills are installed, extract relevant patterns inline
- `{{SHARED_FILES}}` — current contents of AppRoute.swift, AppServices.swift, and any other shared files the feature will modify

Dispatch to Codex:
```
Agent(subagent_type: "codex:rescue", prompt: "<populated PROMPT.md content>")
```

Increment `codex_invocations`. If >= CODEX_CEILING, mark feature as `blocked` in spec.json, log to `.forge/progress.md`, move to next feature.

### Step 2: Floor Checks

Run grep checks on the generated files:

**View file checks** (grep the *View.swift file):
```bash
grep -q "DSScreen" {ViewFile} || echo "FAIL: Missing DSScreen"
grep -q "\.toast(" {ViewFile} || echo "FAIL: Missing .toast()"
grep -q "\.onAppear" {ViewFile} || echo "FAIL: Missing .onAppear"
grep -q "AsyncImage" {ViewFile} && echo "FAIL: AsyncImage banned"
grep -q "@StateObject" {ViewFile} && echo "FAIL: @StateObject banned"
```

**ViewModel file checks** (grep the *ViewModel.swift file):
```bash
grep -q "@Observable" {ViewModelFile} || echo "FAIL: Missing @Observable"
grep -q "var toast: Toast?" {ViewModelFile} || echo "FAIL: Missing toast property"
grep -q "hasLoaded" {ViewModelFile} || echo "FAIL: Missing hasLoaded guard"
```

**DESIGN.md Don'ts check** (grep both files for banned patterns from Section 6):
```bash
# Read Section 6 Don'ts from DESIGN.md, grep for each banned pattern
```

If any check fails: send failures back to Codex (Step 1). Max 2 consecutive floor check failures.

### Step 3: Hardened Build (if installed)

```bash
# Check if hardened-build skill exists
```

If available, dispatch:
```
Skill("hardened-build", args: "<changed files>")
```

If not installed, skip with warning (logged once at pipeline start).
If fails: send fix instructions to Codex (Step 1). Max 2 consecutive failures.

### Step 4: Build + Screenshot

```bash
# Discover project
xcodebuildmcp simulator discover-projs --workspace-root .
xcodebuildmcp simulator list-schemes --project-path ./{AppName}.xcodeproj

# Build and run
xcodebuildmcp simulator build-run-sim --scheme "{AppName} - Mock" --project-path ./{AppName}.xcodeproj --simulator-name "iPhone 17 Pro"

# Navigate to the screen using nav_path from spec.json
# Use snapshot-ui to find elements, tap to navigate
xcodebuildmcp ui-automation snapshot-ui --simulator-id {SIMULATOR_UDID}
xcodebuildmcp ui-automation tap --simulator-id {SIMULATOR_UDID} --x {X} --y {Y}

# Screenshot
xcodebuildmcp ui-automation screenshot --simulator-id {SIMULATOR_UDID} --return-format path
```

If build fails: send error to Codex (Step 1). Max 2 consecutive build failures.

### Step 5: Taste Judge

Dispatch forge-judge (use same dispatch mechanism resolved in Task 11):
```
Agent(description: "Judge screen taste", prompt: "
  You are forge-judge. Read skills/forge-judge/SKILL.md and follow it exactly.
  Mode: Single Screen
  Screenshot: {screenshot_path}
  View file: {view_file_path}
  ViewModel file: {viewmodel_file_path}
  DESIGN.md: .forge/DESIGN.md
  Grade on 5 criteria: Design Quality, Originality, Craft, Craft Intent, Visual Target Match.
  Return PASS or FAIL with specific fix instructions.
")
```

If FAIL: send fix instructions to Codex (Step 1). Max 3 total judge rounds per feature.

### Step 6: Human Gate

Show the screenshot to the user:
```
"Here's the built screen for {feature_name}. [screenshot]
Approve, or give feedback?"
```

If approved: commit files, update spec.json status to "done".
If feedback: send feedback to Codex (Step 1). Max 2 feedback rounds.

### On feature completion or block

Update `.forge/spec.json` — set feature status to `done` or `blocked`.
Log to `.forge/progress.md`:
```
## {feature_name}
Status: done|blocked
Codex invocations: N/8
Judge rounds: N/3
Notes: ...
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: forge-app Phase 2 (design dispatch) + Phase 3 (build loop with 6 steps)"
```

---

### Task 10c: Write forge-app — Phase 4 (Verification) + Phase 5 (Ship)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (append)

- [ ] **Step 1: Append Phase 4 + Phase 5 to SKILL.md**

```markdown
## Hard Gate: All Required Features Done

Before proceeding to Phase 4, verify:
```bash
# Parse spec.json — every feature with "required": true must have "status": "done"
```

If any required feature is `blocked`:
```
"The following required features are blocked: {list}.
You must either:
1. Fix the blocked feature (I'll retry the build loop)
2. Mark it as non-required (scope reduction — I'll note this in progress.md)
3. Explicitly waive the gate

Which option?"
```

Do NOT proceed to Phase 4 until resolved.

## Phase 4: Quality Verification

Run three quality layers. Issues found get fixed and re-verified.

### Layer 1: Adversarial Review (if installed)

```bash
# Check if adversarial-review skill exists
```

If available:
```
Skill("adversarial-review")
```

Fix any Blocker/Bug findings, re-run until clean.
If not installed, log: "Skipping adversarial review — not installed."

### Layer 2: Axiom Deep Scan (if available)

Dispatch available Axiom auditors in parallel:
```
Agent(subagent_type: "axiom:accessibility-auditor", ...)
Agent(subagent_type: "axiom:security-privacy-scanner", ...)
Agent(subagent_type: "axiom:memory-auditor", ...)
Agent(subagent_type: "axiom:concurrency-auditor", ...)
Agent(subagent_type: "axiom:energy-auditor", ...)
```

Fix critical/high findings. Log remaining as known issues.

### Layer 3: Judge Consistency Mode

Dispatch forge-judge in cross-screen mode (use same dispatch mechanism resolved in Task 11):
```
Agent(description: "Judge cross-screen consistency", prompt: "
  You are forge-judge. Read skills/forge-judge/SKILL.md and follow it exactly.
  Mode: Cross-Screen Consistency
  Screenshots: {all_screenshot_paths}
  View files: {all_view_file_paths}
  DESIGN.md: .forge/DESIGN.md
  Check for drift in spacing, colors, typography, components, animations.
  Return CONSISTENT or DRIFT DETECTED with specific fixes.
")
```

If DRIFT DETECTED: fix the drifting screens, re-screenshot, re-judge.

### Layer 4: Navigation Sweep

Walk every nav_path in spec.json to verify reachability:
```bash
# For each feature in spec.json:
#   1. snapshot-ui to find the navigation element
#   2. tap to navigate
#   3. verify the target screen appears (snapshot-ui again, check for expected elements)
#   4. navigate back
```

Log any unreachable screens to progress.md.

## Phase 5: Ship

### Step 1: forge-wire
```
Skill("forge-wire")
```

### Step 2: Post-wire verification
```bash
xcodebuildmcp simulator build-sim --scheme "{AppName} - Development" --project-path ./{AppName}.xcodeproj
xcodebuild test -project {AppName}.xcodeproj -scheme "{AppName} - Development" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

If Axiom available, run concurrency + security auditors on wired managers.

### Step 3: forge-storefront
```
Skill("forge-storefront")
```

### Step 4: forge-ship
```
Skill("forge-ship")
```

## Completion

Present final report:
```
# Forge Build Complete

## Features
{table of all features with status}

## Quality
- Adversarial review: {status}
- Axiom scan: {status}
- Consistency check: {status}
- Navigation sweep: {status}

## Next Steps
- [ ] forge-wire: connect backend
- [ ] forge-storefront: design listing
- [ ] forge-ship: submission prep
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: forge-app Phase 4 (verification) + Phase 5 (ship) + completion report"
```

---

### Task 11: Switch plugin registration + verify Phase B coherence

Now that all skills are real (not placeholders), switch from marketplace to local skills.

- [ ] **Step 0: Update .claude/settings.json to use local skills**

Read current settings, then update to remove marketplace reference and point to local skills:

```bash
cat .claude/settings.json
```

The exact registration format depends on how Claude Code discovers local skills. Test skill discovery:

```bash
# Verify skills/ directory exists and has real content
find skills/ -name "SKILL.md" -o -name "PROMPT.md" | wc -l
```

Expected: 8 files (7 SKILL.md + 1 PROMPT.md). Update settings.json accordingly. If skills are not discoverable after the change, restore the old settings.json and investigate.

- [ ] **Step 0b: Write spec.json schema reference**

Create `skills/forge-app/references/spec-schema.json` with the canonical schema so both forge-app (producer) and forge-design (consumer) reference the same contract:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["app_name", "pitch", "preset", "features", "models", "navigation"],
  "properties": {
    "app_name": { "type": "string" },
    "pitch": { "type": "string" },
    "preset": {
      "type": "object",
      "properties": {
        "spacing": { "enum": ["tight", "balanced", "airy"] },
        "corners": { "enum": ["sharp", "mixed", "rounded"] },
        "weight": { "enum": ["heavy", "light"] },
        "surface": { "enum": ["flat", "elevated", "glass"] }
      }
    },
    "features": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "name", "screen_type", "required", "status", "nav_path"],
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "screen_type": { "enum": ["dashboard", "detail", "list", "form", "onboarding", "paywall", "settings"] },
          "description": { "type": "string" },
          "required": { "type": "boolean" },
          "has_manager": { "type": "boolean" },
          "models": { "type": "array", "items": { "type": "string" } },
          "depends_on": { "type": "array", "items": { "type": "string" } },
          "status": { "enum": ["pending", "building", "done", "blocked"] },
          "nav_case": { "enum": ["tab", "push", "sheet"] },
          "icon": { "type": "string" },
          "nav_path": { "type": "array", "items": { "type": "string" } }
        }
      }
    },
    "models": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": { "type": "string" },
          "fields": { "type": "array", "items": { "type": "object" } }
        }
      }
    },
    "navigation": {
      "type": "object",
      "properties": {
        "tabs": { "type": "array", "items": { "type": "string" } },
        "pushes": { "type": "array", "items": { "type": "string" } },
        "sheets": { "type": "array", "items": { "type": "string" } }
      }
    }
  }
}
```

- [ ] **Step 0c: Commit registration + schema**

```bash
git add .claude/settings.json skills/forge-app/references/spec-schema.json
git commit -m "chore: switch to local skills, add spec.json schema reference"
```

- [ ] **Step 1: Cross-reference forge-app dispatch targets**

Verify forge-app references the correct skill names and paths:

```bash
grep -n "forge-judge\|forge-design\|forge-build\|forge-workspace\|forge-wire\|forge-ship\|forge-storefront" skills/forge-app/SKILL.md
```

Every reference should point to `skills/forge-*/SKILL.md` or `skills/forge-build/PROMPT.md`.

- [ ] **Step 2: Cross-reference forge-judge criteria with forge-app floor checks**

Verify no overlap — floor checks should NOT include any of forge-judge's 5 criteria, and forge-judge should NOT check for DSScreen/toast/Observable (those are floor check concerns):

```bash
grep -n "DSScreen\|\.toast\|@Observable\|AsyncImage\|@StateObject" skills/forge-judge/SKILL.md
```

Expected: Zero matches (judge doesn't check these).

- [ ] **Step 3: Cross-reference PROMPT.md placeholders with forge-app injection**

Verify every `{{PLACEHOLDER}}` in PROMPT.md has corresponding injection logic in forge-app:

```bash
grep -o '{{[A-Z_]*}}' skills/forge-build/PROMPT.md | sort -u
```

Compare with forge-app's prompt construction section.

- [ ] **Step 4: Verify preset references are consistent**

```bash
grep -n "tight\|balanced\|airy\|sharp\|rounded\|mixed\|heavy\|light\|flat\|elevated\|glass" skills/forge-design/SKILL.md | head -20
grep -n "tight\|balanced\|airy\|sharp\|rounded\|mixed\|heavy\|light\|flat\|elevated\|glass" docs/design-reference/presets.md | head -20
```

Vocabulary should match between these two files.

- [ ] **Step 5: Commit any fixes**

```bash
git add skills/
git commit -m "fix: resolve cross-skill reference inconsistencies"
```

---

## Phase C: DS Personality Preset System

Add Swift code to AdaptiveTheme that maps preset axes to concrete token values.

---

### Task 12: Define PresetConfiguration type

**Files:**
- Create: `Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/Presets/PresetConfiguration.swift`

- [ ] **Step 1: Write the PresetConfiguration struct**

```swift
import Foundation

/// Defines the four axes that control visual personality.
public struct PresetConfiguration: Sendable {
    public enum SpacingRhythm: String, Sendable {
        case tight, balanced, airy
    }

    public enum CornerRadius: String, Sendable {
        case sharp, rounded, mixed
    }

    public enum TypographyWeight: String, Sendable {
        case heavy, light
    }

    public enum SurfaceTreatment: String, Sendable {
        case flat, elevated, glass
    }

    public let spacing: SpacingRhythm
    public let corners: CornerRadius
    public let weight: TypographyWeight
    public let surface: SurfaceTreatment

    public init(
        spacing: SpacingRhythm = .balanced,
        corners: CornerRadius = .mixed,
        weight: TypographyWeight = .light,
        surface: SurfaceTreatment = .elevated
    ) {
        self.spacing = spacing
        self.corners = corners
        self.weight = weight
        self.surface = surface
    }
}

// MARK: - Named Presets

extension PresetConfiguration {
    /// Dense, technical, dark — inspired by Linear
    public static let linear = PresetConfiguration(
        spacing: .tight, corners: .sharp, weight: .heavy, surface: .flat
    )

    /// Warm, spacious, friendly — inspired by Airbnb
    public static let airbnb = PresetConfiguration(
        spacing: .airy, corners: .rounded, weight: .light, surface: .elevated
    )

    /// Clean, precise, editorial — inspired by Stripe
    public static let stripe = PresetConfiguration(
        spacing: .balanced, corners: .mixed, weight: .light, surface: .flat
    )

    /// Native, premium, spacious — inspired by Apple
    public static let apple = PresetConfiguration(
        spacing: .airy, corners: .mixed, weight: .light, surface: .glass
    )

    /// The Forge template default
    public static let `default` = PresetConfiguration()
}
```

- [ ] **Step 2: Verify it compiles**

```bash
xcodebuildmcp simulator build-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj
```

- [ ] **Step 3: Commit**

```bash
git add Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/Presets/
git commit -m "feat: add PresetConfiguration type with 4 axes and named presets"
```

---

### Task 13: Extend AdaptiveTheme to accept PresetConfiguration

**Files:**
- Modify: `Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/AdaptiveTheme.swift`

- [ ] **Step 1: Read the current AdaptiveTheme**

```bash
cat Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/AdaptiveTheme.swift
```

Understand the current `init(brandColor:)` and how it constructs spacing, radii, typography, and shadows.

- [ ] **Step 2: Add preset parameter to init**

Add a `preset: PresetConfiguration = .default` parameter to `AdaptiveTheme.init`. The preset selects from curated token scales (all values stay on the 4pt grid):

**Spacing** — curated scales on 4pt grid, NOT multipliers:
```swift
let spacing: SpacingScale = switch preset.spacing {
case .tight:
    SpacingScale(xs: 4, sm: 4, smd: 8, md: 12, mlg: 16, lg: 20, xl: 24, xxlg: 32, xxl: 40)
case .balanced:
    SpacingScale(xs: 4, sm: 8, smd: 12, md: 16, mlg: 20, lg: 24, xl: 32, xxlg: 40, xxl: 52)
case .airy:
    SpacingScale(xs: 8, sm: 12, smd: 16, md: 24, mlg: 28, lg: 32, xl: 40, xxlg: 52, xxl: 64)
}
```

**Radii** — curated scales:
```swift
let radii: RadiiScale = switch preset.corners {
case .sharp:
    RadiiScale(xs: 4, sm: 8, md: 8, lg: 12, xl: 16, pill: 999)
case .mixed:
    RadiiScale(xs: 8, sm: 12, md: 16, lg: 20, xl: 28, pill: 999)  // current default
case .rounded:
    RadiiScale(xs: 12, sm: 16, md: 20, lg: 28, xl: 36, pill: 999)
}
```

**Typography weight** — heavy shifts heading weights up (e.g., `.semibold` → `.bold` for display/title styles), light keeps defaults. Apply to the `TypographyScale` construction.

**Shadows** — curated per surface treatment:
```swift
let shadows: ShadowScale = switch preset.surface {
case .flat:
    ShadowScale(
        soft: ShadowToken(color: .clear, radius: 0, y: 0),
        card: ShadowToken(color: .clear, radius: 0, y: 0),
        lifted: ShadowToken(color: .clear, radius: 0, y: 0)
    )
case .elevated:
    ShadowScale(  // current default
        soft: ShadowToken(color: brandColor.opacity(0.06), radius: 8, y: 3),
        card: ShadowToken(color: brandColor.opacity(0.08), radius: 10, y: 5),
        lifted: ShadowToken(color: brandColor.opacity(0.14), radius: 20, y: 8)
    )
case .glass:
    ShadowScale(  // same as elevated — glass effects handled at view level
        soft: ShadowToken(color: brandColor.opacity(0.06), radius: 8, y: 3),
        card: ShadowToken(color: brandColor.opacity(0.08), radius: 10, y: 5),
        lifted: ShadowToken(color: brandColor.opacity(0.14), radius: 20, y: 8)
    )
}
```

- [ ] **Step 3: Verify it compiles and existing behavior is unchanged**

The `.default` preset should produce identical values to the current implementation:

```bash
xcodebuildmcp simulator build-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj
```

- [ ] **Step 4: Commit**

```bash
git add Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/AdaptiveTheme.swift
git commit -m "feat: extend AdaptiveTheme to accept PresetConfiguration — default preserves existing behavior"
```

---

### Task 14: Write unit tests for preset configurations

**Files:**
- Create: `Packages/core-packages/DesignSystem/Tests/DesignSystemTests/PresetConfigurationTests.swift`

- [ ] **Step 1: Write tests verifying named presets produce expected token values**

```swift
import Testing
@testable import DesignSystem

@Suite("PresetConfiguration")
struct PresetConfigurationTests {

    @Test("Default preset produces standard token values")
    func defaultPreset() {
        let theme = AdaptiveTheme(brandColor: .blue, preset: .default)
        let tokens = theme.tokens

        // Spacing should match ThemeFactory defaults
        #expect(tokens.spacing.xs == 4)
        #expect(tokens.spacing.sm == 8)
        #expect(tokens.spacing.md == 16)
        #expect(tokens.spacing.lg == 24)
        #expect(tokens.spacing.xl == 32)

        // Radii should match AdaptiveTheme defaults
        #expect(tokens.radii.xs == 8)
        #expect(tokens.radii.sm == 12)
        #expect(tokens.radii.md == 16)
        #expect(tokens.radii.lg == 20)
        #expect(tokens.radii.xl == 28)
    }

    @Test("Tight spacing uses curated smaller scale on 4pt grid")
    func tightSpacing() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(spacing: .tight)
        )

        // Curated tight scale: xs=4, sm=4, smd=8, md=12, mlg=16, lg=20, xl=24, xxlg=32, xxl=40
        #expect(theme.tokens.spacing.md == 12)
        #expect(theme.tokens.spacing.lg == 20)
        #expect(theme.tokens.spacing.md < 16) // less than balanced default
    }

    @Test("Airy spacing uses curated larger scale on 4pt grid")
    func airySpacing() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(spacing: .airy)
        )

        // Curated airy scale: xs=8, sm=12, smd=16, md=24, lg=32, xl=40, xxlg=52, xxl=64
        #expect(theme.tokens.spacing.md == 24)
        #expect(theme.tokens.spacing.lg == 32)
        #expect(theme.tokens.spacing.md > 16) // more than balanced default
    }

    @Test("Sharp corners use curated smaller radii")
    func sharpCorners() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(corners: .sharp)
        )

        // Curated sharp scale: xs=4, sm=8, md=8, lg=12, xl=16
        #expect(theme.tokens.radii.md == 8)
        #expect(theme.tokens.radii.xl == 16)
    }

    @Test("Flat surface zeroes all shadow radii")
    func flatSurface() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(surface: .flat)
        )

        // radius=0 is sufficient to prove shadows are invisible
        #expect(theme.tokens.shadows.soft.radius == 0)
        #expect(theme.tokens.shadows.card.radius == 0)
        #expect(theme.tokens.shadows.lifted.radius == 0)
    }

    @Test("Named presets have expected axis values")
    func namedPresets() {
        #expect(PresetConfiguration.linear.spacing == .tight)
        #expect(PresetConfiguration.linear.corners == .sharp)
        #expect(PresetConfiguration.airbnb.spacing == .airy)
        #expect(PresetConfiguration.airbnb.corners == .rounded)
        #expect(PresetConfiguration.stripe.surface == .flat)
        #expect(PresetConfiguration.apple.surface == .glass)
    }
}
```

- [ ] **Step 2: Run the tests**

The preset tests are in the SPM package's `DesignSystemTests` target, NOT the Xcode `ForgeUnitTests` target. Run them via swift test:

```bash
cd Packages/core-packages && swift test --filter PresetConfigurationTests 2>&1 | tail -20
```

Expected: All tests pass.

Also verify the app still builds (presets didn't break anything):

```bash
cd ../.. && xcodebuildmcp simulator build-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj
```

Expected: Build succeeded.

- [ ] **Step 3: Commit**

```bash
git add Packages/core-packages/DesignSystem/Tests/DesignSystemTests/PresetConfigurationTests.swift
git commit -m "test: add unit tests for PresetConfiguration — all 4 axes + named presets"
```

---

### Task 15: Verify Phase C — presets work end-to-end

- [ ] **Step 1: Build with default preset**

```bash
xcodebuildmcp simulator build-run-sim --scheme "Forge - Mock" --project-path ./Forge.xcodeproj --simulator-name "iPhone 17 Pro"
```

Expected: App runs, looks identical to current (default preset preserves existing behavior).

- [ ] **Step 2: Run all tests**

```bash
xcodebuild test -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' 2>&1 | tail -20
```

Expected: All tests pass.

- [ ] **Step 3: Verify preset types are accessible from app code**

```bash
grep -r "PresetConfiguration" Packages/core-packages/DesignSystem/Sources/ | wc -l
```

Expected: At least 2 (the type definition + the AdaptiveTheme usage).

- [ ] **Step 4: Final commit if any fixes needed**

```bash
git add .
git commit -m "fix: resolve any remaining preset integration issues"
```

---

## Summary

| Phase | Tasks | What ships | Independently testable? |
|-------|-------|------------|------------------------|
| A | 1-6 | Skills in `skills/` (unchanged ones migrated, placeholders for rewrites), design-reference docs, v3 archived. Marketplace registration preserved. | Yes — build still works, marketplace skills still functional |
| B | 7-11 | forge-build PROMPT.md, forge-judge, forge-design, forge-app (3 subtasks), spec.json schema, plugin switchover | Yes — skills coherence verified, marketplace registration removed |
| C | 12-15 | PresetConfiguration type, AdaptiveTheme extension with curated scales, unit tests | Yes — build + SPM tests pass, preset API available |

**Total: 17 tasks across 3 phases** (Task 10 decomposed into 10/10b/10c).
