# Design: forge-feature Pipeline

**Date:** 2026-02-22
**Status:** Approved

---

## Problem

Forge has excellent components (AGENTS.md, 3 marketplace skills, design system, architectural rules) but no enforced pipeline connecting them. Feature development is ad-hoc: sometimes you plan, sometimes you don't. Quality varies per session. There's no structured process from idea to shipped feature.

## Solution

A `forge-feature` orchestrator skill that enforces a consistent pipeline by chaining existing tools. Two explicit modes: **full** (opt-in for major features) and **quick** (default for most work). Optional integration with GSD and Ralph Loop when installed.

---

## Pipeline Design

### Quick Mode (Default)

Invoked via `/forge:quick` or detected from simple requests.

```
1. Scaffold  → forge-screens (if new screen needed)
2. Build     → implementation
3. Polish    → swiftui-craft (always runs)
4. Verify    → build check + visual confirmation
```

Cost: ~100K-200K tokens. Skips brainstorming, formal planning, and code review.

### Full Mode

Invoked via `/forge:feature` or explicitly requested.

```
1. Brainstorm  → understand intent, propose approaches, confirm scope
2. Plan        → implementation steps, file list, task breakdown
3. Scaffold    → forge-screens (generate View + ViewModel skeleton)
4. Build       → write the actual code
5. Polish      → swiftui-craft (premium design pass)
6. Verify      → build, check output, visual confirmation
7. Review      → final quality gate against AGENTS.md rules
```

Cost: ~200K-400K tokens depending on feature complexity.

### Step Details

**Step 1 - Brainstorm (full mode only):**
- If `superpowers:brainstorming` is installed, invoke it
- If not, run inline: ask 2-3 clarifying questions, propose approaches, confirm
- Output: confirmed scope and approach (no design doc file needed for inline)

**Step 2 - Plan (full mode only):**
- If `superpowers:writing-plans` is installed, invoke it
- If not, produce an inline numbered task list via TodoWrite
- **GSD escalation trigger:** if the plan has 5+ tasks OR spans 3+ feature areas OR requires multi-session work, auto-escalate to `/gsd:plan-phase`
- Output: task list or GSD PLAN.md

**Step 3 - Scaffold:**
- Invoke `forge-screens` to generate View + ViewModel files
- Skip if the feature doesn't need new screens (e.g., modifying existing screens)
- Output: generated files in Features/{FeatureName}/

**Step 4 - Build:**
- Implement the feature following AGENTS.md rules
- If Ralph Loop is installed and the work is iterative UI, suggest activating it
- Use haiku model for straightforward implementation tasks (cost optimization)
- Output: working implementation

**Step 5 - Polish:**
- Always invoke `swiftui-craft`
- Runs on all new/modified View files from steps 3-4
- Output: polished UI

**Step 6 - Verify:**
- Run `xcodebuild` to confirm compilation
- Use haiku model for build verification (cost optimization)
- If build fails, loop back to step 4
- Output: passing build

**Step 7 - Review (full mode only):**
- If `superpowers:requesting-code-review` is installed, invoke it
- If not, run inline review against AGENTS.md checklist:
  - DS components used (no raw UI)
  - Analytics events tracked
  - MVVM pattern followed
  - Concurrency rules respected
  - No @State for data
- If review finds issues, loop back to appropriate step
- Output: approval or revision notes

---

## GSD Auto-Escalation

During the Plan step, if any of these conditions are met:
- 5+ implementation tasks
- Changes spanning 3+ feature areas
- Multi-session scope detected

The skill automatically escalates:
- Plan step uses `/gsd:plan-phase` instead of inline planning
- Build step uses `/gsd:execute-phase` for atomic commits and checkpoints
- Verify step uses `/gsd:verify-work` for goal-backward verification

**GSD is optional.** If not installed, the skill handles large features with TodoWrite task tracking and manual atomic commits. The pipeline works identically either way.

---

## Token Cost Optimization

### Model Selection Per Step

| Step | Recommended Model | Rationale |
|------|-------------------|-----------|
| Brainstorm | opus | Creative judgment, approach selection |
| Plan | opus | Architectural decisions |
| Scaffold | sonnet | Templated generation, follows patterns |
| Build | sonnet (simple) / opus (complex) | Balance cost and quality |
| Polish | opus | Design judgment, craft quality |
| Verify | haiku | Mechanical build check |
| Review | sonnet | Pattern matching against rules |

### Context Management

- **Subagent isolation:** Run scaffold, polish, and verify as Task subagents with separate context windows. Prevents context bleed and reduces per-step token load.
- **No redundant reads:** The orchestrator tracks which files have been read. Each step receives only the files it needs, not the full conversation history.
- **Quick mode default:** Most features use quick mode (4 steps, ~50% token savings). Full mode is explicitly opted into.

### Estimated Costs Per Feature

| Feature Size | Mode | Estimated Tokens | Approximate Cost |
|---|---|---|---|
| Small (add button, tweak layout) | quick | 80K-120K | ~$0.30-0.50 |
| Medium (new screen with logic) | quick | 150K-250K | ~$0.60-1.00 |
| Medium (new screen, formal) | full | 250K-400K | ~$1.00-1.60 |
| Large (multi-screen feature) | full + GSD | 400K-800K | ~$1.60-3.20 |

---

## Monetization & Dependency Strategy

### Ownership Structure

**Forge template (proprietary, paid product):**
- iOS app source code, AGENTS.md, design system, build configs
- The `forge-feature` skill as the enforced development methodology
- This is the core product buyers pay for

**forge-marketplace (MIT, free):**
- `forge-workspace` — template setup and branding
- `forge-screens` — architecture-correct screen scaffolding
- `swiftui-craft` — premium SwiftUI design polish
- `forge-feature` — the orchestrator pipeline (NEW)
- Free skills are the hook; they make the paid template shine

### Dependency Classification

| Dependency | License | Role | Required? |
|---|---|---|---|
| forge-marketplace skills | MIT (yours) | Core pipeline | Yes |
| Superpowers | MIT | Enhanced brainstorm/plan/review | No — inline fallbacks |
| Ralph Loop | Apache 2.0 | Build iteration | No — manual build works |
| GSD | No license (all rights reserved) | Large feature management | No — TodoWrite fallback |

**Critical rule:** The `forge-feature` pipeline MUST work with zero third-party plugins. Every step has an inline fallback. Third-party tools enhance but are never required.

### License Compliance

The `forge-feature` skill file must include:
- MIT license header (matching forge-marketplace)
- No bundled third-party code
- Detection-only integration: check if plugins exist, invoke if available, fall back if not

### Buyer Experience

When someone buys Forge and clones the repo:
1. AGENTS.md tells them to install forge-marketplace (free, MIT)
2. `forge-feature` works immediately with just forge-marketplace skills
3. README recommends optional enhancements (superpowers, Ralph Loop) for power users
4. GSD is mentioned as optional for multi-session project management
5. No paid dependencies, no license conflicts

---

## Trigger Phrases

**Full mode:**
- `/forge:feature`
- "Build a feature for [X]"
- "I want to add [feature]"
- "Create [feature] for my app"

**Quick mode:**
- `/forge:quick`
- "Just add [small thing]"
- "Quick: [change]"
- "Add a [simple thing] to [screen]"

---

## File Structure

New plugin in forge-marketplace:

```
forge-feature/
├── claude-code.json              # Plugin manifest
└── skills/
    └── forge-feature/
        ├── SKILL.md              # Main orchestrator logic
        └── references/
            ├── pipeline.md       # Step definitions, model hints, escalation rules
            └── fallbacks.md      # Inline fallbacks for when third-party skills aren't installed
```

---

## What Changes in AGENTS.md

Add to the "How to Build Features" section:

```markdown
### Recommended Workflow

Use the `forge-feature` pipeline for consistent, high-quality output:

- **Most features:** `/forge:quick` — scaffold, build, polish, verify
- **Major features:** `/forge:feature` — full pipeline with brainstorming, planning, and review
- **Multi-session work:** Automatically escalates to GSD when complexity warrants it

Install: `claude plugin install forge-feature@forge-marketplace`
```

---

## Success Criteria

1. Every feature built through the pipeline compiles on first verify attempt (>90%)
2. Every screen uses DS components (no raw SwiftUI)
3. Every ViewModel tracks analytics events
4. Premium design quality is consistent across sessions
5. Pipeline works with zero third-party plugins installed
6. Template is commercially distributable without license conflicts
