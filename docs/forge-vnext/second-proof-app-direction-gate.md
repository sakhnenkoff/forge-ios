# Forge vNext Second Proof App Direction Gate — repaired synthesis

Generated: 2026-05-25T19:22:41+0200
Repaired: 2026-05-25T20:01:54+0200 / 2026-05-25T18:01:54Z
Synthesis updated: 2026-05-25T18:27:22Z
Original task: `t_35ba8a8c`
Repair task: `t_770574b9`
Synthesis task: `t_f46570f6`
Parent repair lanes: `t_0df5ff6c`, `t_6fdcb138`, `t_d39b995a`
Status: repaired direction is ready for skeptical judge review of a Matvii decision gate only. Native generation remains blocked.

## Safety and source boundaries

This gate is intentionally limited to read-only local/public research, local static prototype review, and document writing.

Actions not taken:

- no native iOS app generation;
- no generated app repo creation;
- no public posting, external account use, App Store Connect, TestFlight, signing, bundle ID, IAP, payments, credentials, purchases, or work-system actions;
- no deletion/quarantine of old artifacts;
- no use of DayRateLab or any prior proof app as product, design, naming, market, fixture, screenshot, implementation, or verifier inspiration.

DayRateLab is only a negative guardrail: the second proof must not become a generic dashboard/card shell, must not reuse old names/copy/screenshots/verifier assumptions, and must stop at explicit judge/human approval before native generation.

## Synthesis verdict

Verdict for `forgejudge`: `approve_for_matvii_gate`.

Meaning: the repaired parent artifacts now support one concrete human decision gate for Matvii, not native app generation.

The direction is coherent enough to ask Matvii this narrowly scoped question after judge review:

> Do you accept manual quick-add plus rescue queue as the honest MVP for a local second proof, with barcode, OCR, receipt import, loyalty-card import, account/cloud sync, family sharing, StoreKit/IAP, and live payments explicitly deferred?

If Matvii answers yes, Forge may create product/design gate artifacts for the local proof. If Matvii answers no, the honest next action is `repair_again` only if a scanner/sync-free variant is still desired; otherwise `kill_batch` or return to candidate selection.

Native generation is still blocked because the current evidence is source-linked research plus non-native/static prototype proof, not simulator/native/user evidence.

## Parent artifacts integrated

This synthesis updates the gate using the following exact artifacts:

- Raw/source-linked evidence notes: `.forge/research/pantry-rescue-raw-evidence.json` from `t_0df5ff6c`.
- Activation and returning-loop artifact: `docs/forge-vnext/pantry-rescue-activation-prototype.md` from `t_6fdcb138`.
- Static HTML activation prototype: `docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html` from `t_6fdcb138`.
- Money path / Pro boundary artifact: `docs/forge-vnext/pantry-rescue-money-path.md` from `t_d39b995a`.
- Durable matrix updated with this synthesis: `.forge/research/evidence-matrix.json`.

The parent lanes repair the previous contradiction: activation, repeat loop, evidence integrity, and money path are no longer claimed as proven by prose alone. They are either backed by specific local artifacts or explicitly deferred.

## Repaired candidate direction

### Candidate A — Pantry Rescue Queue

Working name: `Pantry Rescue Queue`

One-line direction: A local-first household food-expiry app that stops acting like inventory software and gives the user a daily rescue queue: eat tonight, freeze, cook, ignore, or do-not-buy-again.

### Sharpened beachhead user

Primary beachhead: solo household food operator who does one weekly grocery trip, has fridge/freezer/pantry overflow, and repeatedly discovers expiring food or duplicate buys while deciding dinner.

Evidence posture: the beachhead is a coherent synthesis, not externally proven segment truth. `.forge/research/pantry-rescue-raw-evidence.json` preserves `RAW-BEACHHEAD-GAP-010`, which says external sources support pantry inventory, expiry, duplicate-buying, freezer/pantry visibility, and scanner/sync expectations generally, but do not directly prove solo-household as the optimal first segment.

Excluded users/use cases:

- restaurant/retail inventory teams;
- recipe-only users;
- macro/calorie trackers;
- grocery-delivery optimization users;
- users who require real barcode scanning, OCR, receipt import, loyalty-card import, cloud/account sync, live family sharing, or grocery APIs for the proof to feel honest.

Painful job:

- “What is about to go bad, what can I still rescue tonight, and what should I not buy again?”
- Cost of doing nothing: expired food, duplicate purchases, freezer archaeology, guilt/friction around dinner decisions, and wasted money.

## Evidence synthesis

### Raw/source-linked evidence integrity

`.forge/research/pantry-rescue-raw-evidence.json` contributes 10 raw notes:

- `RAW-APPLE-SEARCH-CATEGORY-001`: App Store category demand and competitor density.
- `RAW-APPLE-REVIEWS-PAIN-002`: duplicate purchases, expiry tracking, freezer/pantry visibility, shopping-list memory.
- `RAW-APPLE-REVIEWS-MANUAL-FRICTION-003`: add-flow/scanner/default-expiry friction.
- `RAW-APPLE-REVIEWS-SYNC-BARCODE-004`: barcode, camera, sync, and household-sharing expectations.
- `RAW-APPLE-LOOKUP-FEATURE-EXPECTATIONS-005`: competitor listing-copy expectations around barcode, receipt/photo import, sync, family/cloud, shopping lists, loyalty-card import.
- `RAW-APPLE-PUBLIC-PRICING-006`: public pricing/IAP rows and paywall limitations.
- `RAW-REDDIT-PUBLIC-SUBSTITUTE-007`: weak/noisy community substitute evidence.
- `RAW-HN-PUBLIC-SUBSTITUTE-008`: sparse builder-community corroboration.
- `RAW-ACCESS-LIMITATIONS-009`: X/Product Hunt/dedicated source access limitations.
- `RAW-BEACHHEAD-GAP-010`: solo-household beachhead remains a gap.

This improves evidence integrity from “matrix exists but needs audit” to “source-linked enough for judge review,” while preserving the remaining gaps instead of hiding them.

### Activation and repeat loop

`docs/forge-vnext/pantry-rescue-activation-prototype.md` and `docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html` repair the activation/retention contradiction at direction-gate level:

- under-30-second activation script: open app, name one item, choose location/urgency, receive a rescue action, commit `Cook tonight`, see queue progress, create duplicate-avoidance memory;
- first useful result by about 12 seconds in the storyboard;
- visible queue progress by about 18 seconds;
- duplicate-avoidance memory before 30 seconds;
- returning-user sketch for weekly recap, duplicate caution, and queue-clearing progress;
- explicit anti-generic design pressure: no inventory table first, no metric-card dashboard, no tab-first generic scaffold, no scanner/OCR/sync affordances in the first proof.

Limit: this is non-native/static prototype evidence, not real user or simulator evidence. It is enough to ask Matvii whether the manual-MVP tradeoff is acceptable. It is not enough to generate native code without the judge/human gate.

### Money path / Pro boundary

`docs/forge-vnext/pantry-rescue-money-path.md` repairs the money contradiction by choosing explicit monetization deferral rather than forcing a false pass.

Current money posture:

- public competitor pricing/IAP exists, but logged-in/in-app paywall UX was not captured;
- no live monetization, StoreKit/IAP, price-point, launch-candidate monetization, or payment claim is approved;
- free proof value must include first useful rescue queue, manual add, expiry urgency, and marking an item rescued/ignored;
- only a later local, non-purchasable Pro-boundary prototype may explore multiple storage zones, reminder templates, duplicate-buy memory/history, recap history, export/share draft, and clearly deferred shared-household concepts;
- `pricing-draft.json` or launch-package artifacts, if created later, should use `recommendedModel: no_monetization_yet` until the money evidence improves.

This makes the money path acceptable for a Matvii manual-MVP gate because the gate no longer claims monetization is proven. It does not make monetization launch-ready.

## Competitor pricing, paywall, and screenshot notes

All notes below come from safe public/read-only App Store sources and the raw evidence artifact. No app was installed, no in-app flow was opened, no purchase was made, and no external account was used. Screenshot notes identify public screenshot availability and listing/product surfaces; they are not a claim that a logged-in paywall was visually audited.

| Competitor | Public source | Pricing / IAP notes | Product-surface notes | Direction implication |
|---|---|---|---|---|
| Pantry Check - Grocery List | `https://apps.apple.com/us/app/pantry-check-grocery-list/id966702368` | Free listing. Public IAP includes `Premium: 2,000 items` and `Pro: 10,000 items` at multiple public price points. | Listing emphasizes barcode scanner, real-time sync/family sharing, expiration reminders, smart shopping lists, custom locations, prices/totals, inventory, and usage timeline. | Strong scanner/sync expectation. Pantry Rescue Queue must compete on rescue triage speed and emotional clarity, not scanner coverage. |
| NoWaste: Food Inventory List | `https://apps.apple.com/us/app/nowaste-food-inventory-list/id926211004` | Free listing. Public IAP includes `NoWaste Pro Annual $6.99` and `NoWaste Pro Lifetime $29.99`. | Listing emphasizes freezer/fridge/pantry lists, barcode/receipt/photo adding, sync, AI assistant, expiration sorting/filtering, moving items, shopping, and meal planning. | Manual MVP is credible only if tightly scoped to rescue decisions, not inventory breadth. |
| Cooklist: Pantry Meals Recipes | `https://apps.apple.com/us/app/cooklist-pantry-meals-recipes/id1352600944` | Free listing. Public IAP includes monthly/yearly Pro prices. | Listing positions Cooklist around grocery loyalty-card import, recipe matching, meal planning, shopping-list/cart generation, household sharing, and cloud backup. | Adjacent competitor; raises automation/import expectations but should not pull Pantry Rescue into recipe-feed-first positioning. |
| Pantry Inventory - Panzy | `https://apps.apple.com/us/app/pantry-inventory-panzy/id6748056076` | Free listing. Public IAP includes monthly/yearly/lifetime plans. | Listing frames it as a smart pantry companion with quantity/expiration add, low-stock automation, barcode scanner, iCloud sync, reminders, and pantry/fridge/freezer organization. | Confirms small apps still monetize pantry utilities and that barcode/iCloud expectations are common. |
| Pantry Manager | `https://apps.apple.com/us/app/pantry-manager/id512026829` | Paid upfront `$3.99`. Public IAP includes `Sync Photos $0.99`. | Listing emphasizes household item management, expiration reminders, shopping list from actual owned items, optional barcode add, cloud sync, local photos, CSV export, tags, and Apple Watch. | Manual-first/upfront precedent exists, but broad inventory scope and modest rating make a paid proof risky without strong native value evidence. |

## Scorecard after parent repair lanes

Scores are direction-gate estimates. They are not native app scores because no native app exists yet.

| Dimension | Hard min for Matvii gate | Repaired score | Pass for Matvii gate? | Evidence IDs / artifact paths | Rationale |
|---|---:|---:|---|---|---|
| Pain/problem clarity | 7 | 8 | yes | `E-PANTRY-RAW-EVIDENCE-1`, `.forge/research/pantry-rescue-raw-evidence.json` | Source-linked App Store reviews and listings support expiry, duplicate buying, freezer/pantry visibility, and add-flow friction. |
| Target user sharpness | 7 | 7 | yes-with-gap | `E-BEACHHEAD-SEGMENT-1`, `RAW-BEACHHEAD-GAP-010` | Beachhead is sharp enough to ask Matvii, while still marked as not directly externally proven. |
| Use-case activation | 7 | 7 | yes-for-Matvii-gate | `E-ACTIVATION-PROTOTYPE-1`, `docs/forge-vnext/pantry-rescue-activation-prototype.md` | Static prototype/storyboard shows a concrete under-30-second manual-add path. Needs native/user evidence later. |
| Repeat-use / retention loop | 7 | 7 | yes-for-Matvii-gate | `E-RETURNING-LOOP-PROTOTYPE-1`, `docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html` | Returning recap, duplicate caution, and queue-clearing progress are sketched with state transitions. Needs persistence/native proof later. |
| Money-path believability | 6 | 6 | yes-by-deferral | `E-MONEY-DEFERRAL-1`, `docs/forge-vnext/pantry-rescue-money-path.md` | Money path is not proven, but the gate is coherent because monetization is explicitly deferred and free/pro local boundary is documented. |
| Product distinctiveness / taste | 7 | 7 | yes-for-direction | `E-ACTIVATION-PROTOTYPE-1` | Rescue Mouth, Rescue Lane, Caution Memory, Quiet Fridge Progress, and Weekly Rescue Recap create app-specific structure. |
| Blueprint coverage / launch-slice integrity | 8 native gate | 6 native / 7 Matvii gate | yes-for-Matvii-gate, no-for-native | `E-ACTIVATION-PROTOTYPE-1`, `E-RETURNING-LOOP-PROTOTYPE-1` | There is enough local prototype coverage to ask a human direction question, but no native coverage matrix or simulator proof. |
| Evidence integrity | 8 | 8 | yes-for-judge-review | `E-PANTRY-RAW-EVIDENCE-1`, `.forge/research/evidence-matrix.json` | Matrix now cites raw/source-linked evidence, activation artifact, and money deferral artifact, and preserves gaps. |

Interpretation:

- `approve_for_matvii_gate` is coherent because the remaining issues are framed as explicit human tradeoff decisions, not hidden false passes.
- `native_generation_allowed` remains `false`.
- The next judge must reject this gate if it believes static activation evidence is too weak to ask Matvii, or if manual quick-add cannot honestly stand without scanner/OCR/sync/import.

## Direction product/taste gate receipt

Receipt type: human-readable direction receipt; no generated app repo exists yet.

```json
{
  "schema_version": "forge.product_taste_gate.v1",
  "app": {
    "id": "pantry-rescue-queue",
    "name": "Pantry Rescue Queue",
    "repo_path": null,
    "run_id": "t_f46570f6"
  },
  "gate": {
    "name": "product_taste",
    "stage": "direction_after_repair_lanes",
    "created_at": "2026-05-25T18:27:22Z",
    "created_by": "forgeproduct",
    "verdict": "approve_for_matvii_gate",
    "confidence": "medium",
    "native_generation_allowed": false
  },
  "source_artifacts": [
    ".forge/research/pantry-rescue-raw-evidence.json",
    "docs/forge-vnext/pantry-rescue-activation-prototype.md",
    "docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html",
    "docs/forge-vnext/pantry-rescue-money-path.md",
    ".forge/research/evidence-matrix.json",
    "docs/forge-vnext/second-proof-app-direction-gate.md"
  ],
  "evidence_ids": [
    "E-PANTRY-RAW-EVIDENCE-1",
    "E-ACTIVATION-PROTOTYPE-1",
    "E-RETURNING-LOOP-PROTOTYPE-1",
    "E-MONEY-DEFERRAL-1",
    "E-BEACHHEAD-SEGMENT-1",
    "E-ACCESS-LIMITATIONS-1",
    "E-DAYRATELAB-NEGATIVE-GUARDRAIL-1"
  ],
  "scores": {
    "weighted_overall_estimate": 7.1,
    "dimensions": {
      "pain_problem_clarity": { "score": 8, "minimum": 7, "pass_for_matvii_gate": true, "evidence_ids": ["E-PANTRY-RAW-EVIDENCE-1"], "rationale": "Source-linked evidence supports expiry, duplicate-buying, freezer/pantry visibility, and add-flow friction." },
      "target_user_sharpness": { "score": 7, "minimum": 7, "pass_for_matvii_gate": true, "evidence_ids": ["E-BEACHHEAD-SEGMENT-1"], "rationale": "Solo-household beachhead is sharp enough for human tradeoff approval, while still marked as not externally proven." },
      "use_case_activation": { "score": 7, "minimum": 7, "pass_for_matvii_gate": true, "evidence_ids": ["E-ACTIVATION-PROTOTYPE-1"], "rationale": "Static prototype/storyboard shows first useful rescue result under 30 seconds." },
      "repeat_use_retention_loop": { "score": 7, "minimum": 7, "pass_for_matvii_gate": true, "evidence_ids": ["E-RETURNING-LOOP-PROTOTYPE-1"], "rationale": "Returning recap, duplicate caution, and queue-clearing progress are represented as prototype state transitions." },
      "money_path_believability": { "score": 6, "minimum": 6, "pass_for_matvii_gate": true, "evidence_ids": ["E-MONEY-DEFERRAL-1"], "rationale": "Money is explicitly deferred; local Pro boundary is documented as future non-purchasable prototype only." },
      "product_distinctiveness_taste": { "score": 7, "minimum": 7, "pass_for_matvii_gate": true, "evidence_ids": ["E-ACTIVATION-PROTOTYPE-1"], "rationale": "Rescue-specific surfaces replace generic inventory/dashboard shapes." },
      "blueprint_coverage_launch_slice_integrity": { "score": 7, "minimum": 7, "pass_for_matvii_gate": true, "native_score": 6, "native_minimum": 8, "pass_for_native_generation": false, "evidence_ids": ["E-ACTIVATION-PROTOTYPE-1", "E-RETURNING-LOOP-PROTOTYPE-1"], "rationale": "Enough local prototype coverage for a Matvii direction gate; no native coverage exists." },
      "evidence_integrity": { "score": 8, "minimum": 8, "pass_for_matvii_gate": true, "evidence_ids": ["E-PANTRY-RAW-EVIDENCE-1", "E-ACCESS-LIMITATIONS-1"], "rationale": "Raw source-linked evidence, access limitations, and remaining gaps are explicit." }
    },
    "hard_minimum_failures": []
  },
  "hard_minimums": {
    "demand_evidence_types_count": 4,
    "required_demand_evidence_types_count": 2,
    "has_excluded_user_statement": true,
    "has_revenue_taste_tradeoff_statement": true,
    "activation_evidence_present": true,
    "activation_evidence_type": "non_native_static_storyboard_and_html_prototype",
    "core_loop_evidence_present": true,
    "retention_evidence_present": true,
    "retention_evidence_type": "non_native_returning_user_storyboard",
    "money_boundary_evidence_present_or_deferred_by_approval": true,
    "money_boundary_status": "explicitly_deferred_no_monetization_yet",
    "evidence_matrix_present": true,
    "raw_source_linked_evidence_present": true,
    "competitor_pricing_notes_present": true,
    "competitor_screenshot_notes_present": true,
    "dayratelab_negative_guardrail_only": true,
    "native_generation_allowed": false,
    "contradictions_unresolved": []
  },
  "native_generation_blockers": [
    "No Matvii approval of the manual quick-add tradeoff yet.",
    "No native/simulator activation walkthrough exists.",
    "No local persistence proof for duplicate caution, weekly recap, or queue state exists.",
    "No accepted native coverage matrix or app blueprint exists.",
    "No monetization launch claim is approved; money path is deferred."
  ],
  "recommendation": {
    "type": "approve_for_matvii_gate",
    "confidence": "medium",
    "summary": "Ask Matvii one concrete manual-MVP decision after skeptical judge review; keep native generation blocked.",
    "matvii_decision_required": true,
    "matvii_question": "Do you accept manual quick-add plus rescue queue as the honest MVP for a local second proof, with barcode/OCR/sync/import/payments explicitly deferred?",
    "allowed_matvii_decisions": ["accept_manual_mvp_and_continue_to_product_design_gate", "request_one_more_repair", "kill_direction"],
    "next_forgejudge_gate": "approve_for_matvii_gate"
  },
  "next_allowed_actions": [
    "forgejudge_review_repaired_synthesis_gate",
    "if_judge_approves_ask_matvii_single_manual_mvp_decision",
    "do_not_generate_native_app_without_judge_and_matvii_approval"
  ]
}
```

## Proposed `.forge/spec.json` outline only if judge and Matvii approve

This outline is not permission to generate native code. It exists so the next gate knows what would be tested if judge review passes and Matvii accepts the risk.

```json
{
  "schema_version": "forge.spec.v1",
  "app": {
    "id": "pantry-rescue-queue",
    "name": "Pantry Rescue Queue",
    "tagline": "Rescue what is about to go bad before you buy more.",
    "category": "household_food_utility",
    "platform": "ios",
    "local_only_for_proof": true
  },
  "target_user": {
    "primary": "Solo household food operator with weekly grocery trips, fridge/freezer/pantry overflow, and recurring expiring-food or duplicate-buying pain during dinner decisions",
    "excluded": ["restaurants", "retail inventory", "calorie trackers", "recipe-only users", "scanner/OCR/sync-dependent users"]
  },
  "activation": {
    "promise": "Create a useful rescue queue from one manually quick-added expiring item in under 30 seconds.",
    "first_use_flow": ["choose storage location", "quick-add food item", "choose expiry urgency", "see rescue action", "mark eat/freeze/cook/ignore", "watch queue/progress update", "optionally remember a do-not-buy-again caution"]
  },
  "core_loop": {
    "trigger": "grocery trip, expiry reminder, weekly recap, or dinner decision",
    "action": "triage food into rescue actions and update local inventory/shopping memory",
    "reward": "queue shrinks, waste-saved progress updates, duplicate-buy warning improves",
    "next_trigger": "next reminder, next grocery trip, weekly rescue recap"
  },
  "monetization": {
    "strategy": "no_monetization_yet",
    "live_iap": false,
    "storekit": false,
    "payment_actions": false,
    "future_local_pro_boundary_candidates": ["multiple storage zones", "reminder templates", "duplicate-buy history", "weekly/monthly rescue recap history", "local export/share draft"]
  },
  "non_goals_before_later_capability_gate": ["barcode", "OCR", "receipt import", "loyalty-card import", "cloud sync", "live family sharing", "grocery APIs", "payments"]
}
```

## Concrete next gate

Next gate for `forgejudge`: `approve_for_matvii_gate`.

Judge question:

- Are the evidence matrix, raw evidence notes, activation prototype, money deferral, hard flags, and hard-minimum failures internally consistent enough to ask Matvii the single manual-MVP decision above?

If yes:

- Ask Matvii the manual quick-add / rescue queue approval question.
- Do not generate native code yet; create product/design gate artifacts only after Matvii accepts.

If no:

- Return `repair_again` only with a narrow concrete blocker, such as “static prototype is too abstract; record a timed walkthrough” or “money deferral still muddies product promise.”
- Return `kill_batch` if scanner/OCR/sync/import is judged mandatory for credibility.

## Stop condition

This task stops here. Do not create the native app repo, do not generate Swift, do not polish or reuse old proof artifacts, and do not touch App Store/TestFlight/signing/IAP/money/external accounts until judge review passes and Matvii explicitly approves this direction.
