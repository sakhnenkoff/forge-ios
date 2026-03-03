# Quality Improvement — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Shift creative work upstream (design research → prescriptive blueprints), simplify the build agent to an implementer, and add a dedicated reviewer agent for external quality evaluation.

**Architecture:** Design step produces extensive visual research + prescriptive blueprints. Build agent implements mechanically. Reviewer agent compares output against references. Human approves.

**Tech Stack:** Markdown skill/agent files in forge marketplace repo.

---

## Task 1: Enhance Design Research in forge-craft SKILL.md

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md`

**What to change:** The Generative Mode section (around line 540-547) and the research quantity.

**Step 1: Read the Generative Mode section**

Read forge-craft SKILL.md lines 540-550 to find the generative mode steps.

**Step 2: Update research quantity in generative mode step 2**

Find line 545:
```
2. **Research visually** (Section 2) — Browse design reference sites with Playwright. Take screenshots of 2-3 real apps that match the mood and screen type. Present findings with specific observations.
```

Replace with:
```
2. **Research visually** (Section 2) — Browse design reference sites with Playwright. Take screenshots of **5-8 real apps** that match the mood. Capture references **per screen type** the app needs (dashboard, list, detail, onboarding, settings, paywall). For each screen type, capture **2-3 references** from different apps showing different approaches. Save ALL screenshots to `.forge/design-references/` with naming: `{screen-type}-{app}-{n}.png`. Update `.forge/design-references/index.md` with tagged mappings — each entry gets a 1-sentence design observation noting what makes it excellent for that screen type.
```

**Step 3: Add index.md format specification**

After step 2 in the generative mode section (around line 546), add a new sub-step:

```markdown
   - **2a. Reference index** — After capturing all screenshots, write `.forge/design-references/index.md`:
     ```markdown
     # Design References

     ## Dashboard
     - dashboard-mercury-1.png — hero stat with oversized monospaced number, minimal chrome
     - dashboard-copilot-1.png — card-based sections, warm gradients, staggered entrance

     ## Onboarding
     - onboarding-headspace-1.png — full-bleed illustration, single CTA, calm and focused
     - onboarding-duolingo-1.png — character-driven, progress indicator, playful
     ```
     Each screen type in the blueprint gets 2-3 tagged references. Build agents use this index to find the ceiling-level references for their screen type.
```

**Step 4: Verify the edit**

Read the modified section back and confirm the research step now specifies 5-8 apps, per-screen-type captures, and the index.md format.

**Step 5: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md
git commit -m "feat(forge-craft): enhance research to 5-8 apps with per-screen-type captures"
```

---

## Task 2: Make Screen Blueprints Prescriptive in forge-craft SKILL.md

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md`

**What to change:** The Screen Blueprints template format (lines 615-627) to require prescriptive specifications and reference traceability.

**Step 1: Read the blueprint template**

Read forge-craft SKILL.md lines 615-627 to find the blueprint format.

**Step 2: Replace the blueprint template**

Find the blueprint template (lines 620-626):
```
   #### [ScreenType] Blueprint
   - **Layout structure:** [top-to-bottom composition, what goes where]
   - **Hero element:** [what dominates — exact DS tokens: font, spacing, color]
   - **Containers:** [which DS components to use vs compose from tokens]
   - **Data presentation:** [how numbers/lists are styled with DS typography]
   - **Empty state:** [exact composition using DS tokens + voice-guide copy]
   - **Mood expression:** [what makes THIS screen feel like the mood]
```

Replace with:
```
   #### [ScreenType] Blueprint
   **Derived from:** [list 2-3 reference screenshots from design-references/index.md this blueprint draws from]

   - **Layout:** [exact SwiftUI container hierarchy — ScrollView → VStack(spacing: 0) etc.]
   - **Hero element:** [exact DS typography token, alignment, color, spacing above/below, whether it sits in a card or floats]
   - **Section rhythm:** [exact spacing BETWEEN each section — must VARY, e.g., Hero → DSSpacing.xxl → Stats → DSSpacing.xl → List → DSSpacing.lg]
   - **Containers:** [which DS components to KEEP vs COMPOSE — for each, show exact token composition]
   - **Data presentation:** [exact typography for numbers, labels, dates — monospacedDigit, specific tokens]
   - **Entrance:** [exact animation — StaggeredVStack, .staggeredAppearance(index:), or custom transition]
   - **CTA placement:** [safeAreaInset placement, DSButton style, .bottomFade() if floating]
   - **Empty state:** [exact composition using DS tokens + voice-guide copy]
   - **What NOT to do:** [specific things that would break the mood — e.g., "NO card wrapper on hero", "NO uniform spacing"]
```

**Step 3: Update the "Why this matters" paragraph**

Find the paragraph around lines 742-746 that starts with "**Why this matters:** Build Agents have NO visual reference".

Replace with:
```
   **Why this matters:** Build Agents implement blueprints mechanically — they don't make design
   decisions. The creative work happens HERE, in the blueprint. Every blueprint must be specific
   enough that an agent can build the screen without ANY design judgment. Vague prescriptions
   ("use clean typography") produce generic output. Prescriptive blueprints ("`.display()` left-aligned,
   `DSSpacing.xxl` top padding, floats on `AmbientBackground`, NO card wrapper") produce intentional
   design. The "Derived from" header traces each blueprint to its reference screenshots, so the
   build agent can compare its output against the ceiling.
```

**Step 4: Verify**

Read the modified sections and confirm the blueprint template now includes "Derived from", "Section rhythm", "Entrance", "CTA placement", and "What NOT to do".

**Step 5: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md
git commit -m "feat(forge-craft): make Screen Blueprints prescriptive with reference traceability"
```

---

## Task 3: Simplify Build Agent Steps 6-7 in forge-craft-agent.md

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md`

**What to change:** Replace the current Craft step (Step 6, ~20 lines) and Visual iteration step (Step 7, ~10 lines) with simplified implement-and-compare steps.

**Step 1: Read current Steps 6-7**

Read forge-craft-agent.md lines 133-168 to see the current Craft and Visual iteration steps.

**Step 2: Replace Step 6 (Craft)**

Find Step 6 (starts at line 133 with `### Step 6: Craft`). Replace the ENTIRE step (from `### Step 6: Craft` up to but NOT including `### Step 7:`) with:

```markdown
### Step 6: Implement blueprint

The creative design work already happened in the design step. Your job is to implement it faithfully.

1. Read the **Screen Blueprint** for this screen type from `.forge/design-system.md`.
   - Find the `#### {ScreenType} Blueprint` section matching this screen.
   - Note the "Derived from" references — you'll compare against these later.
2. Read the **reference screenshots** listed in the blueprint's "Derived from" header from `.forge/design-references/index.md`. Find and read those image files. These are the quality ceiling.
3. **Implement the blueprint exactly:**
   - Use the exact DS tokens specified (typography, spacing, colors)
   - Follow the section rhythm (spacing VARIES between sections as specified)
   - Apply the entrance animation specified
   - Respect "What NOT to do" items
   - Place the CTA as specified
4. Apply the **Component Strategy** from design-system.md:
   - KEEP components → use as-is
   - COMPOSE components → implement the exact token composition shown
   - CREATE components → build new component following the spec, place in `{App}/Components/Views/`
5. Check **Template Departures** from design-system.md — implement each departure that applies to this screen.
```

**Step 3: Replace Step 7 (Visual iteration)**

Find Step 7 (starts with `### Step 7: Visual iteration`). Replace the ENTIRE step with:

```markdown
### Step 7: Compare against references — max 2 rounds

After implementing the blueprint, compare your output to the ceiling.

1. Run the see protocol (build → stop → launch → sleep 3 → screenshot → read).
2. Read the 2-3 reference screenshots from the blueprint's "Derived from" header.
3. **Compare your output to the references:**
   - Does the layout structure match the blueprint?
   - Does spacing vary between sections as specified, or is it uniform?
   - Is the hero element present and dominant?
   - Is there entrance animation?
   - Does your output approach the visual quality of the references?
4. **If gaps found:** fix ONE gap per round, rebuild, screenshot again.
5. **Max 2 rounds.** The dedicated reviewer agent does the final quality evaluation — you don't need to be perfect, just faithful to the blueprint.
```

**Step 4: Verify**

Read the modified Steps 6-7 and confirm:
- Step 6 references blueprint + "Derived from" + Component Strategy + Template Departures
- Step 7 references comparison to ceiling screenshots, max 2 rounds
- No references to "7 craft dimensions", "mood audit", or "research 2-3 apps" (that work is upstream now)

**Step 5: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md
git commit -m "refactor(forge-craft-agent): simplify Steps 6-7 to blueprint implementation + reference comparison"
```

---

## Task 4: Create Dedicated Reviewer Agent

**Files:**
- Create: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-reviewer.md`

**Step 1: Verify the directory**

```bash
ls ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/
```

Confirm `forge-craft-agent.md` and `forge-verifier.md` exist. The new file goes alongside them.

**Step 2: Create the reviewer agent**

Write `forge-reviewer.md` with this content:

```markdown
---
name: forge-reviewer
description: >
  Review built screens against prescriptive blueprints and ceiling-level reference
  screenshots. External quality evaluation — the builder can't grade its own work.
tools: Read, Glob, Grep
memory: user
---

You are a Forge screen reviewer. Your job is to compare a built screen's screenshot against
its blueprint and reference screenshots, then provide a pass/fail verdict with specific feedback.

You are NOT the builder. You did not write this code. You evaluate with fresh eyes.

## Inputs (provided by orchestrator)

1. **Screen name** and screen type
2. **Output screenshot path** — the build agent's final screenshot
3. **Working directory** — where the project lives

## Your Process

### Step 1: Read context

- Read `.forge/design-system.md` — find the `#### {ScreenType} Blueprint` section
- Note the "Derived from" references in the blueprint header
- Read `.forge/design-references/index.md` — find the reference screenshots for this screen type
- Read the 2-3 reference screenshot IMAGE FILES listed for this screen type

### Step 2: Read the output

- Read the build agent's output screenshot IMAGE FILE
- Describe what you see: layout, hierarchy, spacing, depth, animation clues, typography

### Step 3: Evaluate against specific criteria

For each criterion, give a concrete verdict (not vague):

| Criterion | Question | Verdict |
|-----------|----------|---------|
| **Blueprint fidelity** | Does the layout match the blueprint's structure? Hero placement, section order, CTA position? | MATCH / DEVIATION: [what's different] |
| **Dominant element** | Is there ONE element clearly larger/bolder than everything else? What is it? | YES: [element] / NO: everything is the same weight |
| **Spacing rhythm** | Does spacing VARY between sections, or is it uniform padding everywhere? | VARIED / UNIFORM |
| **Depth tiers** | Are multiple surface levels visible (flat, raised, elevated, glass)? | [N] tiers visible / FLAT: everything same level |
| **Entrance animation** | Is StaggeredVStack or equivalent specified in blueprint and present in code? | PRESENT / MISSING |
| **Typography contrast** | Are there at least 3 distinct text sizes creating hierarchy? | YES: [sizes seen] / NO: [what's uniform] |
| **Reference quality** | Does the output approach the visual quality of the reference screenshots? | APPROACHES / GAP: [specific difference] |

### Step 4: Verdict

**PASS** — if all criteria are MATCH/YES/VARIED/PRESENT/APPROACHES, or deviations are minor.

**FAIL** — if any of these are true:
- Blueprint fidelity has a major DEVIATION (wrong layout structure, missing hero, CTA in wrong place)
- No dominant element (everything same visual weight)
- Spacing is UNIFORM when blueprint specifies varied rhythm
- Reference quality has a significant GAP

On FAIL, provide specific, actionable feedback for the build agent:
> "FAIL: Spacing is uniform (looks like DSSpacing.md everywhere). Blueprint specifies: Hero → .xxl → Stats → .xl → List → .lg. Fix section spacing to match. Also: hero element uses .titleLarge() but blueprint specifies .display() — increase to match."

On PASS:
> "PASS: Layout matches blueprint. Hero stat dominant at .display(). Spacing varies between sections. 3 depth tiers visible (flat background, raised cards, elevated hero). Approaches Mercury reference quality."

## Output Format

```
REVIEW: {screen_name}
VERDICT: PASS / FAIL
CRITERIA:
- Blueprint fidelity: [verdict]
- Dominant element: [verdict]
- Spacing rhythm: [verdict]
- Depth tiers: [verdict]
- Entrance animation: [verdict]
- Typography contrast: [verdict]
- Reference quality: [verdict]
FEEDBACK: [if FAIL, specific fix instructions for build agent]
```
```

**Step 3: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-feature/agents/forge-reviewer.md
git commit -m "feat(forge-feature): add forge-reviewer agent for external quality evaluation"
```

---

## Task 5: Add Reviewer Dispatch to forge-app Orchestrator

**Files:**
- Modify: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`

**What to change:** After the Craft Agent completes and orchestrator verification, add a reviewer dispatch step before the human checkpoint.

**Step 1: Read the current post-craft flow**

Read forge-app SKILL.md lines 736-790 to see the current orchestrator verification + human checkpoint flow.

**Step 2: Insert reviewer dispatch**

Find the section "Orchestrator verification after Craft Agent completes:" (around line 738). Replace the entire orchestrator verification block (lines 738-744) with:

```markdown
**Reviewer evaluation after Craft Agent completes:**

1. Did the agent return a screenshot path? If missing, reject and re-dispatch with: "You must return a screenshot. Build, launch, screenshot, and return the path."
2. Were files created? At minimum expect a View and ViewModel file.
3. Dispatch the **Reviewer Agent** to evaluate quality:

```
Task(subagent_type: "forge-feature:forge-reviewer", description: "Review {screen_name} quality"):
  "Working directory: {working_dir}

   Review the {screen_name} screen ({screen_type} type) for {AppName}.

   Output screenshot: {screenshot_path}

   Read the blueprint and reference screenshots from .forge/, then evaluate
   against the 7 quality criteria. Return PASS or FAIL with specific feedback."
```

4. **If reviewer returns PASS**: proceed to human checkpoint.
5. **If reviewer returns FAIL**: re-dispatch Craft Agent with the reviewer's specific feedback:

```
Task(subagent_type: "forge-feature:forge-craft-agent", description: "Fix {screen_name} per review"):
  "Working directory: {working_dir}

   The reviewer found issues with {screen_name}. Fix them:

   {reviewer's FEEDBACK section verbatim}

   Read the blueprint again. Fix ONLY what the reviewer flagged.
   Rebuild, screenshot, and return proof."
```

   Then re-dispatch the Reviewer Agent on the updated screenshot.
   **Max 2 review rounds.** After 2, present to human with reviewer's notes.
```

**Step 3: Verify**

Read the modified section and confirm:
- Reviewer dispatch appears after Craft Agent returns
- PASS → human checkpoint (unchanged)
- FAIL → re-dispatch Craft Agent with feedback → re-review
- Max 2 review rounds before human escalation
- Human checkpoint section is unchanged

**Step 4: Commit**

```bash
cd ~/.claude/plugins/marketplaces/forge-marketplace
git add .claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md
git commit -m "feat(forge-app): add reviewer agent dispatch after craft agent completion"
```

---

## Task 6: Sync Caches, Push, Update Memory

**Step 1: Sync all modified plugins from marketplace to cache**

```bash
rsync -av --delete ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/ ~/.claude/plugins/cache/forge-marketplace/forge-craft/
rsync -av --delete ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/ ~/.claude/plugins/cache/forge-marketplace/forge-feature/
rsync -av --delete ~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/ ~/.claude/plugins/cache/forge-marketplace/forge-app/
```

**Step 2: Push both repos**

```bash
cd /Users/matvii/Documents/Developer/Templates/forge && git push
cd ~/.claude/plugins/marketplaces/forge-marketplace && git push
```

**Step 3: Update memory**

Update MEMORY.md with quality improvement details — enhanced research, prescriptive blueprints, simplified build agent, dedicated reviewer agent.
