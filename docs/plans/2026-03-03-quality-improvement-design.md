# Pipeline Quality Improvement — Design

## Problem

The compliance floor checks (pipeline-quality-fix-design.md) prevent the worst failures — screens that don't use DS components or miss architectural patterns. But compliance is not quality. A screen can pass all 20 floor checks and still be a flat, generic, lifeless VStack of DSCards with uniform spacing. The pipeline has never produced screens better than the template.

## Root Cause

Quality is determined by design decisions (visual hierarchy, spacing rhythm, depth, animation, composition), not by structural compliance. Currently:

1. **Design research is shallow** — forge-craft browses 2-3 apps, captures a few screenshots. Not enough visual input to inform excellent design decisions.
2. **Blueprints are vague** — "Hero element: what dominates" doesn't tell the build agent what to build. The agent interprets it however it wants.
3. **Build agent is asked to be a designer** — the craft step (Steps 6-7) asks the agent to audit against mood, research, synthesize direction, and apply 7 craft dimensions. This is design work, and build agents aren't designers.
4. **Builder grades its own work** — the self-evaluation always passes. No external eyes.

## Core Insight

**Creative work must happen upstream (design step), not downstream (build step).**

The forge-craft research step should do extensive visual research and produce very prescriptive blueprints — exact tokens, spacing, composition. The build agent implements them mechanically. Quality = design quality, not build quality.

The template is the FLOOR. Real apps (Mercury, Flighty, Headspace, Things 3) are the CEILING. The pipeline should compare against the ceiling, not the floor.

## Design

### Change 1: Extensive Design Research (forge-craft SKILL.md)

**Current:** Browse 2-3 apps, capture screenshots, present findings.

**Enhanced:**
- Browse **5-8 reference apps** per mood via Mobbin (screen flows) + App Store (gallery screenshots)
- Capture screenshots **per screen type** the app needs (dashboard, list, detail, onboarding, settings, paywall)
- For each screen type, capture **2-3 references** from different apps showing different approaches
- Save ALL to `.forge/design-references/` with naming convention: `{screen-type}-{app}-{n}.png`
- Update `.forge/design-references/index.md` with tagged mappings:

```markdown
## Dashboard
- dashboard-mercury-1.png — hero stat with oversized monospaced number, minimal chrome, data floats
- dashboard-copilot-1.png — card-based sections, warm gradients, staggered entrance, categorized
- dashboard-flighty-1.png — bold single metric, dense secondary stats, editorial layout

## Onboarding
- onboarding-headspace-1.png — full-bleed illustration, single CTA, calm and focused
- onboarding-duolingo-1.png — character-driven, progress indicator, playful and encouraging
- onboarding-notion-1.png — value prop screens with product screenshots, professional
```

Each entry gets a **1-sentence design observation** — what makes this screenshot excellent for this screen type. These observations inform the blueprint writing.

**Why this matters:** The build agent's output can only be as good as the design input. More visual input → better design decisions → more specific blueprints → better output. The research is the creative foundation.

### Change 2: Prescriptive Screen Blueprints (design-system.md generation)

**Current:** Screen Blueprints have layout description + vague code sketch. "Hero element: what dominates."

**Enhanced:** Each blueprint is derived from specific reference screenshots and specifies exact composition with DS tokens. The blueprint IS the design — the build agent implements it, doesn't interpret it.

Blueprint structure per screen type:

```markdown
#### Dashboard Blueprint
**Derived from:** dashboard-mercury-1.png (hero stat treatment), dashboard-copilot-1.png (section rhythm)

- **Layout:** `ScrollView` → `VStack(spacing: 0)` — sections with CUSTOM spacing between them
- **Hero element:** `.display()` left-aligned, `Color.textPrimary`, `.monospacedDigit()`,
  on `AmbientBackground`, `DSSpacing.xxl` top padding, `DSSpacing.lg` bottom.
  NO card wrapper — number floats directly on the background.
- **Section rhythm:** Hero → `DSSpacing.xxl` → Stats → `DSSpacing.xl` → Activity → `DSSpacing.lg` → Actions
  (Spacing VARIES — this creates visual rhythm, not uniform padding)
- **Stats:** `HStack(spacing: DSSpacing.md)` of 3 `GlassCard` pills,
  each `VStack(spacing: DSSpacing.xs)` with `.captionLarge()` label + `.headlineMedium().monospacedDigit()` value
- **Activity:** `DSSection(title:)` → `DSListCard` with `.raised` depth → `DSListRow` per item
- **Entrance:** All sections wrapped in `StaggeredVStack` with `.staggeredAppearance(index:)` per section
- **CTA:** `safeAreaInset(edge: .bottom)` with `DSButton.cta()` + `.bottomFade()` modifier
- **Empty state:** `ContentUnavailableView` with voice-guide copy, centered, `.bodyMedium()` + `.textSecondary`
```

**Key properties of prescriptive blueprints:**
- References which screenshots they're derived from (traceable)
- Specifies exact DS tokens for every value (no interpretation needed)
- Specifies spacing BETWEEN sections (not just within — this creates rhythm)
- Notes what NOT to do ("NO card wrapper" — prevents default DSCard wrapping)
- Covers all states (populated, empty, entrance animation)

**Creative synthesis happens here:** The act of looking at Mercury's hero treatment, Copilot's section rhythm, and combining them into a unique blueprint using Forge's DS tokens — that's the creative work. It's expressed as a specification.

### Change 3: Build Agent Simplification (forge-craft-agent.md)

With prescriptive blueprints, the build agent's role changes from designer to implementer.

**Current Steps 6-7 (Craft + Visual iteration):**
- Audit against mood using 7 craft dimensions
- Research 2-3 apps matching mood
- Synthesize design direction
- Apply all 7 dimensions
- Anti-pattern check
- Visual iteration (screenshot → evaluate → fix)

**Simplified Steps 6-7:**

**Step 6: Implement blueprint**
- Read the Screen Blueprint for this screen type from `.forge/design-system.md`
- Read the reference screenshots it was derived from (listed in the blueprint header)
- Implement the blueprint exactly — use the specified tokens, spacing, composition
- Where the blueprint says "NO card wrapper," don't add one. Where it says `.xxl` spacing, use `.xxl`.

**Step 7: Self-check against references (max 2 rounds)**
1. Screenshot your output (existing see protocol)
2. Read the 2-3 reference screenshots for this screen type
3. Compare: does your output approach the quality of the references?
   - Is the layout structure matching the blueprint?
   - Does spacing vary between sections as specified?
   - Is the hero element present and dominant?
   - Is there entrance animation?
4. If obvious gaps: fix, rebuild, screenshot again
5. Max 2 self-check rounds — the reviewer agent does the real evaluation

The 7 craft dimensions, mood research, and design synthesis are REMOVED from the build agent. That work already happened in the design step.

### Change 4: Dedicated Reviewer Agent

After the build agent returns its screenshot, the orchestrator dispatches a reviewer agent. This is the external pair of eyes — the builder can't grade its own work.

**Agent type:** `forge-feature:forge-reviewer` (new agent definition)

**Inputs:**
1. Screen Blueprint from `.forge/design-system.md` (what was specified)
2. 2-3 reference screenshots for this screen type (what "excellent" looks like)
3. Build agent's output screenshot (what was actually built)

**Evaluation criteria (specific, not subjective):**

| Criterion | How to evaluate |
|-----------|----------------|
| Blueprint fidelity | Does the layout match the blueprint's structure? Hero, sections, CTA placement? |
| Dominant element | Is there ONE element that's clearly dominant (larger/bolder than everything else)? |
| Spacing rhythm | Does spacing VARY between sections, or is it uniform padding everywhere? |
| Depth tiers | Are multiple depth tiers visible (flat + raised + elevated), or is everything the same level? |
| Entrance animation | Is there visible stagger/transition, or does everything appear at once? |
| Typography contrast | Are there at least 3 distinct text sizes creating hierarchy? |
| Reference quality match | Does the output approach the visual quality of the reference screenshots? |

**Output:**
- **PASS** — meets criteria, proceed to human checkpoint
- **FAIL** — specific feedback per criterion, re-dispatch build agent with feedback

**Iteration:** Max 2 reviewer rounds. If still failing after 2, present to human with reviewer's notes — let the user decide whether to accept or re-do.

### Pipeline Flow (updated)

```
forge-craft research (extensive)
  → capture 10-20 reference screenshots
  → establish mood
  → write prescriptive blueprints derived from references
  → save design-system.md + design-references/

forge-craft-agent (per screen)
  → read blueprint + references
  → scaffold (architecture)
  → implement blueprint mechanically
  → screenshot + self-check against references (max 2 rounds)
  → floor checks (Step 8c — compliance)
  → return screenshot + proof

forge-reviewer (per screen)
  → read blueprint + references + output screenshot
  → evaluate against 7 specific criteria
  → PASS → human checkpoint
  → FAIL → feedback → re-dispatch build agent (max 2 rounds)

human checkpoint
  → first 2 screens: individual approval
  → then: batch approval (2-3 screens)
```

## File Changes

| File | Change | Scope |
|------|--------|-------|
| `forge-craft/SKILL.md` | Enhanced research step (5-8 apps, per-screen-type captures, index.md format) | ~30 lines modified/added |
| `forge-craft/SKILL.md` | Enhanced blueprint format (prescriptive, derived-from references, exact tokens) | ~40 lines modified |
| `forge-craft-agent.md` | Simplified Steps 6-7 (implement blueprint, self-check against references) | ~30 lines replacing ~40 lines |
| `forge-feature/agents/forge-reviewer.md` | NEW: Dedicated reviewer agent with specific visual criteria | ~60 lines (new file) |
| `forge-app/SKILL.md` | Updated dispatch flow (add reviewer step after craft agent) | ~20 lines added |
| **Total** | | **~180 lines** |

## What This Does NOT Change

- Floor checks (Step 8c) — still in place as compliance safety net
- Human checkpoints — still first 2 screens individually, then batch
- Screenshot gate — build agent still MUST return a screenshot
- Mood system — still established in design step, drives blueprint decisions
- DS token system — still the foundation of all design decisions

## Success Criteria

The pipeline produces screens where:
1. A human looking at the output thinks "this looks like a real app" not "this looks like a tutorial"
2. Visual hierarchy is clear — one dominant element per screen
3. Spacing varies between sections (rhythm, not uniformity)
4. Depth tiers are used intentionally (not everything flat or everything elevated)
5. Entrance animations are present and motivated
6. The output approaches the quality of the reference screenshots it was derived from
