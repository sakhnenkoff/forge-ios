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

forge-app maintains `.forge/retrospective.md` — a structured log of pipeline issues, written as they happen. This file replaces the previously proposed `.forge/issues.md` from the v4 spec (which is now dropped).

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
- **Suggested fix:** What specific change would prevent this (e.g., "Add ScrollView mention to dashboard.md fragment")
- **Fix target:** Which file should change (e.g., `skills/forge-build/prompts/dashboard.md`)
- **Severity:** Minor (cosmetic) | Major (wrong output) | Critical (pipeline stuck)
- **Status:** open | applied
- **Build:** {app-name}
```

**Who writes entries:**
- forge-app writes automatically when retries or failures occur
- The user adds entries manually when they see something the pipeline missed
- Entries accumulate throughout the build — no processing until the app is done

### 2. Snapshot Before Build

After the app name is confirmed in Phase 1 (question 1), forge-app creates a git tag:

```bash
# Slugify app name: lowercase, hyphens, no spaces/special chars
APP_SLUG=$(echo "{app_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
TAG_NAME="forge-pre-${APP_SLUG}-$(date +%Y%m%dT%H%M%S)"

# Check for clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree has uncommitted changes. Committing pipeline state before tagging."
  git add -A && git commit -m "chore: snapshot pipeline state before ${APP_SLUG} build"
fi

git tag "$TAG_NAME"
echo "Pipeline snapshot: $TAG_NAME"
```

**What this gives you:**
- Rollback target if improvements break something: `git diff $TAG_NAME..HEAD` (covers ALL files, not just skills/)
- Comparison between pipeline versions
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
1. Triage: filter to Major/Critical entries first. Only review Minor entries after those are resolved.
2. Auto-drop Minor entries that were resolved by a subsequent retry within the same feature (the system self-corrected).
3. Group remaining entries by fix target.
4. For each group: make the fix, commit with message referencing the retrospective.
5. Mark entries as `applied` in the retrospective and note the commit hash.
6. Optionally run `/adversarial-review` on changed files to catch regressions.
7. Copy the retrospective to `docs/pipeline-history/{app-slug}-retrospective.md` in the template repo for cross-build reference.

**Commit message convention:**

```
fix(forge-judge): add spacing variety check to Craft criterion

Retrospective: Dashboard screen passed with uniform 16pt padding.
Judge Craft criterion didn't explicitly check for spacing variety.
```

### 4. Cross-Build Learning

Retrospectives are copied to `docs/pipeline-history/` in the template repo after each build's improvements are applied. This is the persistent cross-build record.

```
docs/pipeline-history/
├── myapp-retrospective.md        # From first app build
├── secondapp-retrospective.md    # From second app build
└── ...
```

When forge-app starts a new build, it checks `docs/pipeline-history/` for prior retrospectives. If any have entries with `Status: open`, it reminds: "There are N unapplied pipeline improvements from prior builds. Want to review them first?"

This avoids the `.forge/` cross-project problem — `.forge/` is per-app, `docs/pipeline-history/` is in the template repo.

### 5. No Test App (for now)

We're not maintaining a canary/test app. The snapshot tags provide rollback safety. If the pipeline matures and changes become riskier, a canary can be added later.

## Proactive Behavior

The pipeline should not rely on the user remembering to do things. forge-app is proactive:

### During the build
- **Auto-log:** Every retry, failure, or human feedback is logged to retrospective.md without asking. The user doesn't have to remember to capture issues.
- **Pattern detection (mechanical):** After each retrospective entry is written, forge-app runs a count on the file grouping by "Fix target" field. If any target appears 3+ times, emit a warning: "This is the Nth time {fix_target} caused an issue. Consider prioritizing this fix after the build."
  ```bash
  grep "Fix target:" .forge/retrospective.md | sort | uniq -c | sort -rn | head -5
  ```
  This is deterministic and works regardless of context window length.
- **Retry context:** When sending fix instructions back to Codex after a failure, forge-app includes what went wrong on previous screens so Codex doesn't repeat the same mistake.

### After the build
- **Retrospective summary:** forge-app's completion report includes a "Pipeline Health" section that groups retrospective entries by fix target and severity, ranked by frequency.
- **Improvement suggestions:** For each group, forge-app includes the "Suggested fix" from the entries: "Dashboard fragment should mention horizontal ScrollView for quick actions (hit 2 times)."
- **Prompt to act:** "You have N retrospective entries across M fix targets. Want me to apply improvements now, or save for later?"

### Between builds (new session)
- **Prior retro check:** forge-app checks `docs/pipeline-history/` for retrospectives with `Status: open` entries.
- **Snapshot diff:** forge-app shows what changed since the last snapshot tag: `git diff $(git tag -l 'forge-pre-*' | sort -V | tail -1)..HEAD --stat` — covers all fix targets (skills, AGENTS.md, DS code, presets).

## What Changes

### In forge-app SKILL.md
1. **Phase 1 (after app name confirmed):** Create snapshot tag with slugified name + timestamp. Check `docs/pipeline-history/` for open entries.
2. **Throughout Phases 3-4:** Auto-append to `.forge/retrospective.md` on every retry, failure, or human feedback. Run mechanical pattern detection (grep/count) after each entry.
3. **Phase 3 retries:** Include cross-screen learnings in Codex retry prompts.
4. **Phase 5 completion report:** Add "Pipeline Health" section with grouped entries, improvement suggestions, and prompt to apply.
5. **Post-build:** Copy retrospective to `docs/pipeline-history/{app-slug}-retrospective.md`.

### In v4 pipeline spec
- Replace `.forge/issues.md` with `.forge/retrospective.md` in gitignore and directory structure.
- `.forge/retrospective.md` is committed in app projects (not gitignored).

### Files

| File | Action |
|------|--------|
| `skills/forge-app/SKILL.md` | Add snapshot tagging, retrospective logging, mechanical pattern detection, proactive suggestions |
| `.forge/retrospective.md` | Created per-app during build (forge-app writes it automatically, committed in app projects) |
| `docs/pipeline-history/` | Directory in template repo for cross-build retrospective copies |
