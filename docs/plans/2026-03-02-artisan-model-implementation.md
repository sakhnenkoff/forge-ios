# Artisan Model Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the broken build→polish pipeline with a single Craft Agent that sees its work, fix App Store browsing with Playwright code, and add human checkpoints.

**Architecture:** Merge forge-builder + forge-polisher into one `forge-craft-agent`. Fix research browsing with element-specific Playwright screenshots. Simplify forge-app orchestrator to dispatch Craft Agents with human checkpoints.

**Tech Stack:** Claude Code agent system (Agent tool, subagent dispatch), Playwright MCP, XcodeBuildMCP CLI

---

### Task 1: Create forge-craft-agent (merged build + polish)

**Files:**
- Create: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md`

**What to build:** A single agent that builds screens AND visually verifies them. This replaces both `forge-builder.md` and `forge-polisher.md`.

**Structure (from existing forge-builder, incorporating polisher's visual loop):**

```markdown
---
name: forge-craft-agent
description: >
  Build and visually craft feature screens for Forge iOS apps. Writes code,
  builds, screenshots, evaluates, and iterates until the screen serves the
  app's mood. Replaces the separate build + polish agents.
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch
permissionMode: bypassPermissions
skills:
  - forge-craft:forge-craft-polish
  - swiftui-expert-skill
memory: user
---
```

**Key sections to write:**

1. **Setup** — discover project details (same as forge-builder)
2. **Step 1: Read context** — from forge-builder Step 1 (AGENTS.md, .forge/ files, 1 reference image)
3. **Step 2: Establish mood** — from forge-builder Step 2
4. **Step 3: Scaffold** — from forge-builder Step 3 (View + ViewModel)
5. **Step 3b: Feature manager** — from forge-builder Step 3b (if domain data)
6. **Step 4: Build** — from forge-builder Step 4 (implement screen logic, DS components, loading patterns)
7. **Step 5: First visual check** — build, launch, screenshot, READ screenshot (from forge-builder Step 5)
8. **Step 6: Craft** — apply forge-craft-polish dimensions WHILE SEEING (merged from polisher Steps 3-7)
   - Take baseline screenshot
   - Audit against mood using craft dimensions
   - Research 2-3 references if needed
   - Apply changes
   - Re-screenshot and evaluate
   - Key difference from old polisher: this agent WROTE the code, so it understands what it's changing
9. **Step 7: Visual iteration** — max 3 rounds of see→evaluate→fix (from polisher Step 8)
   - Each round: rebuild, screenshot, READ, evaluate
   - Evaluation criteria: mood match, visual depth, hierarchy, anti-patterns
   - On each iteration: identify ONE issue, fix it, verify
10. **Step 8: Verify build** — final xcodebuild confirmation
11. **Step 9: Return proof** — screenshot path + 2-sentence evaluation (NEW)
    - REQUIRED: agent must return the final screenshot path and a brief description
    - This is the structural gate — not a 12-item checklist, just "show me what you built"

**Key rules (bottom of file):**
- NEVER skip visual check (Step 5) or craft (Step 6). Seeing is the whole point.
- NEVER return without a screenshot and evaluation. The orchestrator will reject results without visual proof.
- Max 3 craft iterations. Diminishing returns are real.
- All forge-eye protocols are INLINE (not referenced as separate steps) — build, stop, launch, sleep 3, screenshot, read.
- Remove the HARD-GATE verification block from old forge-builder (craft completion was an honor system checklist — replaced by "did you screenshot and evaluate?")
- Remove the 12-item REQUIRED OUTPUT FORMAT. Replace with: screenshot path + evaluation + files created/modified.

**Step 1: Write the agent file**

Take forge-builder.md as the base. Incorporate forge-polisher's Steps 3-8 (research, audit, apply craft, iterate) into the flow AFTER the build step. Remove references to forge-polisher being a separate agent. Remove the REQUIRED OUTPUT FORMAT block. Add the return proof step.

Read both `forge-builder.md` and `forge-polisher.md` first. The new agent should be ~200 lines (builder is 267, polisher is 194 — merged with deduplication should shrink).

**Step 2: Verify the file is well-structured**

Read the new file back. Check:
- Does it have a clear linear flow? (no "go to separate agent" references)
- Does it include visual verification BEFORE returning?
- Is the output format simple (screenshot + evaluation + files)?
- Is it under 250 lines?

**Step 3: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md
git commit -m "feat: create forge-craft-agent (merged build + polish)"
```

---

### Task 2: Delete forge-polisher

**Files:**
- Delete: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/agents/forge-polisher.md`

**Step 1: Delete the file**

```bash
rm ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/agents/forge-polisher.md
```

**Step 2: Update forge-craft/claude-code.json**

Remove the forge-polisher agent entry. The manifest should no longer reference it.

Read `forge-craft/claude-code.json`. It currently lists skills (forge-craft, forge-craft-polish, forge-eye). Agents are NOT listed in claude-code.json (they're auto-discovered from the agents/ directory), so this step may not need a manifest change. Verify.

**Step 3: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add -A
git commit -m "refactor: delete forge-polisher (merged into forge-craft-agent)"
```

---

### Task 3: Rename/remove forge-builder

**Files:**
- Delete: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md`

**Step 1: Delete the old builder**

```bash
rm ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-builder.md
```

**Step 2: Update forge-feature/claude-code.json if needed**

Check if agents are listed in the manifest. If forge-builder is referenced, update to forge-craft-agent.

**Step 3: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add -A
git commit -m "refactor: delete forge-builder (replaced by forge-craft-agent)"
```

---

### Task 4: Fix App Store browsing with Playwright code snippets

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md`

**What to change:** Replace the HARD-GATE instructions about "click into each screenshot" with an actual Playwright code snippet the agent runs via `browser_run_code`.

**Step 1: Read the current browsing protocol**

Read forge-craft SKILL.md lines 100-300 (the research/browsing section).

**Step 2: Write the Playwright helper snippet**

Add this code block to the browsing protocol section, replacing the manual clicking instructions:

```markdown
**App Store screenshot capture — use this code snippet:**

Instead of manually clicking through the gallery, run this via `browser_run_code`:

\`\`\`javascript
async (page) => {
  // Wait for screenshot gallery to load
  await page.waitForSelector('#product_media_phone_', { timeout: 10000 });

  // Screenshot the gallery element (NOT the full page)
  const gallery = page.locator('#product_media_phone_').getByTestId('shelf-item-list');
  await gallery.screenshot({ path: '.forge/design-references/temp-gallery-1.png', scale: 'css' });

  // Scroll gallery right to reveal more screenshots
  const nextBtn = page.locator('#product_media_phone_').getByRole('button', { name: 'Next Page' });
  if (await nextBtn.isEnabled()) {
    await nextBtn.click();
    await page.waitForTimeout(800);
    await gallery.screenshot({ path: '.forge/design-references/temp-gallery-2.png', scale: 'css' });
  }

  return 'Gallery screenshots captured';
}
\`\`\`

This captures App Store screenshots at readable resolution by targeting the gallery element directly. Each gallery screenshot shows 3 screens side-by-side at a size where you can read body text and see spacing.

**After capturing, READ both images.** Extract design decisions from what you see. If text is not readable, the capture failed — retry with a different app.
```

**Step 3: Remove/simplify the HARD-GATE about clicking**

The HARD-GATE at lines ~172-178 says "NEVER screenshot an entire page at a distance." Keep this gate but update it:
- Remove the instructions about clicking into lightboxes (replaced by the code snippet)
- Keep the quality check: "Can I read body text?"
- Add: "Use the Playwright code snippet above for App Store pages. For other sites, screenshot individual device mockups."

**Step 4: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md
git commit -m "fix: replace App Store clicking instructions with Playwright code snippet"
```

---

### Task 5: Update forge-app orchestrator

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**What to change:** The orchestrator currently dispatches forge-builder then forge-polisher as separate agents. Change to dispatch forge-craft-agent as one agent. Add human checkpoints.

**Step 1: Read the orchestrator's Step 6 section**

Read forge-app SKILL.md lines 620-850 (Screen-by-Screen Execution section).

**Step 2: Replace the Build Agent + Polish Agent dispatch**

Replace the two-agent dispatch (lines ~710-860) with a single Craft Agent dispatch:

```markdown
**Craft Agent** — builds, visually verifies, and polishes in one pass.

\`\`\`
Task(subagent_type: "forge-feature:forge-craft-agent", description: "Craft {screen_name} screen"):
  "Working directory: {working_dir}

   Build and visually craft the {screen_name} screen for {AppName}.

   Screen: {screen_name}
   Description: {description from blueprint}
   Navigation: {Tab/Push/Sheet}

   You have forge-craft-polish and swiftui-expert-skill loaded.
   Read AGENTS.md, .forge/ context, and 1 reference image.
   Build the screen, then visually verify it in the simulator.
   Iterate until it serves the mood.

   Return: screenshot path + 2-sentence evaluation + files created/modified."
\`\`\`
```

**Step 3: Replace the orchestrator verification section**

Replace the 10-point verification checklist (lines ~798-813) with a simpler check:

```markdown
**Orchestrator verification after Craft Agent completes:**

1. Did the agent return a screenshot path? If missing → reject, re-dispatch.
2. Read the screenshot. Does it look like a real app or a generic template?
   - If template-grade: re-dispatch with feedback "This looks generic. {specific issue}."
   - If it serves the mood: approve, move to next screen.
3. Human checkpoint (see below).
```

**Step 4: Add human checkpoints**

After the orchestrator verification, add:

```markdown
**Human checkpoint:**

For the first 2 screens: show the user the screenshot and ask for approval.
> "Here's the {screen_name} screen: [screenshot]. Does this match what you're going for, or should I adjust?"

After the first 2 screens are approved: batch-approve groups of 2-3 screens.
> "Built 3 more screens. Here are the screenshots: [screenshots]. Any feedback?"

If the user gives feedback: re-dispatch Craft Agent with the feedback.
> "The user says: '{feedback}'. Revise the {screen_name} screen."
```

**Step 5: Remove the Polish Agent dispatch block entirely**

Delete the entire "Polish Agent" section that dispatches forge-polisher.

**Step 6: Simplify the REQUIRED OUTPUT FORMAT**

The Build Agent's output format has 9 items. Replace with:

```
REQUIRED OUTPUT — the orchestrator reads this:
1. SCREENSHOT: [path to final screenshot]
2. EVALUATION: [2-sentence visual assessment — does it serve the mood?]
3. FILES CREATED: [list]
4. FILES MODIFIED: [list]
5. BUILD: [Succeeded/Failed]
```

**Step 7: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat: orchestrator dispatches Craft Agent with human checkpoints"
```

---

### Task 6: Update forge-feature pipeline

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`

**What to change:** The pipeline currently has separate Build and Polish steps. Merge them.

**Step 1: Read forge-feature SKILL.md**

Read the Quick Mode section (lines 134-304) and Full Mode section (lines 307-495).

**Step 2: Merge Quick Mode Steps 2 and 3**

Current:
- Step 2 — Build (write code)
- Step 3 — Polish & Visual Iteration (invoke forge-craft separately)

New:
- Step 2 — Build & Craft (write code, visually verify, polish — all in one)

Update the step to reference forge-craft-agent instead of forge-builder + forge-polisher.

Remove the HARD-GATE about "you MUST invoke forge-craft" — the craft is now built into the build step, not a separate invocation.

**Step 3: Merge Full Mode Steps 4 and 5**

Same merge as Quick Mode but in the full pipeline.

**Step 4: Update skill boundaries table**

Change "Design polish | Invoking polish on all new/modified views" to "Design craft | Built into the Craft Agent — no separate invocation needed"

**Step 5: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md
git commit -m "refactor: merge build + polish steps in forge-feature pipeline"
```

---

### Task 7: Sync caches and verify

**Files:**
- Sync: marketplace → cache for forge-feature and forge-craft plugins

**Step 1: Read plugin versions**

```bash
cat ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/claude-code.json
cat ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/claude-code.json
```

**Step 2: Sync forge-feature plugin**

```bash
MARKETPLACE=~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins
CACHE=~/.claude/plugins/cache/forge-marketplace

# Get version from claude-code.json
VERSION=$(cat $MARKETPLACE/forge-feature/claude-code.json | python3 -c "import sys,json;print(json.load(sys.stdin)['version'])")

# Sync agents
cp $MARKETPLACE/forge-feature/agents/forge-craft-agent.md $CACHE/forge-feature/$VERSION/agents/
rm -f $CACHE/forge-feature/$VERSION/agents/forge-builder.md

# Sync skills
cp $MARKETPLACE/forge-feature/skills/forge-feature/SKILL.md $CACHE/forge-feature/$VERSION/skills/forge-feature/
cp $MARKETPLACE/forge-feature/claude-code.json $CACHE/forge-feature/$VERSION/
```

**Step 3: Sync forge-craft plugin**

```bash
VERSION=$(cat $MARKETPLACE/forge-craft/claude-code.json | python3 -c "import sys,json;print(json.load(sys.stdin)['version'])")

# Remove polisher agent from cache
rm -f $CACHE/forge-craft/$VERSION/agents/forge-polisher.md

# Sync updated skill
cp $MARKETPLACE/forge-craft/skills/forge-craft/SKILL.md $CACHE/forge-craft/$VERSION/skills/forge-craft/
cp $MARKETPLACE/forge-craft/claude-code.json $CACHE/forge-craft/$VERSION/
```

**Step 4: Verify cache state**

```bash
# Verify forge-craft-agent exists in cache
ls $CACHE/forge-feature/*/agents/
# Should show: forge-craft-agent.md, forge-verifier.md
# Should NOT show: forge-builder.md

# Verify forge-polisher is gone from cache
ls $CACHE/forge-craft/*/agents/
# Should NOT show: forge-polisher.md
```

**Step 5: Commit caches are clean (no git needed for cache — it's local)**

Report: cache synced, verified.

---

### Task 8: Update MEMORY.md

**Files:**
- Modify: `~/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md`

**Step 1: Update the pipeline section**

Add entry about the Artisan Model:

```markdown
## Artisan Model (2026-03-02)

Major pipeline redesign. Merged forge-builder + forge-polisher into single `forge-craft-agent`. Key changes:
- **One agent builds and sees** — no more blind build → separate polish handoff
- **Visual proof required** — agent must return screenshot + 2-sentence evaluation, orchestrator rejects without it
- **Human checkpoints** — first 2 screens individually approved, then batch
- **App Store browsing fixed** — Playwright code snippet captures gallery element at readable resolution
- **Simplified output** — 5 items (screenshot, evaluation, files, build) replaces 9-item compliance checklist
- **forge-polisher deleted** — merged into forge-craft-agent
- **forge-builder deleted** — replaced by forge-craft-agent
- Rules replaced by: code (Playwright), structure (screenshot gate), human eyes (checkpoints)
```

Update the old entry about forge-craft-audit/polish to note that forge-polisher no longer exists.

**Step 2: Commit**

No git commit needed — MEMORY.md is outside the repo.
