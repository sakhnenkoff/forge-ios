# Pipeline Review System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add retrospective logging, snapshot tagging, and proactive improvement suggestions to forge-app so the pipeline learns from its mistakes across builds.

**Architecture:** Three additions to forge-app SKILL.md (snapshot at start, logging during build, summary at end) + pipeline-history directory + v4 spec gitignore update. No Swift code changes.

**Tech Stack:** Markdown (skill files)

**Spec:** `docs/superpowers/specs/2026-04-13-pipeline-review-system-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `skills/forge-app/SKILL.md` | Modify | Add snapshot, retrospective logging, pattern detection, Pipeline Health report |
| `docs/pipeline-history/.gitkeep` | Create | Cross-build retrospective archive |
| `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md` | Modify | Replace `.forge/issues.md` with `.forge/retrospective.md` |

---

### Task 1: Add snapshot tagging and prior-retro check to Phase 1

**Files:**
- Modify: `skills/forge-app/SKILL.md:119-121` (after "Human gate" section, before Phase 2)

- [ ] **Step 1: Insert snapshot and retro check after the human gate in Phase 1**

In `skills/forge-app/SKILL.md`, find the line `Present the spec.json summary to the user. Wait for approval before proceeding to Phase 2.` (line 121).

Insert BEFORE that line (after "Write `.forge/references/index.md`..." block, before the human gate):

```markdown
### Check prior retrospectives

Before proceeding, check if prior builds left unresolved pipeline issues:

```bash
ls docs/pipeline-history/*-retrospective.md 2>/dev/null
```

If files exist, grep for open entries:
```bash
grep -l "Status: open" docs/pipeline-history/*-retrospective.md 2>/dev/null
```

If open entries found, remind the user:
"There are unapplied pipeline improvements from prior builds. Want to review them before starting this build?"

If the user wants to review, show the open entries grouped by fix target. If not, continue.

### Create pipeline snapshot

After the user confirms the spec.json (human gate), create a snapshot tag:

```bash
APP_SLUG=$(echo "{app_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
TAG_NAME="forge-pre-${APP_SLUG}-$(date +%Y%m%dT%H%M%S)"

# Ensure clean working tree for accurate snapshot
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A && git commit -m "chore: snapshot pipeline state before ${APP_SLUG} build"
fi

git tag "$TAG_NAME"
```

Log: "Pipeline snapshot created: {TAG_NAME}. You can rollback to this state if improvements break something."
```

- [ ] **Step 2: Verify the insertion**

```bash
grep -n "pipeline snapshot\|prior retrospective\|pipeline-history" skills/forge-app/SKILL.md
```

Expected: 3+ matches in the Phase 1 section.

- [ ] **Step 3: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add pipeline snapshot tagging and prior-retro check to forge-app Phase 1"
```

---

### Task 2: Add retrospective logging to Phase 3 build loop

**Files:**
- Modify: `skills/forge-app/SKILL.md:267-277` (the "On feature completion or block" section)

- [ ] **Step 1: Add retrospective auto-logging after floor checks, judge, and human gate**

In `skills/forge-app/SKILL.md`, find the section `### On feature completion or block` (around line 267).

Replace the entire section (lines 267-277) with:

```markdown
### Retrospective logging

After EVERY retry, failure, or human feedback event, auto-append to `.forge/retrospective.md`:

```markdown
## Screen: {feature_name}

### Stage: {which stage failed — Codex Build | Floor Checks | Hardened Build | Build | Judge | Human Feedback}
- **Issue:** {one sentence — what went wrong}
- **Root cause:** {best guess — why it went wrong}
- **Suggested fix:** {specific change to prevent this — e.g., "Add ScrollView mention to dashboard.md fragment"}
- **Fix target:** {file path — e.g., `skills/forge-build/prompts/dashboard.md`}
- **Severity:** {Minor | Major | Critical}
- **Status:** open
- **Build:** {app_name}
```

Create the file on first entry:
```bash
if [ ! -f .forge/retrospective.md ]; then
  echo "# Pipeline Retrospective — {app_name}" > .forge/retrospective.md
  echo "" >> .forge/retrospective.md
fi
```

**Pattern detection (mechanical):** After each entry, run a count:
```bash
grep "Fix target:" .forge/retrospective.md | sort | uniq -c | sort -rn | head -5
```

If any fix target appears 3+ times, warn the user:
"⚠ {fix_target} has caused {N} issues so far. Consider prioritizing this fix after the build."

### On feature completion or block

Update `.forge/spec.json` — set feature status to `done` or `blocked`.
Log to `.forge/progress.md`:
```
## {feature_name}
Status: done|blocked
Codex invocations: N/8
Judge rounds: N/3
Retro entries: N
Notes: ...
```
```

- [ ] **Step 2: Verify the insertion**

```bash
grep -n "retrospective\|pattern detection\|Fix target" skills/forge-app/SKILL.md | head -10
```

Expected: Multiple matches in the Phase 3 section.

- [ ] **Step 3: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add retrospective auto-logging and pattern detection to forge-app Phase 3"
```

---

### Task 3: Add Pipeline Health report to Completion section

**Files:**
- Modify: `skills/forge-app/SKILL.md:385-404` (the Completion section)

- [ ] **Step 1: Replace the Completion section with an expanded version**

In `skills/forge-app/SKILL.md`, find the `## Completion` section (around line 385).

Replace everything from `## Completion` to the end of the file with:

```markdown
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

## Pipeline Health

{If .forge/retrospective.md exists and has entries:}

### Retrospective Summary
{Group entries by fix target, count by severity, rank by frequency}

| Fix Target | Issues | Major/Critical | Top Issue |
|-----------|--------|---------------|-----------|
| skills/forge-build/prompts/dashboard.md | 3 | 1 | Missing ScrollView guidance |
| skills/forge-judge/SKILL.md | 2 | 2 | Spacing variety not checked |

### Suggested Improvements
{For each group with 2+ entries, list the suggested fix from the entries:}
1. **dashboard.md** (3 issues): Add horizontal ScrollView mention for quick actions
2. **forge-judge Craft criterion** (2 issues): Add explicit spacing variety check

{If no retrospective entries:}
"No pipeline issues logged — clean build!"

## Next Steps
- [ ] forge-wire: connect backend
- [ ] forge-storefront: design listing
- [ ] forge-ship: submission prep
{If retro entries exist:}
- [ ] Review pipeline improvements: "You have {N} retrospective entries across {M} fix targets. Want me to apply improvements now, or save for later?"
```

### Post-build: Archive retrospective

If the user applies improvements or defers them, copy the retrospective to the template repo for cross-build reference:

```bash
APP_SLUG=$(echo "{app_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
mkdir -p docs/pipeline-history
cp .forge/retrospective.md "docs/pipeline-history/${APP_SLUG}-retrospective.md"
git add "docs/pipeline-history/${APP_SLUG}-retrospective.md"
git commit -m "docs: archive retrospective from ${APP_SLUG} build"
```

When applying improvements, mark entries as `applied` and note the commit:
```bash
# After each fix commit, update the entry's Status field
sed -i '' "s/- \*\*Status:\*\* open/- **Status:** applied (commit: $(git rev-parse --short HEAD))/" .forge/retrospective.md
```
```

- [ ] **Step 2: Verify the update**

```bash
grep -n "Pipeline Health\|Retrospective Summary\|pipeline-history\|Suggested Improvements" skills/forge-app/SKILL.md
```

Expected: 4+ matches in the Completion section.

- [ ] **Step 3: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add Pipeline Health report and retro archiving to forge-app completion"
```

---

### Task 4: Create pipeline-history directory and update v4 spec

**Files:**
- Create: `docs/pipeline-history/.gitkeep`
- Modify: `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md`

- [ ] **Step 1: Create the pipeline-history directory**

```bash
mkdir -p docs/pipeline-history
touch docs/pipeline-history/.gitkeep
```

- [ ] **Step 2: Update v4 spec — replace issues.md with retrospective.md**

In `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md`, find the .forge/ directory structure section (around line 407). Find the line:

```
├── issues.md               # Failures, fallbacks, unresolved problems
```

Replace with:

```
├── retrospective.md        # Pipeline issues log — auto-written by forge-app, committed in app projects
```

Also find the gitignore note (around line 411) that mentions `.forge/issues.md` and replace:

```
.forge/issues.md
```

With nothing (remove the line — retrospective.md is NOT gitignored, it should be committed).

- [ ] **Step 3: Verify**

```bash
grep -n "issues.md\|retrospective.md" docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md
```

Expected: `retrospective.md` present, `issues.md` absent.

```bash
ls docs/pipeline-history/.gitkeep
```

Expected: file exists.

- [ ] **Step 4: Commit**

```bash
git add docs/pipeline-history/.gitkeep docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md
git commit -m "chore: create pipeline-history directory, replace issues.md with retrospective.md in v4 spec"
```

---

### Task 5: Verify cross-references

- [ ] **Step 1: Check forge-app references retrospective.md consistently**

```bash
grep -c "retrospective.md" skills/forge-app/SKILL.md
grep -c "issues.md" skills/forge-app/SKILL.md
```

Expected: retrospective.md = 3+, issues.md = 0.

- [ ] **Step 2: Check no stale issues.md references anywhere in skills**

```bash
grep -rn "issues.md" skills/
```

Expected: 0 matches.

- [ ] **Step 3: Check pipeline-history is referenced in forge-app**

```bash
grep -c "pipeline-history" skills/forge-app/SKILL.md
```

Expected: 2+ (prior-retro check + post-build archive).

- [ ] **Step 4: Commit any fixes**

```bash
git add skills/
git commit -m "fix: resolve any cross-reference inconsistencies in retrospective system"
```

---

## Summary

| Task | Files | What it does |
|------|-------|-------------|
| 1 | `skills/forge-app/SKILL.md` | Snapshot tag + prior-retro check in Phase 1 |
| 2 | `skills/forge-app/SKILL.md` | Auto-logging + pattern detection in Phase 3 |
| 3 | `skills/forge-app/SKILL.md` | Pipeline Health report + retro archiving in Completion |
| 4 | `docs/pipeline-history/.gitkeep`, v4 spec | Create archive dir, replace issues.md |
| 5 | — | Cross-reference verification |

**Total: 5 tasks, 3 files changed.**
