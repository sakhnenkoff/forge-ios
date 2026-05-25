# Forge vNext Pipeline Gap Audit

Date: 2026-05-25
Kanban: board `forge`, card `t_f470a49e`
Scope: diagnosis only. No DayRateLab polishing. No Forge template mutation.

## Executive verdict

DayRateLab proved that Forge can produce *some* useful pipeline artifacts, a separate generated app repo, native screenshots, and local handoff docs. It did **not** prove that Forge can repeatedly generate launchable, non-bullshit apps.

The main failure was not one broken Swift test or one Firebase crash. The systemic failure is that Forge allowed a plausible-looking vertical slice to pass as an end-to-end product-studio proof while major product, design, verification, launch, and learning gates remained shallow or app-specific.

## Top 5 systemic Forge pipeline failures

### 1. Gate contracts were descriptive, not executable enough

**What failed**

The pipeline gates documented what should happen, but did not produce hard, machine-checkable pass/fail criteria for the most important product questions.

Evidence:
- `docs/forge-e2e-pipeline-gates.md` defines P0-P9 gate expectations, but many are prose requirements.
- DayRateLab `.forge/activation-onboarding.md` claimed fast activation, while the native app launched into multiple intro screens before the first useful prediction.
- `.forge/progress.md` still marked P6-P9 as pending even after later native/handoff artifacts existed.

**Gate mapping**

- Product
- Activation
- Retention
- Monetization
- Design
- Judge/repair
- Handoff

**Fix belongs in**

- docs: rewrite gate contracts as checklists with explicit required evidence
- scripts: add artifact validators for `.forge` state consistency
- generator behavior: force each gate to emit JSON + human markdown
- prompt/GoalBuddy task shape: require gate receipts before continuing

**Next proof app must test**

- a gate cannot pass if the implementation contradicts its own `.forge` artifact
- progress/receipt state must update when native/handoff phases complete
- activation gate must be checked against actual first-run simulator evidence, not only prose

---

### 2. Product/taste gates allowed a coherent idea to become a shallow app-shaped slice

**What failed**

DayRateLab had a coherent thesis, but the generated app proof only covered a narrow shell: Today/Patterns/Pro segmented surfaces. It did not prove the full blueprint, the repeat-use loop, or the promised emotional/product depth.

Evidence:
- `.forge/spec.json` lists Today, Insights, History, and Day Detail.
- Native proof focused on Today and Patterns screenshots.
- Handoff itself says Pro/paywall, onboarding, history/detail screenshots are still needed.
- Final audit scored app quality 6/10 and described retention as plausible on paper but partial in UI.

**Gate mapping**

- Product
- Retention
- Monetization
- Design
- Native
- Handoff

**Fix belongs in**

- docs: add a non-bullshit app scorecard with app-specific hard minimums
- generator behavior: force implementation slice selection to match launch bar
- prompt/GoalBuddy task shape: require explicit “what is intentionally not built” with launch impact
- verifier: verify coverage matrix, not just presence of two screenshots

**Next proof app must test**

- whether Forge can reject a dashboard/card shell even when the written concept sounds good
- whether the generated app shows activation, core loop, retention/progress, and money boundary as native states
- whether missing required blueprint surfaces block launch-candidate claims

---

### 3. Design system generation was not strong enough to prevent scaffold-reskin output

**What failed**

The app looked more distinct than the old template, but the visible native experience was still agent-card heavy and not enough like a custom product designed around one workflow.

Evidence:
- Final audit: “Better than template, still agent-card heavy.”
- `docs/forge-vnext-charter.md` now requires custom design system per app and rejects scaffold reskins.
- DayRateLab screenshots showed a dark/mint direction, but Today was still a large card plus generic choice buttons.

**Gate mapping**

- Design
- Native
- Judge/repair

**Fix belongs in**

- docs: add custom design-system gate based on product logic, not token cosmetics
- scripts: require design artifact inventory and screenshot acceptance matrix
- generator behavior: produce HTML/clickable prototype before native expansion
- prompt/GoalBuddy task shape: require human design approval before Swift expansion

**Next proof app must test**

- references + original synthesis artifact exists before Swift work
- HTML/clickable prototype exists before native expansion
- native screenshots are judged against app-specific design acceptance criteria
- default scaffold/card/dashboard patterns are explicitly rejected unless justified by the app

---

### 4. Verification proved DayRateLab-specific markers, not reusable Forge capability

**What failed**

The native verifier is useful as a DayRate smoke test, but it hardcodes domain files and literals. It cannot prove Forge can generate another app without script edits.

Evidence:
- `scripts/forge-e2e-native-verify.mjs` reads `Features/Home/HomeView.swift`, `HomeViewModel.swift`, and `Managers/DayRate/DayRateManager.swift` directly.
- It requires markers like `Patterns`, `Pro`, `hasEnoughPatternData`, `protocol DayRateManagerProtocol`, and `MockDayRateManager()`.
- It requires screenshot names `native-today-screen.jpg` and `native-patterns-screen.jpg`.

**Gate mapping**

- Native
- Verification
- Judge/repair
- Handoff

**Fix belongs in**

- scripts: replace hardcoded domain checks with spec-driven checks from `.forge/spec.json` and a generated `.forge/verification-plan.json`
- docs: define generic evidence matrix and app-specific verifier config format
- generator behavior: emit verifier config during product/design/native planning
- prompt/GoalBuddy task shape: require the verifier to run against a second unrelated app without source edits

**Next proof app must test**

- verifier discovers project/scheme/app features from `.forge` artifacts
- app-specific checks live in generated config, not verifier source
- screenshot requirements are derived from the app’s activation/core/retention/monetization gates
- second app passes verification without editing verifier literals

---

### 5. Launch/handoff and learning loop were local artifacts, not a full product-studio system

**What failed**

The handoff bridge created useful App Store-style copy, but it was still DayRate-shaped, fixed-format, and not connected to a durable learning loop. Forge did not yet produce structured app/pipeline scorecards, learning patch proposals, or app-specific launch package choices.

Evidence:
- `scripts/forge-e2e-handoff.mjs` writes DayRate-specific positioning/copy and fixed screenshot stories.
- Final audit noted handoff copy is practical, but also that production TODOs remain broad.
- `docs/forge-vnext-charter.md` now requires app score + pipeline score, app-specific launch package, postmortem, and reviewed learning patches.

**Gate mapping**

- Monetization
- Handoff
- Judge/repair
- Learning/postmortem

**Fix belongs in**

- docs: define launch-package schema and scorecard/postmortem schema
- scripts: generate app-specific launch package from spec/evidence/positioning config
- generator behavior: emit pricing/privacy/copy/screenshot strategy as explicit artifacts
- prompt/GoalBuddy task shape: require post-run learning patch proposals before completion

**Next proof app must test**

- launch package is proposed per app, not fixed to one template
- privacy, pricing, copy, screenshots, and TestFlight-ready local checklist are separate artifacts
- final audit produces app score and pipeline score separately
- learning patch proposals are created and reviewable, not silently applied

## Gap matrix

| Systemic gap | Gates affected | Fix location | Required next-app proof |
|---|---|---|---|
| Gate prose is not executable enough | Product, Activation, Retention, Monetization, Design, Judge, Handoff | docs, scripts, generator, GoalBuddy task shape | Gate receipts block contradictions between `.forge` docs and native behavior |
| Coherent thesis can still become shallow app shell | Product, Retention, Monetization, Design, Native, Handoff | docs, generator, verifier, task shape | Native app shows activation/core loop/retention or progress/money boundary |
| Design gate allows scaffold-reskin output | Design, Native, Judge | docs, scripts, generator, task shape | HTML/clickable prototype + native screenshots judged against app-specific criteria |
| Verifier is app/domain-specific | Native, Verification, Judge, Handoff | scripts, docs, generator, task shape | Second app verifies without editing verifier source literals |
| Handoff/learning not yet a product-studio loop | Monetization, Handoff, Judge, Learning | docs, scripts, generator, task shape | App-specific launch package + app/pipeline scorecards + learning patch proposals |

## What was DayRate-specific execution weakness vs Forge-systemic weakness

### Mostly DayRate-specific / generated-app issues

- `HomeViewModelTests` referenced stale `selectedHomeTab` and failed compile.
- Non-Mock dev launch crashed due invalid Firebase config.
- DayRateLab onboarding was too long for the promised “thirty-second ritual.”
- DayRateLab Pro/paywall/history/detail surfaces were incomplete.

These should inform gates, but they are not the main thing to patch directly.

### Forge-systemic issues

- Forge did not prevent stale tests from surviving into a “successful” proof.
- Forge did not require Mock-vs-dev launch configuration clarity.
- Forge did not block mismatch between activation spec and first-run native evidence.
- Forge did not enforce full coverage of required launch/evidence surfaces.
- Forge did not keep verifier/handoff app-agnostic.
- Forge did not convert the run into structured learning patches.

These are the vNext targets.

## Recommended next execution graph

### Card 1: Convert charter + audit into executable gate schemas

Output:
- `.forge` gate receipt schema
- scorecard schema
- launch package schema
- learning patch schema

Acceptance:
- each major gate has machine-readable required fields and human-readable rationale
- no gate can pass with prose only

### Card 2: Generalize verifier before second app

Output:
- spec-driven verifier plan
- generic evidence matrix
- generated app-specific verifier config

Acceptance:
- no DayRate literals in reusable verifier source
- second app can define its own required files/screens/evidence

### Card 3: Add design proof gate before native expansion

Output:
- design reference/moodboard artifact contract
- HTML/clickable prototype requirement
- native screenshot review contract

Acceptance:
- no scaffold-reskin app can pass design gate by changing colors/cards only

### Card 4: Add launch-package + learning-loop contracts

Output:
- app-specific launch package artifact structure
- app score + pipeline score artifact
- postmortem + learning patch proposal artifact

Acceptance:
- every run ends with reviewable durable learning in Forge-owned artifacts

### Card 5: Generate second proof app only after Cards 1-4 pass review

Output:
- separate generated app repo
- app-specific research/product/design/native/evidence/launch artifacts
- final skeptical audit

Acceptance:
- TestFlight-ready local package quality
- no template contamination
- no verifier source edits for the app domain

## Recommended gate decision now

Do **not** jump straight to generating the second app.

Proceed to convert this audit + the vNext charter into executable gate/spec artifacts first. The next work should be docs/schema/script design, not native app generation.

Suggested next Kanban focus:

1. `Repair product/taste gates before next app`
2. `Generalize verifier and evidence requirements`

These can be worked in parallel conceptually, but with only the current `default` Hermes profile, run them serially or manually split them into smaller cards before assigning workers.
