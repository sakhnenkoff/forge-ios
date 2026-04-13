# Forge v4 Pipeline Design

> **Supersedes:** `docs/superpowers/specs/2026-04-03-pipeline-redesign-design.md` (v3) and `docs/superpowers/plans/2026-04-03-pipeline-redesign.md` (v3 implementation plan). Those documents are archived and should not be executed.

## Overview

Forge v4 is a complete redesign of the iOS app pipeline. It consolidates two repos into one, flips model assignments (Codex builds, Opus judges), adds layered quality gates, and introduces a design reference translation system that gives every app a unique visual identity.

**Core philosophy:** Each gate owns a domain. Codex generates mechanically. Opus evaluates taste. Global skills handle architecture and deep auditing. The pipeline works standalone but gets better with GSD, Superpowers, Axiom, and Build iOS Apps installed.

## Problem Statement

The v3 pipeline has five critical issues:

1. **Apps look like the template** — no unique visual identity, everything is "SwiftUI with a different tint"
2. **SwiftUI views come out broken** — build/screenshot loop isn't robust enough, no hardened-build gates, build failures get max 2 repair rounds then move on
3. **Features not thought through** — spec phase is 5 questions, not enough depth. Results feel like AI slop
4. **Model assignments are backwards** — Generator runs on Opus (expensive, slow), Judge runs on Sonnet (cheap, less taste). Should be flipped
5. **Not using agent infra** — pipeline predates adversarial review, hardened builds, swift-concurrency skill, multi-model patterns

## Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repo consolidation | Merge forge-marketplace into forge template repo | One repo, no indirection, agent sees everything |
| Skill location | `skills/` at repo root (flat) | Clean, direct, easy to navigate |
| Builder model | Codex via explicit Opus prompts | Opus crafts the prompt with context, Codex executes mechanically |
| Judge model | Opus | Taste evaluation requires the best model |
| Judge scope | Taste only (5 visual criteria) | Architecture checks handled by floor checks + hardened-build |
| Planning phase | Forge-owned iOS questions + optional GSD/Superpowers acceleration | Works standalone, better with planning skills installed |
| Design references | awesome-design-md as inspiration + user refs (priority) + preset axes (fallback) | Multiple input sources, forge-design translates all to iOS-native |
| DS presets | Vocabulary in DESIGN.md + concrete token mappings in AdaptiveTheme | Generator uses code-level tokens, Judge verifies against them |
| forge-verify | Dropped | Floor checks inline, hardened-build covers deeper verification |
| forge-health | Dropped | Use adversarial-review on skill files instead |
| forge-build | Downgraded to prompt template | Not a standalone skill — forge-app sends it to Codex |

---

## Codex Capabilities Contract

Codex is invoked via the `codex:rescue` skill (openai-codex plugin). It runs in a sandboxed environment with:

**What Codex CAN do:**
- Read and write files via bash
- Run shell commands (build, test, grep, git)
- Call xcodebuildmcp CLI commands directly (build, screenshot, snapshot-ui, tap)
- Read DESIGN.md, AGENTS.md, spec.json — these are injected as file paths in the prompt

**What Codex CANNOT do:**
- Invoke Claude Code skills natively (SwiftUI UI Patterns, Liquid Glass, etc.)
- Use MCP tool protocols
- Access Claude Code's agent dispatch system

**How skill knowledge reaches Codex:**
forge-app reads relevant skill content and pastes key excerpts into the Codex prompt. For example, if SwiftUI UI Patterns is installed, forge-app extracts the relevant patterns and includes them as inline guidance in PROMPT.md's context block. Codex receives the knowledge, not the skill invocation.

**Context budget:**
forge-app extracts only the relevant DESIGN.md screen blueprint (not all 8 sections), the relevant AGENTS.md rules (architecture + component reference, ~200 lines), the spec.json feature entry, and preset token values. Total injected context target: under 4K tokens per Codex invocation.

**Build/screenshot orchestration:**
Codex writes code only. forge-app (Opus) handles the build/screenshot/navigation loop in Steps 2-4. Codex is re-invoked only when code changes are needed (floor check failures, build failures, Judge rejections).

---

## Repository Structure

```
forge/
├── Forge/                          # iOS app source
├── Forge.xcodeproj/
├── Packages/core-packages/         # DesignSystem + Core
│   └── DesignSystem/
│       └── Theme/
│           └── Presets/            # DS personality preset token mappings
├── ForgeUnitTests/
├── scripts/
├── skills/                         # Pipeline skills
│   ├── forge-app/SKILL.md          # Orchestrator
│   ├── forge-design/SKILL.md       # Reference → DESIGN.md translator
│   ├── forge-build/PROMPT.md       # Codex prompt template
│   ├── forge-judge/SKILL.md        # Taste evaluator
│   ├── forge-workspace/SKILL.md    # Template setup
│   ├── forge-wire/SKILL.md         # Backend wiring
│   ├── forge-storefront/SKILL.md   # App Store listing
│   └── forge-ship/SKILL.md         # Submission prep
├── docs/
│   └── design-reference/           # Curated reference library
│       ├── README.md               # How to use references
│       ├── presets.md              # DS personality preset catalog
│       └── examples/               # awesome-design-md inspired refs
├── .forge/                         # Generated per-app (gitignored)
│   ├── spec.json
│   ├── DESIGN.md
│   ├── references/
│   └── progress.md
├── AGENTS.md                       # Architecture contract
├── CLAUDE.md
└── .claude/
    └── settings.json               # Plugin registration points to ./skills/
```

The forge-marketplace repo gets archived with a "moved to forge" notice.

---

## Pipeline Phases

### Phase 1: Planning (forge-app)

forge-app runs its own iOS-specific planning conversation covering:

- Pitch + target audience
- Core screens + user journeys (with all states: loading/empty/error/loaded)
- Monetization model
- Reference selection (from `docs/design-reference/`, awesome-design-md, or user-provided)
- DS personality preset selection (spacing/radius/weight/surface)
- Brand direction (color, mood, tone)

**Optional acceleration:**

- **If Superpowers is available:** Wraps the session in Superpowers brainstorming for structured ideation, approach exploration, and design validation. writing-plans can structure the spec with dependencies and verification criteria.
- **If GSD is available:** Uses discuss-phase for adaptive questioning and plan-phase for structured planning with research and verification loops.
- **If both are available:** Superpowers for creative/design exploration (brainstorming the app concept, exploring approaches), GSD for execution mechanics (phase planning, task tracking, wave-based dispatch).
- **If neither:** forge-app's built-in 6-8 question flow handles everything — just less structured.

forge-app owns the iOS domain knowledge (what questions to ask, what spec.json looks like, what makes a good app spec). Planning skills provide workflow mechanics and structure.

**Output:** `.forge/spec.json` + `.forge/references/`

### Phase 2: Design Contract (forge-design)

forge-design reads the selected references + preset + spec and translates web-native design language to iOS-native:

- Maps hex colors → DS semantic tokens
- Maps CSS typography → DS text styles + SwiftUI font modifiers
- Maps web components → DS component rules (DSButton, DSCard, DSListRow, etc.)
- Maps spacing values → DS spacing tokens (xs through xxlg)
- Generates do's/don'ts from reference + preset constraints
- Writes screen blueprints with layout, data, entrance animation, craft moment

No live browsing (no Mobbin, no Stitch). Pure translation from inputs already collected.

**Output:** `.forge/DESIGN.md` (8 sections) → human reviews and approves

### Phase 3: Build Loop (forge-app orchestrates, per feature)

```
forge-app picks next feature from spec.json
         │
         ▼
┌─ STEP 1: Codex Code Generation ───────────────┐
│ forge-app reads forge-build/PROMPT.md          │
│ Injects context (~4K tokens):                  │
│   - DESIGN.md screen blueprint (relevant only) │
│   - AGENTS.md rules (relevant sections only)   │
│   - spec.json feature entry                    │
│   - Preset token values                        │
│   - Skill knowledge (extracted inline — see     │
│     Codex Capabilities Contract)               │
│ Sends to Codex via codex plugin                │
│ Codex writes code only:                        │
│   View + ViewModel + Manager (if needed)       │
│   + model + navigation wiring                  │
│ Codex does NOT build, screenshot, or navigate   │
└────────────────────────────────────────────────┘
         │
         ▼
┌─ STEP 2: Floor Checks (inline grep) ──────────┐
│ View file checks:                              │
│   DSScreen present?                            │
│   .toast() modifier?                           │
│   .onAppear with services/session?             │
│   No AsyncImage?                               │
│   No @StateObject?                             │
│ ViewModel file checks:                         │
│   @Observable present?                         │
│   var toast: Toast? present?                   │
│   hasLoaded guard pattern?                     │
│ Both file types:                               │
│   No banned patterns from DESIGN.md Don'ts?    │
│                                                │
│ FAIL → back to Codex with specific failures    │
│        max 2 retries                           │
└────────────────────────────────────────────────┘
         │ PASS
         ▼
┌─ STEP 3: Hardened Build (global skill) ───────┐
│ Risk classification of changes                 │
│ Architecture verification                      │
│ Deeper checks than grep                        │
│                                                │
│ FAIL → back to Codex with fix instructions     │
│        max 2 retries                           │
└────────────────────────────────────────────────┘
         │ PASS
         ▼
┌─ STEP 4: Build + Screenshot ──────────────────┐
│ xcodebuildmcp build-run-sim                    │
│ Navigate to screen (using spec.json nav_path)  │
│ xcodebuildmcp screenshot                       │
│                                                │
│ BUILD FAIL → back to Codex, max 2 retries      │
└────────────────────────────────────────────────┘
         │ SUCCESS
         ▼
┌─ STEP 5: Taste Judge (Opus) ──────────────────┐
│ Reads: screenshot + code + DESIGN.md contract  │
│ Grades:                                        │
│   - Design Quality (mood, colors, typography)  │
│   - Originality (Don'ts compliance, no         │
│     template sins)                             │
│   - Craft (component rules, spacing, hierarchy)│
│   - Craft Intent (the "one special thing")     │
│   - Visual Target Match (reference comparison) │
│                                                │
│ FAIL → fix instructions back to Codex (step 1) │
│        max 3 total rounds                      │
└────────────────────────────────────────────────┘
         │ PASS
         ▼
┌─ STEP 6: Human Gate ──────────────────────────┐
│ Screenshot shown to user                       │
│ Approve → commit, mark done in spec.json       │
│ Feedback → back to Codex (step 1)              │
│            max 2 feedback rounds               │
└────────────────────────────────────────────────┘
```

**Retry budgets per feature:**

| Gate | Max retries | Restart point | On exhaust |
|------|-------------|---------------|------------|
| Floor checks | 2 | Codex (step 1) | Mark blocked |
| Hardened build | 2 | Codex (step 1) | Mark blocked |
| Build failures | 2 | Codex (step 1) | Mark blocked |
| Judge rounds | 3 total | Codex (step 1) | Mark blocked |
| Human feedback | 2 rounds | Codex (step 1) | Mark blocked |

**Total Codex invocation ceiling: 8 per feature.** This is a hard cap regardless of which gate triggered the retry. Each restart from step 1 counts as one invocation. When Judge or Human feedback loops back to step 1, passing through floor checks and hardened build does NOT consume those gates' individual budgets — only the ceiling counts.

If the ceiling or any individual budget exhausts, forge-app logs the issue to `.forge/progress.md`, marks the feature as `blocked`, and moves to the next feature.

**Hard gate before Phase 4:** All features with `required: true` in spec.json must have status `done`. Any blocked required feature prevents Phase 4 from starting. The human must either fix the blocked feature, mark it as non-required (with scope reduction noted in progress.md), or explicitly waive the gate.

### Phase 4: Quality Verification (after all features)

Three parallel quality layers using existing global skills:

**Layer 1: Adversarial Review** (global skill)
- Opus + Codex review all code changes from the build phase in parallel
- Tech Lead adjudicates disagreements
- Focus: code quality, security, logic bugs, architectural consistency
- Issues get fixed, re-verified

**Layer 2: Axiom Deep Scan** (if available)
- Parallel dispatch of specialized auditors:
  - Accessibility (VoiceOver, Dynamic Type, contrast)
  - Security/Privacy (secrets, ATS, privacy manifest)
  - Memory (retain cycles, delegate patterns)
  - Concurrency (Swift 6 compliance, data races)
  - Energy (battery drain patterns)
  - SwiftUI performance (unnecessary redraws, lazy loading)
- Plus Build iOS Apps plugin audits (SwiftUI Performance Audit) if installed
- Issues get fixed, re-verified

**Layer 3: forge-judge Consistency Mode** (Opus)
- Judge reviews all screens together, not individually
- Checks: consistent spacing rhythm, color usage, typography hierarchy, component treatment, animation style across the app
- Catches drift that happens when features are built one at a time
- FAIL → targeted fixes, re-screenshot, re-judge

### Phase 5: Ship

Three independent post-build skills, run in order:

1. **forge-wire** — connect to real backend (Firebase, Supabase, REST, CloudKit, etc.)
2. **Post-wire verification** — rebuild on Dev scheme, run unit tests, verify no regressions. forge-wire only modifies manager implementations (never views/viewmodels), so a clean build + test pass is sufficient. If Axiom is available, run concurrency and security auditors on the wired managers.
3. **forge-storefront** — design App Store listing (competitor research, screenshots, copy, keywords)
4. **forge-ship** — submission prep (7-category pre-flight audit, Axiom orchestration, auto-fixes, checklist). This serves as the final comprehensive verification of the wired app.

---

## Model Assignments

| Component | Model | Rationale |
|-----------|-------|-----------|
| forge-app (orchestrator) | Opus | Decision-making, prompt crafting, sprint coordination |
| forge-design (DESIGN.md generation) | Opus | Taste-sensitive translation, design language |
| forge-build (code generation) | Codex via Opus | Opus writes the prompt, Codex executes mechanically |
| Floor checks | None (grep) | Deterministic pattern matching, zero cost |
| Hardened build | Opus + Codex | Defined by global skill |
| forge-judge (taste evaluation) | Opus | Visual taste requires the best model |
| Adversarial review | Opus + Codex | Defined by global skill |
| forge-workspace | Inherits from session | Mechanical setup, any model works |
| forge-wire | Inherits from session | Backend wiring, any model works |
| forge-storefront | Inherits from session | Copy + research |
| forge-ship | Inherits from session | Orchestrates Axiom |

Expensive models (Opus, Codex) are concentrated in the build loop where quality matters most. Post-build skills inherit whatever the user's session is running.

---

## DS Personality Presets

### Four axes

| Axis | Options | Controls |
|------|---------|----------|
| Spacing rhythm | tight / balanced / airy | DS spacing token scale (xs-xxlg values), padding defaults, section gaps |
| Corner radius | sharp / rounded / mixed | DS radii tokens (xs-xl values), component radius assignments |
| Typography weight | heavy / light | Display vs body weight contrast, heading boldness, caption treatment |
| Surface treatment | flat / elevated / glass | Shadow usage, surface layering, material effects, depth hierarchy |

### Where they live

**`docs/design-reference/presets.md`** — human-readable catalog describing each option with visual language. Used during planning phase. Example: "tight + sharp + heavy + flat = Linear-like density. airy + rounded + light + elevated = Airbnb-like warmth."

**`Packages/core-packages/DesignSystem/Theme/Presets/`** — Swift code in AdaptiveTheme that maps preset names to concrete token values. Each combination produces deterministic spacing, radii, typography weights, and shadow definitions.

Pre-built combinations can be named after reference apps: `.linear`, `.airbnb`, `.stripe` — convenience shortcuts mapping to their axis values.

### Three input sources (priority order)

1. **User-provided references** — screenshots, apps, their own DESIGN.md. Highest priority, always wins.
2. **awesome-design-md library** — external dependency ([VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md), 66 entries). User picks one or more entries ("Linear's density with Airbnb's warmth"). forge-design reads those web-native DESIGN.md files and translates to iOS-native tokens. Installed via `npx getdesign@latest add <site>`. The pipeline does NOT bundle these files — they are fetched on demand during Phase 1 and saved to `.forge/references/`.
3. **Built-in preset axes** — the four axes as fallback vocabulary when the user doesn't have specific references. Sufficient for prototyping; references produce better results.

### Translation layer (forge-design)

awesome-design-md files are web-native (CSS px, rgba, rem, Radix primitives, breakpoints). forge-design translates:

- CSS spacing values → DS spacing tokens
- CSS typography (font-family, weight, px sizes) → DS text styles + SwiftUI font modifiers
- CSS color roles → DS semantic color palette
- CSS component styling → DS component rules
- Web layout patterns → iOS layout conventions (no breakpoints, tab bars not hamburgers, etc.)
- Web do's/don'ts → iOS-native do's/don'ts

Users can combine references: "Linear's spacing but Stripe's color philosophy." They can also mix references with axis overrides: "Like this screenshot, but with tighter spacing."

After translation, every app maps to concrete values on the four preset axes. The axes are the output vocabulary — inputs can come from anywhere.

---

## Skill Inventory

### Ships with forge (in `skills/`)

| File | Type | Purpose | Model |
|------|------|---------|-------|
| `forge-app/SKILL.md` | Skill | Orchestrator — planning, sprint loop, dispatch, state management. Detects GSD/Superpowers/Build iOS Apps and adapts. | Opus |
| `forge-design/SKILL.md` | Skill | Reads awesome-design-md refs + user refs + preset selection → translates to iOS-native DESIGN.md (8 sections). No live browsing. | Opus |
| `forge-build/PROMPT.md` | Prompt template | Context-aware Codex prompt. forge-app populates with DESIGN.md excerpt, AGENTS.md rules, spec.json entry, available tools list. | Codex via Opus |
| `forge-judge/SKILL.md` | Skill | Taste-only evaluator. 5 criteria: Design Quality, Originality, Craft, Craft Intent, Visual Target Match. Plus cross-screen consistency mode. Read-only, never fixes. | Opus |
| `forge-workspace/SKILL.md` | Skill | Template setup — rename, brand color, feature flags, onboarding/paywall/dashboard customization. | Inherits |
| `forge-wire/SKILL.md` | Skill | Backend wiring — Firebase/Supabase/REST/CloudKit. Only touches managers, never views. | Inherits |
| `forge-storefront/SKILL.md` | Skill | App Store listing — competitor research, screenshot plan, subtitle, description, keywords. | Inherits |
| `forge-ship/SKILL.md` | Skill | Submission prep — 7-category pre-flight audit, Axiom orchestration, auto-fixes, checklist. | Inherits |

### Dropped from v3

| Skill | Reason |
|-------|--------|
| forge-health | Use adversarial-review on skill files instead |
| forge-verify | Floor checks inline in forge-app, hardened-build for deeper checks |
| forge-craft-agent / forge-eye | Merged into forge-build prompt template |
| forge-craft-polish | Anti-patterns folded into DESIGN.md Don'ts section |

### Global skills used by the pipeline (not Forge-specific)

| Skill | Used in | Required? |
|-------|---------|-----------|
| hardened-build | Phase 3 (per feature, after floor checks) | Recommended — if missing, pipeline skips step 3 and relies on floor checks + build |
| adversarial-review | Phase 4 (after all features) | Recommended — if missing, Phase 4 runs only Axiom + Judge consistency |
| xcodebuildmcp-cli | Phase 3 (build, run, screenshot, navigate) | Yes — pipeline cannot function without build/screenshot capability |
| GSD discuss-phase / plan-phase | Phase 1 (planning acceleration) | No, optional |
| Superpowers brainstorming / writing-plans | Phase 1 (planning acceleration) | No, optional |
| Axiom auditors | Phase 4 (deep scan) | No, optional |
| Build iOS Apps plugin (SwiftUI UI Patterns, Liquid Glass, Performance Audit, View Refactor, App Intents, iOS Debugger) | Phase 3 (Codex enhancement) | No, optional |
| swift-concurrency | Phase 3 (Codex enhancement) | No, optional |
| swiftui-expert | Phase 3 (Codex enhancement) | No, optional |
| marketing-skills | Phase 1 (pricing), Phase 5 (storefront) | No, optional |

---

## DESIGN.md Contract Format

Eight sections, same structure as v3 with minor additions (preset axes in Mood, SKIP verdict in Component Rules). Now populated by forge-design's translation layer:

| # | Section | What it defines |
|---|---------|-----------------|
| 1 | Mood | 2-sentence feel description + reference apps + preset axes |
| 2 | Color Palette | 11+ semantic roles mapped to DS tokens (brand, background, surface, text variants, positive, negative, border, divider) |
| 3 | Typography | DS text style tokens with design variants (.default, .rounded, .monospaced, .serif) + weight/size mappings from preset |
| 4 | Component Rules | YES/NO/CUSTOMIZE table for all DS components + surface treatment from preset |
| 5 | Layout Principles | Spacing rules using DS token names + rhythm from preset |
| 6 | Do's and Don'ts | 4-6 patterns TO use, 6-10 GREPPABLE patterns to never use. Includes iOS-native translations of web reference Don'ts |
| 7 | Screen Blueprints | Per screen: hero, sections, list structure, empty state, entrance animation, craft moment, data sources |
| 8 | Voice & Copy | Exhaustive table of exact strings for every user-facing element |

---

## .forge/ Directory Structure

Generated per-app, gitignored in the template, committed in app projects:

```
.forge/
├── spec.json               # Features, models, navigation, statuses
├── DESIGN.md               # 8-section design contract
├── references/             # Gitignored — ephemeral design inputs
│   ├── linear.md           # Fetched from awesome-design-md (web-native)
│   ├── user-screenshot.png # User-provided (may contain proprietary content)
│   └── index.md            # Which refs, how they combine, axis overrides
├── progress.md             # Sprint progress, feature statuses, blocked items
└── retrospective.md        # Pipeline issues log — auto-written by forge-app, committed in app projects
```

**Note:** `.forge/references/` is gitignored by default. Raw reference assets (user screenshots, fetched DESIGN.md files) are ephemeral inputs consumed by forge-design to produce the DESIGN.md contract. Only the derived DESIGN.md is committed. Users can opt in to committing references by removing the gitignore entry.

---

## Gate Ownership Matrix

Each quality concern has exactly one authoritative gate:

| Concern | Authoritative gate | Why not others |
|---------|--------------------|----------------|
| DSScreen, .toast, @Observable, banned patterns | Floor checks (inline grep) | Deterministic, zero cost, catches 80% of violations |
| Architecture compliance, risk classification | Hardened build (global skill) | Deeper than grep, risk-aware, catches structural issues |
| Visual taste, mood match, originality | forge-judge (Opus) | Only a vision-capable model can evaluate screenshots against design intent |
| Cross-screen consistency | forge-judge consistency mode | Requires seeing all screens together |
| Code quality, security, logic bugs | Adversarial review (global skill) | Multi-model consensus, catches what single-model misses |
| iOS-native deep quality (accessibility, memory, concurrency, energy) | Axiom auditors | Domain-specialized, deeper than any generalist check |
| Build correctness | xcodebuildmcp | Compiler is the authority |
| Navigation correctness (all routes reachable, tabs wired) | Phase 4: forge-app navigation sweep | Uses xcodebuildmcp snapshot-ui + tap to walk every nav_path in spec.json and verify reachability |

No two gates own the same concern. Redundancy is heterogeneous (code checks vs. visual judgment vs. domain audits), never homogeneous (two LLMs checking the same thing from the same evidence).

### Minimum Viable Pipeline

The pipeline must function when only the required dependencies are installed. This is the quality floor:

**Required (pipeline will not run without these):**
- forge skills (in `skills/`)
- xcodebuildmcp CLI (build, run, screenshot, navigate)
- Codex plugin (code generation)

**Minimum viable gate coverage without optional skills:**

| Concern | Minimum gate | Limitation |
|---------|-------------|------------|
| Architecture compliance | Floor checks (grep) | Catches pattern presence/absence only, not semantic correctness |
| Code quality | Compiler + floor checks | No logic review, no security analysis |
| Visual taste | forge-judge (Opus) | Full capability, no degradation |
| Build correctness | xcodebuildmcp | Full capability |
| Navigation correctness | Phase 4 nav sweep | Full capability |

**When hardened-build is missing:** forge-app logs a warning at pipeline start: "hardened-build not installed — architecture verification limited to floor checks." Step 3 is skipped entirely.

**When adversarial-review is missing:** Phase 4 Layer 1 is skipped. forge-app logs: "adversarial-review not installed — no multi-model code review. Consider installing before shipping."

**When both are missing:** The pipeline produces apps with visual quality (Judge) but without deep code quality assurance. Acceptable for prototyping, not recommended for production shipping.
