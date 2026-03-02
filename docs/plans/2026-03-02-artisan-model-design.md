# Artisan Model — Pipeline Quality Redesign

## Status
- [ ] Implementation

## Problem

Over 10 marketplace commits in 2 days, we added structural complexity (feature managers, skeleton loading, output format gates, screenshot HARD-GATEs, component strategy changes, 4-phase robustness) to the forge pipeline. Result: agents have more rules than ever and follow fewer of them.

Three concrete failures in the Glyph rebuild:
1. Research agent captures page-level App Store screenshots despite HARD-GATE rules
2. Build agents produce structurally correct but visually dead screens
3. Polish step never executes — the most important step for quality is completely skipped

Root cause: **rules in prompts don't change agent behavior.** No amount of HARD-GATEs, output format compliance items, or structured verification gates substitute for the agent actually SEEING what it builds.

## Design: The Artisan Model

### Core Principle

Visual craft requires seeing. The build-screenshot-evaluate-iterate loop is the only thing that produces quality. Everything else is secondary.

### Agent Architecture

**Current pipeline per screen (4 handoffs, each blind):**
```
Research Agent → Build Agent → Polish Agent → Verify Agent
```

**Artisan Model per screen (1 agent that sees its work):**
```
Craft Agent (build + see + iterate) → Human Checkpoint → Verify Agent
```

The **Craft Agent** is forge-builder and forge-polisher merged into one agent. It:
1. Reads design-system.md, feature spec, voice guide section, 1 reference image
2. Has forge-craft-polish loaded (design philosophy, not checklists)
3. Writes code → builds → launches → screenshots → evaluates → iterates
4. The visual loop is not a "step" — it IS the agent's core job
5. Returns: screenshot proof of what it built + 2-sentence evaluation

The **orchestrator** (forge-app) shows screenshots to the user at checkpoints. User approves or gives direction. If feedback, Craft Agent gets dispatched again with the feedback.

The **Verify Agent** (forge-verifier) checks architecture only — view/viewmodel patterns, navigation wiring, model correctness. NOT visual quality.

### Context & Parallelism

- Each Craft Agent runs as a subagent with its own context window
- Sequential by default (one screen at a time)
- Independent screens can be parallelized (write code in parallel, serialize visual loop due to simulator access)
- Speed is secondary to quality — building 7 screens in 2 hours that look great beats 7 screens in 30 minutes that look generic

### Research Step: Code Over Rules

Live App Store browsing fails because agents screenshot the overview page with tiny thumbnails instead of clicking into individual full-size screenshots. Adding more rules doesn't fix this — agents ignore rules.

**Fix: Playwright code snippets that automate the gallery interaction.**

Instead of prompt instructions saying "click into each screenshot," the research agent calls `browser_run_code` with a pre-written Playwright script that:
1. Navigates to the App Store page
2. Finds screenshot gallery elements
3. Clicks each one to open full-size lightbox
4. Screenshots the lightbox view
5. Closes and moves to the next

Code can't be ignored the way prompt rules can. The agent calls the function, gets full-size screenshots back.

**Secondary source:** Mobbin.com (limited free access) for additional full-screen app UI references.

**Quality gate:** After each screenshot, the agent reads it back. If body text is not readable, the screenshot is discarded and retaken.

### The Visual Loop (Core of Craft Agent)

```
Write code → Build (xcodebuild) → Launch (simctl) → Wait 3s →
Screenshot → READ the screenshot → Evaluate →
  If good: done
  If not: identify what's wrong → fix → rebuild → re-screenshot
```

**Structural enforcement (not prompt rules):**
- Agent's output MUST include a screenshot path AND a 2-sentence evaluation
- If evaluation says "template-grade" or screenshot is missing, orchestrator rejects
- Max 3 iterations per screen

**Evaluation criteria** (from forge-craft-polish):
- Does this look like a *specific* app, or could it be any app with colors changed?
- Can I identify the mood (playful intelligence, clinical precision, etc.)?
- Is there visual depth (shadows, gradients, layering) or is it flat?
- Do transitions feel intentional?

### Human Checkpoints

```
Screen built → Orchestrator takes screenshot → Shows to user
User: "Approve" → Move to next screen
User: "Too flat" → Re-dispatch Craft Agent with feedback
```

**Frequency:** Approve first 2 screens individually to establish the quality bar. After that, batch-approve groups of 2-3 screens.

This is the enforcement mechanism that rules can't provide. A human looking at output and saying "not good enough" is more powerful than any prompt gate.

### What Gets Removed

| Removed | Reason |
|---------|--------|
| Separate polish agent | Merged into Craft Agent |
| Structured output format (12+ items) | Replaced by screenshot + 2-sentence eval |
| Multiple orchestrator compliance gates | Replaced by human checkpoints |
| HARD-GATE rules in prompts | Replaced by code automation and structural requirements |
| Build/Polish as separate concepts | One agent does both |

### What Gets Simplified

| Simplified | How |
|-----------|-----|
| Research browsing | Playwright code handles screenshot capture, agent focuses on observation |
| Orchestrator verification | Screenshot exists + human checkpoint, not a 10-point checklist |
| Feature managers/loading patterns | Still in AGENTS.md, Craft Agent uses when appropriate, not compliance-verified |

### What Stays

| Kept | Reason |
|------|--------|
| forge-workspace | Project setup works fine |
| forge-ux | Feature specs are valuable |
| forge-voice | Copy/voice guide is valuable |
| forge-verifier | Architecture checks (navigation, patterns, models) — NOT visual quality |
| forge-craft-polish skill | Design philosophy (7 craft dimensions, mood-to-mechanics, anti-patterns) |
| forge-eye protocols | Built into Craft Agent, not a separate step |
| Axiom audits (Step 8b) | SwiftUI quality, accessibility, etc. |
| AGENTS.md patterns | Feature managers, loading, navigation — architecture reference |

---

## Files to Modify

| File | Change |
|------|--------|
| `forge-feature/agents/forge-builder.md` | **REWRITE** → rename to `forge-craft-agent.md`. Merge build + polish + visual loop into one agent. |
| `forge-craft/agents/forge-polisher.md` | **DELETE** — merged into craft agent |
| `forge-app/skills/forge-app/SKILL.md` | **UPDATE** — dispatch Craft Agent instead of build+polish, add human checkpoints, simplify verification |
| `forge-craft/skills/forge-craft/SKILL.md` | **UPDATE** — add Playwright code snippets for App Store gallery automation, simplify browsing protocol |
| `forge-feature/skills/forge-feature/SKILL.md` | **UPDATE** — pipeline becomes scaffold → craft → verify (no separate polish step) |
| `forge-craft/claude-code.json` | **UPDATE** — remove forge-polisher agent entry |
| `forge-feature/claude-code.json` | **UPDATE** — rename forge-builder agent to forge-craft-agent |

---

## Key Insight

The pipeline failed not because it lacked rules, but because it had too many rules that agents ignored. The Artisan Model replaces prompt-based enforcement with three things that actually work:

1. **Code** — Playwright scripts for browsing, not instructions
2. **Structure** — agent must return screenshot + evaluation, not fill a 12-item checklist
3. **Human eyes** — user sees every screen and approves quality

Rules failed. Code, structure, and human judgment don't.
