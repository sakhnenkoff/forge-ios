# Forge vNext Lane A: Product/Taste Gate Contracts

Date: 2026-05-25
Task: `t_9c445c70`
Source artifacts:
- `docs/forge-vnext-charter.md`
- `docs/rfcs/2026-05-25-forge-vnext-agentic-product-studio.md`
- `docs/forge-vnext-pipeline-gap-audit.md`

## Purpose

This lane turns Forge vNext's product/taste expectations into executable gate contracts.

The product gate must prevent a coherent idea, dashboard mock, or card shell from being treated as a launchable app. It must force each generated app to prove:

1. a real painful problem;
2. a sharp target user and use case;
3. a repeat-use or retention loop visible in the product;
4. a believable money path;
5. a distinctive app-specific product/design direction;
6. native evidence that the core experience exists;
7. a repair-vs-kill recommendation where Forge recommends and Matvii decides kills.

This artifact is diagnosis/spec work only. It does not generate a second app and does not polish DayRateLab.

## Contract placement

For each generated app repo, Forge should emit:

- Human-readable product/taste contract: `.forge/product-taste-gate.md`
- Machine-readable gate receipt: `.forge/evidence/product-taste-gate-receipt.json`
- Scorecard receipt: `.forge/evidence/app-scorecard.json`
- Coverage matrix: `.forge/evidence/product-coverage-matrix.json`

The human markdown explains judgment and tradeoffs. The JSON receipts are what scripts/verifiers consume before allowing the next phase.

## Gate order

Product/taste checks happen at three moments:

1. Direction gate, before native build:
   - validates pain, target user, use case, retention loop, money thesis, and app-specific taste direction from research/product artifacts.
2. Slice selection gate, before implementation expansion:
   - validates that the planned native slice includes activation, core loop, retention/progress signal, and money boundary where applicable.
3. Native evidence gate, before launch-candidate or final audit claims:
   - validates screenshots/video/tests/receipts against the promised product contract.

No product/taste gate may pass from prose alone. Every pass needs evidence references.

## Non-bullshit app scorecard

Scores are 0-10 integers. `0` means absent or contradicted by evidence. `5` means plausible on paper but not convincingly proven. `8` means strong and specifically evidenced. `10` means exceptional.

Overall score is useful but never sufficient. Hard minimums below override the average.

### Dimensions

#### 1. Pain/problem clarity

Question: Does this app solve a painful, specific problem, not just provide a nice dashboard?

Evidence that can satisfy it:
- research quotes/reviews/forum posts showing pain;
- competitor complaints or paid-app demand;
- user scenario with trigger, cost of doing nothing, and current workaround;
- product spec tying the first useful action to the pain.

Fails if:
- problem is generic productivity/health/finance wording;
- evidence only says users like the category;
- app starts from data cards without a painful trigger;
- the native flow does not address the stated pain.

Hard minimum: 7.

#### 2. Target user sharpness

Question: Can Forge name who this is for and who it is not for?

Evidence that can satisfy it:
- primary user segment with concrete context;
- excluded users/use cases;
- first-run copy that speaks to the segment;
- feature priorities derived from that segment.

Fails if:
- target user is "everyone who wants X";
- persona is demographic fluff without workflow context;
- UI/copy could belong to any app in the category.

Hard minimum: 7.

#### 3. Use-case sharpness and activation

Question: Is there a specific job-to-be-done and can a first-time user reach useful value quickly?

Evidence that can satisfy it:
- activation promise in seconds/minutes;
- first-run simulator evidence or storyboard proving the value path;
- input/output examples;
- clear definition of the first useful result.

Fails if:
- onboarding delays the first useful action without reason;
- value depends on future data that the proof app never creates;
- app opens to a generic home/dashboard before solving anything;
- screenshots do not show the useful result.

Hard minimum: 7.

#### 4. Repeat-use / retention loop

Question: Why would the user come back after the first use?

Evidence that can satisfy it:
- loop definition: trigger -> action -> reward/progress -> next trigger;
- native states showing history/progress/streaks/recommendations/alerts where relevant;
- content/data model that improves or accumulates over time;
- at least one screenshot or video segment proving the returning-user state.

Fails if:
- retention is only "users will check daily";
- app has only one-shot calculation or static cards;
- history/progress/detail surfaces are promised but not evidenced;
- no difference between first session and fifth session is visible.

Hard minimum: 7.

#### 5. Money-path believability

Question: Is there a believable reason someone might pay, subscribe, upgrade, or tolerate another monetization path?

Evidence that can satisfy it:
- competitor pricing/paywall examples;
- paid feature boundary tied to real value;
- local paywall/pro boundary concept if approved for the proof;
- free-vs-paid rationale that does not break trust;
- explicit statement when monetization is intentionally deferred.

Fails if:
- monetization is "could add Pro later";
- paid feature is unrelated to the core pain;
- no competitor/payment evidence exists;
- money path conflicts with user trust and the conflict is not called out.

Hard minimum: 6 for utility/prosumer apps, 7 for apps whose strategy depends on direct revenue, 5 only if Matvii explicitly marks the run as portfolio/learning-first.

#### 6. Product distinctiveness / taste

Question: Does the app feel designed around this problem rather than reskinned from a scaffold?

Evidence that can satisfy it:
- app-specific emotional tone;
- design principles tied to product behavior;
- distinctive workflow shape, interaction model, copy, empty states, motion/haptics, or visual system;
- native screenshot review against the app-specific design acceptance criteria.

Fails if:
- distinctiveness is only colors/typography on standard cards;
- default scaffold/dashboard/card layout dominates without product justification;
- copy is generic AI/productivity phrasing;
- native evidence is weaker than the HTML/design artifact.

Hard minimum: 7.

#### 7. Blueprint coverage / launch-slice integrity

Question: Does the implemented slice cover the minimum product loop needed for honest launch-candidate claims?

Evidence that can satisfy it:
- coverage matrix linking required product surfaces to native evidence;
- explicit list of intentionally not built surfaces and launch impact;
- screenshots/video covering activation, core loop, retention/progress, and money boundary where applicable;
- final audit agreement that omissions do not invalidate the claim.

Fails if:
- only dashboard + list/cards are implemented;
- important promised surfaces are omitted without launch impact;
- handoff says missing screenshots/features are required while final claim says success;
- implementation contradicts `.forge/spec.json`, product strategy, or activation artifact.

Hard minimum: 8.

#### 8. Evidence integrity

Question: Can the score be audited from artifacts without trusting the agent's prose?

Evidence that can satisfy it:
- every claim has evidence IDs and paths;
- missing evidence has a reason and substitute;
- receipts are internally consistent;
- verifier checks pass or explicitly fail with repair plan.

Fails if:
- product claims cite only markdown prose;
- screenshots are absent/stale/not tied to surfaces;
- receipt state contradicts progress or handoff docs;
- final audit has no app-vs-pipeline score separation.

Hard minimum: 8.

## App score vs pipeline score fields relevant to product

Forge must score the app and the Forge pipeline separately.

### App score fields

These judge the generated app itself:

- `pain_problem_clarity`
- `target_user_sharpness`
- `use_case_activation`
- `repeat_use_retention_loop`
- `money_path_believability`
- `product_distinctiveness_taste`
- `blueprint_coverage_launch_slice_integrity`
- `native_product_evidence_quality`
- `launch_candidate_honesty`

The app score answers: "Is this a non-bullshit app worth repairing, killing, or preparing for launch?"

### Pipeline score fields relevant to product

These judge whether Forge's process created and enforced the product/taste bar:

- `research_to_product_traceability`: product claims trace to research evidence.
- `gate_executability`: gate emitted required JSON/markdown receipts, not prose-only approval.
- `slice_selection_discipline`: implementation scope matched the launch bar and did not hide missing critical surfaces.
- `repair_loop_quality`: weak dimensions produced focused repair options, not vague TODOs.
- `taste_enforcement`: scaffold/card/dashboard defaults were rejected unless justified by the app.
- `evidence_consistency`: specs, receipts, screenshots, handoff, and final audit did not contradict each other.
- `human_decision_hygiene`: kill decisions and major tradeoffs were escalated to Matvii with options.
- `learning_patch_quality`: product/taste lessons became reviewable Forge learning patches.

The pipeline score answers: "Did Forge act like a product studio rather than a code generator?"

## Hard minimums

A generated app cannot pass the product/taste gate unless all hard minimums are met.

### Direction gate hard minimums

- `pain_problem_clarity >= 7`
- `target_user_sharpness >= 7`
- `use_case_activation >= 7`
- `repeat_use_retention_loop >= 7`
- `money_path_believability >= configured_minimum`
- `product_distinctiveness_taste >= 7`
- At least 2 independent demand/pain evidence types, unless the receipt marks low-confidence and requests Matvii's decision.
- Explicit excluded-user or excluded-use-case statement.
- Explicit revenue-vs-taste tradeoff if present.

### Slice selection gate hard minimums

- Planned native slice includes activation, core loop, returning-user/progress state, and money boundary or approved monetization deferral.
- Every required blueprint surface is marked one of: `native_required_now`, `prototype_only`, `deferred_non_blocking`, `deferred_blocks_launch`, `not_applicable`.
- Any `deferred_blocks_launch` item forces verdict `repair` or `ask`, never `pass`.
- Implementation plan includes proof artifacts for each `native_required_now` surface.

### Native evidence gate hard minimums

- `blueprint_coverage_launch_slice_integrity >= 8`
- `evidence_integrity >= 8`
- At least one first-use activation evidence item.
- At least one core-loop evidence item.
- At least one returning-user/progress/retention evidence item.
- Money boundary evidence or an approved monetization deferral.
- No unresolved contradictions between product artifact, spec, native screenshots/video, and handoff.

## Verdict thresholds

Use these default thresholds unless an app-specific contract raises them.

- `pass_to_next_phase`: all hard minimums met and weighted overall score >= 7.5.
- `repair`: at least one hard minimum failed, or weighted overall score between 5.5 and 7.49, and repair options are concrete.
- `ask_matvii`: evidence is weak/conflicted, revenue-vs-taste tradeoff is meaningful, or kill is plausible.
- `kill_recommended`: painful problem, retention loop, or money path appears structurally weak after up to two repair loops.
- `launch_candidate`: all native evidence hard minimums met, weighted overall score >= 8, and no `deferred_blocks_launch` surfaces remain.

Only Matvii can choose `kill`. Forge may only set `recommendation.type = "kill_recommended"` and provide evidence/options.

## Repair-vs-kill recommendation format

Every failed product/taste gate must produce this recommendation block in markdown and JSON.

Human-readable format:

```md
## Recommendation

Verdict: repair | ask_matvii | kill_recommended
Confidence: low | medium | high

Why:
- [evidence-backed reason]

Failed hard minimums:
- [dimension]: score [n]/10, minimum [m]/10, evidence [ids]

Repair options:
1. [smallest repair] — expected lift, cost, risk, evidence required
2. [stronger repair] — expected lift, cost, risk, evidence required

Kill case:
- Why this might not be worth repairing.
- What would have to become true to revisit it.

Matvii decision needed:
- approve repair option 1
- approve repair option 2
- kill idea
- override and continue with explicit risk
```

Machine-readable shape:

```json
{
  "recommendation": {
    "type": "repair",
    "confidence": "medium",
    "summary": "Retention loop is plausible but not evidenced in native state.",
    "failed_hard_minimums": [
      {
        "dimension": "repeat_use_retention_loop",
        "score": 5,
        "minimum": 7,
        "evidence_ids": ["product.retention_loop", "native.screens.today"],
        "failure_mode": "Returning-user state is promised but absent from native evidence."
      }
    ],
    "repair_options": [
      {
        "id": "repair_retention_state",
        "title": "Add native returning-user/progress state proof",
        "scope": "small",
        "expected_score_lift": { "repeat_use_retention_loop": 2, "blueprint_coverage_launch_slice_integrity": 1 },
        "cost": "1 implementation slice + screenshot/video update",
        "risk": "May reveal the concept is too thin for repeat use.",
        "required_evidence": ["native.returning_user_screenshot", "product.coverage_matrix_update"]
      }
    ],
    "kill_case": {
      "why_kill_may_be_right": "If users only need a one-shot calculation, the app may not justify a standalone product.",
      "revisit_if": "Research finds recurring trigger or paid workflow."
    },
    "matvii_decision_required": true,
    "allowed_decisions": ["repair_option", "kill", "override_continue_with_risk"]
  }
}
```

## Required machine-readable gate receipt fields

`product-taste-gate-receipt.json` must include these fields.

```json
{
  "schema_version": "forge.product_taste_gate.v1",
  "app": {
    "id": "kebab-case-app-id",
    "name": "Human App Name",
    "repo_path": "../generated-apps/app-name",
    "run_id": "forge-run-id"
  },
  "gate": {
    "name": "product_taste",
    "stage": "direction | slice_selection | native_evidence | final_audit",
    "created_at": "ISO-8601 timestamp",
    "created_by": "agent/profile name",
    "verdict": "pass | repair | ask_matvii | kill_recommended | launch_candidate_blocked | launch_candidate",
    "confidence": "low | medium | high"
  },
  "source_artifacts": [
    {
      "id": "product.strategy",
      "path": ".forge/product-strategy.md",
      "kind": "markdown",
      "hash": "sha256-if-available"
    }
  ],
  "evidence_index": [
    {
      "id": "native.activation.video",
      "path": ".forge/evidence/videos/activation.mp4",
      "kind": "video",
      "proves": ["use_case_activation"],
      "status": "present | missing | substitute | stale",
      "notes": "Shows first useful result within activation promise."
    }
  ],
  "scores": {
    "scale": "0-10 integer",
    "weighted_overall": 7.8,
    "dimensions": {
      "pain_problem_clarity": {
        "score": 8,
        "minimum": 7,
        "weight": 1.2,
        "evidence_ids": ["research.review_quotes", "product.problem_statement"],
        "rationale": "Specific painful trigger and current workaround are evidenced."
      },
      "target_user_sharpness": {
        "score": 7,
        "minimum": 7,
        "weight": 1.0,
        "evidence_ids": [],
        "rationale": ""
      },
      "use_case_activation": {
        "score": 7,
        "minimum": 7,
        "weight": 1.2,
        "evidence_ids": [],
        "rationale": ""
      },
      "repeat_use_retention_loop": {
        "score": 7,
        "minimum": 7,
        "weight": 1.2,
        "evidence_ids": [],
        "rationale": ""
      },
      "money_path_believability": {
        "score": 6,
        "minimum": 6,
        "weight": 1.0,
        "evidence_ids": [],
        "rationale": ""
      },
      "product_distinctiveness_taste": {
        "score": 7,
        "minimum": 7,
        "weight": 1.0,
        "evidence_ids": [],
        "rationale": ""
      },
      "blueprint_coverage_launch_slice_integrity": {
        "score": 8,
        "minimum": 8,
        "weight": 1.3,
        "evidence_ids": [],
        "rationale": ""
      },
      "evidence_integrity": {
        "score": 8,
        "minimum": 8,
        "weight": 1.3,
        "evidence_ids": [],
        "rationale": ""
      }
    },
    "hard_minimum_failures": []
  },
  "hard_minimums": {
    "demand_evidence_types_count": 2,
    "required_demand_evidence_types_count": 2,
    "has_excluded_user_statement": true,
    "has_revenue_taste_tradeoff_statement": true,
    "activation_evidence_present": true,
    "core_loop_evidence_present": true,
    "retention_evidence_present": true,
    "money_boundary_evidence_present_or_deferred_by_approval": true,
    "contradictions_unresolved": []
  },
  "coverage_matrix_ref": ".forge/evidence/product-coverage-matrix.json",
  "recommendation": {
    "type": "pass",
    "confidence": "medium",
    "summary": "All hard minimums met.",
    "failed_hard_minimums": [],
    "repair_options": [],
    "kill_case": null,
    "matvii_decision_required": false,
    "allowed_decisions": []
  },
  "human_decision": {
    "required": false,
    "reason": null,
    "status": "not_required | pending | approved | rejected | overridden",
    "decision_by": null,
    "decision_at": null,
    "decision_artifact": null
  },
  "next_allowed_actions": [
    "proceed_to_design_gate"
  ]
}
```

### Validation rules for receipts

A validator should reject the receipt when:

- any dimension is missing score, minimum, evidence IDs, or rationale;
- any score is outside 0-10 or non-integer;
- any hard minimum failure exists while verdict is `pass` or `launch_candidate`;
- `kill_recommended` has `human_decision.required = false`;
- any `evidence_index.status = "missing"` is used as proof for a passing hard minimum;
- source artifacts do not exist;
- `coverage_matrix_ref` does not exist at native evidence/final audit stages;
- contradictions are unresolved while verdict is passing.

## Product coverage matrix

`product-coverage-matrix.json` maps promised product surfaces to proof.

```json
{
  "schema_version": "forge.product_coverage_matrix.v1",
  "app_id": "kebab-case-app-id",
  "surfaces": [
    {
      "id": "activation.first_use",
      "name": "First useful result",
      "product_role": "activation",
      "required_status": "native_required_now",
      "source_refs": [".forge/product-strategy.md#activation"],
      "native_evidence_ids": ["native.activation.video", "native.activation.screenshot"],
      "prototype_evidence_ids": ["prototype.activation.flow"],
      "launch_impact_if_missing": "blocks_launch_candidate",
      "status": "proven | missing | prototype_only | deferred_non_blocking | deferred_blocks_launch | not_applicable",
      "notes": ""
    },
    {
      "id": "retention.returning_user",
      "name": "Returning-user progress state",
      "product_role": "retention",
      "required_status": "native_required_now",
      "source_refs": [".forge/product-strategy.md#retention-loop"],
      "native_evidence_ids": [],
      "prototype_evidence_ids": [],
      "launch_impact_if_missing": "blocks_launch_candidate",
      "status": "missing",
      "notes": ""
    },
    {
      "id": "money.pro_boundary",
      "name": "Free/paid boundary",
      "product_role": "monetization",
      "required_status": "native_required_now | deferred_non_blocking | not_applicable",
      "source_refs": [".forge/product-strategy.md#money-path"],
      "native_evidence_ids": [],
      "prototype_evidence_ids": [],
      "launch_impact_if_missing": "blocks_launch_candidate | non_blocking_with_approval",
      "status": "missing",
      "notes": ""
    }
  ],
  "required_roles": ["activation", "core_loop", "retention", "monetization_or_approved_deferral"],
  "missing_blockers": ["retention.returning_user"]
}
```

## Evidence that blocks a shallow dashboard/card shell from passing

A dashboard/card shell is any app whose native proof mainly shows static overview cards, generic segmented tabs, lists, or charts without proving the user's job, loop, and consequence.

The gate blocks this by requiring these evidence classes:

1. First-use activation evidence:
   - screenshot/video from cold start or first meaningful flow;
   - shows the input/action and the first useful output;
   - tied to the painful problem.

2. Core-loop evidence:
   - shows the repeatable action the user performs;
   - includes at least one state transition, not only a static result card;
   - demonstrates the product's main mechanic.

3. Returning-user or progress evidence:
   - history, progress, learned personalization, streak, queue, saved item, next recommendation, reminder, or equivalent;
   - proves the app is not only a one-shot calculator or landing page.

4. Money-boundary evidence or approved deferral:
   - shows what is free vs paid/pro/upgrade-worthy, or records Matvii-approved deferral;
   - cannot be a vague "add Pro later" note.

5. Product-specific taste evidence:
   - native screenshot review says what is app-specific about the workflow, copy, visual system, and interactions;
   - rejects generic card/dashboard defaults unless the app's use case specifically needs them.

6. Coverage matrix evidence:
   - every promised surface in product/design/spec artifacts is mapped to native proof, prototype-only proof, deliberate deferral, or not-applicable status;
   - `deferred_blocks_launch` prevents launch-candidate verdict.

### Automatic shallow-shell blockers

Any of these force verdict `repair` or `ask_matvii`:

- The only native screenshots are dashboard/list/card overview states.
- No evidence shows first useful result.
- No evidence shows a returning-user/progress state.
- Pro/paywall/money path is mentioned in copy but absent from evidence and not explicitly deferred by Matvii.
- The app-specific design rationale could apply unchanged to another generated app.
- Handoff says important screenshots/features remain TODO while final audit claims launch-candidate readiness.
- `.forge/spec.json` or product strategy lists required surfaces that do not appear in the coverage matrix.
- Final app score is high while one critical dimension is below its hard minimum.

## Implementation worker checklist

When implementing this lane in Forge scripts/prompts, do this in order:

1. Add product/taste gate artifact generation to the product strategy phase.
2. Add receipt validation before design/native phases can continue.
3. Add coverage matrix generation before native implementation scope is accepted.
4. Add native evidence validation before launch package or final audit can claim launch-candidate status.
5. Add scorecard separation: app product score vs pipeline product-enforcement score.
6. Add repair-vs-kill recommendation generation for every failed hard minimum.
7. Ensure any `kill_recommended` verdict blocks automation and asks Matvii.

## Suggested next task

Implement the schema/validator skeleton for this lane:

- Create JSON schema files for:
  - `forge.product_taste_gate.v1`
  - `forge.product_coverage_matrix.v1`
  - `forge.app_scorecard.v1`
- Add a local validator script that fails on shallow-shell blockers and hard-minimum violations.
- Wire the validator into the pre-native and pre-launch gate flow without generating a new app.

## Open risks

- Score thresholds can become performative if evidence quality is weak; validators must check evidence existence and role coverage, not just numbers.
- The money-path minimum may need app-category-specific presets; early runs should allow Matvii-approved monetization deferral but record the risk.
- Taste remains partly subjective; the contract reduces hand-waving but still needs human review for major design/product direction calls.
- Overly strict gates can stall exploration; repair loops should be capped at two before asking Matvii, matching the charter.
- Receipt schemas should avoid becoming DayRate-specific; implementation must use generated app IDs, surface roles, and evidence IDs rather than domain literals.
