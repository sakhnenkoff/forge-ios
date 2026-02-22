# forge-feature Pipeline Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a `forge-feature` orchestrator skill in the forge-marketplace that enforces a consistent pipeline for building features in Forge apps, with token cost optimization and zero required third-party dependencies.

**Architecture:** A new plugin in the forge-marketplace repo containing a SKILL.md orchestrator that chains forge-screens and swiftui-craft in a defined order, with optional detection of superpowers/GSD/Ralph Loop for enhanced steps. Two modes: quick (default, 4 steps) and full (7 steps).

**Tech Stack:** Claude Code plugin system, SKILL.md format, forge-marketplace Git repo

---

### Task 1: Create the forge-feature plugin scaffold in forge-marketplace

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/claude-code.json`
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/references/pipeline.md`
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/references/fallbacks.md`

**Step 1: Create claude-code.json manifest**

```json
{
  "name": "forge-feature",
  "version": "1.0.0",
  "description": "Consistent quality pipeline for building features in Forge apps — scaffold, build, polish, verify",
  "author": "Matvii Sakhnenko",
  "license": "MIT",
  "skills": [
    {
      "name": "forge-feature",
      "description": "Enforced quality pipeline for building features. Default: quick mode (scaffold, build, polish, verify). Full mode adds brainstorming, planning, and code review. Use when the user says 'build a feature', 'add [feature]', 'create [feature]', or '/forge:feature'. For quick changes: '/forge:quick' or 'just add [thing]'."
    }
  ]
}
```

**Step 2: Create the directory structure**

Run:
```bash
mkdir -p /Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/references
```

**Step 3: Write claude-code.json to disk**

Write the JSON from Step 1 to `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/claude-code.json`

**Step 4: Commit scaffold**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/claude-code.json
git commit -m "feat: add forge-feature plugin scaffold"
```

---

### Task 2: Write the main SKILL.md orchestrator

This is the core of the skill. It must:
- Define both modes (quick and full)
- Detect optional third-party skills and use fallbacks
- Include model hints for token optimization
- Include the AGENTS.md review checklist inline
- Chain forge-screens and swiftui-craft by name

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`

**Step 1: Write SKILL.md**

The SKILL.md must follow this structure (see detailed content below). Key sections:

```markdown
---
name: forge-feature
description: >
  Enforced quality pipeline for building features in Forge apps...
license: MIT
---

# Forge Feature Pipeline

## Mode Detection
- Parse user request to determine quick vs full mode
- `/forge:quick` or simple requests → quick mode
- `/forge:feature` or complex requests → full mode

## Prerequisites Check
- Verify *.xcodeproj exists
- Verify AGENTS.md exists
- Verify Packages/core-packages/DesignSystem/ exists

## Optional Enhancement Detection
- Check if superpowers skills are available (brainstorming, writing-plans, requesting-code-review)
- Check if GSD is available (/gsd:plan-phase)
- Check if Ralph Loop is available
- Log which enhancements are available, proceed with fallbacks for missing ones

## Quick Mode Pipeline (4 steps)
1. Scaffold — invoke forge-screens if new screen needed
2. Build — implement the feature following AGENTS.md
3. Polish — invoke swiftui-craft (always)
4. Verify — xcodebuild check

## Full Mode Pipeline (7 steps)
1. Brainstorm — superpowers:brainstorming OR inline questions
2. Plan — superpowers:writing-plans OR inline task list; GSD auto-escalation check
3. Scaffold — forge-screens
4. Build — implementation; Ralph Loop suggestion for iterative UI
5. Polish — swiftui-craft
6. Verify — xcodebuild
7. Review — superpowers:requesting-code-review OR inline AGENTS.md checklist

## GSD Auto-Escalation (in Plan step)
- Trigger: 5+ tasks OR 3+ feature areas OR multi-session scope
- Replace plan/build/verify with GSD equivalents
- Only if GSD is detected as available

## Token Optimization
- Model hints per step (opus for creative, sonnet for implementation, haiku for verification)
- Subagent isolation guidance for scaffold/polish/verify
- Track which files have been read to avoid redundant reads

## AGENTS.md Review Checklist (inline fallback for Review step)
- [ ] DS components used (no raw SwiftUI views)
- [ ] Analytics events tracked in ViewModel
- [ ] MVVM pattern followed (no logic in View body)
- [ ] Concurrency rules respected (strict concurrency, @MainActor)
- [ ] No @State for data (only for UI animations)
- [ ] All actions are closures in components
- [ ] Navigation wired via AppRoute/AppSheet/AppTab
```

Write the complete SKILL.md with all sections fully fleshed out — not abbreviated. Each step must have clear instructions for what to do, what skill to invoke, and what the fallback is.

**Step 2: Commit SKILL.md**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md
git commit -m "feat: add forge-feature orchestrator skill"
```

---

### Task 3: Write pipeline.md reference

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/references/pipeline.md`

**Step 1: Write pipeline.md**

This reference file contains:
- Detailed step definitions for both modes
- Model selection table with rationale
- GSD escalation rules and thresholds
- Context management guidance (what files each step needs)
- Estimated token costs per feature size
- Error recovery: what to do when a step fails (loop-back rules)

```markdown
# Pipeline Reference

## Step Definitions

### Quick Mode Steps
| Step | Action | Skill | Model Hint | Fallback |
|------|--------|-------|------------|----------|
| 1. Scaffold | Generate View + ViewModel | forge-screens | sonnet | Manual file creation |
| 2. Build | Implement feature logic | (inline) | sonnet/opus | — |
| 3. Polish | Premium design pass | swiftui-craft | opus | — |
| 4. Verify | Build compilation check | (inline) | haiku | — |

### Full Mode Steps
| Step | Action | Skill | Model Hint | Fallback |
|------|--------|-------|------------|----------|
| 1. Brainstorm | Clarify scope, propose approaches | superpowers:brainstorming | opus | Inline: 2-3 AskUserQuestion calls |
| 2. Plan | Task breakdown, file list | superpowers:writing-plans | opus | Inline: numbered TodoWrite list |
| 3. Scaffold | Generate View + ViewModel | forge-screens | sonnet | Manual file creation |
| 4. Build | Implement feature logic | (inline) | sonnet/opus | — |
| 5. Polish | Premium design pass | swiftui-craft | opus | — |
| 6. Verify | Build compilation check | (inline) | haiku | — |
| 7. Review | Quality gate | superpowers:requesting-code-review | sonnet | Inline: AGENTS.md checklist |

## GSD Escalation Rules
...

## Error Recovery
...

## Token Cost Estimates
...
```

**Step 2: Commit pipeline.md**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/skills/forge-feature/references/pipeline.md
git commit -m "docs: add pipeline reference for forge-feature"
```

---

### Task 4: Write fallbacks.md reference

**Files:**
- Create: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/references/fallbacks.md`

**Step 1: Write fallbacks.md**

This reference file contains the inline fallback implementations for when third-party skills are not installed. Each fallback must produce equivalent output to the skill it replaces.

```markdown
# Inline Fallbacks

## Brainstorm Fallback (when superpowers:brainstorming is not available)
1. Ask: "What does this feature do?" (open-ended)
2. Ask: "Which screens/views does it affect?" (multiple choice if possible)
3. Ask: "Any specific requirements or constraints?" (open-ended)
4. Summarize scope, confirm with user before proceeding

## Plan Fallback (when superpowers:writing-plans is not available)
1. List files to create/modify
2. Break into numbered steps (max 8)
3. Create TodoWrite tasks for each step
4. Check GSD escalation triggers (5+ tasks, 3+ areas, multi-session)

## Review Fallback (when superpowers:requesting-code-review is not available)
Run this checklist against all new/modified files:
- [ ] DS components used (no raw SwiftUI — check for Text/Button/VStack without DS prefix)
- [ ] Analytics: ViewModel has Event enum conforming to LoggableEvent
- [ ] MVVM: No business logic in View body (only @State for UI animation)
- [ ] Concurrency: No @unchecked Sendable, no nonisolated(unsafe) without SAFETY comment
- [ ] Components: All data injected via init, actions are closures
- [ ] Navigation: New routes added to AppRoute/AppSheet/AppTab as needed
- [ ] Build: xcodebuild succeeds with zero warnings from app code

If any check fails, list the violations and fix them before completing.
```

**Step 2: Commit fallbacks.md**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/skills/forge-feature/references/fallbacks.md
git commit -m "docs: add inline fallbacks for forge-feature"
```

---

### Task 5: Register forge-feature in marketplace.json

**Files:**
- Modify: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/marketplace.json`

**Step 1: Add forge-feature to the plugins array**

Add this entry to the `plugins` array in marketplace.json:

```json
{
  "name": "forge-feature",
  "version": "1.0.0",
  "source": "./.claude-plugin/plugins/forge-feature",
  "description": "Consistent quality pipeline for building features — scaffold, build, polish, verify with optional brainstorming, planning, and code review",
  "author": {
    "name": "Matvii Sakhnenko"
  }
}
```

**Step 2: Verify marketplace.json is valid JSON**

Run:
```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"
```
Expected: no output (valid JSON)

**Step 3: Commit marketplace.json update**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/marketplace.json
git commit -m "feat: register forge-feature in marketplace"
```

---

### Task 6: Push forge-marketplace changes and install the plugin

**Step 1: Push all commits to the forge-marketplace remote**

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
git push origin main
```

**Step 2: Update the marketplace locally**

```bash
claude plugin marketplace update forge-marketplace
```

**Step 3: Install the new plugin**

```bash
claude plugin install forge-feature@forge-marketplace
```

**Step 4: Verify installation**

```bash
claude plugin list
```
Expected: `forge-feature@forge-marketplace` appears in the list

---

### Task 7: Update AGENTS.md in Forge template

**Files:**
- Modify: `/Users/matvii/Documents/Developer/Templates/forge/AGENTS.md`

**Step 1: Update "How to Build Features" section**

Replace the current "How to Build Features" section (lines 41-57) with:

```markdown
### How to Build Features

Use the `forge-feature` pipeline for consistent, high-quality output:

- **Most features:** `/forge:quick` — scaffold, build, polish, verify (default)
- **Major features:** `/forge:feature` — full pipeline with brainstorming, planning, and review
- **Multi-session work:** Automatically escalates to GSD when complexity warrants it

Install:
```bash
claude plugin install forge-feature@forge-marketplace
```

Or build features manually:

1. **Scaffold**: `forge-screens` generates View + ViewModel with correct architecture
2. **Polish**: `swiftui-craft` makes UI feel premium
3. **Or manually**: Create `{App}/Features/{Feature}/{Feature}View.swift` and `{Feature}ViewModel.swift` following the Quick Start Guide below.
```

**Step 2: Update "Available Skills" table**

Add `forge-feature` to the skills table:

```markdown
| `forge-feature` | Quality pipeline — scaffold, build, polish, verify | `/forge:feature` or `/forge:quick` |
```

**Step 3: Update "Setting Up a New Project" section (line 365-379)**

Add `forge-feature` to the list of available skills.

**Step 4: Commit AGENTS.md changes**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git add AGENTS.md
git commit -m "docs: add forge-feature pipeline to AGENTS.md workflow"
```

---

### Task 8: Update README.md in Forge template

**Files:**
- Modify: `/Users/matvii/Documents/Developer/Templates/forge/README.md`

**Step 1: Update the Claude Code Skills section**

Change "Three AI-powered skills" to "Four AI-powered skills". Add `forge-feature` to the table:

```markdown
| `forge-feature` | `claude plugin install forge-feature@forge-marketplace` | Quality pipeline — scaffold, build, polish, verify |
```

Update the workflow line:
```markdown
**Workflow**: `forge-workspace` (setup) → `forge-feature` (build features with quality pipeline) → or use `forge-screens` + `swiftui-craft` individually
```

**Step 2: Add "Optional Enhancements" subsection**

After the skills table, add:

```markdown
### Optional Enhancements

These free plugins improve the pipeline but are NOT required:

| Plugin | Install | What it adds |
|--------|---------|-------------|
| Superpowers | `claude plugin install superpowers@claude-plugins-official` | Structured brainstorming, planning, and code review |
| Ralph Loop | `claude plugin install ralph-loop@claude-plugins-official` | Continuous build-test-fix iteration |
```

**Step 3: Commit README.md changes**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git add README.md
git commit -m "docs: add forge-feature and optional enhancements to README"
```

---

### Task 9: Create symlink in .agents/skills and push Forge template

**Step 1: Create symlink for forge-feature in .agents/skills**

After the plugin is installed and cached, create the symlink:

```bash
ln -s /Users/matvii/.claude/plugins/cache/forge-marketplace/forge-feature/1.0.0/skills/forge-feature /Users/matvii/.agents/skills/forge-feature
```

**Step 2: Push all Forge template changes**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge
git push origin main
```

**Step 3: Verify the full flow works**

1. Start a new Claude Code session in the Forge directory
2. Type `/forge:feature` — should load the skill
3. Type `/forge:quick` — should load in quick mode
4. Verify forge-screens and swiftui-craft are invoked in the correct order

---

### Task 10: License audit and monetization verification

**Step 1: Verify forge-feature has MIT license header**

Check that SKILL.md starts with `license: MIT` in its frontmatter.

**Step 2: Verify no third-party code is bundled**

Grep all forge-feature files for any copied code from superpowers, GSD, or Ralph Loop. There should be none — only skill name references for detection/invocation.

```bash
cd /Users/matvii/.claude/plugins/marketplaces/forge-marketplace
grep -r "superpowers\|gsd\|ralph" .claude-plugin/plugins/forge-feature/ | grep -v "invoke\|detect\|check\|available\|installed"
```
Expected: no results (only invocation references, no copied code)

**Step 3: Verify pipeline works without third-party plugins**

Test by temporarily noting which third-party skills exist, then verifying the fallback paths are complete and functional in SKILL.md and fallbacks.md.

**Step 4: Document the dependency classification**

Ensure the README "Optional Enhancements" section clearly states these are optional and free. No buyer should think they need to pay for anything beyond the Forge template itself.
