# Forge vNext Lane B: Design / Look-Feel Gate System

Date: 2026-05-25
Kanban: `t_dfbdea2a`
Scope: diagnosis/spec only. Do not generate the second app. Do not polish DayRateLab.

## Objective

Define executable design gates so generated apps cannot pass with scaffold reskins, generic card dashboards, or cosmetic token swaps.

This lane converts the Forge vNext charter design rules into implementation-ready gate contracts. Design is treated as a hard product gate: Swift work may not expand until the app has an app-specific visual/product concept, a clickable proof, and screenshot evidence that matches the concept.

## Inputs this contract assumes

Each generated app run must already have, or produce before this lane starts:

- `.forge/spec.json` — app identity, target user, core workflow, screens, monetization boundary, launch bar.
- `.forge/product-strategy.md` or equivalent — problem, user, repeat-use loop, core promise, app-specific success criteria.
- `.forge/evidence/research.md` or equivalent — market/user references that inform the product direction.

If these are missing, the design lane must block with `missing-prerequisite` instead of inventing product direction.

## Required artifacts

The design lane must emit both human-readable markdown and machine-checkable JSON. Markdown explains taste and rationale. JSON lets future validators reject missing or weak artifacts.

Recommended artifact tree inside each generated app repo:

```text
.forge/design/
  references.md
  references.json
  synthesis.md
  synthesis.json
  emotional-tone.md
  emotional-tone.json
  design-system.md
  design-system.json
  prototype/
    index.html
    prototype-notes.md
    prototype-receipt.json
  screenshot-review.md
  screenshot-review.json
  motion-haptics.md
  motion-haptics.json
  design-gate-receipt.json
```

Forge may place richer visual assets under `.forge/design/assets/`, but the artifacts above are the minimum gate surface.

## Gate order

The order is mandatory because each gate feeds the next one.

1. Product-design handshake gate
2. References + original synthesis gate
3. Emotional tone gate
4. Custom design-system-per-app gate
5. HTML/clickable prototype gate
6. Native screenshot review gate
7. Motion/haptics gate
8. Generic UI rejection gate
9. Final design gate receipt

A later gate may not pass if any earlier gate is missing, failed, or stale relative to `.forge/spec.json`.

## 1. Product-design handshake gate

Purpose: prove the design direction is derived from the app’s product logic, not from the default scaffold.

Required artifact: `.forge/design/design-gate-receipt.json` starts with a `product_design_handshake` section.

Required fields:

```json
{
  "product_design_handshake": {
    "app_name": "string",
    "target_user": "string",
    "core_workflow": "string",
    "core_emotional_job": "string",
    "repeat_use_moment": "string",
    "monetization_boundary": "string | null",
    "launch_bar": ["string"],
    "design_implications": [
      {
        "product_fact": "string",
        "design_consequence": "string",
        "must_show_in_screen_or_flow": "string"
      }
    ]
  }
}
```

Pass criteria:

- Names a sharp user, workflow, emotional job, and repeat-use moment.
- Includes at least 5 `design_implications` mapping product facts to visible UI decisions.
- Includes at least 1 implication for activation, 1 for retention/repeat use, and 1 for money/paywall boundary when monetization exists.
- Uses concrete product language from the app spec, not generic terms like “modern dashboard”, “clean cards”, or “simple tracker”.

Fail examples:

- “The app should feel clean and premium.”
- “Use cards to show the main data.”
- “Dashboard with insights, history, and settings.”

## 2. References + original synthesis gate

Purpose: let references sharpen taste without copying another app or defaulting to scaffold UI.

Required artifacts:

- `.forge/design/references.md`
- `.forge/design/references.json`
- `.forge/design/synthesis.md`
- `.forge/design/synthesis.json`

### References contract

Minimum references:

- 3 visual/product references total.
- At least 1 Apple-native or iOS interaction reference.
- At least 1 category/product reference from the app’s domain or adjacent workflow.
- At least 1 emotional/brand/atmosphere reference outside the direct category.

`references.json` schema:

```json
{
  "references": [
    {
      "name": "string",
      "type": "ios_native | category | emotional | interaction | visual_system",
      "source": "url | app_name | local_screenshot_path",
      "why_relevant": "string",
      "borrow": ["specific traits to learn from"],
      "do_not_copy": ["specific traits to avoid copying"],
      "risk_if_overused": "string"
    }
  ]
}
```

Pass criteria:

- Every reference has `borrow`, `do_not_copy`, and `risk_if_overused`.
- Borrowed traits are specific: e.g. “one-thumb bottom commitment action with immediate state change”, not “nice UX”.
- At least 5 total `do_not_copy` constraints exist across the set.
- References are tied to the product-design handshake.

### Original synthesis contract

`synthesis.md` must answer:

- What is the new original design idea for this app?
- What is the visible metaphor or interaction shape?
- What makes it not a copy of any reference?
- Which default Forge/scaffold patterns are intentionally rejected?
- Which screen or flow best proves the idea?

`synthesis.json` schema:

```json
{
  "original_synthesis": {
    "one_sentence_direction": "string",
    "core_metaphor_or_shape": "string",
    "signature_interactions": ["string"],
    "signature_surfaces": ["string"],
    "reference_synthesis": [
      {
        "from_reference": "string",
        "trait": "string",
        "transformed_into": "string"
      }
    ],
    "explicitly_rejected_patterns": ["string"],
    "proof_screen_or_flow": "string"
  }
}
```

Pass criteria:

- Includes at least 3 transformed reference traits.
- Includes at least 3 explicitly rejected patterns.
- Names one proof screen/flow that will appear in the HTML prototype and native screenshot review.
- The synthesis cannot be satisfied by changing colors, typography, corner radius, or card shadows alone.

## 3. Emotional tone gate

Purpose: define the feeling of using the app so builders have a taste target beyond tokens.

Required artifacts:

- `.forge/design/emotional-tone.md`
- `.forge/design/emotional-tone.json`

`emotional-tone.md` required sections:

```markdown
# Emotional Tone

## Mood sentence
[One sensory/emotional sentence. Banned words: clean, modern, simple, sleek, intuitive unless qualified by concrete imagery.]

## Session arc
- Open: [what the user should feel in the first 5 seconds]
- Act: [what the core interaction should feel like]
- Return: [why coming back feels rewarding]
- Close: [what emotional residue remains]

## Voice and copy posture
[3-5 rules for labels, empty states, nudges, paywall boundary]

## Anti-tone
[3-5 things the app must not feel like]
```

`emotional-tone.json` schema:

```json
{
  "emotional_tone": {
    "mood_sentence": "string",
    "session_arc": {
      "open": "string",
      "act": "string",
      "return": "string",
      "close": "string"
    },
    "voice_rules": ["string"],
    "anti_tone": ["string"],
    "screens_that_must_express_tone": ["string"]
  }
}
```

Pass criteria:

- Mood sentence is specific enough that two unrelated apps would not share it.
- Session arc maps to actual screens/flows in `.forge/spec.json`.
- Anti-tone includes at least one rejection of generic dashboard/card/admin-panel feel.
- Copy posture includes empty-state behavior because empty states are a high-signal design surface.

## 4. Custom design-system-per-app gate

Purpose: define the custom design-system-per-app contract and ensure the generated app has an app-specific design system based on product logic, not the reusable Forge scaffold with new colors.

Required artifacts:

- `.forge/design/design-system.md`
- `.forge/design/design-system.json`

The design system must define decisions in these layers:

1. Design principles
2. Semantic color roles
3. Type scale and text personality
4. Layout/grid/screen composition
5. Components and component behavior
6. Icon/illustration/data-visual language
7. Empty/error/loading states
8. Copy tone
9. Accessibility constraints
10. App-specific banned components/patterns

`design-system.json` schema:

```json
{
  "design_system": {
    "principles": [
      {
        "name": "string",
        "why": "string",
        "visible_consequence": "string"
      }
    ],
    "tokens": {
      "colors": [
        {
          "role": "string",
          "value": "hex | system_color | dynamic_pair",
          "usage": "string",
          "product_rationale": "string"
        }
      ],
      "typography": [
        {
          "role": "string",
          "style": "string",
          "usage": "string",
          "product_rationale": "string"
        }
      ],
      "spacing_and_shape": [
        {
          "role": "string",
          "value": "string",
          "usage": "string",
          "product_rationale": "string"
        }
      ]
    },
    "components": [
      {
        "name": "string",
        "purpose": "string",
        "states": ["default", "pressed", "loading", "empty", "error"],
        "must_differ_from_scaffold_by": ["string"],
        "usage_rules": ["string"]
      }
    ],
    "screen_composition_rules": ["string"],
    "empty_error_loading_rules": ["string"],
    "accessibility_rules": ["string"],
    "banned_patterns": ["string"]
  }
}
```

Pass criteria:

- At least 4 principles, each with a visible consequence.
- At least 8 app-specific components or component variants.
- At least 5 components must differ by structure/behavior, not just color/token values.
- At least 5 banned patterns, including explicit scaffold/card-dashboard bans unless justified by the app.
- Empty, error, and loading states have app-specific copy or composition rules.
- Accessibility rules include contrast, Dynamic Type/text scaling, motion reduction, and VoiceOver labels for the core flow.

Hard rejection:

- A design system made only of palette, typography, spacing, and generic buttons/cards fails.
- A design system that can apply unchanged to DayRateLab and the next app fails.
- A design system that requires `DSScreen`, `DSButton`, or generic `Card` everywhere without app-specific wrappers/variants fails.

Implementation-worker note:

- Reusable Forge primitives are allowed as under-the-hood building blocks.
- The visible API used by generated app screens should be app-specific wrappers/variants where identity matters, e.g. `RitualCheckInStrip`, `SignalTimeline`, `DecisionDeck`, not only `DSCard` with different colors.

## 5. HTML/clickable prototype gate

Purpose: prove the app’s look, flow, and interaction shape before native Swift expansion.

Required artifacts:

- `.forge/design/prototype/index.html`
- `.forge/design/prototype/prototype-notes.md`
- `.forge/design/prototype/prototype-receipt.json`

Prototype requirements:

- Local, static, no external network dependency.
- Clickable through at least the activation moment and one core repeat-use loop.
- Shows at least 3 app states: first-run/activation, active/core loop, empty/error/edge or paywall boundary.
- Expresses the emotional tone and original synthesis visibly.
- Uses realistic copy/data from product strategy, not lorem ipsum.
- Mobile viewport first; desktop rendering is optional.

`prototype-receipt.json` schema:

```json
{
  "prototype": {
    "entry_file": ".forge/design/prototype/index.html",
    "viewports_tested": ["iPhone 17 Pro", "iPhone SE or compact width"],
    "flows": [
      {
        "name": "string",
        "steps": ["string"],
        "product_gate_covered": "activation | core_loop | retention | monetization | empty_error"
      }
    ],
    "screens_or_states": [
      {
        "name": "string",
        "what_it_proves": "string",
        "design_artifacts_expressed": ["synthesis", "emotional_tone", "design_system"]
      }
    ],
    "known_limitations": ["string"],
    "human_review_recommendation": "approve | repair | reject"
  }
}
```

Pass criteria:

- Prototype exists and can be opened locally without build tools.
- At least 2 clickable transitions are present.
- Covers activation and core loop.
- Covers at least one non-happy state: empty, error, edge, loading, locked, or paywall boundary.
- Reviewer can identify the app’s product category and emotional tone from the prototype without reading the spec.
- Includes a `human_review_recommendation` and repair notes if not approved.

Fail examples:

- Static landing page mock.
- Three generic cards with icons and placeholder metrics.
- Prototype that looks interchangeable with another generated app after text replacement.
- Prototype that ignores the app’s repeat-use loop.

## 6. Native screenshot review gate

Purpose: make native implementation prove it preserved the design intent before feature expansion.

Required artifacts:

- Native screenshots under the generated app’s evidence folder, e.g. `.forge/evidence/screenshots/native/`.
- `.forge/design/screenshot-review.md`
- `.forge/design/screenshot-review.json`

Minimum screenshot set:

- Activation / first useful moment.
- Core loop in realistic active state.
- Repeat-use / progress / history / retention state.
- Empty or zero-data state.
- Error or constrained state when relevant.
- Monetization/paywall boundary if the app has one.
- Compact-width screenshot if the UI risks overflow.
- Dark/light variants only when the app claims both as supported design states.

`screenshot-review.json` schema:

```json
{
  "native_screenshot_review": {
    "screenshots": [
      {
        "path": "string",
        "screen_or_state": "string",
        "required_by_gate": "activation | core_loop | retention | monetization | empty_error | accessibility",
        "matches_prototype": "yes | partial | no",
        "matches_design_system": "yes | partial | no",
        "distinctiveness_score": 0,
        "workflow_clarity_score": 0,
        "apple_native_fit_score": 0,
        "notes": "string"
      }
    ],
    "rubric_scores": {
      "app_specific_identity": 0,
      "workflow_clarity": 0,
      "visual_hierarchy": 0,
      "native_feel": 0,
      "emotional_tone_match": 0,
      "non_generic_composition": 0,
      "accessibility_visible_care": 0
    },
    "blocking_findings": ["string"],
    "repair_required": ["string"],
    "verdict": "pass | repair | reject"
  }
}
```

Scoring scale:

- 0 = absent / contradicts artifact
- 1 = weak / generic / mostly token-level
- 2 = adequate but not distinctive
- 3 = strong and app-specific

Pass criteria:

- No required screenshot category is missing.
- No score is 0.
- `app_specific_identity`, `workflow_clarity`, `emotional_tone_match`, and `non_generic_composition` must each be at least 2.
- At least two of those four critical dimensions must be 3.
- `verdict` is `pass` only when `blocking_findings` is empty.
- If `matches_prototype` is `partial` or `no`, review explains why the native divergence is better, not just different.

Hard rejection:

- First screenshot is a generic dashboard, segmented tab shell, or list of cards unless the synthesis explicitly justifies that shape and the implementation adds app-specific interaction behavior.
- Screenshots show only populated happy path with no activation/empty/error/retention evidence.
- Screenshot review is written before screenshot files exist.

## 7. Motion/haptics rubric

Purpose: make motion and haptics useful, app-specific, and accessible instead of generic flourish.

Required artifacts:

- `.forge/design/motion-haptics.md`
- `.forge/design/motion-haptics.json`

`motion-haptics.json` schema:

```json
{
  "motion_haptics": {
    "principles": [
      {
        "name": "string",
        "why_product_needs_it": "string",
        "anti_pattern": "string"
      }
    ],
    "interactions": [
      {
        "trigger": "string",
        "user_intent": "string",
        "motion": "string",
        "haptic": "none | selection | light | medium | heavy | success | warning | error",
        "duration_ms": 0,
        "easing": "string",
        "feedback_purpose": "confirm | orient | reward | warn | reveal | transition",
        "reduce_motion_behavior": "string",
        "failure_mode_if_missing_or_overdone": "string"
      }
    ],
    "banned_motion": ["string"],
    "verification_notes": ["string"]
  }
}
```

Pass criteria:

- At least 3 app-specific interaction moments are defined when the app has enough interaction surface.
- Every motion/haptic has a product purpose: confirm, orient, reward, warn, reveal, or transition.
- Every animation has a reduce-motion behavior.
- Haptics are not assigned to every tap; they mark meaningful state changes.
- Banned motion includes generic bounce/confetti/spinner flourish unless product-specific justification exists.

Native screenshot/video follow-up:

- Screenshot review can pass before motion is fully implemented only if `motion_haptics.verification_notes` marks motion as planned and not needed for the current static screenshot proof.
- Final verification cannot claim native UX quality without video or equivalent proof for any motion/haptic defined as critical.

## 8. Generic UI rejection tests

Purpose: make rejection explicit and repeatable. A generated app should fail design if it could be mistaken for a scaffold reskin.

These tests should be implemented first as review checklist + JSON fields, then later automated where possible with artifact validators and screenshot/vision review.

### Test A: Token-swap test

Question: If app name, colors, and icons were changed, would this UI still describe a different generated app?

Fail if yes.

Evidence required:

```json
{
  "token_swap_test": {
    "verdict": "pass | fail",
    "why_not_interchangeable": ["string"],
    "app_specific_structural_choices": ["string"]
  }
}
```

Pass bar:

- At least 3 structural/interaction choices are app-specific and visible.
- Reasons are not token-only.

### Test B: Card-dashboard density test

Question: Is the first useful screen primarily a stack/grid of generic cards, metrics, and CTA buttons?

Fail unless the original synthesis justifies card/dashboard as the product’s native mental model and adds distinctive behavior.

Evidence required:

```json
{
  "card_dashboard_test": {
    "verdict": "pass | fail | justified_exception",
    "card_like_regions_count": 0,
    "generic_metric_tiles_count": 0,
    "justification_if_exception": "string | null",
    "distinctive_non_card_mechanisms": ["string"]
  }
}
```

Pass bar:

- `justified_exception` requires both product rationale and distinctive behavior.
- If `card_like_regions_count` is high, there must be an explicit repair recommendation or exception.

### Test C: Scaffold component dependency test

Question: Does the visible UI depend mainly on default scaffold components without app-specific wrappers or behavior?

Fail if default components dominate visible identity.

Evidence required:

```json
{
  "scaffold_dependency_test": {
    "verdict": "pass | fail",
    "default_components_used": ["string"],
    "app_specific_components_used": ["string"],
    "identity_carried_by": "tokens | copy | layout | components | interactions | workflow_shape",
    "repair_if_tokens_only": ["string"]
  }
}
```

Pass bar:

- `identity_carried_by` must include at least two of: layout, components, interactions, workflow_shape.
- Tokens/copy alone cannot pass.

### Test D: Screen-shape uniqueness test

Question: Are the screen compositions visibly different across activation, core loop, retention, and monetization/edge states for product reasons?

Fail if all screens share the same title-card-list-button formula.

Evidence required:

```json
{
  "screen_shape_uniqueness_test": {
    "verdict": "pass | fail",
    "screen_shapes": [
      {
        "screen": "string",
        "composition_shape": "string",
        "why_this_shape_matches_task": "string"
      }
    ],
    "repeated_formula_risk": "string"
  }
}
```

Pass bar:

- At least 3 screen/state shapes are listed.
- Repetition is justified by workflow continuity, not default convenience.

### Test E: Emotional-tone blind test

Question: Can a reviewer infer the intended emotional tone from screenshots/prototype without reading the tone artifact?

Evidence required:

```json
{
  "emotional_tone_blind_test": {
    "reviewer_inferred_tone": "string",
    "intended_tone": "string",
    "match": "yes | partial | no",
    "mismatches": ["string"]
  }
}
```

Pass bar:

- `match` must be `yes` or `partial` with repair notes.
- A total mismatch blocks the design gate.

## 9. Final design gate receipt

Required artifact: `.forge/design/design-gate-receipt.json`

Final receipt schema:

```json
{
  "schema_version": "forge.design_gate.v1",
  "app_id": "string",
  "app_name": "string",
  "spec_hash_or_timestamp": "string",
  "gate_status": "pass | repair | reject",
  "artifacts": {
    "references_md": ".forge/design/references.md",
    "references_json": ".forge/design/references.json",
    "synthesis_md": ".forge/design/synthesis.md",
    "synthesis_json": ".forge/design/synthesis.json",
    "emotional_tone_md": ".forge/design/emotional-tone.md",
    "emotional_tone_json": ".forge/design/emotional-tone.json",
    "design_system_md": ".forge/design/design-system.md",
    "design_system_json": ".forge/design/design-system.json",
    "prototype_entry": ".forge/design/prototype/index.html",
    "prototype_receipt": ".forge/design/prototype/prototype-receipt.json",
    "screenshot_review_md": ".forge/design/screenshot-review.md",
    "screenshot_review_json": ".forge/design/screenshot-review.json",
    "motion_haptics_md": ".forge/design/motion-haptics.md",
    "motion_haptics_json": ".forge/design/motion-haptics.json"
  },
  "product_design_handshake": {},
  "subgate_verdicts": {
    "references_synthesis": "pass | repair | reject",
    "emotional_tone": "pass | repair | reject",
    "design_system": "pass | repair | reject",
    "prototype": "pass | repair | reject",
    "native_screenshots": "pass | repair | reject | not_started",
    "motion_haptics": "pass | repair | reject",
    "generic_ui_rejection_tests": "pass | repair | reject"
  },
  "generic_ui_rejection_tests": {
    "token_swap_test": {},
    "card_dashboard_test": {},
    "scaffold_dependency_test": {},
    "screen_shape_uniqueness_test": {},
    "emotional_tone_blind_test": {}
  },
  "blocking_findings": ["string"],
  "repair_plan": [
    {
      "finding": "string",
      "required_change": "string",
      "artifact_or_screen": "string"
    }
  ],
  "approval": {
    "human_review_required_before_swift_expansion": true,
    "recommended_decision": "approve | repair | reject",
    "rationale": "string"
  }
}
```

Overall pass criteria:

- Every required artifact exists.
- Every JSON artifact validates against the lane contract.
- All subgates are `pass` except `native_screenshots` may be `not_started` only before Swift expansion.
- Before native feature expansion, prototype must pass and human review must approve/explicitly waive.
- Before launch-candidate claims, native screenshots and motion/haptics evidence must pass.
- `blocking_findings` is empty.

## Suggested implementation tasks

### Task 1: Add design artifact schema docs

Create a schema doc or JSON schema files for:

- `references.json`
- `synthesis.json`
- `emotional-tone.json`
- `design-system.json`
- `prototype-receipt.json`
- `screenshot-review.json`
- `motion-haptics.json`
- `design-gate-receipt.json`

Acceptance:

- Schemas include required fields from this lane doc.
- Validator can report missing artifacts and missing required fields.

### Task 2: Add design gate validator

Create a local script, proposed path:

- `scripts/forge-vnext-design-gate-verify.mjs`

Inputs:

- generated app root
- optional `--phase pre-native | native-review | final`

Acceptance:

- `pre-native` requires references, synthesis, emotional tone, design system, prototype, generic rejection tests, and final receipt.
- `native-review` additionally requires screenshot review and screenshot files.
- `final` additionally requires motion/video evidence when critical motion is defined.
- Script fails if default-scaffold/card-dashboard rejection tests fail.

### Task 3: Add generator prompt contract

Update generator/task prompts so the design worker must emit this artifact tree before any SwiftUI expansion worker runs.

Acceptance:

- Prompt forbids passing with token-only design systems.
- Prompt requires the HTML prototype before native work.
- Prompt requires explicit `repair | reject` instead of pretending weak design passes.

### Task 4: Add review workflow to Kanban/GoalBuddy task shape

Design gate tasks should block for human review after prototype unless Matvii has explicitly allowed autonomous continuation for that run.

Acceptance:

- Major gate message presents 3 options: approve, repair specific weaknesses, reject/choose new direction.
- Message includes artifact paths, tradeoffs, recommendation, and what Swift work would do next.

### Task 5: Wire native screenshot review into verifier lane

The generic verifier should read `screenshot-review.json` and require screenshot categories from `.forge/spec.json` and `design-gate-receipt.json`.

Acceptance:

- Screenshot requirements are app-specific.
- No DayRateLab literals or screenshot names are in reusable verifier code.
- Missing screenshot category blocks launch-candidate claims.

## Open risks

- Human taste remains partly subjective. Mitigation: make subjective judgments explicit via rubrics, examples, blind tests, and repair plans.
- Vision/screenshot automation may be flaky. Mitigation: start with structured manual review artifacts, then automate artifact presence and obvious anti-pattern checks.
- App-specific design systems can become over-designed. Mitigation: require product rationale for every component and keep YAGNI: only components needed for activation/core/retention/money proof.
- Builders may satisfy JSON mechanically while producing weak visuals. Mitigation: prototype + native screenshot gates require visual evidence and human/design review.
- Strict design gates slow the second proof app. This is acceptable for vNext because Forge must prove quality, not speed.

## Suggested next Kanban task

Title: `Implement Forge vNext design gate schemas and validator`

Assignee: a coding-capable Forge worker.

Body:

- Use `docs/forge-vnext/lanes/design-look-feel-gates.md` as source of truth.
- Add JSON schema files or a schema module for all design artifacts.
- Add `scripts/forge-vnext-design-gate-verify.mjs` with `pre-native`, `native-review`, and `final` phases.
- Add fixture app roots for pass/fail cases, including token-swap, generic-card-dashboard, and missing-prototype failures.
- Do not generate the second proof app.

Acceptance:

- Validator fails a token-only design system.
- Validator fails missing HTML prototype before native expansion.
- Validator fails missing screenshot categories in native-review phase.
- Validator passes a minimal but app-specific fixture.
- No DayRateLab literals are required by the reusable validator.
