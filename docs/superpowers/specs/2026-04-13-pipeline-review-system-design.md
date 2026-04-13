# Pipeline Review & Iteration System

## Overview

A lightweight system for capturing pipeline issues during app builds, protecting against regressions, and batch-applying improvements. No test apps, no CI — just structured logging, git tags, and disciplined commits.

## Problem

The v4 pipeline is new and untested on real apps. When it makes mistakes — and it will — we need to:
1. Remember what went wrong (not lose it by screen 7)
2. Know what to fix (which skill, which rule, which component)
3. Not break what worked when we fix things

## How It Works

### 1. Continuous Capture (during build)

forge-app maintains `.forge/retrospective.md` — a structured log of pipeline issues, written as they happen.

**When entries are created:**
- Human gate feedback (user says "this looks wrong")
- Codex retry (floor check or build failure — what tripped?)
- Judge failure (what criterion failed and was the failure correct?)
- Judge pass that shouldn't have been (user overrides a pass)
- forge-design output that needed manual DESIGN.md edits

**Entry format:**

```markdown
## Screen: {feature_name}

### Stage: {Codex Build | Floor Checks | Hardened Build | Judge | Design}
- **Issue:** What went wrong (one sentence)
- **Root cause:** Why it went wrong (best guess)
- **Fix target:** Which file should change to prevent this next time
- **Severity:** Minor (cosmetic) | Major (wrong output) | Critical (pipeline stuck)
```

**Who writes entries:**
- forge-app writes automatically when retries or failures occur
- The user adds entries manually when they see something the pipeline missed
- Entries accumulate throughout the build — no processing until the app is done

### 2. Snapshot Before Build

Before starting any new app, forge-app creates a git tag:

```bash
git tag forge-pre-{app-name}-$(date +%Y%m%d)
```

This runs as the first action in Phase 1, before any questions are asked. The tag marks the exact pipeline state used for this build.

**What this gives you:**
- Rollback target if improvements break something: `git diff forge-pre-appname-20260413..HEAD -- skills/`
- Comparison between pipeline versions: "App 1 used this pipeline state, App 2 used that one"
- Audit trail: which pipeline version produced which app

### 3. Batch Improvement (after build)

After the app is done, review `.forge/retrospective.md`. Each entry maps to a fix target:

| Fix target | When to change |
|-----------|---------------|
| `skills/forge-build/PROMPT.md` | Codex consistently misunderstands an instruction |
| `skills/forge-build/prompts/*.md` | Screen-type-specific guidance was wrong or missing |
| `skills/forge-judge/SKILL.md` | Judge criteria missed something or were too strict/lenient |
| `skills/forge-design/SKILL.md` | Translation rules didn't produce good DESIGN.md |
| `skills/forge-app/SKILL.md` | Orchestrator flow issue (wrong dispatch, retry logic, state tracking) |
| `AGENTS.md` | Architecture rule was wrong, missing, or too restrictive |
| `docs/design-reference/presets.md` | Preset descriptions didn't match actual output |
| `Packages/core-packages/DesignSystem/` | DS component behavior or token values need adjustment |

**Process:**
1. Read `.forge/retrospective.md` end to end
2. Group entries by fix target
3. For each group: make the fix, commit with message referencing the retrospective
4. Optionally run `/adversarial-review` on changed skill files to catch regressions
5. The retrospective file stays in the app project as a record — don't delete it

**Commit message convention:**

```
fix(forge-judge): add spacing variety check to Craft criterion

Retrospective: Dashboard screen passed with uniform 16pt padding.
Judge Craft criterion didn't explicitly check for spacing variety.
```

### 4. No Test App (for now)

We're not maintaining a canary/test app. The snapshot tags provide rollback safety. If the pipeline matures and changes become riskier, a canary can be added later — run a 2-3 screen spec through the pipeline after skill changes and verify the output hasn't degraded.

## Proactive Behavior

The pipeline should not rely on the user remembering to do things. forge-app is proactive:

### During the build
- **Auto-log:** Every retry, failure, or human feedback is logged to retrospective.md without asking. The user doesn't have to remember to capture issues — they're captured automatically.
- **Pattern detection:** If the same issue recurs across multiple screens (e.g., Codex keeps using hardcoded spacing, Judge keeps failing on the same criterion), forge-app flags it mid-build: "This is the 3rd time Codex used hardcoded padding instead of DS tokens. Consider updating PROMPT.md after this build."
- **Retry context:** When sending fix instructions back to Codex after a failure, forge-app includes what went wrong on previous screens so Codex doesn't repeat the same mistake.

### After the build
- **Retrospective summary:** forge-app's completion report includes a "Pipeline Health" section that groups retrospective entries by fix target and severity, ranked by frequency: "PROMPT.md dashboard fragment: 3 issues. forge-judge Craft criterion: 2 issues. AGENTS.md: 1 issue."
- **Improvement suggestions:** For each group, forge-app suggests the specific change: "Dashboard fragment should mention horizontal ScrollView for quick actions (hit 2 times)."
- **Prompt to act:** "You have 6 retrospective entries across 3 fix targets. Want me to apply improvements now, or save for later?"

### Between builds (new session)
- **Retrospective check:** When forge-app starts a new build, it checks if a previous `.forge/retrospective.md` exists in the template repo (from a prior app's improvements that were applied). If unapplied retrospective entries exist from a previous build, it reminds: "There are unapplied pipeline improvements from your last build. Want to review them first?"
- **Snapshot diff:** forge-app shows what changed since the last snapshot tag: "Pipeline changed since your last app build (forge-pre-lastapp-20260413): 3 skill files updated. Changes look intentional."

## What Changes in forge-app

Additions to the forge-app SKILL.md:

1. **Phase 1 start:** Create git tag `forge-pre-{app-name}-$(date +%Y%m%d)` before asking questions. Check for unapplied retrospective from prior builds.
2. **Throughout Phases 3-4:** Auto-append to `.forge/retrospective.md` on every retry, failure, or human feedback. Detect recurring patterns and flag them mid-build.
3. **Phase 3 retries:** Include cross-screen learnings in Codex retry prompts so mistakes don't repeat.
4. **Phase 5 completion report:** Add "Pipeline Health" section with grouped retrospective entries, frequency-ranked improvement suggestions, and prompt to apply fixes.

## Files

| File | Action |
|------|--------|
| `skills/forge-app/SKILL.md` | Add snapshot tagging, retrospective logging, pattern detection, proactive suggestions |
| `.forge/retrospective.md` | Created per-app during build (forge-app writes it automatically) |
