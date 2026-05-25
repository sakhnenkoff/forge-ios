# Pantry Rescue Queue — Native Proof Spec

Generated: 2026-05-25T18:54:00Z / 2026-05-25T20:54:00+0200
Kanban task: `t_a048159e`
Status: local product/design/native-proof preparation only. No Swift, no generated app repo, no App Store/TestFlight/signing/IAP/payment/account action.
Machine-readable companion: `docs/forge-vnext/pantry-rescue-native-proof-spec.json`

## Scope boundary

This spec materializes the approved Pantry Rescue Queue direction after Matvii accepted the manual quick-add + rescue queue MVP for local product/design/native-proof preparation.

Allowed now:

- local product spec and native-proof acceptance criteria;
- local design/product planning for a later iOS proof;
- local machine-readable spec artifacts.

Explicitly not allowed in this task/spec:

- Swift/native app code;
- separate app repo creation;
- barcode scanning;
- OCR;
- receipt import;
- loyalty-card import;
- cloud/account sync;
- live family sharing;
- StoreKit/IAP;
- payments;
- public launch/App Store/TestFlight/signing/account actions;
- using DayRateLab as inspiration, baseline, naming source, UI pattern, fixture source, screenshot reference, or verifier assumption.

Money posture: `no_monetization_yet`. Money work is limited to local hypothesis/pro-boundary notes. No live price, paywall, StoreKit, purchase, or launch-candidate monetization claim is approved.

## Source artifacts read

- `docs/forge-vnext/persistent-orchestrator-charter.md`
- `docs/forge-vnext/second-proof-app-direction-gate.md`
- `docs/forge-vnext/pantry-rescue-activation-prototype.md`
- `docs/forge-vnext/pantry-rescue-money-path.md`
- `.forge/research/evidence-matrix.json`
- `.forge/research/pantry-rescue-raw-evidence.json`

## Product summary

App: Pantry Rescue Queue

One-line promise:

Rescue what is about to go bad before you buy more.

Honest MVP:

A local-first iOS proof where a solo household food operator manually quick-adds one at-risk food item, gets an immediate rescue queue decision, marks an action, and sees local progress/duplicate caution state persist into a later session.

Not an inventory app first:

The useful result is not “item added to pantry.” The useful result is “I know what to do with this expiring thing now, and the app remembers enough to help me avoid repeating the mistake.”

## Target user

Primary user:

A solo household food operator who does one weekly grocery trip, has fridge/freezer/pantry overflow, and repeatedly discovers expiring food or duplicate buys while deciding dinner.

Context:

- Sunday/evening or pre-dinner uncertainty;
- sees an item like spinach, yogurt, mushrooms, chicken, or leftovers about to go bad;
- does not want to build a complete inventory before receiving value;
- may feel guilt/friction around wasting food and duplicate purchases.

Excluded users/use cases:

- restaurants and retail inventory teams;
- recipe-feed-first users;
- macro/calorie trackers;
- grocery delivery optimization users;
- users who require barcode, OCR, receipt import, loyalty-card import, cloud/account sync, live family sharing, grocery APIs, StoreKit/IAP, or payments for the proof to feel honest.

Evidence caveat:

The solo-household beachhead is a sharp synthesis for a local proof, not externally proven as the optimal segment. `RAW-BEACHHEAD-GAP-010` preserves this gap.

## Activation promise

A first-time user can get a useful rescue decision from one manually quick-added item in under 30 seconds, without a complete pantry inventory, account, scanner, OCR, sync, payment, or dashboard setup.

First useful result:

By roughly 12 seconds, the app should show a concrete rescue action for the entered item, e.g. `Spinach is first in the rescue queue. Best rescue: cook tonight with eggs or pasta. Fallback: freeze before bed.`

Activation succeeds only if:

- the app opens on the rescue prompt, not a metric dashboard or inventory table;
- the user enters one item + location + urgency;
- the app creates a rescue lane entry with immediate verbs;
- the user commits one action and sees queue/progress change;
- the user can create or decline duplicate caution before exit.

## First-use flow

Scenario: solo household operator notices spinach wilting while deciding dinner.

1. Open app.
   - First visible prompt: `What needs rescuing?`
   - Cursor/focus is in the one-line quick-add field.
   - No account, dashboard, empty table, scanner prompt, or onboarding carousel first.
2. Enter item.
   - User types `spinach` or taps a common/recent chip.
3. Choose location.
   - User taps one of `fridge`, `freezer`, `pantry`.
4. Choose urgency.
   - User taps one of `tonight`, `1-2 days`, `this week`, `not sure`.
5. See rescue action.
   - App creates `Spinach — rescue tonight` at the front of the lane.
   - Primary action: `Cook tonight`.
   - Fallback actions: `Freeze`, `Ignore this time`, `Do not buy again`.
6. Commit action.
   - User taps one verb.
   - Queue/progress state updates immediately.
7. Store optional caution.
   - App asks: `Should I warn you before buying spinach again?`
   - Choices: `yes, nudge me`, `only if still unused`, `no memory`.
8. Exit with value.
   - User has a plan, visible progress, and optional duplicate-avoidance memory.

## Core loop

Trigger:

- dinner decision;
- weekly grocery trip;
- weekly rescue recap;
- local expiry/urgency reminder in a later proof;
- opening the app because “something in the fridge is yelling.”

Action:

- quick-add or review at-risk item;
- choose rescue verb: eat, freeze, cook, ignore, do-not-buy-again;
- optionally record local caution.

Reward/progress:

- queue shrinks;
- guilt becomes a plan;
- weekly rescue count changes;
- duplicate-buy caution becomes available before next grocery trip;
- app feels calmer because fewer items are “yelling.”

Next trigger:

- remaining queue item;
- weekly recap with next action;
- future grocery pre-check showing caution;
- user sees another at-risk food.

## Screen list for native proof

The later native proof should include only enough screens/surfaces to prove the loop. Names are product roles, not final Swift types.

1. Rescue Mouth / First Use
   - Role: activation.
   - Contains one-line item entry, location chips, urgency rail.
   - Required now for native proof.
   - Must not be an inventory table, metric dashboard, or scanner-first flow.
2. Rescue Lane
   - Role: core loop.
   - Shows ranked at-risk items and immediate rescue verbs.
   - Required now for native proof.
   - Must show at least one meaningful state transition after action.
3. Quiet Fridge Progress
   - Role: reward/progress.
   - Shows queue shrinking and weekly rescue progress as relief-oriented copy, not abstract metric cards.
   - Required now for native proof.
4. Caution Memory
   - Role: duplicate caution / returning value.
   - Created from a rescue/ignore/do-not-buy-again action.
   - Required now for native proof if duplicate caution is claimed.
5. Weekly Rescue Recap
   - Role: returning loop.
   - Shows prior rescue action, at least one remaining/next item, and a next action.
   - Required now for native proof.
6. Local Settings / Trust Note
   - Role: boundary clarity.
   - Minimal local-only trust copy if needed.
   - Optional for native proof; must not introduce account/sync/paywall scope.

No separate Paywall/Pro/Pricing screen is required now. If a future local Pro-boundary concept is drafted, it must be non-purchasable and explicitly marked prototype-only.

## Data model sketch

The native proof can remain local-only/in-memory or local persistence-backed, but acceptance requires state restoration evidence for returning-loop claims.

Core entities:

### RescueItem

- `id`: stable local identifier.
- `name`: user-entered food name, e.g. `spinach`.
- `location`: `fridge | freezer | pantry`.
- `urgency`: `tonight | one_to_two_days | this_week | not_sure`.
- `status`: `queued | planned | rescued | frozen | ignored | too_late`.
- `createdAt`: local timestamp.
- `updatedAt`: local timestamp.
- `lastActionId`: optional link to latest rescue action.

### RescueAction

- `id`: stable local identifier.
- `itemId`: linked rescue item.
- `verb`: `eat | freeze | cook | ignore | do_not_buy_again`.
- `label`: human copy, e.g. `Cook tonight`.
- `createdAt`: local timestamp.
- `effect`: `queue_position_changed | queue_removed | caution_prompted | recap_updated`.

### CautionMemory

- `id`: stable local identifier.
- `itemName`: normalized item name.
- `sourceActionId`: rescue action that created it.
- `condition`: `warn_on_next_grocery_trip | warn_if_recent_rescue | warn_if_still_unused`.
- `status`: `active | snoozed | cleared`.
- `createdAt`: local timestamp.
- `lastShownAt`: optional local timestamp.

### WeeklyRecap

- `weekId`: local week key.
- `rescuedCount`: integer.
- `ignoredCount`: integer.
- `newCautionCount`: integer.
- `remainingQueueItemIds`: list of local item IDs.
- `nextSuggestedItemId`: optional local item ID.

## Local persistence requirement

For the native proof, local persistence is not about production storage architecture. It exists to prove that returning value is not fake.

Minimum persistence behavior to prove:

- at least one `RescueItem` survives app relaunch or simulated returning session;
- at least one `RescueAction` updates queue/progress state;
- at least one `CautionMemory` is created from an action and later surfaced;
- `WeeklyRecap` or equivalent derived recap references prior action state.

Allowed implementation later:

- simple local JSON/UserDefaults/SwiftData/mock manager, chosen by native implementation worker.

Not allowed now:

- cloud sync;
- account identity;
- remote backend;
- shared household real-time state.

## Native-proof acceptance criteria

A later native proof passes only if all of these are demonstrated with local simulator evidence/screenshots/video/tests, not prose alone:

1. Activation under 30 seconds
   - Cold-start/first-run path from prompt to useful rescue decision.
   - No account/scanner/OCR/sync/payment setup before value.
2. Manual quick-add is useful
   - One item + location + urgency creates a ranked rescue lane entry.
   - Result is a decision/action, not just a database row.
3. Core loop transition
   - Tapping eat/freeze/cook/ignore/do-not-buy-again changes queue/progress state.
4. Local persistence / returning state
   - Returning session shows prior rescue/caution/progress state.
5. Duplicate caution
   - Caution is created from a rescue action and appears in a later grocery/pre-buy context or recap context.
6. Weekly recap/progress
   - Recap references prior actions and suggests a next action.
7. Money boundary
   - Monetization remains `no_monetization_yet`; no paywall/StoreKit/payment surface appears.
8. Non-goals are absent
   - No barcode, OCR, receipt, loyalty card, sync, family sharing, cloud account, IAP, payment, public launch flow, or signing/account action.
9. Anti-generic product shape
   - First useful screen is Rescue Mouth + Rescue Lane, not dashboard cards or inventory tables.
10. Evidence integrity
   - Screenshots/video/test notes are tied to the coverage matrix IDs in this spec and companion JSON.

## Native-proof success gates

A local native proof should be considered successful enough for the next Forge judge only if:

- `activation.first_use` has simulator evidence and reaches a useful rescue action within the specified flow;
- `core_loop.rescue_action` has evidence of an action changing queue/progress state;
- `persistence.returning_state` has evidence after relaunch or equivalent returning-state simulation;
- `retention.weekly_recap` has evidence referencing prior actions and producing a next action;
- `memory.duplicate_caution` has evidence of creation and later surfacing;
- `money.deferred_boundary` is explicitly preserved with no live monetization surface;
- the app-specific UI would fail if pantry/rescue/caution concepts were token-swapped away;
- a skeptical reviewer cannot fairly describe the result as a generic dashboard/card/list scaffold.

## Native-proof failure gates

A local native proof should fail or be repaired if any of these happen:

- user sees a generic dashboard, metric cards, inventory table, or tab scaffold before the first useful rescue action;
- activation requires quantity, price, purchase date, account, complete inventory, barcode, OCR, receipt, sync, family setup, or payment;
- manual add produces only a row/list item without a recommended rescue action;
- action buttons do not produce visible queue/progress state changes;
- returning session cannot show prior action/caution/recap state;
- duplicate caution is only a static note and not created from user action;
- weekly recap summarizes without a next action;
- monetization copy claims Pro/subscription/premium/trial/price or hides core value behind a paid boundary;
- implementation introduces barcode/OCR/sync/import/payment scope as if required for MVP;
- evidence cannot be audited from screenshots/video/tests/coverage artifacts.

## Coverage matrix

| Coverage area | Required proof surface | Status for this spec | Evidence source now | Later native proof required | Failure mode |
|---|---|---|---|---|---|
| Activation | Rescue Mouth -> Rescue Lane first-use path under 30s | required_native_later | `E-ACTIVATION-PROTOTYPE-1`, `pantry-rescue-activation-prototype.md` | simulator/video/screenshot sequence | Dashboard/table/onboarding before value |
| Returning loop | Weekly recap and next action after prior rescue | required_native_later | `E-RETURNING-LOOP-PROTOTYPE-1` | returning-state screenshot/video/test | No visible difference between first and later session |
| Local persistence | Item/action/caution/recap state survives returning session | required_native_later | gap `G-NATIVE-RETENTION-PROOF-1` | local persistence proof after relaunch or simulated return | Recap/caution is placeholder-only |
| Duplicate caution | Caution created from rescue action and surfaced later | required_native_later | activation prototype frame 4; raw duplicate-buy pain | action -> caution -> later warning evidence | Caution is a static settings/list feature |
| Weekly recap/progress | Quiet progress path + weekly recap with next action | required_native_later | activation prototype returning-user sketch | native state transition + recap evidence | Abstract metrics without next rescue |
| Deferred-money boundary | no_monetization_yet, no paid surface | required_boundary_now_and_later | `E-MONEY-DEFERRAL-1`, `pantry-rescue-money-path.md` | evidence that no paywall/IAP/payment path appears | Pro/trial/price/StoreKit copy appears before approval |

## Evidence links

Evidence IDs from `.forge/research/evidence-matrix.json`:

- `E-PANTRY-RAW-EVIDENCE-1`: source-linked evidence for category demand, competitor expectations, review pain, pricing surfaces, and gaps.
- `E-ACTIVATION-PROTOTYPE-1`: static storyboard/HTML support for manual quick-add to useful rescue decision under 30 seconds.
- `E-RETURNING-LOOP-PROTOTYPE-1`: returning recap, duplicate caution, and queue-clearing progress sketch.
- `E-MONEY-DEFERRAL-1`: explicit monetization deferral with future local/non-purchasable Pro-boundary candidates only.
- `E-BEACHHEAD-SEGMENT-1`: sharp solo-household segment with segment-proof gap preserved.
- `E-ACCESS-LIMITATIONS-1`: source coverage limitations are explicit.
- `E-DAYRATELAB-NEGATIVE-GUARDRAIL-1`: prior proof app remains negative guardrail only.

Raw note IDs from `.forge/research/pantry-rescue-raw-evidence.json`:

- `RAW-APPLE-SEARCH-CATEGORY-001`: category demand and competitor density.
- `RAW-APPLE-REVIEWS-PAIN-002`: duplicate purchases, expiry tracking, freezer/pantry visibility, shopping-list memory.
- `RAW-APPLE-REVIEWS-MANUAL-FRICTION-003`: add-flow/scanner/default-expiry friction.
- `RAW-APPLE-REVIEWS-SYNC-BARCODE-004`: scanner/sync/household expectations risk.
- `RAW-APPLE-LOOKUP-FEATURE-EXPECTATIONS-005`: competitor listing expectations around scanner/import/sync/family/cloud/shopping.
- `RAW-APPLE-PUBLIC-PRICING-006`: public pricing/IAP visibility and paywall limitation.
- `RAW-REDDIT-PUBLIC-SUBSTITUTE-007`, `RAW-HN-PUBLIC-SUBSTITUTE-008`, `RAW-ACCESS-LIMITATIONS-009`: weak/substitute community evidence and access gaps.
- `RAW-BEACHHEAD-GAP-010`: solo-household beachhead gap.

## Non-goals / deferred capabilities

Deferred and not to be designed as required native-proof scope:

- barcode;
- OCR;
- receipt import;
- loyalty-card import;
- cloud/account sync;
- live family sharing;
- grocery APIs;
- StoreKit/IAP;
- payments;
- public launch/App Store/TestFlight/signing;
- native app repo generation in this task;
- complete inventory management;
- recipe feed as primary surface;
- social/sharing loops;
- production notification permission flows;
- DayRateLab-derived UI/fixtures/copy/verifier assumptions.

Potential future local-only hypotheses, not commitments:

- multiple named storage zones;
- reminder templates;
- duplicate-buy history;
- weekly/monthly rescue recap history;
- export/share draft of rescue list as local text/CSV;
- non-purchasable Pro-boundary concept after first-use/returning loop proof.

## Self-review checklist

- [x] Target user is concrete and exclusions are explicit.
- [x] Activation promise names first useful result and timing.
- [x] First-use flow avoids scanner/OCR/sync/account/payment scope.
- [x] Core loop includes trigger, action, reward/progress, next trigger.
- [x] Data model sketch covers rescue items, actions, caution memory, and recap.
- [x] Screen list covers activation, loop, progress, duplicate caution, and recap.
- [x] Non-goals include barcode, OCR, receipt import, loyalty-card import, cloud/account sync, live family sharing, StoreKit/IAP, payments, public launch/App Store/TestFlight/signing.
- [x] Money posture is `no_monetization_yet`.
- [x] Coverage matrix includes activation, returning loop, local persistence, duplicate caution, weekly recap/progress, and deferred-money boundary.
- [x] Native-proof success/failure gates are explicit.
- [x] Evidence links point to existing local artifacts and IDs.
- [x] No Swift/native app code or app repo was created.
