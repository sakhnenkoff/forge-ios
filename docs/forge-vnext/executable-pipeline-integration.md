# Forge vNext Executable Pipeline Integration Plan

> **For Hermes:** Use Kanban to execute this plan card-by-card. Do not generate the second proof app until Matvii approves one of the gate decision options in this document.

**Goal:** Convert Forge vNext lane specs A-D into one executable, app-agnostic product-studio pipeline that can safely generate a second proof app after product/design/verifier/launch gates are repaired.

**Architecture:** Forge owns durable pipeline contracts as schemas, gate prompts, validators, verifier runners, evidence indexes, launch-package artifacts, and learning patches. Generated apps own app-specific `.forge/` artifacts and native evidence; reusable Forge scripts must stay generic and read those artifacts instead of embedding app-domain literals.

**Tech Stack:** Markdown contracts, JSON Schema-style artifacts, Node.js `.mjs` validators/runners, SwiftUI generated app repos, Xcode Mock builds, simulator screenshots/video when feasible, Hermes Kanban for execution gates.

---

## 1. Synthesis verdict

Do not jump to the existing child card `t_81f3440f` (`Generate second proof app from scratch`) yet.

The four lane specs agree on the next move: repair Forge's executable pipeline contracts first, then run a deliberately skeptical second-app proof. The pipeline must be able to fail an app before native generation if product/design evidence is shallow, and fail it after native generation if evidence, screenshots, launch packaging, or learning outputs are missing.

The integrated plan is:

1. Define shared schema/artifact contracts for product, design, verification, launch, scorecards, postmortem, and learning patches.
2. Implement local validators/runners that prove these contracts are executable.
3. Replace DayRate-specific verifier/handoff assumptions with app-specific `.forge/` plans read by generic scripts.
4. Add fixtures that demonstrate pass/fail behavior without creating a real second app.
5. Ask Matvii whether to proceed to second-app generation, repair more first, or change the bar.

## 2. Source lanes used

- Lane A product/taste gates: `docs/forge-vnext/lanes/product-taste-gates.md`
- Lane B design/look-feel gates: `docs/forge-vnext/lanes/design-look-feel-gates.md`
- Lane C verifier/evidence architecture: `docs/forge-vnext/lanes/verifier-evidence-architecture.md`
- Lane D launch package + learning loop: `docs/forge-vnext/lanes/launch-learning-package.md`
- Owner charter: `docs/forge-vnext-charter.md`
- RFC: `docs/rfcs/2026-05-25-forge-vnext-agentic-product-studio.md`
- Gap audit: `docs/forge-vnext-pipeline-gap-audit.md`

## 3. Integrated principles

### 3.1 Forge is the pipeline product

Generated apps are evidence. They must not contaminate the Forge template, and they are not the primary object being polished during vNext repair.

### 3.2 Every major gate emits two artifacts

Each gate must emit:

- human-readable markdown for review and operator decisions
- machine-readable JSON for validators, verifier runners, dashboards, and future learning

A prose-only pass is not a pass.

### 3.3 App score and pipeline score remain separate

The second app can be mediocre while the pipeline succeeds if Forge honestly detects weakness and blocks/repairs. Conversely, a lucky good app does not prove the pipeline if receipts, evidence, and learning are weak.

### 3.4 Human gates stay explicit in early vNext

Forge may recommend pass/repair/kill/launch, but Matvii decides idea kills, major gate approvals, launch use, learning-patch adoption, external/public actions, signing/accounts, money, and TestFlight/App Store actions.

### 3.5 Generic scripts read app-specific contracts

Reusable Forge verifier/handoff/launch scripts may implement generic interpreters only. App-specific literals belong in `.forge/spec.json`, `.forge/gates/*.json`, `.forge/design/*.json`, `.forge/verification-plan.json`, and `.forge/launch/*.json` inside the generated app.

## 4. Final artifact and file layout

### 4.1 Forge repo docs

These files are source-of-truth documentation and review aids:

```text
docs/forge-vnext/
  executable-pipeline-integration.md              # this document
  lanes/
    product-taste-gates.md
    design-look-feel-gates.md
    verifier-evidence-architecture.md
    launch-learning-package.md
  schemas/
    README.md
    forge.gate-receipt.v1.schema.json
    forge.product-taste-gate.v1.schema.json
    forge.product-coverage-matrix.v1.schema.json
    forge.app-scorecard.v1.schema.json
    forge.pipeline-scorecard.v1.schema.json
    forge.design-handshake.v1.schema.json
    forge.design-system.v1.schema.json
    forge.design-review-receipt.v1.schema.json
    forge.verification-plan.v1.schema.json
    forge.evidence-index.v1.schema.json
    forge.substitute-evidence.v1.schema.json
    forge.launch-package.v1.schema.json
    forge.privacy-draft.v1.schema.json
    forge.pricing-draft.v1.schema.json
    forge.postmortem.v1.schema.json
    forge.learning-patches.v1.schema.json
  fixtures/
    shallow-dashboard-fail/
    token-reskin-fail/
    missing-evidence-fail/
    minimal-app-specific-pass/
  prompts/
    product-gate-contract.md
    design-gate-contract.md
    verifier-plan-contract.md
    launch-package-contract.md
    postmortem-learning-contract.md
```

### 4.2 Forge repo scripts

These scripts are local-only and app-agnostic:

```text
scripts/
  forge-vnext-gate-validate.mjs          # validates shared gate receipts + product/design/launch schema files
  forge-vnext-design-gate-verify.mjs     # phase-specific design artifact validator
  forge-vnext-verifier.mjs               # generic evidence runner driven by .forge/verification-plan.json
  forge-vnext-launch-package.mjs         # local launch package generator/validator
  forge-vnext-final-audit.mjs            # final audit aggregator: scores + evidence + postmortem readiness
```

Existing DayRate-shaped scripts should either remain as legacy examples or be wrapped/replaced by the generic vNext scripts:

- `scripts/forge-e2e-native-verify.mjs` currently hardcodes DayRate files/literals and must not be the reusable vNext proof.
- `scripts/forge-e2e-handoff.mjs` currently writes DayRate-shaped launch copy and must not be the reusable vNext launch package path.

### 4.3 Generated app `.forge/` layout

Each generated app repo should own its app-specific plan and evidence:

```text
.forge/
  spec.json
  research/
    evidence-matrix.json
    judge-critique.md
  gates/
    direction-gate.json
    slice-selection-gate.json
    product-taste-gate.json
    product-coverage-matrix.json
    native-evidence-gate.json
    final-audit-gate.json
  design/
    references.json
    original-synthesis.md
    emotional-tone.md
    design-system.json
    prototype-receipt.json
    native-screenshot-review.json
    final-design-receipt.json
  verification-plan.json
  evidence/
    evidence-index.json
    substitutes/
      <substitute-id>.json
    screenshots/
    videos/
    logs/
    audit-receipts/
  launch/
    launch-package.json
    asc-drafts.json
    privacy-draft.json
    pricing-draft.json
    copy-draft.md
    screenshot-plan.json
    testflight-local-checklist.md
  scorecards/
    app-scorecard.json
    pipeline-scorecard.json
  learning/
    postmortem.md
    learning-patches.json
```

### 4.4 Generated app native layout

The generated app must live outside the Forge template in a separate local repo. The exact native structure can vary per app, but the proof bar requires:

- SwiftUI app project or package-backed app that builds in Mock scheme
- feature slices with mock data, previews, and tests where practical
- native screenshots proving activation/core loop/retention or progress/money boundary as applicable
- no DayRateLab names or Forge template sample-app contamination
- evidence links from `.forge/evidence/evidence-index.json` to actual files

## 5. Unified gate sequence

### Gate 0: Pipeline contract readiness

Purpose: prove Forge has executable contracts before attempting a second app.

Required outputs:

- schema docs under `docs/forge-vnext/schemas/`
- fixture trees under `docs/forge-vnext/fixtures/`
- validators that fail known shallow/generic/missing-evidence fixtures

Pass bar:

- product/taste hard minimum failures block
- generic design shells block
- missing required evidence blocks unless approved substitute evidence is indexed
- launch/learning artifacts validate locally

### Gate 1: Research and direction

Purpose: select a second-app direction without pretending weak evidence is strong.

Required outputs:

- evidence matrix with sources/confidence/gaps
- three directions and one recommendation
- product/taste gate receipt
- explicit repair/kill recommendation if a critical dimension is weak

Human decision: Matvii approves, repairs, or rejects the selected direction.

### Gate 2: Product/taste contract

Purpose: prevent coherent but shallow app-shaped slices.

Required outputs:

- target user, painful problem, use case, activation, core loop, retention/progress, money boundary
- product coverage matrix
- app scorecard draft with hard minimums
- pipeline product-enforcement score fields

Hard blockers:

- no sharp user/problem/use case
- missing repeat-use loop
- money path absent without explicit approved deferral
- dashboard/card shell without activation/core loop/retention/money proof
- weak evidence integrity

### Gate 3: Design proof before Swift expansion

Purpose: make design a hard gate, not late polish.

Required outputs:

- product-design handshake
- references + original synthesis
- emotional tone
- app-specific design-system JSON
- HTML/clickable prototype receipt
- generic UI rejection tests

Hard blockers:

- token-only scaffold reskin
- generic dashboard/card density without app-specific workflow shape
- prototype missing before native expansion
- native screenshots later contradict the design contract

### Gate 4: Native implementation slice

Purpose: generate only enough native app to prove the selected product/design slice, not a sprawling fake complete product.

Required outputs:

- separate generated app repo
- Mock build target
- app-specific SwiftUI feature slice(s)
- tests/previews/mock data where practical
- screenshots for activation/core loop/retention or progress/money boundary

Hard blockers:

- app is hand-built outside the pipeline
- app only contains static docs/mockup
- template contamination
- native screen contradicts gate artifacts

### Gate 5: Generic verification and evidence

Purpose: prove verifier reusability and evidence integrity.

Required outputs:

- `.forge/verification-plan.json`
- `.forge/evidence/evidence-index.json`
- build/test/run/screenshot/video or approved substitute evidence
- audit receipt from generic verifier

Hard blockers:

- verifier needs domain-specific source edits
- screenshot slots are hardcoded instead of derived from app gates
- missing evidence has no approved substitute
- console success has no evidence index

### Gate 6: Launch package and scorecards

Purpose: produce a local, reviewable TestFlight/App Store-ready package without external side effects.

Required outputs:

- local ASC-ready drafts
- privacy draft
- pricing/paywall recommendation
- copy draft
- screenshot plan/artifacts
- TestFlight-ready local checklist
- app scorecard and pipeline scorecard

Hard blockers:

- privacy/pricing/copy are generic or not linked to app evidence
- launch package claims unsupported by screenshots/evidence
- any live ASC/TestFlight/IAP/signing/privacy action attempted without approval

### Gate 7: Postmortem and learning patches

Purpose: turn the run into durable Forge learning without silently mutating the pipeline.

Required outputs:

- postmortem
- learning-patches.json
- evidence gaps
- decision log
- reviewed patch recommendations

Hard blockers:

- learning patches auto-applied without human review
- app score and pipeline score collapsed into one score
- final report omits evidence gaps or failed repairs

## 6. Implementation sequence

### Phase 1: Shared contracts first

Build the minimal shared schema set and fixture tree. This is the foundation for all lanes.

Acceptance:

- all schema files exist under `docs/forge-vnext/schemas/`
- each schema has a small pass fixture and at least one fail fixture
- validator command can run locally against fixtures
- no generated app is created

### Phase 2: Product + design validators

Implement product/taste and design gate validators before verifier work. These are earlier in the pipeline and prevent bad native work from starting.

Acceptance:

- shallow dashboard/card-shell fixture fails product gate
- token-reskin fixture fails design gate
- minimal app-specific fixture passes only with real activation/core loop/design evidence

### Phase 3: Generic verifier and evidence index

Implement the generic verifier runner driven by `.forge/verification-plan.json`.

Acceptance:

- two different fixture app trees can be verified by editing only their `.forge/verification-plan.json` and evidence files
- no DayRateLab literals appear in reusable verifier source
- missing evidence fails unless substitute evidence is explicitly approved and indexed

### Phase 4: Launch package + learning loop

Implement local-only launch package generator/validator and postmortem/learning patch validator.

Acceptance:

- launch package is app-specific and linked to spec/evidence
- scorecards separate app quality from pipeline quality
- learning patches are generated as proposals only

### Phase 5: Integrated dry run on fixtures

Run the whole vNext gate flow on fixtures before touching a real second proof app.

Acceptance:

- known bad fixtures fail at the expected gate
- minimal app-specific fixture passes through all local validators
- final audit output clearly states pass/repair/kill/launch recommendation and evidence gaps

### Phase 6: Matvii decision gate

Stop and ask Matvii whether to generate the second proof app now.

The existing child card `t_81f3440f` should remain unassigned/blocked from execution until Matvii chooses the proceed option and the implementation cards below are complete.

## 7. Conflicts, disagreements, and integration decisions

### 7.1 Strict gates vs exploration speed

- Lane A warns strict product gates can stall exploration.
- Lane B accepts slower second proof app in exchange for quality.
- Lane C warns schema/check-type complexity can creep.
- Lane D warns learning patches can add complexity creep.

Integration decision: keep v1 deliberately small, with two repair loops before asking Matvii. Strict gates are correct for vNext proof, but every validator must explain the smallest repair that could pass.

### 7.2 Human taste vs automated scoring

- Product and design lanes both recognize taste is partly subjective.
- Verifier can prove evidence existence and receipts, but not fully judge quality.

Integration decision: automated validators block missing/contradictory/generic evidence; Matvii remains the taste authority at major gates. Use machine scores as decision support, not hidden autopilot.

### 7.3 Launch package depth before real app proof

- Lane D wants complete launch-package structure.
- The current task forbids generating the second app.

Integration decision: implement launch/learning contracts and fixtures now; generate real app-specific launch package only during the second-app run.

### 7.4 External tools vs local trust

- Lane D names optional screenshot/marketing tools.
- Safety model requires local/non-destructive work unless approved.

Integration decision: external tools are optional after sandbox/security/fit vetting. v1 should pass with local artifacts first.

### 7.5 Verifier genericity vs useful app-specific checks

- Lane C forbids app literals in reusable source.
- Product/design lanes require app-specific checks.

Integration decision: reusable source may implement generic check types (`file_exists`, `json_path_equals`, `screenshot_required`, `build_command`, `test_command`, `flow_video_required`) while app-specific paths, slots, and expected markers live in generated `.forge/verification-plan.json`.

## 8. Exact next Kanban cards for implementation

Available profiles discovered on this machine:

- `forgeproduct`
- `forgedesign`
- `forgeverifier`
- `forgelaunch`
- `forgejudge`
- `default`

Create these cards only after Matvii chooses the implementation path. Cards 1-4 can run in parallel after this synthesis is approved. Cards 5-7 are gated.

### Card 1: Implement product/taste schema and validator skeleton

Assignee: `forgeproduct`

Parents: `t_d9a685b2`

Body:

```text
Implement Forge vNext product/taste executable contracts. Do not generate a second app.

Inputs:
- docs/forge-vnext/executable-pipeline-integration.md
- docs/forge-vnext/lanes/product-taste-gates.md
- docs/forge-vnext-charter.md
- docs/forge-vnext-pipeline-gap-audit.md

Deliverables:
- docs/forge-vnext/schemas/forge.product-taste-gate.v1.schema.json
- docs/forge-vnext/schemas/forge.product-coverage-matrix.v1.schema.json
- docs/forge-vnext/schemas/forge.app-scorecard.v1.schema.json
- docs/forge-vnext/fixtures/shallow-dashboard-fail/
- docs/forge-vnext/fixtures/minimal-app-specific-pass/
- scripts/forge-vnext-gate-validate.mjs product mode or equivalent local validator entrypoint

Acceptance:
- shallow dashboard/card shell fixture fails on hard minimums
- minimal app-specific fixture passes product/taste validation
- app score and pipeline score fields remain separate
- validator is app-agnostic and contains no DayRateLab literals
- no second app generation, no external actions
```

### Card 2: Implement design gate schemas and fixture validator

Assignee: `forgedesign`

Parents: `t_d9a685b2`

Body:

```text
Implement Forge vNext design/look-feel executable gate contracts. Do not generate a second app.

Inputs:
- docs/forge-vnext/executable-pipeline-integration.md
- docs/forge-vnext/lanes/design-look-feel-gates.md
- docs/forge-vnext-charter.md

Deliverables:
- docs/forge-vnext/schemas/forge.design-handshake.v1.schema.json
- docs/forge-vnext/schemas/forge.design-system.v1.schema.json
- docs/forge-vnext/schemas/forge.design-review-receipt.v1.schema.json
- docs/forge-vnext/fixtures/token-reskin-fail/
- docs/forge-vnext/fixtures/shallow-dashboard-fail/design/
- scripts/forge-vnext-design-gate-verify.mjs

Acceptance:
- token-only scaffold reskin fixture fails
- missing HTML/clickable prototype receipt fails pre-native phase
- minimal app-specific fixture can pass with references, original synthesis, emotional tone, and design-system evidence
- native screenshot review contract is defined but can use fixture evidence only
- no second app generation, no external actions
```

### Card 3: Implement generic verifier plan/evidence index runner

Assignee: `forgeverifier`

Parents: `t_d9a685b2`

Body:

```text
Implement Forge vNext generic verification/evidence contracts. Do not generate a second app.

Inputs:
- docs/forge-vnext/executable-pipeline-integration.md
- docs/forge-vnext/lanes/verifier-evidence-architecture.md
- current scripts/forge-e2e-native-verify.mjs as an anti-pattern/reference only

Deliverables:
- docs/forge-vnext/schemas/forge.verification-plan.v1.schema.json
- docs/forge-vnext/schemas/forge.evidence-index.v1.schema.json
- docs/forge-vnext/schemas/forge.substitute-evidence.v1.schema.json
- docs/forge-vnext/fixtures/missing-evidence-fail/
- at least two verifier fixture app trees with different .forge/verification-plan.json files
- scripts/forge-vnext-verifier.mjs

Acceptance:
- two fixture apps verify without editing verifier source
- missing required evidence fails
- approved substitute evidence can pass only when indexed with rationale/owner
- reusable verifier source contains no DayRateLab/domain-specific literals
- screenshot requirements are read from/derived through fixture .forge plans, not hardcoded names
```

### Card 4: Implement local launch package + learning schemas

Assignee: `forgelaunch`

Parents: `t_d9a685b2`

Body:

```text
Implement Forge vNext local launch-package and learning-loop contracts. Do not generate a second app and do not touch real App Store/TestFlight/IAP/signing resources.

Inputs:
- docs/forge-vnext/executable-pipeline-integration.md
- docs/forge-vnext/lanes/launch-learning-package.md
- docs/forge-vnext-charter.md

Deliverables:
- docs/forge-vnext/schemas/forge.launch-package.v1.schema.json
- docs/forge-vnext/schemas/forge.privacy-draft.v1.schema.json
- docs/forge-vnext/schemas/forge.pricing-draft.v1.schema.json
- docs/forge-vnext/schemas/forge.pipeline-scorecard.v1.schema.json
- docs/forge-vnext/schemas/forge.postmortem.v1.schema.json
- docs/forge-vnext/schemas/forge.learning-patches.v1.schema.json
- scripts/forge-vnext-launch-package.mjs or validator/generator fixture equivalent
- fixture launch package and learning patch proposals for minimal app-specific pass

Acceptance:
- local launch package validates as app-specific, evidence-linked, and side-effect free
- privacy/pricing/copy/screenshot/TestFlight checklist artifacts are separate
- app score and pipeline score remain separate
- learning patches are proposals only and include human-review requirement
- no live external actions
```

### Card 5: Fan-in validator integration and final audit dry run

Assignee: `forgejudge`

Parents: Cards 1, 2, 3, and 4

Body:

```text
Integrate product, design, verifier, launch, and learning validators into one Forge vNext dry-run gate package. Do not generate a second app.

Inputs:
- outputs from product/design/verifier/launch implementation cards
- docs/forge-vnext/executable-pipeline-integration.md

Deliverables:
- scripts/forge-vnext-final-audit.mjs or equivalent aggregate runner
- docs/forge-vnext/fixtures/README.md documenting expected pass/fail fixtures
- updated docs/forge-vnext/executable-pipeline-integration.md if implementation changes the plan
- final dry-run receipt showing which fixtures fail/pass at which gates

Acceptance:
- bad fixtures fail at expected gates
- minimal app-specific pass fixture passes all local validators
- aggregate report names evidence gaps and repair suggestions
- no second app generation
- blocks for Matvii decision with clear proceed/repair/tighten options
```

Implementation note from fan-in dry run:

- Aggregate runner: `scripts/forge-vnext-final-audit.mjs`
- Fixture matrix docs: `docs/forge-vnext/fixtures/README.md`
- Receipt command: `node scripts/forge-vnext-final-audit.mjs --receipt docs/forge-vnext/final-dry-run-receipt.md`
- The pass fixture now includes a generic `.forge/verification-plan.json` plus `.forge/evidence/evidence-index.json`, so product, design, verifier, and launch-learning validators all pass locally without generating a second app.
- Expected-fail fixtures remain intentionally failing at their configured gates: shallow dashboard (product/design), token reskin (design), missing evidence (verifier), and substitute without owner (verifier).

### Card 6: Matvii decision gate for second-app generation

Assignee: `forgejudge`

Parents: Card 5

Body:

```text
Present the Forge vNext dry-run gate package to Matvii and ask whether to proceed to second-app generation.

Inputs:
- final dry-run receipt from Card 5
- docs/forge-vnext/executable-pipeline-integration.md

Deliverable:
- Kanban block or comment with three decision options: proceed, repair first, tighten bar

Acceptance:
- no second app starts until Matvii explicitly chooses proceed
- if proceed, assign/unblock t_81f3440f or create a replacement second-app card with concrete assignee and updated acceptance bar
```

### Card 7: Generate second proof app from scratch

Assignee: choose after Card 6. Candidate: `default` if it is the implementation-capable profile; otherwise ask Matvii which worker should own generation.

Parents: Card 6 proceed decision

Existing related card: `t_81f3440f` is already present but unassigned. Prefer updating/assigning that card after approval instead of creating a duplicate.

Body additions for `t_81f3440f` when approved:

```text
Use the repaired Forge vNext pipeline and gate package from docs/forge-vnext/executable-pipeline-integration.md.

Before native generation:
- product/taste gate must pass or block for Matvii
- design proof gate must pass or block for Matvii
- .forge/verification-plan.json must exist

Completion bar:
- separate generated app repo outside Forge template
- native Mock build succeeds
- simulator run succeeds
- screenshots/evidence prove activation/core loop/retention or progress/money boundary
- generic verifier passes without source edits
- local launch package exists
- app scorecard + pipeline scorecard + postmortem + learning-patches.json exist
- no template contamination and no generic dashboard/card-shell pass
```

## 9. Gate decision options for Matvii

### Option A: Proceed with pipeline repair now (recommended)

Run Cards 1-5, then stop again for Card 6.

Why:

- matches every lane's suggested next task
- keeps second-app generation blocked until executable gates exist
- proves Forge can fail shallow/generic work before spending native generation effort

Tradeoff:

- slower before the exciting second app
- adds schema/validator work that must stay small to avoid complexity creep

### Option B: Tighten the bar before implementation

Ask one more planning pass to reduce v1 scope and define the absolute minimum schema/check set.

Why:

- reduces risk of overbuilding schemas
- useful if Matvii wants a narrower vNext proof

Tradeoff:

- delays execution
- may repeat decisions already converged across lanes

### Option C: Proceed directly to second app with manual gates

Assign `t_81f3440f` now, but require manual product/design/verifier/launch reviews using the lane docs.

Why:

- fastest path to a visible second app
- useful if momentum matters more than proving automation

Tradeoff:

- not recommended: it risks repeating DayRateLab's failure mode where prose gates look good but executable evidence remains weak
- verifier genericity and launch/learning contracts may remain unproven

## 10. Recommendation

Choose Option A.

Create Cards 1-4 in parallel, then Card 5 as fan-in, then Card 6 as the Matvii decision gate. Keep `t_81f3440f` unassigned until the dry-run gate package proves that shallow product, generic design, missing evidence, and generic launch artifacts fail locally.

## 11. Immediate stop condition

This synthesis is complete when this document exists and the current Kanban task blocks for Matvii's decision. No code implementation, second app generation, or external action should happen in this task.
