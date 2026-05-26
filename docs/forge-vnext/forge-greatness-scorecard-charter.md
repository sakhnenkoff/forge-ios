# Forge Greatness Scorecard and Operating Charter

Status: vNext operating bar before more app generation.
Scope: defines what "Forge is super great" means. This charter scores the generated app and the Forge pipeline separately; neither score may hide the other.

## 1. North-star definition

Forge is super great when it can repeatedly produce a launch-candidate native iOS app from a researched direction, with app-specific taste, local evidence, launch packaging, and honest failure/learning loops — without stale sample-app contamination, template leakage, fake human gates, or self-reported proof.

Generated apps are evidence. The pipeline is the product.

## 2. 10-point scorecard

Use two scores every time:

- App quality score: "Did this specific app deserve to exist and feel native/tasteful?"
- Pipeline quality score: "Did Forge reliably force the right work, evidence, failures, and learning?"

A run is not allowed to average these into one hidden grade. Report both as `app_score / 10` and `pipeline_score / 10` plus hard-fail status.

### 2.1 App quality score: 10 points

| Points | Dimension | Hard minimum | Evidence required |
| --- | --- | --- | --- |
| 2.0 | Product pain and target sharpness | >= 1.5 | Specific painful job, excluded non-users, credible source/evidence matrix, not a vague productivity/dashboard idea. |
| 1.5 | Activation and core loop | >= 1.0 | First useful moment, repeated action loop, saved/returning state where relevant, screenshots or prototype receipt. |
| 1.5 | Taste and design | >= 1.0 | App-specific emotional tone, original reference synthesis, design system/prototype, native screenshots matching the contract. |
| 1.5 | Native implementation craft | >= 1.0 | Separate native app repo/path, SwiftUI/architecture rules followed, mock build target, no template/sample-app contamination. |
| 1.0 | Evidence-backed monetization or explicit deferral | >= 0.5 | Money boundary, pricing/paywall hypothesis, or explicit accepted deferral tied to evidence. |
| 1.0 | Launch readiness | >= 0.5 | Local copy/privacy/pricing/screenshot/TestFlight checklist draft linked to app evidence. |
| 1.5 | Distinctiveness and non-bullshit factor | >= 1.0 | Judge says it is not a generic card shell, token reskin, static mockup, or scaffold pretending to be a product. |

App verdicts:

- 9.0-10.0: launch-candidate app, subject to human external-action approval.
- 8.0-8.9: credible proof app; launch needs focused repairs.
- 7.0-7.9: learning-quality app; pipeline may pass if it detected the weakness honestly.
- < 7.0: app failed; use only for learning and repair.

### 2.2 Pipeline quality score: 10 points

| Points | Dimension | Hard minimum | Evidence required |
| --- | --- | --- | --- |
| 1.5 | Research and direction pressure | >= 1.0 | Multiple directions considered, gaps named, weak directions killed/repair-routed before native work. |
| 1.5 | Gate clarity and enforcement | >= 1.0 | Product/design/native/verifier/launch/learning gates emit markdown plus machine-readable artifacts. |
| 1.0 | Design gate actually blocks bad design | >= 0.75 | Token-reskin/generic-dashboard failure paths exist; prototype/design receipt required before native expansion. |
| 1.5 | Generic verifier reliability | >= 1.0 | Build/test/run/screenshots/evidence index checked by app-agnostic scripts/plans; no domain literals in reusable verifier source. |
| 1.0 | Native repo isolation and hygiene | >= 0.75 | Generated app separate from Forge template; no stale sample-app residue; no unreviewed irreversible cleanup. |
| 1.0 | Launch package discipline | >= 0.75 | Local-only ASC/privacy/pricing/copy/screenshot artifacts; no live external action without approval. |
| 1.0 | Operator UX and Kanban flow | >= 0.75 | Workers stop only at real gates, blockers are classified/routed, handoffs are compact and actionable. |
| 1.5 | Learning loop quality | >= 1.0 | Postmortem, evidence gaps, proposed learning patches, and judge decision are recorded without silently mutating the pipeline. |

Pipeline verdicts:

- 9.0-10.0: repeatable product-studio pipeline; ready to run another app with less supervision.
- 8.0-8.9: acceptable vNext proof pipeline; proceed only through named human gates.
- 7.0-7.9: useful but still fragile; run repair cards before more app generation unless Matvii explicitly accepts risk.
- < 7.0: pipeline failed; no new app generation.

## 3. Hard fail criteria

Any item below forces `hard_fail: true` regardless of numeric score.

### Product pain

- No sharp target user, painful job, or specific use case.
- App idea is a generic dashboard, tracker, wrapper, or "AI helper" without a repeated painful moment.
- Money path is absent and no explicit approved deferral exists.
- Research/evidence is only agent opinion or circular self-report.

### Taste and design

- Token-only reskin of template components.
- Generic cards/lists/charts with no app-specific workflow shape.
- Prototype/design receipt missing before native expansion.
- Native screenshots contradict the approved design contract.
- Copy, empty states, or emotional tone are generic SaaS filler.
- Human visual verdict says “regular AI slop” or equivalent; this is an automatic design hard fail, not a polish note.

### Visual inspiration and judge layer

- No external visual inspiration/research packet from high-quality apps, patterns, and product references.
- No original synthesis explaining what to borrow, what to avoid, and why it fits the app’s product loop.
- No dedicated visual judge pass before native expansion and again after native screenshots.
- No human-readable comparison between reference quality bar and generated screenshots.

### Native implementation

- App is generated inside/over the Forge template instead of a separate app repo/path.
- Stale sample-app names, assumptions, screenshots, launch copy, verifier literals, or design references appear outside explicit negative-audit context.
- App is static docs/mockup only; activation/core loop/returning state is not implemented where required.
- Mock build cannot be produced or native evidence is missing.

### Verifier evidence

- Claims are not backed by `.forge/evidence/evidence-index.json` or equivalent indexed local evidence.
- Reusable verifier needs app-specific source edits to pass.
- Screenshot/video/build/test/run evidence is missing and no approved substitute is indexed.
- Evidence was captured from an old/stale app state and reused as if current.

### Launch package

- Privacy/pricing/copy/screenshot plan is generic or unsupported by app evidence.
- Any live App Store Connect, TestFlight, signing, IAP, analytics, public posting, paid tool, or account action is attempted without Matvii approval.
- Launch package hides gaps instead of naming them.

### Operator UX

- Workers block for vague "review" when a verifier/judge gate exists.
- Workers proceed through a real human gate without approval.
- App score and pipeline score are merged into one number.
- Blocked cards are reported as status only and not classified/routed into repair, pipeline bug, worker error, dependency shape bug, or real human gate.

## 4. Autonomy rules

Agents may autonomously:

1. Research public/read-only sources and local artifacts.
2. Produce product/design/verifier/launch/learning artifacts under `docs/forge-vnext/` or generated app `.forge/` directories.
3. Run local validators, tests, builds, simulator runs, screenshots, and evidence indexing.
4. Create Kanban repair/judge/verifier cards for mechanical failures.
5. Fail, repair-route, or kill weak directions before native generation.
6. Preserve evidence and write postmortems/learning-patch proposals.

Agents must stop and ask Matvii before:

1. Generating a new native proof app from an approved direction if the preceding direction gate asks for taste/product approval.
2. Any public/external/account/money/App Store/TestFlight/signing/IAP/paid-tool/credential action.
3. Deleting or irreversibly moving repos/apps/artifacts; use scoped review and recoverable deletion when cleanup is approved.
4. Accepting final "Forge is super great" status or interview-level claim.
5. Overriding a judge on product taste, strategy, or launch readiness.
6. Applying pipeline learning patches that materially change future behavior, unless the task explicitly grants that scope.

## 5. Exact next human gates

Current state: local Forge vNext contracts, fixtures, validators, and evidence receipts exist; no new app generation should happen until the next gate is answered.

Gate A — Proceed to second proof app direction:

- Question: accept the current local dry-run bar and continue from the approved/recommended app direction research?
- Options: `proceed`, `repair`, or `tighten`.
- Default if unanswered: `repair/tighten`; do not generate a new app.
- Required packet: final dry-run receipt, app-direction research gate, known evidence gaps.

Gate B — Direction approval before native generation:

- Question: is the selected app direction tasteful and strategically worth a native proof attempt?
- Options: `approve_direction`, `revise_direction`, `kill_direction`.
- Default if unanswered: block native generation.
- Required packet: target user, painful job, use case, activation/core loop, retention/progress, money boundary, research gaps, product/taste score.

Gate C — External/launch action approval:

- Question: may Forge use any live external surface such as TestFlight, App Store Connect, signing, IAP, analytics, paid tools, posting, or accounts?
- Options: explicit per-action approval only.
- Default if unanswered: local-only artifacts.
- Required packet: exact action, account/surface, reversibility, cost/risk, local evidence already produced.

Gate D — Final greatness claim:

- Question: does Matvii accept that Forge has reached the "super great" / interview-level bar?
- Options: `accept_greatness`, `repair_pipeline`, `repair_app`, `run_another_trial`.
- Default if unanswered: do not claim done.
- Required packet: app scorecard, pipeline scorecard, hard-fail list, verifier evidence index, launch package, postmortem, learning-patch decisions, skeptical judge verdict.

## 6. Operating rule for the next run

Before any more app generation, the orchestrator must attach this charter to the gate packet and require:

- app score and pipeline score reported separately;
- hard-fail checklist completed;
- exact human gate named, not a vague review request;
- no stale sample-app-derived direction/design/verifier/launch assumptions;
- no code generation until Gate A and Gate B both pass for the selected direction.
