# Forge visual judge contract and rubric

Generated: 2026-05-26
Task: `t_2d563b32`
Parent artifact: `docs/forge-vnext/visual-excellence-research-and-judge-layer.md`
Scope: local schema, fixtures, and operating summary only. No native app generation, no paid/account actions, no external mutation.

## Artifact contract

Forge now has two machine-readable visual judge schemas:

- `docs/forge-vnext/schemas/forge.visual-evidence-packet.v1.schema.json` defines the evidence packet consumed by visual judges: safe references, original synthesis, prototype receipt, optional native screenshot/accessibility evidence, and paths to judge outputs.
- `docs/forge-vnext/schemas/forge.visual-judge.v1.schema.json` defines judge output for both stages.

Generated app paths expected by the contract:

```text
.forge/design/visual-evidence-packet.json
.forge/design/references.json
.forge/design/original-synthesis.json
.forge/design/design-system.json
.forge/design/prototype/prototype-receipt.json
.forge/evidence/screenshots/native/{activation,core-loop-after-action,returning-progress,empty-error,money-boundary}.png
.forge/evidence/screenshots/native/accessibility-snapshots/*.json
.forge/evidence/evidence-index.json
.forge/judges/visual-judge-pre-native.json
.forge/judges/visual-judge-post-native.json
```

## Judge stages

1. `pre_native`: runs after reference research, original synthesis, design system, and prototype receipt. It may allow `next_gate: native_expansion`; it does not allow human review because native evidence does not exist yet.
2. `post_native`: runs after simulator screenshots/accessibility snapshots for activation, core loop, returning-progress/progress, empty/error, and money/deferred boundary. It is the only visual judge stage that can set `human_gate_allowed: true`.

## Hard-fail reasons

Any hard fail blocks the next gate even if numeric score is high:

- `missing_references`: fewer than five total references, fewer than three category references, or no credible craft/platform reference.
- `copying_reference`: competitor layout/assets/brand/copy are copied instead of transformed.
- `missing_original_synthesis`: no borrow/avoid/transform logic or no first-screen contract.
- `generic_first_screen`: first screen could become another app by swapping nouns.
- `token_reskin`: Forge template or previous app shape with only colors/copy changed.
- `no_signature_surface`: promised category-specific surface is absent above the fold.
- `prototype_missing`: no local prototype/design receipt before native expansion.
- `native_mismatch`: native screenshots contradict the approved prototype/design system.
- `screenshots_missing`: required native state sequence is missing without approved substitute.
- `empty_shell`: screenshots show placeholder shell, dashboard/table/cards/tabs/settings/auth/onboarding/paywall before first useful loop.
- `stale_residue`: old sample app names, auth/paywall/backend residue, screenshots, or design references leak outside explicit negative-audit context.
- `human_says_slop`: Matvii says “regular AI slop” or equivalent.
- `unsafe_reference_capture`, `paid_or_account_action_required`, `medical_or_financial_claim_creep`: safety-specific blockers.

## Numeric rubric

Pass requires all three:

1. `scores.total >= 80`.
2. Every dimension meets its hard minimum.
3. `hard_fails` is empty.

| Dimension | Max | Hard min |
| --- | ---: | ---: |
| Reference quality and provenance | 12 | 8 |
| Original synthesis | 14 | 10 |
| First-screen product specificity | 14 | 11 |
| Workflow shape | 12 | 9 |
| Native iOS craft | 10 | 7 |
| Visual hierarchy and density | 10 | 7 |
| Emotional tone and copy | 8 | 6 |
| Evidence integrity | 10 | 8 |
| Distinctiveness / non-bullshit | 10 | 8 |

## Fixtures

Pass fixtures:

- `docs/forge-vnext/fixtures/visual-judge-pre-native-pass/.forge/judges/visual-judge-pre-native.json`
- `docs/forge-vnext/fixtures/visual-judge-post-native-pass/.forge/judges/visual-judge-post-native.json`

Fail fixtures:

- `docs/forge-vnext/fixtures/visual-judge-ai-slop-fail/.forge/judges/visual-judge-post-native.json`
- `docs/forge-vnext/fixtures/visual-judge-missing-screenshots-fail/.forge/judges/visual-judge-post-native.json`

The test `tests/forge-visual-judge-contract.test.mjs` verifies the schemas parse, the fixtures use the shared rubric thresholds, pass fixtures clear hard fails, and fail fixtures block both next-gate and human review.

## Operating rule

Build/verifier success is not enough. Forge may request human review only when the post-native visual judge passes, has no hard-fail reasons, has current screenshot/accessibility evidence for the required state sequence, and sets `human_gate_allowed: true`.
