# Forge Pipeline Redesign: Planner-Generator-Evaluator Architecture

> **Note (2026-04-04):** This spec describes the v2 architecture. See `2026-04-04-pipeline-visual-design-phase-design.md` for the v3 evolution which adds: forge-design skill (required visual design phase), code-only Generator, 7-criteria Judge, centralized build verification, agent teams, and `/forge:continue` session handoff.

## Problem Statement

The current Forge pipeline has 11 skills totaling 7,000+ lines, 10 sequential steps, and triple-layer agent delegation. It produces mediocre iOS apps while burning excessive tokens. Research across Anthropic, Lovable, Bolt, v0, Microsoft, and Google identifies three root causes:

1. **Coordination tax** — 79% of multi-agent failures stem from coordination, not model capability. Triple delegation (orchestrator → general-purpose agent → skill → browser agent) degrades context at every handoff.
2. **Context rot** — Agent coherence degrades after 20-30 turns. A 10-step sequential pipeline with 7,000 lines of instructions drowns signal in noise.
3. **No independent critic** — Single agents are sycophantic. The pipeline has no skeptical evaluator, so mediocre output passes every gate.

## Architecture: Three Skills + One Contract (v2)

```
Current (11 skills, ~7,000 lines):
  forge-app → general-purpose → forge-ux/craft/voice/screens → forge-browse/craft-agent/verifier

New (3 core skills, ~900 lines + DESIGN.md contract):
  forge-app (Orchestrator)     ~400 lines
  forge-build (Generator) ~300 lines  
  forge-judge (Evaluator) ~200 lines
  DESIGN.md format        ~100 lines (format spec, not a skill)
```

> **v3 update:** This has been superseded by a 4-skill architecture. See the v3 spec for details.

### What Happens to the Other Skills

| Old Skill | Lines | Fate | Rationale |
|-----------|-------|------|-----------|
| forge-app | 1,162 | **Rewrite** → Orchestrator | Streamlined: spec conversation + DESIGN.md generation + sprint orchestration |
| forge-ux | 286 | **Absorbed** → Orchestrator | Feature design is part of spec creation, not a separate step |
| forge-craft | 1,093 | **Split** → Orchestrator + DESIGN.md | Research/direction → Orchestrator. Build instructions → DESIGN.md contract. No separate skill. |
| forge-voice | 274 | **Absorbed** → Orchestrator | Voice/copy goes directly into DESIGN.md voice section |
| forge-screens | 351 | **Absorbed** → Generator | Scaffolding is part of building, not a separate step |
| forge-feature | 515 | **Replaced** by Generator + Judge loop | The sprint loop replaces the pipeline |
| forge-craft-agent | 215 | **Replaced** by Generator | Simplified mechanical builder |
| forge-verifier | 92 | **Replaced** by Judge | Compliance checks move to the evaluator |
| forge-craft-polish | 59 | **Killed** | Anti-pattern reference moves to DESIGN.md Don'ts section |
| forge-eye | 439 | **Absorbed** → Judge | Screenshot verification is the Judge's job |
| forge-health | 478 | **Replaced** by Judge | Quality auditing is what the Judge does |
| forge-workspace | 391 | **Stays** | Project setup, run once, separate concern |
| forge-wire | 940 | **Stays** | Post-build, separate concern |
| forge-ship | 1,113 | **Stays** | Post-build, separate concern |
| forge-storefront | 262 | **Stays** | Post-build, separate concern |

### Delegation Model

**Current:** Three layers of delegation per screen build.
```
forge-app (orchestrator context)
  └─ Task(general-purpose) — re-reads AGENTS.md, blueprint, mood, voice-guide
       └─ invokes forge-craft skill — loads 1,093 lines of instructions
            └─ spawns forge-browse agent — separate context for browsing
```

**New:** One layer of delegation per screen build.
```
forge-app (Orchestrator — runs in main context)
  ├─ Task(forge-build) — reads AGENTS.md + DESIGN.md + spec.json feature entry
  └─ Task(forge-judge) — reads DESIGN.md + screenshot + created files
```

No intermediate general-purpose agents. No skill-within-skill invocation. Direct dispatch.

---

## Skill 1: The Orchestrator (forge-app)

### Purpose
Takes an app idea → produces a complete build contract (spec.json + DESIGN.md) through conversation with the user. Then orchestrates the sprint loop.

### Phase 1: Spec Conversation (~5 questions, adaptive)

The Orchestrator asks questions to understand the app. Unlike the current 8-question sequence + pre-blueprint research + blueprint generation, this is streamlined:

1. **Pitch + Target** — "What does your app do and who is it for?"
2. **Monetization** — "How does it make money?" (Free / Freemium / Subscription)
3. **Reference apps** — "Name 1-2 apps whose feel you want to match."
4. **Core screens + flows** — Orchestrator proposes screens based on answers. User confirms/adjusts.
5. **Brand direction** — Orchestrator suggests brand color + mood based on domain and references. User confirms.

If the user provides all context upfront, skip to spec generation. No re-asking what's already answered.

### Phase 2: Contract Generation

The Orchestrator produces two artifacts:

**`spec.json`** — The technical contract:
```json
{
  "app": { "name": "Ledgr", "bundle_id": "com.example.ledgr", "pitch": "..." },
  "features": [
    {
      "id": "dashboard",
      "type": "tab",
      "screen_type": "primary_surface",
      "description": "Monthly spending overview with hero stat and recent transactions",
      "has_manager": true,
      "models": ["Transaction"],
      "depends_on": [],
      "status": "pending"
    }
  ],
  "models": [
    {
      "name": "Transaction",
      "fields": [
        { "name": "id", "type": "String" },
        { "name": "merchant", "type": "String" },
        { "name": "amount", "type": "Double" },
        { "name": "category", "type": "TransactionCategory" },
        { "name": "createdAt", "type": "Date" }
      ]
    }
  ],
  "navigation": {
    "tabs": ["dashboard", "transactions", "settings"],
    "routes": ["transactionDetail"],
    "sheets": ["addTransaction"]
  }
}
```

**`DESIGN.md`** — The prescriptive design contract including voice/copy (see Section: The DESIGN.md Format below).

### Phase 3: Sprint Orchestration

For each feature in `spec.json`:
```
1. Dispatch Generator (Task subagent) → builds the feature
2. Dispatch Judge (Task subagent) → evaluates screenshot + code
3. If Judge says FAIL → dispatch Generator with surgical fix instructions
4. If Judge says PASS → show screenshot to human for final approval
5. Human approves → mark feature "done" in spec.json, move to next
6. Human requests changes → dispatch Generator with human's feedback
```

Max 2 Judge fix rounds per feature. Max 2 human feedback rounds per feature. After that, move on and log the issue.

### Phase 4: Finalization

After all features are built:
1. Dispatch Judge for cross-screen consistency check (one pass over all View files)
2. Navigation wiring verification
3. Final build verification
4. Completion report

### What the Orchestrator Does NOT Do
- No browsing (forge-browse is an optional tool, not part of the core pipeline)
- No Stitch mockup generation
- No UI Pro Max queries
- No marketing research sub-tasks

These tools can optionally inform the DESIGN.md during Phase 2 if available, but they're not required. The DESIGN.md contract must stand on its own.

### Optional Enhancements (detected, not required)

If available, the Orchestrator uses these during Phase 2 to inform DESIGN.md:
- **Playwright** — browse 2-3 reference apps for visual inspiration
- **Stitch MCP** — generate 1-2 direction mockups
- **Marketing skills** — inform onboarding/paywall copy in DESIGN.md

If none are available, the Orchestrator writes DESIGN.md from the spec conversation alone.

---

## The DESIGN.md Format

The core innovation. Based on Google Stitch's DESIGN.md concept and the awesome-design-md format, adapted for SwiftUI/iOS.

**Why this works where our current design-system.md fails:** The current file uses descriptive language ("the hero should feel important, use generous spacing"). DESIGN.md uses prescriptive tokens and explicit bans. LLMs follow constraints better than aspirations.

### Format Structure

```markdown
# {AppName} Design Contract

## 1. Mood
{1-2 sentence mood statement. This is the touchstone for every decision.}

## 2. Color Palette

| Role | Light | Dark | Usage |
|------|-------|------|-------|
| brand | #0071E3 | #0A84FF | Interactive elements only. Never backgrounds. |
| background | #FFFFFF | #000000 | Primary surface |
| surface | #F5F5F7 | #1C1C1E | Cards, grouped content |
| textPrimary | #1D1D1F | #F5F5F7 | Headlines, body |
| textSecondary | #86868B | #98989D | Captions, metadata |
| positive | #34C759 | #30D158 | Income, success |
| negative | #FF3B30 | #FF453A | Expense, errors |

Map to: `Color.themePrimary`, `.backgroundPrimary`, `.surface`, `.textPrimary`, etc.

## 3. Typography

| Role | Token | Design | Weight | Size | Tracking |
|------|-------|--------|--------|------|----------|
| Display number | `.display()` | .monospaced | .bold | 48 | -0.5 |
| Section title | `.titleMedium()` | .default | .semibold | 20 | -0.4 |
| Body | `.bodyMedium()` | .default | .regular | 17 | 0 |
| Caption | `.captionLarge()` | .default | .regular | 13 | 0 |
| Data value | `.headlineMedium()` | .monospaced | .medium | 22 | -0.2 |

## 4. Component Rules

| DS Component | Use | How |
|-------------|-----|-----|
| DSButton | YES | Primary = filled brand color. Secondary = outlined. |
| DSCard | CUSTOMIZE | Depth: .flat. Add thin border (Color.border, 8% opacity). No shadow. |
| DSHeroCard | NO | Don't use. Hero is a standalone number with whitespace. |
| DSListRow | YES | Add monospaced digits to trailing amounts. |
| DSScreen | YES | Standard wrapper. |
| EmptyStateView | NO | Single italic line, centered, secondary text. No icon. |
| GlassCard | NO | Glass doesn't serve clinical mood. |
| StaggeredVStack | NO | No staggered entrance. Use simple top-to-bottom fade. |

## 5. Layout Principles

- Spacing rhythm: tight within groups (DSSpacing.sm), generous between sections (DSSpacing.xxl)
- One dominant element per screen (the hero)
- Minimum 3 text sizes per screen for hierarchy
- No uniform padding — vary spacing to create structure

## 6. Do's and Don'ts

### Do
- Use monospaced digits for ALL numbers
- Vary spacing between sections (never uniform DSSpacing.lg everywhere)
- Use opacity variants of brand color for subtle tints (10% for surfaces)
- Let whitespace create hierarchy, not card wrappers

### Don't
- Don't use AmbientBackground gradient
- Don't use DSHeroCard for hero numbers
- Don't use StaggeredVStack entrance animations
- Don't use bouncy springs (use .smooth or .snappy)
- Don't use generic empty state icons
- Don't use Font.system(size:) — always DS typography tokens
- Don't use Color literals — always semantic colors
- Don't wrap everything in cards

## 7. Screen Blueprints

### Dashboard
**Hero:** Monthly total — .display(), monospaced, left-aligned. No card wrapper.
**Stats row:** 3 metrics in surface pills. Label above (.captionLarge()), value below (.headlineMedium(), monospaced).
**List:** Recent transactions. Category icon, merchant name, amount right-aligned (monospaced).
**Empty state:** "No transactions recorded." — single italic line.
**Entrance:** Fade-in, top-to-bottom, .smooth spring.

### Settings
**Structure:** DSListCard groups with DSListRow items.
**Destructive actions:** Confirmation dialog, not immediate.
**Version:** Bottom, .captionLarge(), .textTertiary.

{...one blueprint per screen}

## 8. Voice & Copy

### Tone
{1-2 sentences about voice personality}

### Per-Screen Copy
| Screen | Element | Copy |
|--------|---------|------|
| Dashboard | Empty state | "No transactions recorded." |
| Dashboard | Error toast | "Couldn't load transactions. Pull to retry." |
| Onboarding Step 1 | Title | "Track every dollar." |
| Onboarding Step 1 | Body | "See where your money goes with zero effort." |
| Settings | Delete account | "This can't be undone. All data will be permanently deleted." |

{...exhaustive copy table for all screens and states}
```

### Why This Format Works

1. **Semantic color roles** — The AI knows exactly where each color goes, not just "use blue."
2. **Typography tables** — Exact tokens, weights, sizes. No room for interpretation.
3. **Component rules with YES/NO/CUSTOMIZE** — Explicit. Not "consider using" — either use it or don't.
4. **Do's and Don'ts** — The poka-yoke mechanism. Explicitly bans the AI defaults that produce template smell.
5. **Screen blueprints** — Describe WHAT each screen looks like using DS token names. No SwiftUI code.
6. **Copy table** — Exhaustive. No generic "No items" or "Submit" anywhere.

---

## Skill 2: The Generator (forge-build)

### Purpose
Mechanical screen implementer. Reads DESIGN.md + AGENTS.md + spec.json feature entry. Builds the feature. Screenshots. Returns proof.

### What It Reads (per sprint)
- `AGENTS.md` — architecture rules (ViewModel patterns, loading states, navigation)
- `.forge/DESIGN.md` — the full design contract
- `.forge/spec.json` — the specific feature being built
- Existing files being modified (JIT — only files relevant to this feature)

### What It Does NOT Read
- No mood.md (mood is in DESIGN.md Section 1)
- No design-references/ (visual research is done, contract is written)
- No feature-specs/ (feature spec is in spec.json)
- No voice-guide.md (copy is in DESIGN.md Section 8)
- No progress.md (progress is in spec.json feature statuses)

One file for design decisions, one file for what to build. That's it.

### Pipeline Per Feature

```
1. Read AGENTS.md (relevant sections only)
2. Read DESIGN.md
3. Read spec.json feature entry
4. If feature has_manager: create protocol + mock manager, register in AppServices
5. Create/modify View + ViewModel files following:
   - AGENTS.md architecture patterns (MVVM, @Observable, toast, onAppear, etc.)
   - DESIGN.md component rules (YES/NO/CUSTOMIZE table)
   - DESIGN.md screen blueprint (the specific screen being built)
   - DESIGN.md do's and don'ts (hard constraints)
   - DESIGN.md voice copy (exact strings from copy table)
6. Build in simulator (xcodebuild)
7. Launch app, navigate to screen, screenshot
8. READ the screenshot — verify it rendered
9. Run floor checks (grep for banned patterns from DESIGN.md Don'ts + AGENTS.md Post-Build Checks)
10. If floor checks fail → fix and rebuild (max 2 rounds)
11. Commit: "feat: build {feature_name} screen"
12. Return: screenshot path, files created/modified, build status
```

### Key Design Decisions

- **No aesthetic judgment.** The Generator follows the DESIGN.md contract. It doesn't evaluate whether the result "looks good." That's the Judge's job.
- **No self-critique.** Research shows single agents praise their own mediocre work. The Generator builds and reports. Period.
- **Floor checks are mechanical.** Grep for `Font.system(size:`, `Color(red:`, `AsyncImage`, `@StateObject`, `StaggeredVStack` (if banned in Don'ts). Binary pass/fail.
- **One feature per dispatch.** No building 3 screens in one context. Fresh context per feature prevents context rot.

### Agent Type
`forge-feature:forge-build` — a dedicated subagent with Write/Edit/Bash/Read/Grep/Glob tools. Runs with `bypassPermissions` for uninterrupted building.

---

## Skill 3: The Judge (forge-judge)

### Purpose
Independent skeptical evaluator. Runs in a SEPARATE context from the Generator. Grades the output against the DESIGN.md contract.

### What It Reads
- `.forge/DESIGN.md` — the contract to grade against
- Screenshot of the built screen (provided by Orchestrator from Generator's output)
- The View and ViewModel files that were created/modified

### Grading Criteria

The Judge grades on 4 criteria (from Anthropic's harness research):

**1. Design Quality (PASS/FAIL)**
- Does the screen have a distinct visual identity matching the mood?
- Does the typography hierarchy use the tokens specified in DESIGN.md Section 3?
- Does the color usage match DESIGN.md Section 2 roles?
- Is there one dominant element (hero) per screen?

**2. Originality (PASS/FAIL)**
- Does it avoid AI defaults? Check DESIGN.md Don'ts list against actual code.
- Does it look like a DESIGNED app or assembled components?
- Are there template sins? (uniform padding, same card everywhere, generic empty states)

**3. Craft (PASS/FAIL)**
- Spacing: Does spacing vary between sections (not uniform)?
- Typography: Are there 3+ text sizes creating hierarchy?
- Components: Are component rules (YES/NO/CUSTOMIZE) followed correctly?
- Copy: Does the copy match DESIGN.md Section 8 exactly? Any generic "No items" or "Submit"?

**4. Architecture (PASS/FAIL)**
- AGENTS.md compliance: DSScreen, .toast(), .onAppear, @Observable, Event enum, hasLoaded
- No @StateObject, no AsyncImage, no business logic in View body
- Manager pattern correct (if applicable): protocol + mock, skeleton loading, empty state

### Output Format

```
JUDGE VERDICT: {PASS|FAIL}

Design Quality: {PASS|FAIL}
  {specific observations}

Originality: {PASS|FAIL}  
  {specific observations — reference DESIGN.md Don'ts violations if any}

Craft: {PASS|FAIL}
  {specific observations — spacing, typography, copy violations}

Architecture: {PASS|FAIL}
  {specific observations — AGENTS.md violations}

FIXES REQUIRED (if FAIL):
1. {specific fix with file path and what to change}
2. {specific fix}
...
```

### Key Design Decisions

- **Skeptical by default.** The Judge's system prompt includes: "Assume the output is mediocre until proven otherwise. Your job is to catch problems, not praise competence."
- **Separate context.** The Judge never shares context with the Generator. This prevents sycophantic convergence.
- **Grades against the contract.** Every judgment traces back to a specific DESIGN.md section. No subjective "I think it should be different."
- **Cross-screen consistency.** After all features are built, the Judge does one final pass checking all View files against each other for consistency (same spacing rhythm, same component vocabulary, same typography treatment).

### Agent Type
`forge-feature:forge-judge` — a dedicated subagent with Read/Grep/Glob/Bash tools. No Write/Edit — the Judge diagnoses, it doesn't fix. Fixes go back to the Generator.

---

## The Sprint Loop

This is how the three skills work together for each feature:

```
Orchestrator (main context):
  for each feature in spec.json where status == "pending":
    
    1. GENERATE
       dispatch Task(forge-build):
         "Build feature: {feature.id}
          Working directory: {dir}
          Read AGENTS.md, .forge/DESIGN.md, .forge/spec.json
          Feature: {feature as JSON}
          Return: screenshot path, files created, build status"
       
       wait for completion
       if build failed → log, retry once, if still failed → mark "failed", continue

    2. EVALUATE  
       dispatch Task(forge-judge):
         "Evaluate feature: {feature.id}
          Working directory: {dir}
          Screenshot: {screenshot_path}
          Files created: {file_list}
          Read .forge/DESIGN.md for grading criteria
          Grade: Design Quality, Originality, Craft, Architecture"
       
       wait for completion

    3. FIX (if Judge says FAIL)
       dispatch Task(forge-build):
         "Fix feature: {feature.id}
          Working directory: {dir}
          Judge feedback: {judge_verdict}
          Fix ONLY the specific issues listed. Don't rebuild from scratch.
          Return: screenshot path, files modified, build status"
       
       wait → re-evaluate with Judge (max 2 fix rounds)

    4. HUMAN GATE
       Show screenshot to user:
         "Here's {feature.id}. [describe screenshot]. Approve or request changes?"
       
       if approved → update spec.json status to "done"
       if feedback → dispatch Generator with human's feedback (max 2 rounds)
       
    5. PROGRESS
       "Built {n}/{total} features. Next: {next_feature.id}"
```

### Parallelization

Independent features (no `depends_on` entries) can be built in parallel using multiple Generator dispatches. The Judge evaluates each independently. This is safe because each Generator works on different files.

Dependent features must be sequential (e.g., detail screen depends on list screen existing first).

---

## Context Management

### The Hydration Pattern (from Lovable)

**Problem:** Dumping the entire project into every agent call wastes context and degrades quality.

**Solution:** Each agent reads only what it needs:

| Agent | Reads | Does NOT Read | Estimated Context |
|-------|-------|---------------|-------------------|
| Orchestrator | User conversation, spec.json | Code files, AGENTS.md | ~2K tokens |
| Generator | AGENTS.md (~400 lines relevant), DESIGN.md (~150 lines), spec.json feature (~20 lines), existing files being modified (~200 lines) | Other features, design references, progress history | ~4K tokens |
| Judge | DESIGN.md (~150 lines), screenshot, created files (~300 lines) | AGENTS.md, spec.json, conversation history | ~2K tokens |

**Compare to current:** Each forge-craft-agent invocation loads AGENTS.md (422 lines) + design-system.md (varies, 200-500 lines) + mood.md + voice-guide.md + feature-specs/ + the skill itself (215 lines) + the parent skill (1,093 lines loaded by the general-purpose agent that invoked it). Estimated: 8-15K tokens of instructions before writing a single line of code.

### File Consolidation

**Current:** 6+ files in .forge/ that agents must cross-reference:
- blueprint.md, mood.md, design-system.md, voice-guide.md, progress.md, feature-specs/*.md, design-references/index.md, analytics-strategy.md, design-decisions.md, issues.md

**New:** 2 files:
- `spec.json` — what to build (features, models, navigation, status tracking)
- `DESIGN.md` — how it should look, sound, and feel (design + voice + do's/don'ts)

Everything the Generator and Judge need is in these two files. No cross-referencing. No "read mood.md then read design-system.md then read voice-guide.md then check feature-specs/."

---

## Token Budget Comparison

### Current Pipeline (estimated per screen)

| Step | Tokens In | Tokens Out | Notes |
|------|-----------|------------|-------|
| forge-app orchestrator context | 5,000 | 500 | Skill itself + conversation |
| General-purpose agent spawn | 3,000 | 200 | Re-reads project context |
| forge-craft skill load | 4,000 | - | 1,093 lines of skill instructions |
| forge-browse agent | 5,000 | 1,000 | Browsing, screenshots |
| forge-craft-agent skill load | 2,000 | - | 215 lines + references |
| Actual code generation | 3,000 | 2,000 | The actual work |
| forge-verifier | 2,000 | 500 | Compliance checks |
| **Total per screen** | **~24,000** | **~4,200** | |

### New Pipeline (estimated per screen)

| Step | Tokens In | Tokens Out | Notes |
|------|-----------|------------|-------|
| Generator dispatch | 4,000 | 2,000 | AGENTS.md + DESIGN.md + spec entry + code gen |
| Judge dispatch | 2,000 | 500 | DESIGN.md + screenshot + grade |
| Fix round (50% of screens) | 2,000 | 1,000 | Surgical fix |
| **Total per screen** | **~8,000** | **~3,500** | |

**Estimated savings: ~65% fewer input tokens per screen.** For a 7-screen app, that's ~112K saved.

---

## What Stays Unchanged

- **AGENTS.md** — Architecture rules, ViewModel patterns, DS component reference, post-build checks. No changes needed.
- **DesignSystem package** — Token system, components, theme. No changes.
- **Template app structure** — Features/, Managers/, Models/, Components/, App/. No changes.
- **forge-workspace** — Project setup skill. Stays as-is.
- **forge-wire** — Backend connection. Stays as-is.
- **forge-ship** — App Store submission. Stays as-is.
- **forge-storefront** — App Store listing. Stays as-is.
- **XcodeBuildMCP** — Build/launch/screenshot tooling. Stays as-is.

---

## Migration Path

### Phase 1: The Contract (DESIGN.md format)
- Define the DESIGN.md format specification
- Create 2-3 example DESIGN.md files for different app moods (clinical, warm, playful)
- Write a converter that maps the current design-system.md + mood.md + voice-guide.md → DESIGN.md

### Phase 2: The Judge (forge-judge)
- Build the evaluator agent
- Define grading criteria and output format
- Test by running it against existing forge-app builds (evaluate screens that already exist)

### Phase 3: The Generator (forge-build)
- Build the simplified builder agent
- Replace forge-craft-agent
- Test: build one screen with DESIGN.md + AGENTS.md, have Judge evaluate

### Phase 4: The Orchestrator (forge-app)
- Rewrite the orchestrator
- Streamlined spec conversation
- DESIGN.md generation
- Sprint loop with Generator + Judge

### Phase 5: End-to-End Test
- Build a complete test app through the new pipeline
- Compare output quality to the old pipeline
- Iterate on DESIGN.md format based on results

### Phase 6: Kill Old Skills
- Remove forge-ux, forge-craft, forge-voice, forge-screens, forge-feature, forge-health
- Remove forge-craft-agent, forge-verifier, forge-browse, forge-eye, forge-craft-polish
- Update forge-marketplace README
- Update this repo's README

---

## Design Decisions (Resolved)

1. **Judge has NO Write/Edit tools.** The Judge diagnoses, the Generator fixes. This adds a round-trip but maintains separation of concerns. Research shows that combining generation and evaluation in the same agent causes sycophantic convergence. The round-trip cost is worth the quality gain.

2. **Orchestrator generates DESIGN.md, human approves.** The Orchestrator generates the full DESIGN.md from the spec conversation. The human reviews and can edit any section before building starts. This is faster than having the human write from scratch, and the human gate catches bad design decisions.

3. **~~forge-browse is killed.~~ Visual references are REQUIRED (v3).** The v2 spec made references optional. The Kova build (2026-04-04) proved this was wrong — without visual targets, the pipeline produces generic output. In v3, forge-design runs Playwright → Mobbin as a required phase before DESIGN.md generation. The DESIGN.md contract is informed by approved mockups, not generated from text alone.

4. **Impeccable is optional and runs inside the Judge.** If `impeccable:critique` is available, the Judge invokes it as part of the Craft grading criterion. If not, the Judge grades Craft using its own analysis. Impeccable supplements the Judge; it doesn't replace it.

---

## Research Sources

This design is informed by research compiled in NotebookLM notebook "Forge Pipeline Redesign Research" (ID: 12d5a4b9). Key sources:

- [Building Effective AI Agents](https://www.anthropic.com/engineering/building-effective-agents) — Anthropic
- [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) — Anthropic (March 2026)
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Anthropic
- [Building a C compiler with parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) — Anthropic
- [Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices) — Anthropic
- [Lovable: Building an AI-Powered Platform with Multiple LLM Integration](https://www.zenml.io/llmops-database/building-an-ai-powered-software-development-platform-with-multiple-llm-integration) — ZenML
- [Design Systems + Lovable, Bolt, v0, Replit](https://www.designsystemscollective.com/design-systems-lovable-bolt-v0-and-replit-50a0a197bc35) — Design Systems Collective
- [How AI Prototyping Tools Actually Work: Bolt's Architecture](https://amankhan1.substack.com/p/how-ai-prototyping-tools-actually) — Substack
- [The Swarm Diaries: Multi-Agent Failure Post-Mortem](https://techcommunity.microsoft.com/blog/appsonazureblog/the-swarm-diaries-what-happens-when-you-let-ai-agents-loose-on-a-codebase/4501393) — Microsoft
- [Context Rot: Why AI Agents Fail After Turn Twenty](https://www.techaheadcorp.com/blog/context-rot-problem/) — TechAhead
- [Single-Agent vs Multi-Agent AI](https://www.augmentcode.com/guides/single-agent-vs-multi-agent-ai) — Augment Code
- [Choose a design pattern for agentic AI](https://docs.cloud.google.com/architecture/choose-design-pattern-agentic-ai-system) — Google Cloud
- [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) — VoltAgent (Google Stitch DESIGN.md format)
