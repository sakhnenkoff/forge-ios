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
| `skills/forge-app/references/spec-format.md` | Modify | Replace stale `issues.md` reference |
| `docs/pipeline-history/.gitkeep` | Create | Cross-build retrospective archive |
| `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md` | Modify | Replace `.forge/issues.md` with `.forge/retrospective.md` |

---

### Task 1: Add prior-retro check and snapshot tagging to Phase 1

**Files:**
- Modify: `skills/forge-app/SKILL.md`

- [ ] **Step 1: Insert prior-retro check BEFORE the human gate section**

In `skills/forge-app/SKILL.md`, find the line `### Human gate` (around line 119).

Insert BEFORE `### Human gate`:

```markdown
### Check prior retrospectives

Before proceeding, check if prior builds left unresolved pipeline issues:

```bash
ls docs/pipeline-history/*-retrospective.md 2>/dev/null
```

If files exist, grep for open entries (note: markdown bold format):
```bash
grep -l "Status:.*open" docs/pipeline-history/*-retrospective.md 2>/dev/null
```

If open entries found, remind the user:
"There are unapplied pipeline improvements from prior builds. Want to review them before starting this build?"

If the user wants to review, show the open entries grouped by fix target. If not, continue.

Show what changed since the last snapshot:
```bash
LAST_TAG=$(git tag -l 'forge-pre-*' | sort -V | tail -1)
if [ -n "$LAST_TAG" ]; then
  echo "Pipeline changes since last build ($LAST_TAG):"
  git diff "$LAST_TAG"..HEAD --stat
fi
```
```

- [ ] **Step 2: Insert snapshot creation AFTER the human gate body**

Find the line `Present the spec.json summary to the user. Wait for approval before proceeding to Phase 2.` (around line 121).

Insert AFTER that line:

```markdown
### Create pipeline snapshot

After the user approves the spec, create a snapshot tag before any build artifacts are generated:

```bash
APP_SLUG=$(echo "{app_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
TAG_NAME="forge-pre-${APP_SLUG}-$(date +%Y%m%dT%H%M%S)"

# Refuse to tag a dirty tree — ask user to commit or stash first
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree has uncommitted changes. Please commit or stash before proceeding."
  # Wait for user to resolve, then retry
fi

git tag "$TAG_NAME"
```

Log: "Pipeline snapshot created: {TAG_NAME}. You can rollback to this state if improvements break something."
```

- [ ] **Step 3: Verify**

```bash
grep -n "prior retrospective\|pipeline snapshot\|pipeline-history\|forge-pre-" skills/forge-app/SKILL.md
```

Expected: 5+ matches. Prior-retro check appears before `### Human gate`. Snapshot appears after the human gate body.

- [ ] **Step 4: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add prior-retro check and pipeline snapshot to forge-app Phase 1"
```

---

### Task 2: Add retrospective logging to Phase 3 build loop

**Files:**
- Modify: `skills/forge-app/SKILL.md`

- [ ] **Step 1: Insert retrospective logging section BEFORE "On feature completion or block"**

In `skills/forge-app/SKILL.md`, find the section `### On feature completion or block` (around line 267).

Insert BEFORE it:

```markdown
### Retrospective logging

After EVERY retry, failure, or human feedback event, auto-append to `.forge/retrospective.md`:

```markdown
## Screen: {feature_name}

### Stage: {Codex Build | Floor Checks | Hardened Build | Judge | Design | Human Feedback}
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

**Auto-drop rule:** If a Minor entry is logged for a feature, and the feature subsequently passes the same stage on retry, remove the Minor entry (the system self-corrected).

**Pattern detection (mechanical):** After each entry, run a count:
```bash
grep "Fix target:" .forge/retrospective.md | sort | uniq -c | sort -rn | head -5
```

If any fix target appears 3+ times, warn the user:
"This is the Nth time {fix_target} caused an issue. Consider prioritizing this fix after the build."

**Cross-screen retry context:** When sending fix instructions back to Codex after a failure, include relevant retrospective entries from prior screens that share the same fix target. This prevents Codex from repeating the same mistake across screens.
```

- [ ] **Step 2: Update "On feature completion or block" to include retro entry count**

In the existing `### On feature completion or block` section, add `Retro entries: N` to the progress.md log template:

```
## {feature_name}
Status: done|blocked
Codex invocations: N/8
Judge rounds: N/3
Retro entries: N
Notes: ...
```

- [ ] **Step 3: Verify**

```bash
grep -n "Retrospective logging\|pattern detection\|Cross-screen retry\|Auto-drop" skills/forge-app/SKILL.md
```

Expected: 4 matches in Phase 3.

- [ ] **Step 4: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add retrospective logging, pattern detection, and cross-screen retry context to Phase 3"
```

---

### Task 3: Add Pipeline Health report to Completion section

**Files:**
- Modify: `skills/forge-app/SKILL.md`

- [ ] **Step 1: Replace the Completion section**

Find `## Completion` (around line 385). Replace everything from there to end of file with:

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
{Group entries by fix target, count by severity, rank by frequency. Filter: show Major/Critical first, then Minor only if Major/Critical are resolved.}

| Fix Target | Issues | Major/Critical | Top Issue |
|-----------|--------|---------------|-----------|
| skills/forge-build/prompts/dashboard.md | 3 | 1 | Missing ScrollView guidance |
| skills/forge-judge/SKILL.md | 2 | 2 | Spacing variety not checked |

### Suggested Improvements
{For each group with 2+ entries, list the "Suggested fix" from the entries:}
1. **dashboard.md** (3 issues): Add horizontal ScrollView mention for quick actions
2. **forge-judge Craft criterion** (2 issues): Add explicit spacing variety check

{If no retrospective file or no entries:}
"No pipeline issues logged — clean build!"

## Next Steps
- [ ] forge-wire: connect backend
- [ ] forge-storefront: design listing
- [ ] forge-ship: submission prep
{If retro entries exist:}
- [ ] Review pipeline improvements: "You have {N} retrospective entries across {M} fix targets. Want me to apply improvements now, or save for later?"
```

### Post-build: Archive retrospective

If `.forge/retrospective.md` exists, archive it to the template repo:

```bash
if [ -f .forge/retrospective.md ]; then
  APP_SLUG=$(echo "{app_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  ARCHIVE_NAME="${APP_SLUG}-$(date +%Y%m%dT%H%M%S)-retrospective.md"
  mkdir -p docs/pipeline-history
  cp .forge/retrospective.md "docs/pipeline-history/${ARCHIVE_NAME}"
  git add "docs/pipeline-history/${ARCHIVE_NAME}"
  git commit -m "docs: archive retrospective from ${APP_SLUG} build"
fi
```

When applying improvements, mark entries individually — after EACH fix commit, update only the specific entry that was fixed. Do NOT use a global sed replace. Instead, identify the entry by its Screen + Stage header and update its Status line:

```
Find the entry for the specific screen/stage you just fixed.
Change its line from:
  - **Status:** open
To:
  - **Status:** applied (commit: {short_hash})
```

This must be done per-entry, not globally, so each fix maps to its own commit hash.
```

- [ ] **Step 2: Verify**

```bash
grep -n "Pipeline Health\|Retrospective Summary\|pipeline-history\|Suggested Improvements\|per-entry" skills/forge-app/SKILL.md
```

Expected: 5+ matches in Completion section.

- [ ] **Step 3: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: add Pipeline Health report and retro archiving to forge-app completion"
```

---

### Task 4: Create pipeline-history directory and update v4 spec + spec-format.md

**Files:**
- Create: `docs/pipeline-history/.gitkeep`
- Modify: `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md`
- Modify: `skills/forge-app/references/spec-format.md`

- [ ] **Step 1: Create the pipeline-history directory**

```bash
mkdir -p docs/pipeline-history
touch docs/pipeline-history/.gitkeep
```

- [ ] **Step 2: Update v4 spec — replace issues.md with retrospective.md**

In `docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md`, find the .forge/ directory structure section. Find the line:

```
├── issues.md               # Failures, fallbacks, unresolved problems
```

Replace with:

```
├── retrospective.md        # Pipeline issues log — auto-written by forge-app, committed in app projects
```

Also in the gitignore section, if `.forge/issues.md` appears as a gitignored path, remove that line. (retrospective.md is NOT gitignored — it should be committed in app projects.)

- [ ] **Step 3: Update spec-format.md — replace stale issues.md reference**

In `skills/forge-app/references/spec-format.md`, find any reference to `.forge/issues.md` and replace with `.forge/retrospective.md`.

- [ ] **Step 4: Verify**

```bash
grep -rn "issues.md" docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md skills/forge-app/references/spec-format.md
```

Expected: 0 matches.

```bash
ls docs/pipeline-history/.gitkeep
```

Expected: file exists.

- [ ] **Step 5: Commit**

```bash
git add docs/pipeline-history/.gitkeep docs/superpowers/specs/2026-04-12-forge-v4-pipeline-design.md skills/forge-app/references/spec-format.md
git commit -m "chore: create pipeline-history directory, replace issues.md with retrospective.md everywhere"
```

---

### Task 5: Verify cross-references

- [ ] **Step 1: Check forge-app references retrospective.md consistently**

```bash
grep -c "retrospective.md" skills/forge-app/SKILL.md
grep -c "issues.md" skills/forge-app/SKILL.md
```

Expected: retrospective.md = 3+, issues.md = 0.

- [ ] **Step 2: Check no stale issues.md references anywhere**

```bash
grep -rn "issues.md" skills/ docs/superpowers/specs/ docs/design-reference/
```

Expected: 0 matches.

- [ ] **Step 3: Check pipeline-history is referenced in forge-app**

```bash
grep -c "pipeline-history" skills/forge-app/SKILL.md
```

Expected: 2+ (prior-retro check + post-build archive).

- [ ] **Step 4: Check grep pattern uses correct markdown format**

```bash
grep -n 'Status:.*open\|Status: open' skills/forge-app/SKILL.md
```

Expected: all grep commands use `Status:.*open` pattern (not `Status: open` which won't match bold markdown).

- [ ] **Step 5: Commit any fixes**

```bash
git add skills/ docs/
git commit -m "fix: resolve cross-reference inconsistencies in retrospective system"
```

---

## Summary

| Task | Files | What it does |
|------|-------|-------------|
| 1 | `skills/forge-app/SKILL.md` | Prior-retro check + snapshot diff before gate, snapshot tag after gate |
| 2 | `skills/forge-app/SKILL.md` | Auto-logging + pattern detection + cross-screen retry context + auto-drop |
| 3 | `skills/forge-app/SKILL.md` | Pipeline Health report + per-entry status marking + retro archiving |
| 4 | `docs/pipeline-history/.gitkeep`, v4 spec, spec-format.md | Create archive dir, replace issues.md everywhere |
| 5 | — | Cross-reference verification including grep pattern check |

**Total: 5 tasks, 4 files changed.**
